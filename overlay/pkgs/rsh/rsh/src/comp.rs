use crossterm::{
	cursor::{MoveTo, RestorePosition, Show}, execute, style::Print, terminal::{disable_raw_mode, enable_raw_mode, size, Clear, ClearType, EnterAlternateScreen, LeaveAlternateScreen}
};
use log::info;
use rustyline::{completion::{Candidate, Completer, FilenameCompleter}, error::ReadlineError, history::{FileHistory, History}, Context, Helper, Highlighter, Hinter, Validator};
use skim::{prelude::{SkimItemReader, SkimOptionsBuilder}, Skim};
use std::{collections::HashSet, env, io::stdout, path::PathBuf};

use crate::{interp::expand, shellenv::ShellEnv};

#[derive(Hinter,Highlighter,Validator,Helper)]
pub struct RshHelper<'a> {
	filename_comp: FilenameCompleter,
	commands: Vec<String>, // List of built-in or cached commands
	shellenv: &'a ShellEnv
}

impl<'a> RshHelper<'a> {
	pub fn new(shellenv: &'a ShellEnv) -> Self {
		// Prepopulate some built-in commands (could also load dynamically)
		let commands = vec![
			"cd".to_string(),
			"ls".to_string(),
			"echo".to_string(),
			"exit".to_string(),
		];

		let mut helper = RshHelper {
			filename_comp: FilenameCompleter::new(),
			commands,
			shellenv
		};
		helper.update_commands_from_path();
		helper
	}

	// Dynamically add commands (if needed, e.g., external binaries in $PATH)
	fn update_commands_from_path(&mut self) {
		if let Some(paths) = env::var_os("PATH") {
			let mut external_commands = HashSet::new();
			for path in env::split_paths(&paths) {
				if let Ok(entries) = std::fs::read_dir(path) {
					for entry in entries.flatten() {
						if let Ok(file_name) = entry.file_name().into_string() {
							external_commands.insert(file_name);
						}
					}
				}
			}
			self.commands.extend(external_commands);
		}
	}
}

impl<'a> Completer for RshHelper<'a> {
	type Candidate = String;

	fn complete(
			&self,
			line: &str,
			pos: usize,
			_: &Context<'_>,
	) -> Result<(usize, Vec<Self::Candidate>), ReadlineError> {
			let mut completions = Vec::new();
			let num_words = line.split_whitespace().count();

			// Determine if this is a file path or a command completion
			if !line.is_empty() && num_words > 1 {
					let hist_path = expand::expand_var(self.shellenv, "$HIST_FILE".into());
					info!("history path in init_prompt(): {}", hist_path);
					let hist_path = PathBuf::from(hist_path);

					// Delegate to FilenameCompleter for file path completion
					let mut history = FileHistory::new();
					history.load(&hist_path).unwrap();
					let (start, matches) = self.filename_comp.complete(line, pos, &Context::new(&history))?;
					completions.extend(matches.iter().map(|c| c.display().to_string()));

					// Invoke fuzzyfinder if there are matches
					if !completions.is_empty() && completions.len() > 1 {
							if let Some(selected) = skim_comp(completions.clone()) {
									return Ok((start, vec![selected]));
							}
					}

					return Ok((start, completions));
			}

			// Command completion
			let prefix = &line[..pos]; // The part of the line to match
			completions.extend(
					self.commands
							.iter()
							.filter(|cmd| cmd.starts_with(prefix)) // Match prefix
							.cloned(), // Clone matched command names
			);

			// Invoke fuzzyfinder if there are matches
			if completions.len() > 1 {
					if let Some(selected) = skim_comp(completions.clone()) {
							return Ok((0, vec![selected]));
					}
			}

			// Return completions, starting from the beginning of the word
			Ok((0, completions))
	}
}

pub fn skim_comp(options: Vec<String>) -> Option<String> {
    let mut stdout = stdout();

    // Enter the alternate screen
    execute!(stdout, EnterAlternateScreen).unwrap();
    enable_raw_mode().unwrap();

    // Get terminal dimensions
    let (cols, rows) = size().unwrap();
    let width = cols.min(50); // Set floating window width
    let height = rows.min(10); // Set floating window height
    let start_col = 0;
    let start_row = (rows - height) / 2;

    // Draw the floating window border
    execute!(
        stdout,
        MoveTo(start_col, start_row),
        Print("┌".to_string() + &"─".repeat(width as usize - 2) + "┐")
    )
    .unwrap();

    for i in 1..height - 1 {
        execute!(
            stdout,
            MoveTo(start_col, start_row + i),
            Print("│".to_string() + &" ".repeat(width as usize - 2) + "│")
        )
        .unwrap();
    }

    execute!(
        stdout,
        MoveTo(start_col, start_row + height - 1),
        Print("└".to_string() + &"─".repeat(width as usize - 2) + "┘")
    )
    .unwrap();

    // Prepare options for skim
    let options_join = options.join("\n");
    let input = SkimItemReader::default().of_bufread(std::io::Cursor::new(options_join));

    let skim_options = SkimOptionsBuilder::default()
        .prompt("Select > ".to_string())
        .height("25%".to_string()) // Height in lines relative to floating window
        .multi(false)
        .build()
        .unwrap();

    // Run skim within the alternate screen
    let selected = Skim::run_with(&skim_options, Some(input))
        .and_then(|out| out.selected_items.first().cloned())
        .map(|item| item.output().to_string());

    // Leave the alternate screen and restore original content
    execute!(stdout, Clear(ClearType::All), RestorePosition, LeaveAlternateScreen, Show).unwrap();
    disable_raw_mode().unwrap();

    selected
}
