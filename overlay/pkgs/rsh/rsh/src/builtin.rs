use std::collections::VecDeque;
use std::ffi::{CString, OsStr};
use std::fs;
use std::os::fd::AsRawFd;
use std::os::unix::ffi::OsStrExt;
use std::os::unix::fs::{FileTypeExt, MetadataExt};
use std::path::{Path, PathBuf};
use bitflags::bitflags;
use libc::{getegid, geteuid};
use log::info;
use nix::fcntl::OFlag;
use nix::sys::stat::Mode;
use nix::sys::wait::{waitpid, WaitStatus};
use nix::unistd::{access, fork, isatty, setpgid, AccessFlags, ForkResult};

use crate::execute::{ProcIO, RshWaitStatus, RustFd};
use crate::interp::parse::{NdFlags, NdType, Node, Span};
use crate::interp::{expand, token};
use crate::interp::token::{Redir, RedirType, Tk, TkType};
use crate::shellenv::{EnvFlags, JobFlags, ShellEnv};
use crate::event::ShellError;

pub const BUILTINS: [&str; 14] = [
	"echo", "set", "shift", "export", "cd", "readonly", "declare", "local", "unset", "trap", "node",
	"exec", "source", "wait",
];

bitflags! {
	#[derive(Debug)]
	pub struct EchoFlags: u8 {
		const USE_ESCAPE = 0b0001;
		const NO_NEWLINE = 0b0010;
		const NO_ESCAPE = 0b0100;
		const STDERR = 0b1000;
	}
}

fn open_file_descriptors(redirs: VecDeque<Node>) -> Result<Vec<RustFd>, ShellError> {
	let mut fd_stack: Vec<RustFd> = Vec::new();
	let mut fd_dupes: Vec<(i32,i32)> = Vec::new();
	info!("Handling redirections for builtin: {:?}", redirs);

	for redir_tk in redirs {
		if let NdType::Redirection { ref redir } = redir_tk.nd_type {
			let Redir { fd_source, op, fd_target, file_target } = redir;

			if let Some(target) = fd_target {
				fd_dupes.push((*target,*fd_source));
			} else if let Some(file_path) = file_target {
				let source_fd = RustFd::new(*fd_source)?;
				let flags = match op {
					RedirType::Input => OFlag::O_RDONLY,
					RedirType::Output => OFlag::O_WRONLY | OFlag::O_CREAT | OFlag::O_TRUNC,
					RedirType::Append => OFlag::O_WRONLY | OFlag::O_CREAT | OFlag::O_APPEND,
					_ => unimplemented!("Heredocs and herestrings are not implemented yet."),
				};
				let mut file_fd = RustFd::open(Path::new(file_path.text()), flags, Mode::from_bits(0o644).unwrap())?;
				file_fd.dup2(&source_fd)?;
				file_fd.close()?;
				fd_stack.push(source_fd);
			}
		}
	}

	while let Some((target,source)) = fd_dupes.pop() {
		let mut target_fd = RustFd::new(target)?;
		let source_fd = RustFd::new(source)?;
		target_fd.dup2(&source_fd)?;
		target_fd.close()?;

		fd_stack.push(source_fd);
	}

	Ok(fd_stack)
}

pub fn catstr(mut c_strings: VecDeque<CString>,newline: bool) -> CString {
	let mut cat: Vec<u8> = vec![];
	let newline_bytes = b"\n\0";
	let space_bytes = b" ";

	while let Some(c_string) = c_strings.pop_front() {
		let bytes = c_string.to_bytes_with_nul();
		if c_strings.is_empty() {
			// Last string: include the null terminator
			cat.extend_from_slice(&bytes[..bytes.len() - 1]);
		} else {
			// Intermediate strings: exclude the null terminator and add whitespace
			cat.extend_from_slice(&bytes[..bytes.len() - 1]);
			cat.extend_from_slice(space_bytes);
		}
	}
	if newline {
		cat.extend_from_slice(newline_bytes);
	} else {
		cat.extend_from_slice(b"\0");
	}

	CString::from_vec_with_nul(cat).unwrap()
}

