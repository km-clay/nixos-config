use crate::comp::RshHelper;
use crate::event::Signals;
use std::path::{Path, PathBuf};

use tokio::sync::mpsc;
use log::info;
use rustyline::{self, config::Configurer, error::ReadlineError, history::{DefaultHistory, History}, ColorMode, Config, EditMode, Editor};

use crate::{event::ShellEvent, shellenv::ShellEnv};
use crate::interp::parse::{descend, NdType};
use crate::interp::expand;



fn init_prompt(shellenv: &ShellEnv) -> Editor<RshHelper, DefaultHistory> {
	let mut config = Config::builder();

	// Read options from ShellEnv
	let max_size = shellenv.get_shopt("max_hist").max(1000); // Default to 1000
	let hist_dupes = shellenv.get_shopt("hist_ignore_dupes") != 0;
	let comp_limit = shellenv.get_shopt("comp_limit").max(5); // Default to 5
	let edit_mode = match shellenv.get_shopt("edit_mode") {
		0 => EditMode::Emacs,
		_ => EditMode::Vi,
	};
	let auto_hist = shellenv.get_shopt("auto_hist") != 0;
	let prompt_highlight = match shellenv.get_shopt("prompt_highlight") {
		0 => ColorMode::Disabled,
		_ => ColorMode::Enabled,
	};
	let tab_stop = shellenv.get_shopt("tab_stop").max(1); // Default to at least 1

	// Build configuration
	config = config
		.max_history_size(max_size)
		.unwrap_or_else(|e| {
			eprintln!("Invalid max history size: {}", e);
			std::process::exit(1);
		})
	.history_ignore_dups(hist_dupes)
		.unwrap()
		.completion_prompt_limit(comp_limit)
		.edit_mode(edit_mode)
		.auto_add_history(auto_hist)
		.color_mode(prompt_highlight)
		.tab_stop(tab_stop);

		let config = config.build();

		// Initialize editor
		let mut rl = Editor::with_config(config).unwrap_or_else(|e| {
			eprintln!("Failed to initialize Rustyline editor: {}", e);
			std::process::exit(1);
		});
		rl.set_completion_type(rustyline::CompletionType::List);
		rl.set_helper(Some(RshHelper::new(shellenv)));

		// Load history file
		let hist_path = expand::expand_var(shellenv, "$HIST_FILE".into());
		info!("history path in init_prompt(): {}",hist_path);
		let hist_path = PathBuf::from(hist_path);
		if let Err(e) = rl.load_history(&hist_path) {
			eprintln!("No previous history found or failed to load history: {}", e);
		}

		rl
}

pub async fn prompt(sender: mpsc::Sender<ShellEvent>, shellenv: &mut ShellEnv) {
	let mut rl = init_prompt(shellenv);
	let hist_path = expand::expand_var(shellenv, "$HIST_FILE".into());
	let prompt = expand::expand_prompt(shellenv);
	match rl.readline(&prompt) {
		Ok(line) => {
			let _ = rl.history_mut().add(&line);
			let _ = rl.history_mut().save(Path::new(&hist_path));
			shellenv.set_last_input(&line);
			let state = descend(&line,shellenv);
			match state {
				Ok(parse_state) => {
					if let NdType::Root { deck } = &parse_state.ast.nd_type {
						if !deck.is_empty() {
							let _ = sender.send(ShellEvent::NewAST(parse_state.ast)).await;
						}
					}
				}
				Err(e) => {
					let _ = sender.send(ShellEvent::CatchError(e)).await;
				}
			}
		}
		Err(ReadlineError::Interrupted) => {
			let _ = sender.send(ShellEvent::Signal(Signals::SIGINT)).await;
		}
		Err(ReadlineError::Eof) => {
			let _ = sender.send(ShellEvent::Signal(Signals::SIGQUIT)).await;
		}
		Err(e) => {
			eprintln!("{:?}",e);
		}
	}
	let _ = sender.send(ShellEvent::Prompt).await;
}
