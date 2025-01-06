use chrono::Local;
use glob::glob;
use log::{debug, info, trace};
use std::collections::VecDeque;
use std::mem::take;
use std::path::PathBuf;
use crate::event::ShellError;
use crate::interp::token::{Tk, TkType, WdFlags, WordDesc};
use crate::interp::helper::{self,StrExtension, VecDequeExtension};
use crate::shellenv::{EnvFlags, ShellEnv};

use super::parse::{self, NdType, Node, ParseState};
use super::token::RshTokenizer;

pub fn check_globs(string: String) -> bool {
	string.has_unescaped("?") ||
		string.has_unescaped("*")
}

pub fn expand_arguments(shellenv: &ShellEnv, node: &mut Node) -> Result<Vec<Tk>,ShellError> {
	let argv = node.get_argv()?;
	let mut expand_buffer = Vec::new();
	for arg in &argv {
		let mut expanded = expand_token(shellenv, arg.clone());
		while let Some(token) = expanded.pop_front() {
			if !token.text().is_empty() {
				// Do not return empty tokens
				expand_buffer.push(token);
			}
		}
	}
	match &node.nd_type {
		NdType::Builtin {..} => {
			node.nd_type = NdType::Builtin { argv: expand_buffer.clone().into() };
			Ok(expand_buffer)
		}
		NdType::Command {..}  => {
			node.nd_type = NdType::Command { argv: expand_buffer.clone().into() };
			Ok(expand_buffer)
		}
		NdType::Subshell { body, argv: _ } => {
			node.nd_type = NdType::Subshell { body: body.to_string(), argv: expand_buffer.clone().into() };
			Ok(expand_buffer)
		}
		_ => Err(ShellError::from_internal("Called expand arguments on a non-command node"))
	}
}

pub fn esc_seq(c: char) -> Option<char> {
	//TODO:
	match c {
		'a' => Some('\x07'),
		'n' => Some('\n'),
		't' => Some('\t'),
		'\\' => Some('\\'),
		'"' => Some('"'),
		'\'' => Some('\''),
		_ => panic!()
	}
}

pub fn expand_time(fmt: &str) -> String {
	let right_here_right_now = Local::now();
	right_here_right_now.format(fmt).to_string()
}