/// Performs a test on a single argument by transforming it and then applying a property check.
///
/// This function takes a mutable reference to a `VecDeque` of `String` arguments, a transformation function,
/// and a property function. It pops the front element from the `VecDeque`, applies the transformation
/// function to it, and then checks the transformed value against the property function.
///
/// # Arguments
///
/// * `args` - A mutable reference to a `VecDeque` of `String` arguments.
/// * `transform` - A function that takes a `String` and returns a `Result<T, ShellError>`.
/// * `property` - A function that takes a reference to `T` and returns a `bool`.
///
/// # Returns
///
/// * `Ok(bool)` - If the transformation and property check are successful, returns the result of the property check.
/// * `Err(ShellError)` - If the `VecDeque` is empty or the transformation fails, returns an appropriate `ShellError`.
///
/// # Example
///
/// ```
/// let mut args = VecDeque::new();
/// args.push_back("42".to_string());
/// let transform = |s: String| -> Result<i32, ShellError> { Ok(s.parse::<i32>().unwrap()) };
/// let property = |x: &i32| -> bool { *x > 0 };
/// let result = do_test(&mut args, transform, property);
/// assert!(result.unwrap());
/// ```
fn do_test<T, F1, F2>(
	args: &mut VecDeque<Tk>,
	transform: F1,
	property: F2,
	span: Span
) -> Result<bool, ShellError>
where
		F1: FnOnce(Tk) -> Result<T, ShellError>,
		F2: FnOnce(&T) -> bool
{
	if let Some(st) = args.pop_front() {
		let transformed = transform(st).map_err(|_| false);
		if transformed.is_err() {
			return Ok(false)
		}
		Ok(property(&transformed.unwrap()))
	} else {
		Err(ShellError::from_syntax("Did not find a comparison target for integer in test", span))
	}
}

/// Compares two arguments by transforming them and then applying a comparison function.
///
/// This function takes a `String` argument, a mutable reference to a `VecDeque` of `String` arguments,
/// a transformation function, and a comparison function. It pops the front element from the `VecDeque`,
/// applies the transformation function to both the provided `String` and the popped element, and then
/// compares the transformed values using the comparison function.
///
/// # Arguments
///
/// * `arg1` - The first `String` argument to be transformed and compared.
/// * `args` - A mutable reference to a `VecDeque` of `String` arguments.
/// * `transform` - A function that takes a `String` and returns a `Result<T, ShellError>`.
/// * `comparison` - A function that takes two references to `T` and returns a `bool`.
///
/// # Returns
///
/// * `Ok(bool)` - If the transformation and comparison are successful, returns the result of the comparison.
/// * `Err(ShellError)` - If the `VecDeque` is empty or the transformation fails, returns an appropriate `ShellError`.
///
/// # Example
///
/// ```
/// let mut args = VecDeque::new();
/// args.push_back("42".to_string());
/// let transform = |s: String| -> Result<i32, ShellError> { Ok(s.parse::<i32>().unwrap()) };
/// let comparison = |x: &i32, y: &i32| -> bool { x == y };
/// let result = do_cmp("42".to_string(), &mut args, transform, comparison);
/// assert!(result.unwrap());
/// ```
fn do_cmp<T, F1, F2>(
	arg1: Tk,
	args: &mut VecDeque<Tk>,
	transform: F1,
	comparison: F2
) -> Result<bool, ShellError>
where
		F1: Fn(Tk) -> Result<T, ShellError>,
		F2: FnOnce(&T, &T) -> bool
{
	if let Some(st) = args.pop_front() {
		let left = transform(arg1).map_err(|_| false);
		let right = transform(st).map_err(|_| false);
		if left.is_err() || right.is_err() {
			return Ok(false)
		}
		Ok(comparison(&left.unwrap(), &right.unwrap()))
	} else {
		Err(ShellError::from_syntax("Did not find a comparison target for integer in test", arg1.span()))
	}
}

