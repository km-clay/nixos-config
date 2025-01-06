use crate::{interp::token::REGEX, shellenv::ShellEnv};
use nix::unistd::dup2;
use std::{collections::VecDeque, env, fs::{self, metadata}, io, os::{fd::AsRawFd, unix::fs::PermissionsExt}, path::Path};

use super::parse::{NdType, Node};

pub trait VecExtension<T> {
	fn extended(self, vec: Vec<T>) -> Vec<T>;
}

impl<T> VecExtension<T> for Vec<T> {
	fn extended(self, vec: Vec<T>) -> Vec<T> {
		let mut new_vec = self;
		new_vec.extend(vec);
		new_vec
	}
}

pub trait VecDequeExtension<T> {
	fn map_rotate<F>(&mut self, transform: F) where F: FnMut(T);
}

impl<T> VecDequeExtension<T> for VecDeque<T> {
	/// Applies a transformation function to each element of the `VecDeque`
	/// while preserving the original order of elements.
	///
	/// This method "rotates" the `VecDeque` by repeatedly removing the element
	/// at the front, applying the given transformation function to it, and
	/// appending it to the back. The process ensures that all elements are
	/// visited exactly once, and the final order remains unchanged.
	///
	/// # Type Parameters
	/// - `T`: The type of elements in the `VecDeque`.
	/// - `F`: A closure or function that takes a mutable reference to an element
	///   and applies the desired transformation.
	///
	/// # Parameters
	/// - `transform`: A closure or function of type `FnMut(&mut T)` that modifies
	///   each element in place.
	///
	/// # Examples
	///
	/// ```rust
	/// use std::collections::VecDeque;
	///
	/// trait VecDequeExtension<T> {
	///     fn map_rotate<F>(&mut self, transform: F)
	///     where
	///         F: FnMut(&mut T);
	/// }
	///
	/// impl<T> VecDequeExtension<T> for VecDeque<T> {
	///     fn map_rotate<F>(&mut self, mut transform: F)
	///     where
	///         F: FnMut(&mut T),
	///     {
	///         let len = self.len();
	///         for _ in 0..len {
	///             if let Some(mut element) = self.pop_front() {
	///                 transform(&mut element);
	///                 self.push_back(element);
	///             }
	///         }
	///     }
	/// }
	///
	/// let mut deque: VecDeque<String> = VecDeque::from(vec![
	///     String::from("hello"),
	///     String::from("world"),
	///     String::from("rust"),
	/// ]);
	///
	/// // Capitalize all elements
	/// deque.map_rotate(|text| *text = text.to_uppercase());
	///
	/// assert_eq!(deque, VecDeque::from(vec![
	///     String::from("HELLO"),
	///     String::from("WORLD"),
	///     String::from("RUST"),
	/// ]));
	/// ```
	fn map_rotate<F>(&mut self, mut transform: F)
		where F: FnMut(T) {
			let len = self.len();
			for _ in 0..len {
				if let Some(element) = self.pop_front() {
					transform(element);
				}
			}
		}
}

pub trait StrExtension {
	fn split_last(&self, pat: &str) -> Option<(String,String)>;
	fn has_unescaped(&self, pat: &str) -> bool;
	fn consume_escapes(&self) -> String;
}

impl StrExtension for str {
	fn consume_escapes(&self) -> String {
		let mut result = String::new();
		let mut chars = self.chars().peekable();

		while let Some(ch) = chars.next() {
			if ch == '\\' {
				if let Some(&next_ch) = chars.peek() {
					chars.next(); // Consume the escaped character
					result.push(next_ch); // Add the unescaped pattern character
				}
			} else {
				result.push(ch); // Add non-escaped characters as-is
			}
		}

		result
	}

