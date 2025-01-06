//pub mod event;
//pub mod prompt;
//pub mod parser;
//mod rsh;
//
//use log::debug;
//
//use tokio::io::{self, AsyncBufReadExt, BufReader};
//use tokio_stream::{wrappers::LinesStream, StreamExt};
//
//use crate::event::EventLoop;
//
//#[tokio::main]
//async fn main() {
//env_logger::init();
//let mut event_loop = EventLoop::new();
//
//debug!("Starting event loop");
//TODO: use the value returned by this for something
//let _ = event_loop.listen().await;
//}


pub mod prompt;
pub mod event;
pub mod execute;
pub mod shellenv;
pub mod interp;
pub mod builtin;
pub mod comp;

use std::{env, fs::File, io::Read, os::fd::{AsFd, BorrowedFd}};

use event::{EventLoop, ShellError, ShellErrorFull};
use execute::{NodeWalker, RshWaitStatus};
use interp::parse::descend;
use libc::STDERR_FILENO;
use log::info;
use nix::unistd::write;
use shellenv::EnvFlags;

//use crate::event::EventLoop;
use crate::shellenv::ShellEnv;


#[tokio::main]
async fn main() {
	let args = env::args().collect::<Vec<String>>();

	let mut shellenv = ShellEnv::new(EnvFlags::empty());
	if args[0].starts_with('-') {
		shellenv.source_profile().ok();
	}
	match args.len() {
		1 => {
			shellenv.set_flags(EnvFlags::INTERACTIVE);
			main_interactive(shellenv).await;
		},
		_ => {
			main_noninteractive(args,shellenv).await;
		}
	}

}



async fn main_noninteractive(args: Vec<String>, mut shellenv: ShellEnv) {
	let stderr = unsafe { BorrowedFd::borrow_raw(STDERR_FILENO) };
	let mut pos_params: Vec<String> = vec![];
	let input;

	// Input Handling
	if args[1] == "-c" {
		if args.len() < 3 {
			write(stderr.as_fd(), b"Expected a command after '-c' flag\n").unwrap();
			return;
		}
		input = args[2].clone(); // Store the command string
	} else {
		let script_name = &args[1];
		if args.len() > 2 {
			pos_params = args[2..].to_vec();
		}
		let file = File::open(script_name);
		match file {
			Ok(mut script) => {
				let mut buffer = vec![];
				if let Err(e) = script.read_to_end(&mut buffer) {
					write(stderr.as_fd(), format!("Error reading file: {}\n", e).as_bytes()).unwrap();
					return;
				}
				input = String::from_utf8_lossy(&buffer).to_string(); // Convert file contents to String
			}
			Err(e) => {
				write(stderr.as_fd(), format!("Error opening file: {}\n", e).as_bytes()).unwrap();
				return;
			}
		}
	}

	// Code Execution Logic
	shellenv.set_last_input(&input);
	for (index,param) in pos_params.into_iter().enumerate() {
		let key = format!("{}",index + 1);
		shellenv.set_parameter(key, param);
	}
	let state = descend(&input, &shellenv);
	match state {
		Ok(parse_state) => {
			let mut walker = NodeWalker::new(parse_state.ast, &mut shellenv);
			match walker.start_walk() {
				Ok(code) => {
					info!("Last exit status: {:?}", code);
					if let RshWaitStatus::Fail { code, cmd, span } = code {
						if code == 127 {
							if let Some(cmd) = cmd {
								let err = ShellErrorFull::from(shellenv.get_last_input(),ShellError::from_no_cmd(&cmd, span));
								write(stderr, format!("{}", err).as_bytes()).unwrap();
							}
						}
					}
				}
				Err(e) => {
					let err = ShellErrorFull::from(shellenv.get_last_input(),e);
					write(stderr.as_fd(), format!("{}", err).as_bytes()).unwrap();
				}
			}
		}
		Err(e) => {
			let err = ShellErrorFull::from(shellenv.get_last_input(),e);
			write(stderr.as_fd(), format!("{}", err).as_bytes()).unwrap();
		}
	}
}

async fn main_interactive(mut shellenv: ShellEnv) {
	env_logger::init();
	let mut event_loop = EventLoop::new(&mut shellenv);
	let _ = event_loop.listen().await;
}

//#[tokio::main]
//async fn main() {
//env_logger::init();
//loop {
//let mut stdout = io::stdout();
//stdout.write_all(b"> ").await.unwrap();
//stdout.flush().await.unwrap();
//
//let stdin = io::stdin();
//let mut reader = BufReader::new(stdin);
//
//let mut input = String::new();
//reader.read_line(&mut input).await.unwrap();
//
//let trimmed_input = input.trim().to_string();
//trace!("Received input! {}",trimmed_input);
//let shellenv = ShellEnv::new(false,false);
//let state = descend(&input,&shellenv);
//if let Err(e) = state {
//println!("{}",e);
//} else {
//println!("debug tree:");
//println!("{}",state.unwrap().ast);
//}
//}
//}