/// Performs a logical operation (AND or OR) on two boolean results.
///
/// This function takes a mutable reference to a `VecDeque` of `String` arguments, the command (`test` or `[`),
/// the first result of a test, and the logical operator (`-a` for AND, `-o` for OR). It recursively calls the `test`
/// function to evaluate the next condition and combines the results using the specified logical operator.
///
/// # Arguments
///
/// * `args` - A mutable reference to a `VecDeque` of `String` arguments.
/// * `command` - The command (`test` or `[`).
/// * `result1` - The result of the first test.
/// * `operator` - The logical operator (`-a` for AND, `-o` for OR).
///
/// # Returns
///
/// * `Result<bool, ShellError>` - Returns the combined result of the logical operation.
///
/// # Errors
///
/// * Returns `ShellError::from_syntax` if there is a syntax error or missing arguments.
fn do_logical_op(
	args: &mut VecDeque<Tk>,
	command: Tk,
	result1: bool,
	operator: Tk
) -> Result<bool, ShellError> {
	args.push_front(command);
	let result2 = test(std::mem::take(args)).map(|res| matches!(res,RshWaitStatus::Success {..}))?;
	match operator.text() {
		"!" => { Ok(!result2) },
		"-a" => { Ok(result1 && result2) },
		"-o" => { Ok(result1 || result2) },
		_ => Err(ShellError::from_syntax("Expected a logical operator (-a or -o)", operator.span())),
	}
}

