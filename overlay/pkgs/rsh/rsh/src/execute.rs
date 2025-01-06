use libc::{memfd_create, tcsetpgrp, MFD_CLOEXEC, STDIN_FILENO};
use nix::sys::signal::Signal;
use nix::unistd::{close, dup, dup2, execve, execvpe, fork, getpgid, getpid, pipe, setpgid, ForkResult, Pid};
use nix::fcntl::{open,OFlag};
use nix::sys::stat::Mode;
use nix::sys::wait::{waitpid, WaitStatus};
use std::fmt::{self, Display};
use std::io;
use std::os::fd::{AsFd, AsRawFd, FromRawFd, IntoRawFd, RawFd};
use std::ffi::CString;
use std::collections::{HashMap, VecDeque};
use std::path::Path;
use std::sync::{Arc, Mutex};
use log::{info,trace};
use glob::MatchOptions;

use crate::builtin::{alias, cd, echo, export, jobs, pwd, set_or_unset, source, test};
use crate::event::ShellError;
use crate::interp::helper::{self, VecDequeExtension};
use crate::interp::{expand, parse};
use crate::interp::token::{Redir, RedirType, Tk, TkType, WdFlags};
use crate::interp::parse::{NdFlags, NdType, Node, Span};
use crate::shellenv::ShellEnv;

pub const GLOB_OPTS: MatchOptions = MatchOptions {
	case_sensitive: false,
	require_literal_separator: true,
	require_literal_leading_dot: false
};

/// A wrapper struct for idiomatic and safe handling of file descriptors in Rust.
///
/// `RustFd` provides a safer and more ergonomic interface for working with file descriptors (`RawFd`),
/// addressing common pitfalls associated with direct handling of file descriptors in systems programming.
///
/// ### Key Features:
/// - **Automatic Resource Management**: Implements the `Drop` trait, ensuring the file descriptor is
///   automatically closed when the `RustFd` instance goes out of scope, preventing resource leaks.
/// - **Prevention of Double-Closing**: Once closed, the internal file descriptor is set to `-1`,
///   denoting a "dead" file descriptor and safeguarding against double-close errors.
/// - **Uniqueness**: `RustFd` does not implement the `Copy` or `Clone` traits, ensuring each instance
///   uniquely owns its file descriptor. This design eliminates the risk of unintended file descriptor
///   duplication and the associated lifecycle ambiguities.
/// - **Proof of Openness**: The existence of a `RustFd` instance guarantees that the file descriptor it wraps
///   is valid and open. This makes reasoning about resource states easier and more reliable.
///
/// ### Advantages:
/// Compared to raw file descriptors from `libc` or `nix::unistd`, `RustFd` reduces the likelihood of:
/// - Resource leaks caused by missing `close` calls.
/// - Use-after-close bugs from accessing invalid file descriptors.
/// - Double-close errors.
///
/// ### Example:
/// ```rust
/// use std::os::unix::io::RawFd;
///
/// let fd: RawFd = open_some_file(); // Hypothetical function that opens a file and returns a RawFd.
/// let rust_fd = RustFd::new(fd);
/// // `rust_fd` ensures the file descriptor is properly closed when it goes out of scope.
/// ```
#[derive(Hash, Eq, PartialEq, Debug)]
pub struct RustFd {
	fd: RawFd,
}

impl RustFd {
	pub fn new(fd: RawFd) -> Result<Self,ShellError> {
		if fd < 0 {
			return Err(ShellError::from_internal("Attempted to create a new RustFd from a negative FD"));
		}
		Ok(RustFd { fd })
	}

	/// Create a `RustFd` from a duplicate of `stdin` (FD 0)
	pub fn from_stdin() -> Result<Self,ShellError> {
		let fd = dup(0).map_err(|_| ShellError::from_io())?;
		Ok(Self { fd })
	}

	/// Create a `RustFd` from a duplicate of `stdout` (FD 1)
	pub fn from_stdout() -> Result<Self,ShellError> {
		let fd = dup(1).map_err(|_| ShellError::from_io())?;
		Ok(Self { fd })
	}

	/// Create a `RustFd` from a duplicate of `stderr` (FD 2)
	pub fn from_stderr() -> Result<Self,ShellError> {
		let fd = dup(2).map_err(|_| ShellError::from_io())?;
		Ok(Self { fd })
	}

	/// Create a `RustFd` from a type that provides an owned or borrowed FD
	pub fn from_fd<T: AsFd>(fd: T) -> Result<Self,ShellError> {
		let raw_fd = fd.as_fd().as_raw_fd();
		if raw_fd < 0 {
			return Err(ShellError::from_internal("Attempted to convert to RustFd from a negative FD"));
		}
		Ok(RustFd { fd: raw_fd })
	}

	/// Create a `RustFd` by consuming ownership of an FD
	pub fn from_owned_fd<T: IntoRawFd>(fd: T) -> Result<Self,ShellError> {
		let raw_fd = fd.into_raw_fd(); // Consumes ownership
		if raw_fd < 0 {
			return Err(ShellError::from_internal("Attempted to convert to RustFd from a negative FD"));
		}
		Ok(RustFd { fd: raw_fd })
	}