pub fn expand_prompt(shellenv: &ShellEnv) -> String {
	// TODO:
	//\j - number of managed jobs
	//\l - shell's terminal device name
	//\v - rsh version
	//\V - rsh release; version + patch level
	//\! - history number of this command
	//\# - command number of this command
	let default_color = if shellenv.env_vars.get("UID").is_some_and(|uid| uid == "0") {
		"31" // Red if uid is 0, aka root user
	} else {
		"32" // Green if anyone else
	};
	let cwd: String = shellenv.env_vars.get("PWD").map_or("", |cwd| cwd).to_string();
	let default_path = if cwd.as_str() == "/" {
		"\\e[36m\\w\\e[0m".to_string()
	} else {
		format!("\\e[1;{}m\\w\\e[1;36m/\\e[0m",default_color)
	};
	let ps1: String = shellenv.env_vars.get("PS1").map_or(format!("\\n{}\\n\\e[{}mdebug \\$\\e[36m>\\e[0m ",default_path,default_color), |ps1| ps1.clone());
	let mut result = String::new();
	let mut chars = ps1.chars().collect::<VecDeque<char>>();
	while let Some(c) = chars.pop_front() {
		match c {
			'\\' => {
				if let Some(esc_c) = chars.pop_front() {
					match esc_c {
						'a' => result.push('\x07'),
						'n' => result.push('\n'),
						'r' => result.push('\r'),
						'\\' => result.push('\\'),
						'\'' => result.push('\''),
						'"' => result.push('"'),
						'd' => result.push_str(expand_time("%a %b %d").as_str()),
						't' => result.push_str(expand_time("%H:%M:%S").as_str()),
						'T' => result.push_str(expand_time("%I:%M:%S").as_str()),
						'A' => result.push_str(expand_time("%H:%M").as_str()),
						'@' => result.push_str(expand_time("%I:%M %p").as_str()),
						_ if esc_c.is_digit(8) => {
							let mut octal_digits = String::new();
							octal_digits.push(esc_c); // Add the first digit

							for _ in 0..2 {
								if let Some(next_c) = chars.front() {
									if next_c.is_digit(8) {
										octal_digits.push(chars.pop_front().unwrap());
									} else {
										break;
									}
								}
							}

							if let Ok(value) = u8::from_str_radix(&octal_digits, 8) {
								result.push(value as char);
							} else {
								// Invalid sequence, treat as literal
								result.push_str(&format!("\\{}", octal_digits));
							}
						}
						'e' => {
							result.push('\x1B');
							if chars.front().is_some_and(|&ch| ch == '[') {
								result.push(chars.pop_front().unwrap()); // Consume '['
								while let Some(ch) = chars.pop_front() {
									result.push(ch);
									if ch == 'm' {
										break; // End of ANSI sequence
									}
								}
							}
						}
						'[' => {
							// Handle \[ (start of non-printing sequence)
							while let Some(ch) = chars.pop_front() {
								if ch == ']' {
									break; // Stop at the closing \]
								}
								result.push(ch); // Add non-printing content
							}
						}
						']' => {
							// Handle \] (end of non-printing sequence)
							// Do nothing, it's just a marker
						}
						'w' => {
							let mut cwd = shellenv.env_vars.get("PWD").map_or(String::new(), |pwd| pwd.to_string());
							let home = shellenv.env_vars.get("HOME").map_or("", |home| home);
							if cwd.starts_with(home) {
								cwd = cwd.replacen(home, "~", 1); // Use `replacen` to replace only the first occurrence
							}
							// TODO: unwrap is probably safe here since this option is initialized with the environment but it might still cause issues later if this is left unhandled
							let trunc_len = shellenv.shopts.get("trunc_prompt_path").unwrap_or(&0);
							if *trunc_len > 0 {
								let mut path = PathBuf::from(cwd);
								let mut cwd_components: Vec<_> = path.components().collect();
								if cwd_components.len() > *trunc_len {
									cwd_components = cwd_components.split_off(cwd_components.len() - *trunc_len);
									path = cwd_components.iter().collect(); // Rebuild the PathBuf
								}
								cwd = path.to_string_lossy().to_string();
							}
							result.push_str(&cwd);
						}
						'W' => {
							let cwd = PathBuf::from(shellenv.env_vars.get("PWD").map_or("", |pwd| pwd));
							let mut cwd = cwd.components().last().map(|comp| comp.as_os_str().to_string_lossy().to_string()).unwrap_or_default();
							let home = shellenv.env_vars.get("HOME").map_or("", |home| home);
							if cwd.starts_with(home) {
								cwd = cwd.replacen(home, "~", 1); // Replace HOME with '~'
							}
							result.push_str(&cwd);
						}
						'H' => {
							let hostname = shellenv.env_vars.get("HOSTNAME").map_or("unknown host", |host| host);
							result.push_str(hostname);
						}
						'h' => {
							let hostname = shellenv.env_vars.get("HOSTNAME").map_or("unknown host", |host| host);
							if let Some((hostname, _)) = hostname.split_once('.') {
								result.push_str(hostname);
							} else {
								result.push_str(hostname); // No '.' found, use the full hostname
							}
						}
						's' => {
							let sh_name = shellenv.env_vars.get("SHELL").map_or("rsh", |sh| sh);
							result.push_str(sh_name);
						}
						'u' => {
							let user = shellenv.env_vars.get("USER").map_or("unknown", |user| user);
							result.push_str(user);
						}
						'$' => {
							let uid = shellenv.env_vars.get("UID").map_or("0", |uid| uid);
							match uid {
								"0" => result.push('#'),
								_ => result.push('$'),
							}
						}
						_ => {
							result.push('\\');
							result.push(esc_c);
						}
					}
				} else {
					result.push('\\');
				}
			}
			_ => result.push(c)
		}
	}
	result
}