/// Implements the `test` builtin command for a Unix shell.
///
/// The `test` command evaluates conditional expressions and returns a success or failure status based on the evaluation.
/// This function handles various types of tests, including file attributes, string comparisons, and integer comparisons.
///
/// # Arguments
///
/// * `argv` - A vector of `CString` arguments passed to the `test` command.
///
/// # Returns
///
/// * `Ok(RshWaitStatus)` - Returns a success or failure status based on the evaluation of the conditional expression.
/// * `Err(ShellError)` - Returns an appropriate `ShellError` if there is a syntax error or other issues with the arguments.
///
/// # Examples
///
/// ```
/// let argv = vec![CString::new("test").unwrap(), CString::new("-f").unwrap(), CString::new("file.txt").unwrap()];
/// let result = test(argv);
/// assert!(result.is_ok());
/// ```
///
/// ```
/// let argv = vec![CString::new("[").unwrap(), CString::new("1").unwrap(), CString::new("-eq").unwrap(), CString::new("1").unwrap(), CString::new("]").unwrap()];
/// let result = test(argv);
/// assert!(result.is_ok());
/// ```
///
/// # Supported Tests
///
/// ## File Tests
///
/// - `-b`: Block device
/// - `-c`: Character device
/// - `-d`: Directory
/// - `-e`: File exists
/// - `-f`: Regular file
/// - `-g`: Set-group-ID flag set
/// - `-G`: Group-ID matches
/// - `-h`: Symbolic link
/// - `-L`: Symbolic link (same as `-h`)
/// - `-k`: Sticky bit set
/// - `-N`: Modified since last read
/// - `-O`: User-ID matches
/// - `-p`: Named pipe
/// - `-r`: Readable
/// - `-s`: File size greater than zero
/// - `-S`: Socket
/// - `-u`: Set-user-ID flag set
/// - `-w`: Writable
/// - `-x`: Executable
///
/// ## String Tests
///
/// - `-n`: String is non-empty
/// - `-z`: String is empty
/// - `=`: Strings are equal
/// - `!=`: Strings are not equal
///
/// ## Integer Tests
///
/// - `-eq`: Equal
/// - `-ge`: Greater than or equal
/// - `-gt`: Greater than
/// - `-le`: Less than or equal
/// - `-lt`: Less than
/// - `-ne`: Not equal
///
/// ## Logical Operators
///
/// - `-a`: And
/// - `-o`: Or
///
/// ## Special Operators
///
/// - `!`: Not
/// - `-t`: File descriptor is associated with a terminal
///
/// # Notes
///
/// - The `test` command can be invoked using the `test` keyword or with square brackets `[ ]`.
/// - The function handles various error conditions, such as missing arguments or invalid syntax.
///
/// # Errors
///
/// - Returns `ShellError::from_syntax` if there is a syntax error or missing arguments.
/// - Returns `ShellError::from_syntax` if an expected comparison operator is missing.
///
/// # Safety
///
/// This function uses unsafe code to get the effective user ID and group ID using `geteuid` and `getegid`.
///
/// # Panics
///
/// This function does not panic.
pub fn test(mut argv: VecDeque<Tk>) -> Result<RshWaitStatus, ShellError> {
	info!("Starting builtin test");
	let span = Span::from(argv.front().unwrap().span().start,argv.back().unwrap().span().end);
	let is_false = || -> Result<RshWaitStatus, ShellError> { Ok(RshWaitStatus::Fail { code: 1, cmd: Some("test".into()), span }) };
	let is_true = || -> Result<RshWaitStatus, ShellError> { Ok(RshWaitStatus::Success { span }) };
	let is_int = |tk: &Tk| -> bool { tk.text().parse::<i32>().is_ok() };
	let to_int = |tk: Tk| -> Result<i32, ShellError> {
		tk.text().parse::<i32>().map_err(|_| ShellError::from_syntax("Expected an integer in test", tk.span()))
	};
	let is_path = |tk: &Tk| -> bool { PathBuf::from(tk.text()).exists() };
	let to_meta = |tk: Tk| -> Result<fs::Metadata, ShellError> {
		fs::metadata(tk.text()).map_err(|_| ShellError::from_syntax(&format!("Test: Path '{}' does not exist", tk.text()), tk.span()))
	};
	let string_noop = |tk: Tk| -> Result<String, ShellError> { Ok(tk.text().into()) };
	let command = argv.pop_front().unwrap();
	let is_bracket = match command.text() {
		"[" => true,
		"test" => false,
		_ => unreachable!()
	};

	if is_bracket {
		if let Some(arg) = argv.back() {
			if arg.text() != "]" {
				return Err(ShellError::from_syntax("Test is missing a closing bracket", arg.span()))
			}
		} else {
			return Err(ShellError::from_syntax("Found a test with no arguments", command.span()))
		}
	}

	if let Some(arg) = argv.pop_front() {
		let result1 = match arg.text() {
			"!" => do_logical_op(&mut argv, command.clone(), true, arg)?,
			"-t" => do_test(&mut argv, to_int, |int| isatty(*int).is_ok(), arg.span())?,
			"-b" => do_test(&mut argv, to_meta, |meta| meta.file_type().is_block_device(), arg.span())?,
			"-c" => do_test(&mut argv, to_meta, |meta| meta.file_type().is_char_device(), arg.span())?,
			"-d" => do_test(&mut argv, to_meta, |meta| meta.is_dir(), arg.span())?,
			"-f" => do_test(&mut argv, to_meta, |meta| meta.is_file(), arg.span())?,
			"-g" => do_test(&mut argv, to_meta, |meta| meta.mode() & 0o2000 != 0, arg.span())?,
			"-G" => do_test(&mut argv, to_meta, |meta| meta.gid() == unsafe { getegid() }, arg.span())?,
			"-h" => do_test(&mut argv, to_meta, |meta| meta.is_symlink(), arg.span())?,
			"-L" => do_test(&mut argv, to_meta, |meta| meta.is_symlink(), arg.span())?,
			"-k" => do_test(&mut argv, to_meta, |meta| meta.mode() & 0o1000 != 0, arg.span())?,
			"-N" => do_test(&mut argv, to_meta, |meta| meta.mtime() > meta.atime(), arg.span())?,
			"-O" => do_test(&mut argv, to_meta, |meta| meta.uid() == unsafe { geteuid() }, arg.span())?,
			"-p" => do_test(&mut argv, to_meta, |meta| meta.file_type().is_fifo(), arg.span())?,
			"-s" => do_test(&mut argv, to_meta, |meta| meta.len() > 0, arg.span())?,
			"-S" => do_test(&mut argv, to_meta, |meta| meta.file_type().is_socket(), arg.span())?,
			"-u" => do_test(&mut argv, to_meta, |meta| meta.mode() & 0o4000 != 0, arg.span())?,
			"-n" => do_test(&mut argv, string_noop, |st| !st.is_empty(), arg.span())?,
			"-z" => do_test(&mut argv, string_noop, |st| st.is_empty(), arg.span())?,
			"-e" => do_test(&mut argv, string_noop, |st| Path::new(st).exists(), arg.span())?,
			"-r" => do_test(&mut argv, string_noop, |st| access(Path::new(st), AccessFlags::R_OK).is_ok(), arg.span())?,
			"-w" => do_test(&mut argv, string_noop, |st| access(Path::new(st), AccessFlags::W_OK).is_ok(), arg.span())?,
			"-x" => do_test(&mut argv, string_noop, |st| access(Path::new(st), AccessFlags::X_OK).is_ok(), arg.span())?,
			_ if is_int(&arg) => {
				if let Some(cmp) = argv.pop_front() {
					match cmp.text() {
						"-eq" => do_cmp(arg, &mut argv, to_int, |left, right| left == right)?,
						"-ge" => do_cmp(arg, &mut argv, to_int, |left, right| left >= right)?,
						"-gt" => do_cmp(arg, &mut argv, to_int, |left, right| left > right)?,
						"-le" => do_cmp(arg, &mut argv, to_int, |left, right| left <= right)?,
						"-lt" => do_cmp(arg, &mut argv, to_int, |left, right| left < right)?,
						"-ne" => do_cmp(arg, &mut argv, to_int, |left, right| left != right)?,
						_ => {
							return Err(ShellError::from_syntax("Expected an integer after comparison operator in test", cmp.span()));
						}
					}
				} else {
					return Err(ShellError::from_syntax("Expected a comparison operator after integer in test", command.span()));
				}
			}
			_ if is_path(&arg) && argv.front().is_some_and(|arg| matches!(arg.text(), "-ef" | "-nt" | "-ot")) => {
				if let Some(cmp) = argv.pop_front() {
					match cmp.text() {
						"-ef" => do_cmp(arg, &mut argv, to_meta, |left, right| left.dev() == right.dev() && left.ino() == right.ino())?,
						"-nt" => do_cmp(arg, &mut argv, to_meta, |left, right| left.mtime() > right.mtime())?,
						"-ot" => do_cmp(arg, &mut argv, to_meta, |left, right| left.mtime() < right.mtime())?,
						_ => {
							return Err(ShellError::from_syntax("Expected a file name after -b flag", cmp.span()));
						}
					}
				} else {
					return Err(ShellError::from_syntax("Expected a comparison operator after path name in test", command.span()));
				}
			}
			_ => {
				if argv.is_empty() {
					!arg.text().is_empty() // Default behavior is to return true if a string is not empty
				} else if let Some(cmp) = argv.pop_front() {
					match cmp.text() {
						"=" => do_cmp(arg, &mut argv, string_noop, |left, right| left == right)?,
						"!=" => do_cmp(arg, &mut argv, string_noop, |left, right| left != right)?,
						_ => {
							if cmp.text() == "==" {
								return Err(ShellError::from_syntax("`==` is not a valid comparison operator, use `=` instead", cmp.span()));
							} else {
								return Err(ShellError::from_syntax("Expected a comparison operator after string in test", cmp.span()));
							}
						}
					}
				} else {
					return Err(ShellError::from_syntax("Expected a comparison operator after string in test", command.span()));
				}
			}
		};
		if let Some(arg) = argv.pop_front() {
			match arg.text() {
				"-a" | "-o" => { // And/Or
					let result = do_logical_op(&mut argv, command, result1, arg)?;
					match result {
						true => return is_true(),
						false => return is_false(),
					}
				}
				"]" => {}
				_ => {
					return Err(ShellError::from_syntax("Unexpected extra argument found in test", arg.span()));
				}
			}
		}
		match result1 {
			true => is_true(),
			false => is_false(),
		}
	} else {
		Err(ShellError::from_syntax("Test called with no arguments", command.span()))
	}
}