	/// Create a new `RustFd` that points to an in-memory file descriptor. In-memory file descriptors can be interacted with as though they were normal files.
	pub fn new_memfd(name: &str, executable: bool) -> Result<Self, ShellError> {
		let c_name = CString::new(name).map_err(|_| ShellError::from_internal("Invalid name for memfd"))?;
		let flags = if executable {
			0
		} else {
			MFD_CLOEXEC
		};
		let fd = unsafe { memfd_create(c_name.as_ptr(), flags) };
		Ok(RustFd { fd })
	}

	/// Write some bytes to the contained file descriptor
	pub fn write(&self, buffer: &[u8]) -> Result<(),ShellError> {
		if !self.is_valid() {
			return Err(ShellError::from_internal("Attempted to write to an invalid RustFd"));
		}
		let result = unsafe { libc::write(self.fd, buffer.as_ptr() as *const libc::c_void, buffer.len()) };
		if result < 0 {
			Err(ShellError::from_io())
		} else {
			Ok(())
		}
	}

	/// Wrapper for nix::unistd::pipe(), simply produces two `RustFds` that point to a read and write pipe respectfully
	pub fn pipe() -> Result<(Self,Self),ShellError> {
		let (r_pipe,w_pipe) = pipe().map_err(|_| ShellError::from_io())?;
		let r_fd = RustFd::from_owned_fd(r_pipe)?;
		let w_fd = RustFd::from_owned_fd(w_pipe)?;
		Ok((r_fd,w_fd))
	}

	/// Produce a `RustFd` that points to the same resource as the 'self' `RustFd`
	pub fn dup(&self) -> Result<Self,ShellError> {
		if !self.is_valid() {
			return Err(ShellError::from_internal("Attempted to dup an invalid fd"));
		}
		let new_fd = dup(self.fd).map_err(|_| ShellError::from_io())?;
		Ok(RustFd { fd: new_fd })
	}

	/// A wrapper for nix::unistd::dup2(), 'self' is duplicated to the given target file descriptor.
	pub fn dup2<T: AsRawFd>(&self, target: &T) -> Result<(),ShellError> {
		let target_fd = target.as_raw_fd();
		if self.fd == target_fd {
			// Nothing to do here
			return Ok(())
		}
		if !self.is_valid() || target_fd < 0 {
			return Err(ShellError::from_io());
		}

		dup2(self.fd, target_fd).map_err(|_| ShellError::from_io())?;
		Ok(())
	}

	/// Open a file using a file descriptor, with the given OFlags and Mode bits
	pub fn open(path: &Path, flags: OFlag, mode: Mode) -> Result<Self,ShellError> {
		let file_fd: RawFd = open(path, flags, mode).map_err(|_| ShellError::from_io())?;
		Ok(Self { fd: file_fd })
	}

	pub fn close(&mut self) -> Result<(),ShellError> {
		if !self.is_valid() {
			return Err(ShellError::from_internal("Attempted to close an invalid RustFd"));
		}
		close(self.fd).map_err(|_| ShellError::from_io())?;
		self.fd = -1;
		Ok(())
	}

	pub fn mk_shared(self) -> Arc<Mutex<Self>> {
		Arc::new(Mutex::new(self))
	}

	pub fn is_valid(&self) -> bool {
		self.fd > 0
	}
}

impl Display for RustFd {
	fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
		write!(f, "{}", self.fd)
	}
}

impl Drop for RustFd {
	fn drop(&mut self) {
		if self.fd >= 0 {
			self.close().ok();
		}
	}
}

impl AsRawFd for RustFd {
	fn as_raw_fd(&self) -> RawFd {
		self.fd
	}
}

impl IntoRawFd for RustFd {
	fn into_raw_fd(self) -> RawFd {
		let fd = self.fd;
		std::mem::forget(self);
		fd
	}
}

impl FromRawFd for RustFd {
	unsafe fn from_raw_fd(fd: RawFd) -> Self {
		RustFd { fd }
	}
}

#[derive(Debug)]
pub struct ProcIO {
	pub stdin: Option<Arc<Mutex<RustFd>>>,
	pub stdout: Option<Arc<Mutex<RustFd>>>,
	pub stderr: Option<Arc<Mutex<RustFd>>>,
	pub backup: HashMap<RawFd,RustFd>
}

