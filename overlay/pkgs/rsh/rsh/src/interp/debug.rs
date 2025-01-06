use std::fmt;

use crate::interp;
use interp::parse::{NdType,Node};

impl fmt::Display for Node {
	fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
		fn write_tree(node: &Node, f: &mut fmt::Formatter<'_>, indent: usize) -> fmt::Result {
			let prefix = "|   ".repeat(indent);
			writeln!(f, "{}Node (span: {:?})", prefix, node.span)?;

			match &node.nd_type {
				NdType::Root { deck } => {
					writeln!(f, "{}Root", prefix)?;
					for node in deck {
						write_tree(node, f, indent + 1)?;
					}
				}
				NdType::If { cond_blocks, else_block } => {
					writeln!(f, "{}If", prefix)?;
					for block in cond_blocks {
						writeln!(f, "{}|--- Condition", prefix)?;
						write_tree(&block.condition, f, indent + 2)?;
						writeln!(f, "{}|--- Body", prefix)?;
						write_tree(&block.body, f, indent + 2)?;
					}
					if let Some(else_block) = else_block {
						writeln!(f, "{}|--- Else", prefix)?;
						write_tree(else_block, f, indent + 1)?;
					}
				}
				NdType::For { loop_vars, loop_arr, loop_body } => {
					let var_texts: Vec<_> = loop_vars.iter().map(|var| var.text()).collect();
					let arr_texts: Vec<_> = loop_arr.iter().map(|arr| arr.text()).collect();
					writeln!(f, "{}For", prefix)?;
					writeln!(f, "{}|--- Loop Vars: {:?}", prefix, var_texts)?;
					writeln!(f, "{}|--- Loop Array: {:?}", prefix, arr_texts)?;
					writeln!(f, "{}|--- Body", prefix)?;
					write_tree(loop_body, f, indent + 1)?;
				}
				NdType::Loop { condition, logic } => {
					writeln!(f, "{}Loop (condition: {})", prefix, condition)?;
					writeln!(f, "{}|--- Condition", prefix)?;
					write_tree(&logic.condition, f, indent + 1)?;
					writeln!(f, "{}|--- Body", prefix)?;
					write_tree(&logic.body, f, indent + 1)?;
				}
				NdType::Case { input_var, cases } => {
					writeln!(f, "{}Case (input: {:?})", prefix, input_var.text())?;
					for case in cases {
						writeln!(f, "{}|--- Pattern: {:?}", prefix, case.0)?;
						write_tree(case.1, f, indent + 1)?;
					}
				}
				NdType::Select { select_var, opts, body } => {
					let opts_texts: Vec<_> = opts.iter().map(|opt| opt.text()).collect();
					writeln!(
						f,
						"{}Select (input: {:?}, options: {:?})",
						prefix, select_var.text(), opts_texts
					)?;
					write_tree(body, f, indent + 1)?;
				}
				NdType::Pipeline { left, right, both: _ } => {
					writeln!(f, "{}Pipeline", prefix)?;
					writeln!(f, "{}|--- Left", prefix)?;
					write_tree(left, f, indent + 1)?;
					writeln!(f, "{}|--- Right", prefix)?;
					write_tree(right, f, indent + 1)?;
				}
				NdType::Chain { left, right, op } => {
					writeln!(f, "{}Chain (operator span: {:?})", prefix, op.span)?;
					writeln!(f, "{}|--- Left", prefix)?;
					write_tree(left, f, indent + 1)?;
					writeln!(f, "{}|--- Right", prefix)?;
					write_tree(right, f, indent + 1)?;
				}
				NdType::BraceGroup { body } => {
					writeln!(f, "{}BraceGroup", prefix)?;
					write_tree(body, f, indent + 1)?;
				}
				NdType::Subshell { body, argv: _ } => {
					writeln!(f, "{}Subshell (body: {:?})", prefix, body)?;
				}
				NdType::FuncDef { name, body } => {
					writeln!(f, "{}Function Definition (name: {})", prefix, name)?;
					write_tree(body, f, indent + 1)?;
				}
				NdType::Assignment { name, value } => {
					writeln!(f, "{}Assignment (name: {}, value: {:?})", prefix, name, value)?;
				}
				NdType::Command { argv } | NdType::Builtin { argv } => {
					let argv_texts: Vec<_> = argv.iter().map(|arg| arg.text()).collect();
					writeln!(
						f,
						"{}Command (args: {:?})",
						prefix, argv_texts
					)?;
				}
				NdType::And => {
					writeln!(f, "{}And", prefix)?;
				}
				NdType::Or => {
					writeln!(f, "{}Or", prefix)?;
				}
				NdType::Redirection { .. } => {
					writeln!(f, "{}Redir", prefix)?;
				}
				NdType::Pipe => {
					writeln!(f, "{}Pipe", prefix)?;
				}
				NdType::PipeBoth => {
					writeln!(f, "{}PipeBoth", prefix)?;
				}
				NdType::Cmdsep => {
					writeln!(f, "{}Cmdsep", prefix)?;
				}
				NdType::NullNode => panic!()
			}
			Ok(())
		}

		write_tree(self, f, 0)
	}
}