	fn split_last(&self, pat: &str) -> Option<(String, String)> {
		let mut last_index = None;
		let pat_len = pat.len();

		// Iterate through the string and find the last occurrence of `pat`
		for i in 0..=self.len().saturating_sub(pat_len) {
			if &self[i..i + pat_len] == pat {
				last_index = Some(i);
			}
		}

		// If no occurrence is found, return None
		last_index.map(|index| (
				self[..index].to_string(),        // Everything before `pat`
				self[index + pat_len..].to_string(), // Everything after `pat`
		))
	}

	/// Checks to see if a string slice contains a specified unescaped text pattern. This method assumes that '\' is the escape character.
	///
	fn has_unescaped(&self, pat: &str) -> bool {
		let mut chars = self.chars().collect::<VecDeque<char>>();
		let mut working_pat = String::new();
		let mut escaped = false;

		while let Some(ch) = chars.pop_front() {
			if !escaped && working_pat.contains(pat) {
				return true;
			}
			match ch {
				' ' | '\t' => {
					// Check for unescaped match when encountering a space/tab
					// Reset for next segment
					escaped = false;
					working_pat.clear();
				}
				'\\' => {
					escaped = true;
				}
				_ => {
					working_pat.push(ch);
				}
			}
		}

		// Check for unescaped match at the end of the string
		!escaped && working_pat.contains(pat)
	}

}

// This is used when pesky system calls want to emit their own errors
// Which ends up being redundant, since rsh has it's own error reporting system
// Kind of hacky but fuck it
// It works by taking the function as an argument and then executing it in
// an isolated context where stderr is briefly redirected to /dev/null.
pub fn suppress_err<F: FnOnce() -> T, T>(f: F) -> T {
	let stderr = io::stderr();
	let stderr_fd = stderr.as_raw_fd();
	let devnull = fs::OpenOptions::new().write(true).open("/dev/null").unwrap();
	let devnull_fd = devnull.as_raw_fd();

	dup2(devnull_fd, stderr_fd).unwrap();
	let result = f();
	dup2(stderr_fd,stderr_fd).unwrap();
	result
}

pub fn which(shellenv: &ShellEnv, command: &str) -> Option<String> {
	if let Some(env_path) = shellenv.get_variable("PATH") {
		for path in env::split_paths(&env_path) {
			let full_path = path.join(command);
			if full_path.is_file() && is_exec(&full_path) {
				return Some(full_path.to_string_lossy().to_string())
			}
		}
	}
	None
}

pub fn is_exec(path: &Path) -> bool {
	fs::metadata(path)
		.map(|meta| meta.is_file() && (meta.permissions().mode() & 0o111) != 0)
		.unwrap_or(false)
}

pub fn flatten_pipeline(left: Node, right: Node, mut flattened: VecDeque<Node>) -> VecDeque<Node> {
	flattened.push_front(right);
	if let NdType::Pipeline { left, right, both: _ } = left.nd_type {
		flattened = flatten_pipeline(*left, *right, flattened);
	} else {
		flattened.push_front(left);
	}
	flattened
}

pub fn is_brace_expansion(text: &str) -> bool {
	if REGEX["brace_expansion"].is_match(text) &&
		REGEX["brace_expansion"].captures(text).unwrap()[1].is_empty() {
			let mut brace_count: i32 = 0;
			let mut chars = text.chars();
			while let Some(ch) = chars.next() {
				match ch {
					'{' => brace_count += 1,
					'}' => {
						brace_count -= 1;
						if brace_count < 0 {
							// found a closing brace before an open brace
							return false
						}
					},
					'\\' => { chars.next(); },
					_ => { /* Do nothing */ }
				}
			}
			brace_count == 0
		} else {
			false
		}
}

#[cfg(test)]
mod test {
	use super::StrExtension;

	#[test]
	fn split_last_test() {
		let string = "hello there here is a pattern '&&&' and another occurence of it '&&&' and another! '&&&' a lot of patterns today";
		if let Some((left,right)) = string.split_last("&&&") {
			assert_eq!((left,right),("hello there here is a pattern '&&&' and another occurence of it '&&&' and another! '".into(),"' a lot of patterns today".into()))
		} else {
			panic!()
		}
	}
}