pub fn alias(shellenv: &mut ShellEnv, node: Node) -> Result<RshWaitStatus, ShellError> {
	let mut argv: VecDeque<Tk> = node.get_argv()?.into();
	argv.pop_front();
	while let Some(arg) = argv.pop_front() {
		if !token::REGEX["assignment"].is_match(arg.text()) {
			return Err(ShellError::from_syntax(&format!("Expected an assignment pattern in alias args, got {}",arg.text()), arg.span()))
		}
		let (alias,value) = arg.text().split_once('=').unwrap();
		if let Err(e) = shellenv.set_alias(alias.into(), value.into()) {
			return Err(ShellError::from_parse(e.as_str(), node.span()))
		}
	}
	Ok(RshWaitStatus::Success { span: node.span() })
}

pub fn cd(shellenv: &mut ShellEnv, node: Node) -> Result<RshWaitStatus,ShellError> {
	let mut argv = node
		.get_argv()?
		.iter()
		.map(|arg| CString::new(arg.text()).unwrap())
		.collect::<VecDeque<CString>>();
	argv.pop_front();
	let new_pwd;
	if let Some(arg) = argv.pop_front() {
		new_pwd = arg;
	} else if let Some(home_path) = shellenv.get_variable("HOME") {
		new_pwd = CString::new(home_path).unwrap();
	} else {
		new_pwd = CString::new("/").unwrap();
	}
	let path = Path::new(new_pwd.to_str().unwrap());
	shellenv.change_dir(path, node.span())?;
	Ok(RshWaitStatus::Success { span: node.span() })
}