impl ProcIO {
	pub fn new() -> Self {
		Self { stdin: None, stdout: None, stderr: None, backup: HashMap::new() }
	}
	pub fn from(stdin: Option<Arc<Mutex<RustFd>>>, stdout: Option<Arc<Mutex<RustFd>>>, stderr: Option<Arc<Mutex<RustFd>>>) -> Self {
		Self {
			stdin,
			stdout,
			stderr,
			backup: HashMap::new(),
		}
	}
	pub fn close_all(&mut self) -> Result<(),ShellError> {
		if let Some(fd) = &self.stdin {
			fd.lock().unwrap().close()?;
		}
		if let Some(fd) = &self.stdout {
			fd.lock().unwrap().close()?;
		}
		if let Some(fd) = &self.stderr {
			fd.lock().unwrap().close()?;
		}
		Ok(())
	}
	pub fn backup_fildescs(&mut self) -> Result<(), ShellError> {
		let mut backup = HashMap::new();
		// Get duped file descriptors
		let dup_in = RustFd::from_stdin()?;
		let dup_out = RustFd::from_stdout()?;
		let dup_err = RustFd::from_stderr()?;
		// Store them in a hashmap
		backup.insert(0,dup_in);
		backup.insert(1,dup_out);
		backup.insert(2,dup_err);
		self.backup = backup;
		Ok(())
	}
	pub fn restore_fildescs(&mut self) -> Result<(), ShellError> {
		// Get duped file descriptors from hashmap
		if !self.backup.is_empty() {
			// Dup2 to restore file descriptors
			if let Some(mut saved_in) = self.backup.remove(&0) {
				saved_in.dup2(&0)?;
				saved_in.close()?;
			}
			if let Some(mut saved_out) = self.backup.remove(&1) {
				saved_out.dup2(&1)?;
				saved_out.close()?;
			}
			if let Some(mut saved_err) = self.backup.remove(&2) {
				saved_err.dup2(&2)?;
				saved_err.close()?;
			}
		}
		Ok(())
	}
	pub fn do_plumbing(&mut self) -> Result<(), ShellError> {
		if let Some(ref mut err_pipe) = self.stderr {
			let mut pipe = err_pipe.lock().unwrap();
			pipe.dup2(&2)?;
			pipe.close()?;
		}
		// Redirect stdout
		if let Some(ref mut w_pipe) = self.stdout {
			let mut pipe = w_pipe.lock().unwrap();
			pipe.dup2(&1)?;
			pipe.close()?;
		}

		// Redirect stdin
		if let Some(ref mut r_pipe) = self.stdin {
			let mut pipe = r_pipe.lock().unwrap();
			pipe.dup2(&0)?;
			pipe.close()?;
		}
		Ok(())
	}

	pub fn try_clone(&self) -> Self {
		ProcIO::from(self.stdin.clone(),self.stdout.clone(),self.stderr.clone())
	}
}

impl Default for ProcIO {
	fn default() -> Self {
		Self::new()
	}
}

#[derive(PartialEq,Debug,Clone)]
pub enum RshWaitStatus {
	Success { span: Span },
	Fail { code: i32, cmd: Option<String>, span: Span },
	Signaled { sig: Signal },
	Stopped { sig: Signal },
	Terminated { signal: i32 },
	Continued,
	Running,
	Killed { signal: i32 },
	TimeOut,

	// These wait statuses are returned by builtins like `return` and `break`
	SIGRETURN, // Return from a function
	SIGCONT, // Restart a loop from the beginning
	SIGBREAK, // Break a loop
	SIGRSHEXIT // Internal call to exit early
}

impl Display for RshWaitStatus {
	fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
		match self {
			RshWaitStatus::Success { .. } => write!(f, "done"),
			RshWaitStatus::Fail { code, .. } => write!(f, "exit {}", code),
			RshWaitStatus::Signaled { sig } => write!(f, "exit {}", sig),
			RshWaitStatus::Stopped { sig } => write!(f, "stopped {}", sig),
			RshWaitStatus::Terminated { signal } => write!(f, "terminated {}", signal),
			RshWaitStatus::Continued => write!(f, "continued"),
			RshWaitStatus::Running => write!(f, "running"),
			RshWaitStatus::Killed { signal } => write!(f, "killed {}", signal),
			RshWaitStatus::TimeOut => write!(f, "time out"),
			_ => write!(f, "{:?}",self)
		}
	}
}

impl RshWaitStatus {
	pub fn new() -> Self {
		RshWaitStatus::Success { span: Span::new() }
	}
	pub fn s(span: Span) -> Self {
		RshWaitStatus::Success { span }
	}
	pub fn f(code: i32, cmd: Option<String>, span: Span) -> Self {
		RshWaitStatus::Fail { code, cmd, span }
	}
}

impl Default for RshWaitStatus {
	fn default() -> Self {
		RshWaitStatus::new()
	}
}


pub struct NodeWalker<'a> {
	ast: Node,
	shellenv: &'a mut ShellEnv,
}

impl<'a> NodeWalker<'a> {
	pub fn new(ast: Node, shellenv: &'a mut ShellEnv) -> Self {
		Self {
			ast,
			shellenv
		}
	}
	pub fn start_walk(&mut self) -> Result<RshWaitStatus,ShellError> {
		info!("Going on a walk...");
		// Save file descs just in case
		let saved_in = RustFd::from_stdin()?;
		let saved_out = RustFd::from_stdout()?;
		let saved_err = RustFd::from_stderr()?;
		let mut exit_status = RshWaitStatus::new();
		let mut nodes;
		if let NdType::Root { ref mut deck } = self.ast.nd_type {
			nodes = std::mem::take(deck);
		} else { unreachable!() }
		while let Some(node) = nodes.pop_front() {
			exit_status = self.walk(node, ProcIO::new(), false)?;
		}
		// Restore file descs just in case
		saved_in.dup2(&0)?;
		saved_out.dup2(&1)?;
		saved_err.dup2(&2)?;
		Ok(exit_status)
	}