pub fn process_ansi_escapes(input: &str) -> String {
	let mut result = String::new();
	let mut chars = input.chars().collect::<VecDeque<char>>();

	while let Some(c) = chars.pop_front() {
		if c == '\\' {
			if let Some(next) = chars.pop_front() {
				match next {
					'a' => result.push('\x07'), // Bell
					'b' => result.push('\x08'), // Backspace
					't' => result.push('\t'),   // Tab
					'n' => result.push('\n'),   // Newline
					'r' => result.push('\r'),   // Carriage return
					'e' | 'E' => result.push('\x1B'), // Escape (\033 in octal)
					'0' => {
						// Octal escape: \0 followed by up to 3 octal digits
						let mut octal_digits = String::new();
						while octal_digits.len() < 3 && chars.front().is_some_and(|ch| ch.is_digit(8)) {
							octal_digits.push(chars.pop_front().unwrap());
						}
						if let Ok(value) = u8::from_str_radix(&octal_digits, 8) {
							let character = value as char;
							result.push(character);
							// Check for ANSI sequence if the result is ESC (\033 or \x1B)
							if character == '\x1B' && chars.front().is_some_and(|&ch| ch == '[') {
								result.push(chars.pop_front().unwrap()); // Consume '['
								while let Some(ch) = chars.pop_front() {
									result.push(ch);
									if ch == 'm' {
										break; // Stop at the end of the ANSI sequence
									}
								}
							}
						}
					}
					_ => {
						// Unknown escape, treat literally
						result.push('\\');
						result.push(next);
					}
				}
			} else {
				// Trailing backslash, treat literally
				result.push('\\');
			}
		} else if c == '\x1B' {
			// Handle raw ESC characters (e.g., \033 in octal or actual ESC char)
			result.push(c);
			if chars.front().is_some_and(|&ch| ch == '[') {
				result.push(chars.pop_front().unwrap()); // Consume '['
				while let Some(ch) = chars.pop_front() {
					result.push(ch);
					if ch == 'm' {
						break; // Stop at the end of the ANSI sequence
					}
				}
			}
		} else {
			result.push(c);
		}
	}

	result
}

pub fn expand_alias(shellenv: &ShellEnv, mut node: Node) -> Result<Node, ShellError> {
	match node.nd_type {
		NdType::Command { ref mut argv } | NdType::Builtin { ref mut argv } => {
			if let Some(cmd_tk) = argv.pop_front() {
				if let Some(alias_content) = shellenv.get_alias(cmd_tk.text()) {
					let new_argv = take(argv);
					let mut child_shellenv = shellenv.clone();
					child_shellenv.mod_flags(|f| *f |= EnvFlags::NO_ALIAS);
					let mut state = ParseState {
						input: alias_content,
						shellenv: &child_shellenv,
						tokens: VecDeque::new(),
						ast: Node::new(),
					};

					let mut tokenizer = RshTokenizer::new(alias_content);
					tokenizer.tokenize();
					state.tokens = tokenizer.tokens.into();
					let mut alias_tokens = state.tokens;
					// Trim `SOI` and `EOI` tokens
					alias_tokens.pop_back();
					alias_tokens.pop_front();
					alias_tokens.extend(new_argv);

					// Guard against recursive aliasing
					// i.e. "alias grep="grep --color-auto"
					if alias_tokens.front().is_some_and(|tk| tk.text() == cmd_tk.text()) {
						for token in &mut alias_tokens {
							if token.text() == cmd_tk.text() {
								token.wd.flags |= WdFlags::FROM_ALIAS
							}
						}
					}

					state.tokens = alias_tokens;
					state = parse::parse(state)?;
					for redir in node.redirs {
						state.ast.redirs.push_back(redir.clone())
					}
					Ok(state.ast)
				} else {
					argv.push_front(cmd_tk);
					Ok(node)
				}
			} else {
				Ok(node)
			}
		}
		_ => unreachable!()
	}
}