pub fn source(shellenv: &mut ShellEnv, node: Node) -> Result<RshWaitStatus,ShellError> {
	let mut argv = node
		.get_argv()?
		.iter()
		.map(|arg| CString::new(arg.text()).unwrap())
		.collect::<VecDeque<CString>>();
	argv.pop_front();
	for path in argv {
		let file_path = Path::new(OsStr::from_bytes(path.as_bytes()));
		shellenv.source_file(file_path.to_path_buf())?
	}
	Ok(RshWaitStatus::Success { span: node.span() })
}

fn flags_from_chars(chars: &str) -> EnvFlags {
	let flag_list = chars.chars();
	let mut env_flags = EnvFlags::empty();
	for ch in flag_list {
		match ch {
			'a' => env_flags |= EnvFlags::EXPORT_ALL_VARS,
			'b' => env_flags |= EnvFlags::REPORT_JOBS_ASAP,
			'e' => env_flags |= EnvFlags::EXIT_ON_ERROR,
			'f' => env_flags |= EnvFlags::NO_GLOB,
			'h' => env_flags |= EnvFlags::HASH_CMDS,
			'k' => env_flags |= EnvFlags::ASSIGN_ANYWHERE,
			'm' => env_flags |= EnvFlags::ENABLE_JOB_CTL,
			'n' => env_flags |= EnvFlags::NO_EXECUTE,
			'r' => env_flags |= EnvFlags::ENABLE_RSHELL,
			't' => env_flags |= EnvFlags::EXIT_AFTER_EXEC,
			'u' => env_flags |= EnvFlags::UNSET_IS_ERROR,
			'v' => env_flags |= EnvFlags::PRINT_INPUT,
			'x' => env_flags |= EnvFlags::STACK_TRACE,
			'B' => env_flags |= EnvFlags::EXPAND_BRACES,
			'C' => env_flags |= EnvFlags::NO_OVERWRITE,
			'E' => env_flags |= EnvFlags::INHERIT_ERR,
			'H' => env_flags |= EnvFlags::HIST_SUB,
			'P' => env_flags |= EnvFlags::NO_CD_SYMLINKS,
			'T' => env_flags |= EnvFlags::INHERIT_RET,
			_ => eprintln!("set: no such option '{}'",ch)
		}
	}
	env_flags
}