	fn walk(&mut self, node: Node, io: ProcIO, in_pipe: bool) -> Result<RshWaitStatus,ShellError> {
		let last_status;
		match node.nd_type {
			NdType::Command { ref argv } | NdType::Builtin { ref argv } => {
				let mut node = node.clone();
				let command_name = argv.front().unwrap();
				let not_from_alias = !command_name.flags().contains(WdFlags::FROM_ALIAS);
				let is_not_command_builtin = command_name.text() != "command";
				if not_from_alias && is_not_command_builtin {
					node = expand::expand_alias(self.shellenv, node.clone())?;
				}
				if let Some(_func) = self.shellenv.get_function(command_name.text()) {
					last_status = self.handle_function(node, io, in_pipe)?;
				} else if !matches!(node.nd_type, NdType::Command {..} | NdType::Builtin {..}) {
					// If the resulting alias expansion returns a root node
					// then walk the resulting sub-tree
					return self.walk_root(node, None, io,in_pipe)
				} else {
					match node.nd_type {
						NdType::Command {..} => {
							trace!("Found command: {:?}",node);
							last_status = self.handle_command(node, io, in_pipe)?;
						}
						NdType::Builtin {..} => {
							last_status = self.handle_builtin(node, io, in_pipe)?;
						}
						_ => unreachable!()
					}
				}
			}
			NdType::Pipeline {..} => {
				last_status = self.handle_pipeline(node, io)?;
			}
			NdType::Chain {..} => {
				last_status = self.handle_chain(node)?;
			}
			NdType::If {..} => {
				last_status = self.handle_if(node,io,in_pipe)?;
			}
			NdType::For {..} => {
				last_status = self.handle_for(node,io,in_pipe)?;
			}
			NdType::Loop {..} => {
				last_status = self.handle_loop(node,io,in_pipe)?;
			}
			NdType::Case {..} => {
				last_status = self.handle_case(node,io,in_pipe)?;
			}
			NdType::Select {..} => {
				todo!("handle select")
			}
			NdType::Subshell {..} => {
				last_status = self.handle_subshell(node,io,in_pipe)?;
			}
			NdType::FuncDef {..} => {
				last_status = self.handle_func_def(node)?;
			}
			NdType::Assignment {..} => {
				last_status = self.handle_assignment(node)?;
			}
			NdType::Cmdsep => {
				last_status = RshWaitStatus::new();
			}
			_ => unimplemented!("Support for node type `{:?}` is not yet implemented",node.nd_type)
		}
		Ok(last_status)
	}

	fn walk_root(&mut self, mut node: Node, break_condition: Option<bool>, io: ProcIO, in_pipe: bool) -> Result<RshWaitStatus,ShellError> {
		let mut last_status = RshWaitStatus::new();
		if !node.redirs.is_empty() {
			node = parse::propagate_redirections(node)?;
		}
		if let NdType::Root { deck } = node.nd_type {
			for node in &deck {
				last_status = self.walk(node.clone(), io.try_clone(), in_pipe)?;
				if let Some(condition) = break_condition {
					match condition {
						true => {
							if let RshWaitStatus::Fail {..} = last_status {
								break
							}
						}
						false => {
							if let RshWaitStatus::Success {..} = last_status {
								break
							}
						}
					}
				}
			}
		}
		Ok(last_status)
	}

	fn handle_func_def(&mut self, node: Node) -> Result<RshWaitStatus, ShellError> {
		let last_status = RshWaitStatus::new();
		if let NdType::FuncDef { name, body } = node.nd_type {
			self.shellenv.set_function(name, body)?;
			Ok(last_status)
		} else { unreachable!() }
	}

	fn handle_case(&mut self, node: Node, io: ProcIO, in_pipe: bool) -> Result<RshWaitStatus, ShellError> {
		let span = node.span();
		if let NdType::Case { input_var, cases } = node.nd_type {
			for case in cases {
				let (pat,body) = case;
				if pat == input_var.text() {
					return self.walk_root(body, None, io, in_pipe)
				}
			}
			Ok(RshWaitStatus::Fail { code: 1, cmd: None, span })
		} else { unreachable!() }
	}

	/// For loops in bash can have multiple loop variables, e.g. `for a b c in 1 2 3 4 5 6`
	/// In this case, loop_vars are also iterated through, e.g. a = 1, b = 2, c = 3, etc
	/// Here, we use the modulo operator to figure out which variable to set on each iteration.
	fn handle_for(&mut self, node: Node, io: ProcIO, in_pipe: bool) -> Result<RshWaitStatus, ShellError> {
		let mut last_status = RshWaitStatus::new();
		let body_io = ProcIO::from(None, io.stdout, io.stderr);
		let redirs = node.get_redirs()?;
		self.handle_redirs(redirs.into())?;

		if let NdType::For { loop_vars, mut loop_arr, loop_body } = node.nd_type {
			let var_count = loop_vars.len();
			let mut var_index = 0;
			let mut iteration_count = 0;

			let mut arr_buffer = VecDeque::new();
			loop_arr.map_rotate(|elem| {
				for token in expand::expand_token(self.shellenv, elem) {
					arr_buffer.push_back(token);
				}
			});
			loop_arr.extend(arr_buffer.drain(..));


			while !loop_arr.is_empty() {

				// Get the current value from the array
				let current_value = loop_arr.pop_front().unwrap().text().to_string();

				// Set the current variable to the current value
				let current_var = loop_vars[var_index].text().to_string();
				self.shellenv.set_variable(current_var, current_value);

				// Update the variable index for the next iteration
				iteration_count += 1;
				var_index = iteration_count % var_count;

				// Execute the body of the loop
				last_status = self.walk_root(*loop_body.clone(), None, body_io.try_clone(),in_pipe)?;
			}
		}

		Ok(last_status)
	}