pub fn expand_token(shellenv: &ShellEnv, token: Tk) -> VecDeque<Tk> {
	trace!("expand(): Starting expansion with token: {:?}", token);
	let mut working_buffer: VecDeque<Tk> = VecDeque::new();
	let mut product_buffer: VecDeque<Tk> = VecDeque::new();

	//TODO: find some way to clean up this surprisingly functional mess
	// Escaping breaks this right now I think

	working_buffer.push_back(token.clone());
	while let Some(mut token) = working_buffer.pop_front() {
		let is_glob = check_globs(token.text().into());
		let is_brace_expansion = helper::is_brace_expansion(token.text());

		let expand_home = token.text().has_unescaped("~");
		if expand_home {
			// If this unwrap fails, god help you
			let home = shellenv.get_variable("HOME").unwrap();
			token.wd.text = token.wd.text.replace("~",&home);
		}

		if !is_glob && !is_brace_expansion {
			debug!("expanding var for {}",token.text());
			if token.text().has_unescaped("$") && !token.wd.flags.intersects(WdFlags::FROM_VAR | WdFlags::SNG_QUOTED) {
				info!("found unescaped dollar in: {}",token.text());
				if token.text().has_unescaped("$@") {
					let mut param_tokens = expand_params(shellenv,token);
					while let Some(param) = param_tokens.pop_back() {
						working_buffer.push_front(param);
					}
					continue
				}
				token.wd.text = expand_var(shellenv, token.text().into());
			}
			if helper::is_brace_expansion(token.text()) || token.text().has_unescaped("$") {
				working_buffer.push_front(token);
			} else {
				let expand_home = token.text().has_unescaped("~");
				if expand_home {
					// If this unwrap fails, god help you
					let home = shellenv.get_variable("HOME").unwrap();
					token.wd.text = token.wd.text.replace("~",&home);
				}
				product_buffer.push_back(token)
			}

		} else if is_brace_expansion && token.text().has_unescaped("{") && token.tk_type != TkType::String {
			// Perform brace expansion
			let expanded = expand_braces(token.text().to_string(), VecDeque::new());
			for mut expanded_token in expanded {
				expanded_token = expand_var(shellenv, expanded_token);
				working_buffer.push_back(
					Tk {
						tk_type: TkType::Expanded,
						wd: WordDesc {
							text: expanded_token,
							span: token.span(),
							flags: token.flags()
						}
					}
				);
			};
		} else if is_glob {
			// Expand glob patterns
			for path in glob(token.text()).unwrap().flatten() {
				working_buffer.push_back(
					Tk {
						tk_type: TkType::Expanded,
						wd: WordDesc {
							text: path.to_str().unwrap().to_string(),
							span: token.span(),
							flags: token.flags()
						}
					}
				);
			}
		} else if shellenv.get_alias(token.text()).is_some() {
			let alias_content = shellenv.get_alias(token.text()).unwrap().split(' ');
			for word in alias_content {
				working_buffer.push_back(
					Tk {
						tk_type: TkType::Expanded,
						wd: WordDesc {
							text: word.into(),
							span: token.span(),
							flags: token.flags()
						}
					}
				);
			}
		} else {
			let expand_home = token.text().has_unescaped("~");
			if expand_home {
				// If this unwrap fails, god help you
				let home = shellenv.get_variable("HOME").unwrap();
				token.wd.text = token.wd.text.replace("~",&home);
			}
			product_buffer.push_back(token);
		}
	}

	let mut temp_buffer = VecDeque::new();
	product_buffer.map_rotate(|mut elem| {
		elem.wd.text = elem.wd.text.consume_escapes();
		temp_buffer.push_back(elem);
	});
	product_buffer.extend(temp_buffer.drain(..));
	product_buffer
}

pub fn clean_escape_chars(token_buffer: &mut VecDeque<Tk>) {
	for token in token_buffer {
		let mut text = std::mem::take(&mut token.wd.text);
		text = text.replace('\\',"");
		token.wd.text = text;
	}
}

pub fn expand_braces(word: String, mut results: VecDeque<String>) -> VecDeque<String> {
	if let Some((preamble, rest)) = word.split_once("{") {
		if let Some((amble, postamble)) = rest.split_last("}") {
			// the current logic makes adjacent expansions look like this: `left}{right`
			// let's take advantage of that, shall we
			if let Some((left,right)) = amble.split_once("}{") {
				// Reconstruct the left side into a new brace expansion: left -> {left}
				let left = format!("{}{}{}","{",left,"}");
				// Same with the right side: right -> {right}
				// This also has the side effect of rebuilding any subsequent adjacent expansions
				// e.g. "right1}{right2}{right3" -> {right1}{right2}{right3}
				let right = format!("{}{}{}","{",right,"}");
				// Recurse
				let left_expanded = expand_braces(left.to_string(), VecDeque::new());
				let right_expanded = expand_braces(right.to_string(), VecDeque::new());
				// Combine them
				for left_part in left_expanded {
					for right_part in &right_expanded {
						results.push_back(format!("{}{}",left_part,right_part));
					}
				}
			} else {
				let mut expanded = expand_amble(amble);
				while let Some(string) = expanded.pop_front() {
					let expanded_word = format!("{}{}{}", preamble, string, postamble);
					results = expand_braces(expanded_word, results); // Recurse for nested braces
				}
			}
		} else {
			// Malformed brace: No closing `}` found
			results.push_back(word);
	}
} else {
	// Base case: No more braces to expand
	results.push_back(word);
}
results
}