pub fn set_or_unset(shellenv: &mut ShellEnv, node: Node, set: bool) -> Result<RshWaitStatus,ShellError> {
	let span = node.span();
	if let NdType::Builtin { mut argv } = node.nd_type {
		argv.pop_front(); // Ignore 'set'
		if argv.front().is_none_or(|arg| !arg.text().starts_with('-')) {
			return Err(ShellError::from_execf("Invalid 'set' invocation", 1, span))
		}
		let flag_arg = argv.pop_front().unwrap();
		let set_flags = flag_arg.text();
		let set_flags = set_flags.strip_prefix('-').unwrap();
		let env_flags = flags_from_chars(set_flags);
		match set {
			true => shellenv.set_flags(env_flags),
			false => shellenv.unset_flags(env_flags),
		}
		Ok(RshWaitStatus::new())
	} else { unreachable!() }
}

pub fn pwd(shellenv: &ShellEnv, span: Span) -> Result<RshWaitStatus, ShellError> {
	if let Some(pwd) = shellenv.get_variable("PWD") {
		let stdout = RustFd::from_stdout()?;
		stdout.write(pwd.as_bytes())?;
		Ok(RshWaitStatus::Success { span })
	} else {
		Err(ShellError::from_execf("PWD environment variable is unset", 1, span))
	}
}

pub fn export(shellenv: &mut ShellEnv, node: Node) -> Result<RshWaitStatus, ShellError> {
	let last_status = RshWaitStatus::Success { span: node.span() };
	if let NdType::Builtin { mut argv } = node.nd_type {
		argv.pop_front(); // Ignore "export"
		while let Some(ass) = argv.pop_front() {
			if let Some((key,value)) = ass.text().split_once('=') {
				shellenv.export_variable(key.to_string(), value.to_string());
			} else {
				return Err(ShellError::from_execf(format!("Expected a variable assignment in export, got this: {}", ass.text()).as_str(), 1, ass.span()))
			}
		}
		Ok(last_status)
	} else { unreachable!() }
}

pub fn jobs(shellenv: &mut ShellEnv, node: Node, mut io: ProcIO, in_pipe: bool) -> Result<RshWaitStatus,ShellError> {
	let mut argv = node.get_argv()?.into_iter().collect::<VecDeque<Tk>>();
	argv.pop_front();
	let mut flags = JobFlags::empty();
	while let Some(arg) = argv.pop_front() {
		let mut chars = arg.text().chars().collect::<VecDeque<char>>();
		if chars.front().is_none_or(|ch| *ch != '-') {
			return Err(ShellError::from_execf("Invalid flag in `jobs` invocation", 1, node.span()))
		}
		chars.pop_front(); // Ignore the leading hyphen
		while let Some(ch) = chars.pop_front() {
			let flag = match ch {
				'l' => JobFlags::LONG,
				'p' => JobFlags::PIDS_ONLY,
				'n' => JobFlags::NEW_ONLY,
				'r' => JobFlags::RUNNING,
				's' => JobFlags::STOPPED,
				_ => return Err(ShellError::from_execf("Invalid flag in `jobs` invocation", 1, node.span()))
			};
			flags |= flag;
		}
	}
	shellenv.job_table.print_jobs(&flags);

	Ok(RshWaitStatus::Success { span: node.span() })
}