	fn handle_loop(&mut self, node: Node, io: ProcIO, in_pipe: bool) -> Result<RshWaitStatus, ShellError> {
		let mut last_status = RshWaitStatus::new();
		let cond_io = ProcIO::from(io.stdin, None, None);
		let body_io = ProcIO::from(None, io.stdout, io.stderr);

		if let NdType::Loop { condition, logic } = node.nd_type {
			let cond = *logic.condition;
			let body = *logic.body;
			// TODO: keep an eye on this; cloning in the loop body may be too expensive
			loop {
				// Evaluate the loop condition
				let condition_status = self.walk_root(cond.clone(),Some(condition),cond_io.try_clone(),in_pipe)?;

				match condition {
					true => {
						if !matches!(condition_status,RshWaitStatus::Success {..}) {
							break; // Exit for a `while` loop when condition is false
						}
					}
					false => {
						if matches!(condition_status,RshWaitStatus::Success {..}) {
							break; // Exit for an `until` loop when condition is true
						}
					}
				}

				// Execute the body of the loop
				last_status = self.walk_root(body.clone(),None,body_io.try_clone(),in_pipe)?;

				// Check for break or continue signals
				// match last_status {
				// RshWaitStatus::Break => return Ok(RshWaitStatus::Break),
				// RshWaitStatus::Continue => continue,
				// _ => {}
				// }
			}
			Ok(last_status)
		} else {
			Err(ShellError::from_syntax(
					"Expected a loop node in handle_loop",
					node.span()
			))
		}
	}

	fn handle_if(&mut self, node: Node, io: ProcIO, in_pipe: bool) -> Result<RshWaitStatus, ShellError> {
		let mut last_result = RshWaitStatus::new();
		let cond_io = ProcIO::from(io.stdin, None, None);
		let body_io = ProcIO::from(None, io.stdout, io.stderr);

		if let NdType::If { mut cond_blocks, else_block } = node.nd_type {
			while let Some(block) = cond_blocks.pop_front() {
				let cond = *block.condition;
				let body = *block.body;
				last_result = self.walk_root(cond,Some(false),cond_io.try_clone(),in_pipe)?;
				if let RshWaitStatus::Success {..} = last_result {
					return self.walk_root(body,None,body_io,in_pipe)
				}
			}
			if let Some(block) = else_block {
				return self.walk_root(*block,None,body_io,in_pipe)
			}
		}
		Ok(last_result)
	}

	fn handle_chain(&mut self, node: Node) -> Result<RshWaitStatus, ShellError> {
		let mut last_status = RshWaitStatus::new();

		if let NdType::Chain { left, right, op } = node.nd_type {
			match self.walk(*left, ProcIO::new(), false)? {
				RshWaitStatus::Success {..} => {
					if let NdType::And = op.nd_type {
						last_status = self.walk(*right, ProcIO::new(), false)?;
					}
				}
				_ => {
					if let NdType::Or = op.nd_type {
						last_status = self.walk(*right, ProcIO::new(), false)?;
					}
				}
			}

		}
		Ok(last_status)
	}


	fn handle_assignment(&mut self, node: Node) -> Result<RshWaitStatus,ShellError> {
		let span = node.span();
		if let NdType::Assignment { name, value } = node.nd_type {
			let value = value.unwrap_or_default();
			self.shellenv.set_variable(name, value);
		}
		Ok(RshWaitStatus::s(span))
	}

	fn handle_builtin(&mut self, mut node: Node, io: ProcIO, in_pipe: bool) -> Result<RshWaitStatus,ShellError> {
		let argv = expand::expand_arguments(self.shellenv, &mut node)?;
		match argv.first().unwrap().text() {
			"echo" => echo(self.shellenv, node, io,in_pipe),
			"set" => set_or_unset(self.shellenv, node, true),
			"jobs" => jobs(self.shellenv, node, io, in_pipe),
			"unset" => set_or_unset(self.shellenv, node, false),
			"source" => source(self.shellenv, node),
			"cd" => cd(self.shellenv, node),
			"pwd" => pwd(self.shellenv, node.span()),
			"alias" => alias(self.shellenv, node),
			"export" => export(self.shellenv, node),
			"[" | "test" => test(node.get_argv()?.into()),
			"builtin" => {
				// This one allows you to safely wrap builtins in aliases/functions
				if let NdType::Builtin { mut argv } = node.nd_type {
					argv.pop_front();
					node.nd_type = NdType::Builtin { argv };
					self.handle_builtin(node, io, in_pipe)
				} else { unreachable!() }
			}
			_ => unimplemented!("found this builtin: {}",argv[0].text())
		}
	}