pub fn expand_amble(amble: String) -> VecDeque<String> {
	let mut result = VecDeque::new();
	if amble.contains("..") && amble.len() >= 4 {
		let num_range = amble.chars().next().is_some_and(|ch| ch.is_ascii_digit())
				&& amble.chars().last().is_some_and(|ch| ch.is_ascii_digit());

		let lower_alpha_range = amble.chars().next().is_some_and(|ch| ch.is_ascii_lowercase())
				&& amble.chars().last().is_some_and(|ch| ch.is_ascii_lowercase())
				&& amble.chars().next() <= amble.chars().last(); // Ensure valid range

		let upper_alpha_range = amble.chars().next().is_some_and(|ch| ch.is_ascii_uppercase())
				&& amble.chars().last().is_some_and(|ch| ch.is_ascii_uppercase())
				&& amble.chars().next() <= amble.chars().last(); // Ensure valid range

		if lower_alpha_range || upper_alpha_range {
			let left = amble.chars().next().unwrap();
			let right = amble.chars().last().unwrap();
			for i in left..=right {
				result.push_back(i.to_string());
			}
		}
		if num_range {
			let (left,right) = amble.split_once("..").unwrap();
			for i in left.parse::<i32>().unwrap()..=right.parse::<i32>().unwrap() {
				result.push_back(i.to_string());
			}
		}
	} else {
		let mut cur_string = String::new();
		let mut chars = amble.chars();
		let mut brace_stack = vec![];
		while let Some(ch) = chars.next() {
			match ch {
				'{' => {
					cur_string.push(ch);
					brace_stack.push(ch);
				}
				'}' => {
					cur_string.push(ch);
					brace_stack.pop();
				}
				',' => {
					if brace_stack.is_empty() {
						result.push_back(cur_string);
						cur_string = String::new();
					} else {
						cur_string.push(ch)
					}
				}
				'\\' => {
					let next = chars.next();
					if !matches!(next, Some('}') | Some('{')) {
						cur_string.push(ch)
					}
					if let Some(next) = next {
						cur_string.push(next)
					}
				}
				_ => cur_string.push(ch)
			}
		}
		result.push_back(cur_string);
	}
	result
}

pub fn expand_var(shellenv: &ShellEnv, string: String) -> String {
	let mut left = String::new();
	let mut right = String::new();
	let mut chars = string.chars().collect::<VecDeque<char>>();
	while let Some(ch) = chars.pop_front() {
		match ch {
			'\\' => {
				left.push(ch);
				left.push(if let Some(ch) = chars.pop_front() { ch } else { break })
			}
			'$' => {
				right.extend(chars.drain(..));
				break
			},
			_ => left.push(ch)
		}
	}
	if right.is_empty() {
		return string.to_string()
	}
	let mut right_chars = right.chars().collect::<VecDeque<char>>();
	let mut var_name = String::new();
	while let Some(ch) = right_chars.pop_front() {
		match ch {
			_ if ch.is_alphanumeric() => {
				var_name.push(ch);
			}
			'_' => {
				var_name.push(ch);
			}
			'-' | '*' | '?' | '$' | '#' => {
				var_name.push(ch);
				break
			}
			'{' => continue,
			'}' => break,
			_ => {
				right_chars.push_front(ch);
				break
			}
		}
	}
	let right = right_chars.iter().collect::<String>();

	let value = shellenv.get_variable(&var_name).unwrap_or_default();
	let expanded = format!("{}{}{}",left,value,right);
	if expanded.has_unescaped("$") {
		expand_var(shellenv,expanded)
	} else {
		expanded
	}
}

fn expand_params(shellenv: &ShellEnv, token: Tk) -> VecDeque<Tk> {
	let mut expanded_tokens = VecDeque::new();
	// Get the positional parameter string from shellenv and split it
	let arg_string = shellenv.get_variable("@").unwrap_or_default();
	let arg_split = arg_string.split(' ');

	// Split the token's text at the first instance of '$@' and make two new tokens
	// Subsequent instances will be handled in later iterations of expand()
	let (left,right) = token.text().split_once("$@").unwrap();
	let left_token = Tk::new(left.to_string(), token.span(), token.flags());
	let right_token = Tk::new(right.to_string(), token.span(), token.flags());

	// Push the left token into the deque
	if !left_token.text().is_empty() {
		expanded_tokens.push_back(left_token);
	}
	for arg in arg_split {
		// For each arg, make a new token and push it into the deque
		let new_token = Tk::new(arg.to_string(),token.span(), token.flags() | WdFlags::FROM_VAR);
		expanded_tokens.push_back(new_token);
	}
	// Now push the right token into the deque
	if !right_token.text().is_empty() {
		expanded_tokens.push_back(right_token);
	}
	expanded_tokens
}