pub fn echo(shellenv: &mut ShellEnv, node: Node, mut io: ProcIO, in_pipe: bool) -> Result<RshWaitStatus, ShellError> {
	let mut flags = EchoFlags::empty();
	let span = node.span();
	let mut argv = node.get_argv()?.into_iter().collect::<VecDeque<Tk>>();
	argv.pop_front(); // Remove 'echo' from argv
										// Get flags
	if argv.front().is_some_and(|arg| arg.text().starts_with('-')) {
		let next_arg = argv.pop_front().unwrap();
		let mut options = next_arg.text().strip_prefix('-').unwrap().chars();
		loop {
			match options.next() {
				Some('e') => {
					if flags.contains(EchoFlags::NO_ESCAPE) {
						flags &= !EchoFlags::NO_ESCAPE
					}
					flags |= EchoFlags::USE_ESCAPE
				}
				Some('r') => flags |= EchoFlags::STDERR,
				Some('n') => flags |= EchoFlags::NO_NEWLINE,
				Some('E') => {
					if flags.contains(EchoFlags::USE_ESCAPE) {
						flags &= !EchoFlags::USE_ESCAPE
					}
					flags |= EchoFlags::NO_ESCAPE
				}
				_ => break
			}
		}
		if flags.is_empty() {
			argv.push_front(next_arg);
		}
	}
	let argv = argv.into_iter().map(|tk| {
		let text = tk.text();
		if flags.contains(EchoFlags::USE_ESCAPE) {
			CString::new(expand::process_ansi_escapes(text)).unwrap()
		} else {
			CString::new(tk.text()).unwrap()
		}
	}).collect::<VecDeque<CString>>();

	let redirs = node.get_redirs()?;
	info!("Executing echo with argv: {:?}, and redirs: {:?}", argv,node.redirs);

	io.backup_fildescs()?;
	let newline_opt = !flags.contains(EchoFlags::NO_NEWLINE);
	let output_str = catstr(argv, newline_opt);
	let mut fd_stack = vec![];
	fd_stack.extend(open_file_descriptors(redirs.into())?);

	let output_fd = if flags.contains(EchoFlags::STDERR) {
		if let Some(ref err_fd) = io.stderr {
			err_fd.lock().unwrap().dup().unwrap_or_else(|_| RustFd::from_stderr().unwrap())
		} else {
			RustFd::from_stderr()?
		}
	} else if let Some(ref out_fd) = io.stdout {
			out_fd.lock().unwrap().dup().unwrap_or_else(|_| RustFd::from_stdout().unwrap())
		} else {
			RustFd::from_stdout()?
	};

	if let Some(ref fd) = io.stderr {
		if !flags.contains(EchoFlags::STDERR) {
			let fd = fd.lock().unwrap();
			output_fd.dup2(&fd.as_raw_fd())?;
		}
	}

	if in_pipe {
		output_fd.write(output_str.as_bytes())?;
		std::process::exit(0);
	}
	match unsafe { fork() } {
		Ok(ForkResult::Child) => {
			output_fd.write(output_str.as_bytes())?;
			std::process::exit(0);
		}
		Ok(ForkResult::Parent { child }) => {
			for mut fd in fd_stack {
				fd.close().unwrap();
			}
			io.restore_fildescs()?;
			if node.flags.contains(NdFlags::BACKGROUND) {
				setpgid(child, child).map_err(|_| ShellError::from_io())?;
				shellenv.new_job(vec![child], vec!["echo".into()], child);
				Ok(RshWaitStatus::Success { span })
			} else {
				match waitpid(child, None) {
					Ok(WaitStatus::Exited(_, code)) => match code {
						0 => Ok(RshWaitStatus::Success { span }),
						_ => Ok(RshWaitStatus::Fail { code, cmd: Some("echo".into()), span }),
					},
					Ok(WaitStatus::Signaled(_,signal,_)) => {
						Ok(RshWaitStatus::Fail { code: 128 + signal as i32, cmd: Some("echo".into()), span })
					}
					Ok(_) => Err(ShellError::from_execf("Unexpected waitpid result", 1, span)),
					Err(err) => Err(ShellError::from_execf(&format!("Waitpid failed: {}", err), 1, span)),
				}
			}
		}
		Err(_) => Err(ShellError::from_execf("Fork failed", 1, span)),
	}
}