	/// Extracts arguments and redirections from an AST node.
	///
	/// This function processes an AST node of type `Command`, `Builtin`, or `Function`
	/// and extracts the arguments and redirections from it. The arguments are converted
	/// to `CString` and collected into a vector, while the redirections are collected
	/// into a `VecDeque`.
	///
	/// # Arguments
	///
	/// * `node` - The AST node to extract arguments and redirections from.
	///
	/// # Returns
	///
	/// A tuple containing:
	/// * A vector of `CString` representing the extracted arguments.
	/// * A `VecDeque` of `Tk` representing the extracted redirections.
	///
	/// # Panics
	///
	/// This function will panic if the provided `node` is not of type `Command`, `Builtin`,
	/// or `Function`.
	///
	/// # Example
	///
	/// let node = Node::Command { argv: vec![...].into_iter().collect() };
	/// let (args, redirs) = shell.extract_args(node);
	///
	/// # Notes
	///
	/// - The function uses `trace!` and `debug!` macros for logging purposes.
	/// - Variable substitutions (`$var`) are resolved using the `shellenv`'s `get_variable` method.
	/// - If a variable substitution is not found, an empty `CString` is added to the arguments.
	fn handle_redirs(&self, mut redirs: VecDeque<Node>) -> Result<VecDeque<RustFd>, ShellError> {
		let mut fd_queue: VecDeque<RustFd> = VecDeque::new();
		let mut fd_dupes: VecDeque<Redir> = VecDeque::new();

		while let Some(redir_tk) = redirs.pop_front() {
			if let NdType::Redirection { ref redir } = redir_tk.nd_type {
				let Redir { fd_source, op, fd_target, file_target } = &redir;
				if fd_target.is_some() {
					fd_dupes.push_back(redir.clone());
				} else if let Some(file_path) = file_target {
					let source_fd = RustFd::new(*fd_source)?;
					let flags = match op {
						RedirType::Input => OFlag::O_RDONLY,
						RedirType::Output => OFlag::O_WRONLY | OFlag::O_CREAT | OFlag::O_TRUNC,
						RedirType::Append => OFlag::O_WRONLY | OFlag::O_CREAT | OFlag::O_APPEND,
						_ => unimplemented!("Heredocs and herestrings are not implemented yet."),
					};
					let mut file_fd: RustFd = RustFd::open(Path::new(file_path.text()), flags, Mode::from_bits(0o644).unwrap())?;
					info!("Duping file FD {} to FD {}", file_fd, fd_source);
					file_fd.dup2(&source_fd)?;
					file_fd.close()?;
					fd_queue.push_back(source_fd);
				}
			}
		}

		while let Some(dupe_redir) = fd_dupes.pop_front() {
			let Redir { fd_source, op: _, fd_target, file_target: _ } = dupe_redir;
			let mut target_fd = RustFd::new(fd_target.unwrap())?;
			let source_fd = RustFd::new(fd_source)?;
			target_fd.dup2(&source_fd)?;
			target_fd.close()?;
			fd_queue.push_back(source_fd);
		}

		Ok(fd_queue)
	}

	fn handle_subshell(&mut self, mut node: Node, mut io: ProcIO, in_pipe: bool) -> Result<RshWaitStatus,ShellError> {
		expand::expand_arguments(self.shellenv, &mut node)?;
		let redirs = node.redirs;
		let mut shellenv = self.shellenv.clone();
		shellenv.clear_pos_parameters();
		if let NdType::Subshell { mut body, mut argv } = node.nd_type {
			let mut c_argv = vec![CString::new("subshell").unwrap()];
			while let Some(tk) = argv.pop_front() {
				let c_arg = CString::new(tk.text()).unwrap();
				c_argv.push(c_arg);
			}
			if !body.starts_with("#!") {
				let interpreter = std::env::current_exe().unwrap();
				let mut shebang = "#!".to_string();
				shebang.push_str(interpreter.to_str().unwrap());
				shebang.push('\n');
				shebang.push_str(&body);
				body = shebang;
			} else if body.starts_with("#!") && !body.contains('/') {
				let mut command = String::new();
				let mut body_chars = body.chars().collect::<VecDeque<char>>();
				body_chars.pop_front(); body_chars.pop_front(); // Skip the '#!'
				while let Some(ch) = body_chars.pop_front() {
					if matches!(ch, ' ' | '\t' | '\n' | ';') {
						while body_chars.front().is_some_and(|ch| matches!(ch, ' ' | '\t' | '\n' | ';')) {
							body_chars.pop_front();
						}
						body = body_chars.iter().collect::<String>();
						break
					} else {
						command.push(ch);
					}
				}
				if let Some(path) = helper::which(self.shellenv,&command) {
					let path = format!("{}{}{}","#!",path,'\n');
					body = format!("{}{}",path,body);
				}
			}
			// Step 1: Create a pipe
			let memfd = RustFd::new_memfd("subshell", true)?;
			memfd.write(body.as_bytes())?;
			io.backup_fildescs()?;
			io.do_plumbing()?;

			if in_pipe {
				let mut open_fds: VecDeque<RustFd> = VecDeque::new();
				if !redirs.is_empty() {
					open_fds.extend(self.handle_redirs(redirs)?);
				}
				let fd_path = format!("/proc/self/fd/{}", memfd);
				let fd_path = CString::new(fd_path).unwrap();
				let env = shellenv.get_cvars();
				execve(&fd_path, &c_argv, &env).unwrap();
			} else {
				match unsafe { fork() } {
					Ok(ForkResult::Child) => {
						let mut open_fds: VecDeque<RustFd> = VecDeque::new();
						if !redirs.is_empty() {
							open_fds.extend(self.handle_redirs(redirs)?);
						}
						let fd_path = format!("/proc/self/fd/{}", memfd);
						let fd_path = CString::new(fd_path).unwrap();
						let env = shellenv.get_cvars();
						execve(&fd_path, &c_argv, &env).unwrap();
						unreachable!();
					}
					Ok(ForkResult::Parent { child }) => {
						io.restore_fildescs()?;
						nix::sys::wait::waitpid(child, None).unwrap();
					}
					Err(_) => {}
				}
			}
		} else { unreachable!() }
		Ok(RshWaitStatus::new())
	}


	fn handle_pipeline(&mut self, node: Node, io: ProcIO) -> Result<RshWaitStatus, ShellError> {
		// Step 1: Flatten the pipeline tree into a sequential list
		let mut flattened_pipeline;
		if let NdType::Pipeline { ref left, ref right, .. } = node.nd_type {
			flattened_pipeline = helper::flatten_pipeline(*left.clone(), *right.clone(), VecDeque::new());
		} else {
			unreachable!(); // Only call handle_pipeline with pipeline nodes
		}

		// Here we are checking to see if the final token of the final command is a background '&' operator
		let background = flattened_pipeline.back()
			.is_some_and(|node| node.flags.contains(NdFlags::BACKGROUND));

		let span = node.span();

		// Step 2: Iterate through the flattened pipeline
		let mut prev_read_pipe: Option<RustFd> = None; // Previous read pipe
		let mut last_status = Ok(RshWaitStatus::new());
		let mut pgid: Option<Pid> = None;
		let mut cmds = vec![];
		let mut pids = vec![];

		while let Some(command) = flattened_pipeline.pop_front() {
			// Create a new pipe for this command, except for the last one
			let (r_pipe, mut w_pipe) = if !flattened_pipeline.is_empty() {
				let (r_pipe, w_pipe) = RustFd::pipe()?;
				(Some(r_pipe),Some(w_pipe))
			} else {
				(None, None) // Last command doesn't need a pipe
			};


			let argv = command.get_argv()?;
			if let NdType::Subshell {..} = command.nd_type {
				// We are in a subshell
				cmds.push("subshell".into());
			} else {
				let cmd_name = argv.first().unwrap().text().to_string();
				cmds.push(cmd_name);
			}


			// Set up IO for the current command
			let current_io = ProcIO::from(
				prev_read_pipe.take().map(|pipe| pipe.mk_shared()), // stdin from the previous pipe
				w_pipe.take().map(|pipe| pipe.mk_shared()), // stdout to the write pipe
				io.stderr.clone(),                           // Shared stderr
			);

			// Fork the process for this command
			match unsafe { fork() } {
				Ok(ForkResult::Child) => {
					// In the child process
					if let Some(mut read_pipe) = prev_read_pipe {
						read_pipe.close()?; // Close the previous read pipe
					}
					if let Some(ref mut write_pipe) = w_pipe {
						write_pipe.close()?; // Close the current write pipe
					}
					self.walk(command, current_io, true)?;
					std::process::exit(0);
				}
				Ok(ForkResult::Parent { child }) => {
					// In the parent process

					pids.push(child);
					if let Some(mut read_pipe) = prev_read_pipe {
						read_pipe.close()?; // Close the previous read pipe in the parent
					}
					if let Some(mut write_pipe) = w_pipe {
						write_pipe.close()?; // Close the current write pipe in the parent
					}

					if pgid.is_none() {
						pgid = Some(child)
					}
					setpgid(child, pgid.unwrap()).map_err(|_| ShellError::from_internal("Failed to set pgid in pipeline"))?;

					// Update the read pipe for the next command
					prev_read_pipe = r_pipe;

					// Wait for the child process if it's the last command
					if flattened_pipeline.is_empty() {
						if background {
							self.shellenv.new_job(pids,cmds,pgid.unwrap());
							return last_status;
						}
						last_status = match waitpid(child, None) {
							Ok(WaitStatus::Exited(_, code)) => match code {
								0 => Ok(RshWaitStatus::Success { span }),
								_ => Ok(RshWaitStatus::Fail { code, cmd: None, span }),
							},
							Ok(WaitStatus::Signaled(_, signal, _)) => {
								Ok(RshWaitStatus::Fail { code: 128 + signal as i32, cmd: None, span })
							}
							Ok(_) => Err(ShellError::from_execf("Unexpected waitpid result in pipeline", 1, span)),
							Err(err) => Err(ShellError::from_execf(&format!("Pipeline waitpid failed: {}", err), 1, span)),
						};
					}
				}
				Err(e) => {
					return Err(ShellError::from_execf(
							"Execution failed in pipeline",
							e.to_string().parse::<i32>().unwrap_or(1),
							span,
					));
				}
			}
		}

		// Step 3: Return the status of the last command
		last_status
	}

	fn handle_function(&mut self, node: Node, io: ProcIO, in_pipe: bool) -> Result<RshWaitStatus,ShellError> {
		let node_span = node.span();
		if let NdType::Command { mut argv } | NdType::Builtin { mut argv } = node.nd_type {
			let func_name = argv.pop_front().unwrap();
			let mut pos_params = vec![];
			while let Some(token) = argv.pop_front() {
				pos_params.push(token.text().to_string())
			}
			// Unwrap is safe here because we checked for Some() in self.walk()
			let mut func = self.shellenv.get_function(func_name.text()).unwrap();
			for redir in node.redirs {
				func.redirs.push_back(redir.clone());
			}
			let saved_parameters = self.shellenv.parameters.clone();
			self.shellenv.clear_pos_parameters();
			for (index,param) in pos_params.into_iter().enumerate() {
				self.shellenv.set_parameter((index + 1).to_string(), param);
			}
			let mut sub_walker = NodeWalker::new(*func.clone(), self.shellenv);

			// Returns exit status or shell error
			let mut result = sub_walker.walk_root(*func, None, io,in_pipe);
			if let Err(ref mut e) = result {
				// Use the span of the function call rather than the stuff inside the function
				*e = e.overwrite_span(node_span)
			}
			self.shellenv.parameters = saved_parameters;
			result
		} else { unreachable!() }
	}


	fn handle_command(&mut self, mut node: Node, mut io: ProcIO, in_pipe: bool) -> Result<RshWaitStatus, ShellError> {
		let argv = expand::expand_arguments(self.shellenv, &mut node)?;
		let argv = argv
			.iter()
			.map(|arg| CString::new(arg.text()).unwrap())
			.collect::<Vec<CString>>();
		let redirs = node.get_redirs()?;
		let span = node.span();
		// Let's expand aliases here
		if let NdType::Command { ref argv } = node.nd_type {
			// If the shellenv is allowing aliases, and the token is not from an expanded alias
			if !argv.front().unwrap().flags().contains(WdFlags::FROM_ALIAS) {
				let node = expand::expand_alias(self.shellenv, node.clone())?;

				if !matches!(node.nd_type, NdType::Command {..}) {
					// If the resulting alias expansion does not return this node
					// then walk the resulting sub-tree
					return self.walk_root(node, None, io,in_pipe)
				}
			}
			// Check if autocd is enabled
			if self.shellenv.shopts.get("autocd").is_some_and(|opt| *opt > 0) && argv.len() == 1 {
				// Check if argv[0] looks like a path, and exists at a path
				let path_candidate = argv.front().unwrap();
				let is_relative_path = path_candidate.text().starts_with('.');
				let contains_slash = path_candidate.text().contains('/');
				let path_exists = Path::new(path_candidate.text()).is_dir();

				if (is_relative_path || contains_slash) && path_exists {
					// Produce a new Builtin {..} node with cd as the command, and call self.walk() on it
					let cd_token = Tk::new("cd".into(),span,path_candidate.flags());
					let mut autocd_argv = argv.clone();
					autocd_argv.push_front(cd_token);
					let autocd = Node {
						nd_type: NdType::Builtin { argv: autocd_argv },
						span,
						flags: node.flags,
						redirs: node.redirs
					};
					return self.walk(autocd, io,in_pipe)

				}
			}
		}
		io.backup_fildescs()?; // Save original stdin, stdout, and stderr
		io.do_plumbing()?; // Route pipe logic using fildescs

		// Prepare the execvpe arguments
		let cmd = argv[0].clone().into_string().unwrap();
		let command = &argv[0];
		let envp = self.shellenv.get_cvars();

		// Now let's tell the child process what to do
		let child_instruction = || -> Result<(),ShellError> {
			// Handle redirections
			let mut open_fds: VecDeque<RustFd> = VecDeque::new();
			if !redirs.is_empty() {
				open_fds.extend(self.handle_redirs(redirs.clone().into())?);
			}

			// Execute the command
			let Err(_) = execvpe(command, &argv, &envp);
			std::process::exit(127);
		};
		if in_pipe {
			// We are currently in a child process,
			// So we will execute the instructions here
			child_instruction()?;
			unreachable!() // If the thread returns, something has gone horribly wrong
		} else {
			match unsafe { fork() } {
				Ok(ForkResult::Child) => {
					child_instruction()?;
					unreachable!()
				}
				Ok(ForkResult::Parent { child }) => {
					if node.flags.contains(NdFlags::BACKGROUND) {
						// Background job logic
						// Set process group id here
						setpgid(child, child).map_err(|_| ShellError::from_io())?;
						// Add job to the job table
						self.shellenv.new_job(vec![child], vec![cmd], child);
						// Restore saved file descriptors
						io.restore_fildescs()?;
						Ok(RshWaitStatus::Success { span })
					} else {
						// Foreground job logic
						// Here we get a lock on the current stdin file descriptor
						let stdin_fd = &io.try_clone().stdin.unwrap_or(RustFd::from_stdin().unwrap().mk_shared());
						let stdin_fd = stdin_fd.lock().unwrap();

						//And then get the pgid of rsh
						let self_pid = getpid();
						let self_pgid = getpgid(Some(self_pid)).map_err(|_| ShellError::from_io())?;

						// Now surrender control of the terminal to the child process
						// Required for interactive programs, i.e. running another shell program
						unsafe { tcsetpgrp(stdin_fd.as_raw_fd(), child.into()) };
						let status = match waitpid(child, None) {
							Ok(WaitStatus::Exited(_, code)) => match code {
								0 => Ok(RshWaitStatus::Success { span }),
								_ => Ok(RshWaitStatus::Fail { code, cmd: Some(cmd), span }),
							},
							Ok(WaitStatus::Signaled(_,signal,_)) => {
								Ok(RshWaitStatus::Signaled { sig: signal })
							}
							Ok(_) => Err(ShellError::from_execf("Unexpected waitpid result", 1, span)),
							Err(err) => Err(ShellError::from_execf(&format!("Waitpid failed: {}", err), 1, span)),
						};

						// Regain control of the terminal after child process ends
						unsafe { tcsetpgrp(stdin_fd.as_raw_fd(), self_pgid.into()) };

						// Drop the lock on the stdin file descriptor
						drop(stdin_fd);

						// Restore saved file descriptors
						io.restore_fildescs()?;

						// Return wait status
						status
					}
				}
				Err(_) => Err(ShellError::from_io())
			}
		}
	}
}
