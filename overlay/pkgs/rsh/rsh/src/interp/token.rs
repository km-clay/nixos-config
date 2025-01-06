use bitflags::bitflags;
use once_cell::sync::Lazy;
use log::trace;
use regex::Regex;
use std::collections::HashMap;
use std::collections::VecDeque;
use std::io;
use std::mem::take;

use crate::interp::parse::Span;
use crate::event::ShellError;

use super::helper::StrExtension;

pub static REGEX: Lazy<HashMap<&'static str, Regex>> = Lazy::new(|| {
	let mut regex = HashMap::new();
	regex.insert("redirection",Regex::new(r"^(?P<fd_out>[0-9]+)?(?P<operator>>{1,2}|<{1,3})(?:[&]?(?P<fd_target>[0-9]+))?$").unwrap());
	regex.insert("rsh_shebang",Regex::new(r"^#!((?:/[^\s]+)+)((?:\s+arg:[a-zA-Z][a-zA-Z0-9_\-]*)*)$").unwrap());
	regex.insert("brace_expansion",Regex::new(r"(\$?)\{(?:[\x20-\x7e,]+|[0-9]+(?:\.\.[0-9+]){1,2}|[a-z]\.\.[a-z]|[A-Z]\.\.[A-Z])\}").unwrap());
	regex.insert("process_sub",Regex::new(r"^>\(.*\)$").unwrap());
	regex.insert("command_sub",Regex::new(r"^\$\([^\)]+\)$").unwrap());
	regex.insert("arithmetic",Regex::new(r"^\$\(\([^\)]+\)\)$").unwrap());
	regex.insert("subshell",Regex::new(r"^\([^\)]+\)$").unwrap());
	regex.insert("test",Regex::new(r"^\[\s*(.*?)\s*\]$").unwrap());
	regex.insert("sng_string",Regex::new(r#"^\'([^\']*)\'$"#).unwrap());
	regex.insert("dub_string",Regex::new(r#"^\"([^\"]*)\"$"#).unwrap());
	regex.insert("var_sub",Regex::new(r"\$(?:([A-Za-z_][A-Za-z0-9_]*)|\{([A-Za-z_][A-Za-z0-9_]*)\})").unwrap());
	regex.insert("assignment",Regex::new(r"^[A-Za-z_][A-Za-z0-9_]*=.*$").unwrap());
	regex.insert("funcdef",Regex::new(r"^[\x20-\x7E]*\(\)\s+\{[\s\S]*?\}").unwrap());
	regex.insert("operator",Regex::new(r"(?:&&|\|\||[><]=?|[|&])").unwrap());
	regex.insert("cmdsep",Regex::new(r"^(?:\n|;)$").unwrap());
	regex.insert("ident",Regex::new(r"^[\x20-\x7E]*$").unwrap());
	regex
});

pub const KEYWORDS: [&str;14] = [
	"if", "while", "until", "for", "case", "select",
	"then", "elif", "else", "in",
	"do", "done", "fi", "esac"
];
pub const OPENERS: [&str;6] = [
	"if", "while", "until", "for", "case", "select",
];
pub const BUILTINS: [&str; 22] = [
	"echo", "jobs", "unset", "fg", "bg", "set", "builtin", "test", "[", "shift", "alias", "export", "cd", "readonly", "declare", "local", "unset", "trap", "node", "exec", "source", "wait",
];
pub const CMDSEP: [char;2] = [
	';', '\n'
];
pub const WHITESPACE: [char;2] = [
	' ', '\t'
];

bitflags! {
	#[derive(Debug,Clone,Copy,PartialEq,Eq)]
	pub struct FnFlags: u32 {
		const RECURSE = 0b0001;
	}
	#[derive(Debug,Hash,Clone,Copy,PartialEq,Eq)]
	pub struct WdFlags: u32 {
		const KEYWORD =    0b000000000000000001;
		const BUILTIN =    0b000000000000000010;
		const FUNCTION =   0b000000000000000100;
		const ALIAS =      0b000000000000001000;
		const IS_ARG =     0b000000000000010000;
		const DUB_QUOTED = 0b000000000000100000;
		const SNG_QUOTED = 0b000000000001000000;
		const IN_BRACE =   0b000000000010000000;
		const IN_PAREN =   0b000000000100000000;
		const IS_SUB =     0b000000001000000000;
		const IS_OP =      0b000000010000000000;
		const EXPECT_IN =  0b000000100000000000;
		const IS_PATH =    0b000001000000000000;
		const FROM_ALIAS = 0b000010000000000000;
		const FROM_FUNC  = 0b000100000000000000;
		const FROM_VAR   = 0b001000000000000000;
	}
	}

macro_rules! define_expectations {
	($($name:expr => $pattern:expr),* $(,)?) => {{
		use crate::interp::token::TkState::*;
		let mut m = HashMap::new();
		$(m.insert($name, $pattern);)*
			m
	}};
}

#[derive(Debug,Hash,Clone,PartialEq,Eq)]
pub struct WordDesc {
	pub text: String,
	pub span: Span,
	pub flags: WdFlags
}

impl WordDesc {
	pub fn empty() -> Self {
		Self {
			text: String::new(),
			span: Span::new(),
			flags: WdFlags::empty()
		}
	}
	pub fn set_span(self, span: Span) -> Self {
		Self {
			text: self.text,
			span,
			flags: self.flags
		}
	}
	pub fn add_char(&mut self, ch: char) -> Self {
		trace!("cloning text: {}",self.text);
		let mut text = std::mem::take(&mut self.text);
		trace!("cloned text: {}",text);
		trace!("pushing char: {}",ch);
		text.push(ch);
		trace!("after pushing: {}",text);

		Self {
			text,
			span: Span::from(self.span.start, self.span.end),
			flags: self.flags,
		}
	}
	pub fn cat_string(mut self, s: &str) -> Self {
		self.text.push_str(s);
		Self {
			text: self.text,
			span: Span::from(self.span.start, self.span.end + 1),
			flags: self.flags
		}
	}
	pub fn contains_flag(&self, flag: WdFlags) -> bool {
		self.flags.contains(flag)
	}

	pub fn add_flag(self, flag: WdFlags) -> Self {
		let mut flags = self.flags;
		flags |= flag;
		let new = Self {
			text: self.text,
			span: self.span,
			flags
		};
		trace!("added flag: {:?}, new flags {:?}",flag,new.flags);
		new
	}

	pub fn remove_flag(self, flag: WdFlags) -> Self {
		let mut flags = self.flags;
		flags &= !flag;
		Self {
			text: self.text,
			span: self.span,
			flags
		}
	}

	pub fn toggle_flag(self, flag: WdFlags) -> Self {
		let mut flags = self.flags;
		flags ^= flag;
		Self {
			text: self.text,
			span: self.span,
			flags
		}
	}
	pub fn reset_flags(self) -> Self {
		Self {
			text: self.text,
			span: self.span,
			flags: WdFlags::empty()
		}
	}
	pub fn push_span(&mut self, count: usize) {
		self.span = Span::from(self.span.start,self.span.end + count);
	}
	pub fn push_span_start(&mut self, count: usize) {
		let mut span_start = self.span.start;
		let mut span_end = self.span.end;
		span_start += count;
		if span_end < span_start {
			span_end = span_start
		}
		self.span = Span::from(span_start,span_end);
	}
	pub fn delimit(self, delim: char) -> Self {
		let flag = match delim {
			'{' => WdFlags::IN_BRACE,
			'(' => WdFlags::IN_PAREN,
			_ => unreachable!()
		};
		self.add_flag(flag)
	}
}

impl Default for WordDesc {
	fn default() -> Self {
	    Self::empty()
	}
}

#[derive(Debug,Hash,Clone,PartialEq,Eq)]
pub struct Tk {
	pub tk_type: TkType,
	pub wd: WordDesc
	}

#[derive(Debug,Hash,Clone,PartialEq,Eq)]
pub enum TkType {
	// Control Flow Keywords
	If,
	Then,
	Else,
	Elif,
	Fi,
	For,
	While,
	Until,
	Do,
	Done,
	Case,
	Esac,
	Select,
	In,
	FuncBody,

	Redirection { redir: Redir },
	FuncDef,
	Assignment, // `=`
	LogicAnd, // `&&`
	LogicOr, // `||`
	Pipe, // `|`
	PipeBoth, // '|&'
	Background, // `&`

	// Grouping and Subshells
	ProcessSub,
	Subshell, // `(`
	Array { elements: Vec<Tk> },
	Vars { vars: Vec<Tk> },

	// Strings and Identifiers
	String, // Generic string literal
	Ident,  // Identifier for variables, functions, etc.
	Expanded, // Token from an expansion

	// Expansions
	BraceExpansion,
	VariableSub, // `$var`, `${var}`
	CommandSub, // `$(command)`

	// Comments
	Comment, // `#`

	// Special Characters
	Cmdsep, // ';' or '\n'
	CasePat,
	Whitespace, // Space or tab
	SOI,
	EOI,

}

impl Tk {
	pub fn new(text: String, span: Span, flags: WdFlags) -> Self {
		Self {
			tk_type: TkType::String,
			wd: WordDesc {
				text,
				span,
				flags
			}
		}
	}
	pub fn from(mut wd: WordDesc, context: TkState) -> Result<Self,ShellError> {
		use crate::interp::token::TkState::*;
		use crate::interp::token::TkType as TkT;
		match context {
			Root => panic!("not supposed to be here"),
			Ident => Ok(Tk { tk_type: TkT::Ident, wd }),
			Arg => Ok(Tk { tk_type: TkT::Ident, wd: wd.add_flag(WdFlags::IS_ARG) }),
			Command => Ok(Tk { tk_type: TkT::Ident, wd }),
			Array => Ok(Tk { tk_type: TkT::Array { elements: vec![] }, wd }),
			If => Ok(Tk { tk_type: TkT::If, wd: wd.add_flag(WdFlags::KEYWORD) }),
			For => Ok(Tk { tk_type: TkT::For, wd: wd.add_flag(WdFlags::KEYWORD) }),
			Loop => Ok({
				if wd.text == "while" {
					Tk { tk_type: TkT::While, wd: wd.add_flag(WdFlags::KEYWORD) }
				} else if wd.text == "until" {
					Tk { tk_type: TkT::Until, wd: wd.add_flag(WdFlags::KEYWORD) }
				} else { unreachable!("reached loop context with this: {}",wd.text) }
			}),
			Case => Ok(Tk { tk_type: TkT::Case, wd: wd.add_flag(WdFlags::KEYWORD) }),
			Select => Ok(Tk { tk_type: TkT::Select, wd: wd.add_flag(WdFlags::KEYWORD) }),
			In | CaseIn => Ok(Tk { tk_type: TkT::In, wd: wd.add_flag(WdFlags::KEYWORD) }),
			CasePat => Ok(Tk { tk_type: TkT::Ident, wd }),
			Elif => Ok(Tk { tk_type: TkT::Elif, wd: wd.add_flag(WdFlags::KEYWORD) }),
			Else => Ok(Tk { tk_type: TkT::Else, wd: wd.add_flag(WdFlags::KEYWORD) }),
			Do => Ok(Tk { tk_type: TkT::Do, wd: wd.add_flag(WdFlags::KEYWORD) }),
			Then => Ok(Tk { tk_type: TkT::Then, wd: wd.add_flag(WdFlags::KEYWORD) }),
			Done => Ok(Tk { tk_type: TkT::Done, wd: wd.add_flag(WdFlags::KEYWORD) }),
			Fi => Ok(Tk { tk_type: TkT::Fi, wd: wd.add_flag(WdFlags::KEYWORD) }),
			Esac => Ok(Tk { tk_type: TkT::Esac, wd: wd.add_flag(WdFlags::KEYWORD) }),
			Subshell => Ok(Tk { tk_type: TkT::Subshell, wd }),
			SQuote => Ok(Tk { tk_type: TkT::String, wd }),
			DQuote => Ok(Tk { tk_type: TkT::String, wd }),
			Redirect => todo!(),
			CommandSub => Ok(Tk { tk_type: TkT::CommandSub, wd }),
			Separator => Ok(Tk { tk_type: TkT::Cmdsep, wd }),
			_ => return Err(ShellError::from_parse(format!("Parse error: {}", wd.text).as_str(), wd.span))
		}
	}
	pub fn start_of_input() -> Self {
		Tk {
			tk_type: TkType::SOI,
			wd: WordDesc { text: "".into(), span: Span::from(0,0), flags: WdFlags::empty() }
		}
	}
	pub fn end_of_input(end: usize) -> Self {
		Tk {
			tk_type: TkType::EOI,
			wd: WordDesc { text: "".into(), span: Span::from(end,end), flags: WdFlags::empty() }
		}
	}
	pub fn cmdsep(wd: &WordDesc, pos: usize) -> Self {
		Tk {
			tk_type: TkType::Cmdsep,
			wd: WordDesc { text: wd.text.clone(), span: Span::from(pos + 1,pos + 1), flags: WdFlags::empty() }
		}
	}
	fn get_keyword_token(wd: &WordDesc) -> Result<TkType,ShellError> {
		let text = wd.text.clone();
		match text.as_str() {
			"if" => Ok(TkType::If),
			"elif" => Ok(TkType::Elif),
			"else" => Ok(TkType::Else),
			"then" => Ok(TkType::Then),
			"fi" => Ok(TkType::Fi),
			"for" => Ok(TkType::For),
			"while" => Ok(TkType::While),
			"until" => Ok(TkType::Until),
			"do" => Ok(TkType::Do),
			"done" => Ok(TkType::Done),
			"case" => Ok(TkType::Case),
			"esac" => Ok(TkType::Esac),
			"select" => Ok(TkType::Select),
			"in" => Ok(TkType::In),
			_ => Err(ShellError::from_parse(format!("Unrecognized keyword: {}",wd.text).as_str(), wd.span))
		}
	}
	fn split_func(wd: &WordDesc) -> Result<TkType,ShellError> {
		let func_raw = &wd.text;
		let (mut name,mut body) = func_raw.split_once(' ').unwrap();
		name = name.trim();
		body = body.trim();
		if name.ends_with("()") {
			name = name.strip_suffix("()").unwrap();
			name = name.trim();
		}
		if body.starts_with('{') && body.ends_with('}') {
			body = body.strip_prefix('{').unwrap();
			body = body.strip_suffix('}').unwrap();
			body = body.trim();
		} else {
			return Err(ShellError::from_internal(format!("This body made it to split_func with no surrounding braces: {}",body).as_str()));
		}

		Ok(TkType::FuncDef)
	}
	fn get_operator_type(word_desc: &WordDesc) -> TkType {
		match word_desc.text.as_str() {
			"|&" => TkType::PipeBoth,
			"&" => TkType::Background,
			"&&" => TkType::LogicAnd,
			"||" => TkType::LogicOr,
			"|" => TkType::Pipe,
			_ => unreachable!()
		}
	}
	pub fn text(&self) -> &str {
		self.wd.text.as_str()
	}
	pub fn span(&self) -> Span {
		self.wd.span
	}
	pub fn class(&self) -> TkType {
		self.tk_type.clone()
	}
	pub fn flags(&self) -> WdFlags {
		self.wd.flags
	}
}


#[derive(Debug,Hash,Clone,PartialEq,Eq)]
pub struct Redir {
	pub fd_source: i32,
	pub op: RedirType,
	pub fd_target: Option<i32>,
	pub file_target: Option<Box<Tk>>
}

#[derive(Debug,Hash,Clone,PartialEq,Eq)]
pub enum RedirType {
	Output,
	Append,
	Input,
	Heredoc,
	Herestring
}


#[derive(Eq,Hash,PartialEq)]
pub enum TkState {
	Root, // Outer contex, allows for anything and everything. Closed by the EOI token
	ArrDec, // Used in arrays like for i in ArrDec1 ArrDec2
	VarDec, // Used in for loop vars like for VarDec1 VarDec2 in array
	SingleVarDec, // Used in case and select
	Ident, // Generic words used for var and arr declarations
	Arg, // Command arguments; only appear after commands
	Command, // Starting point for the tokenizer
	FuncDef, // defining a function like() { this }
	FuncBody, // The stuff { inside braces }
	Array, // Used in for loops and select statements
	If, // If statement opener
	For, // For loop opener
	Loop, // While/Until opener
	Case, // Case opener
	Select, // Select opener
	In, // Used in for, case, and select statements
	CaseBlock, // this)kind of thing;;
	CaseIn, // 'In' context used for case statements, signaling the tokenizer to look for stuff 'like)this;;esac'
	CasePat, // the left side of this)kind of thing
	CaseBody, // the right side of this)kind of thing
	Elif, // Secondary if/then blocks
	Else, // Else statements
	Do, // Select, for, and while/until condition/body separator
	Then, // If statement condition/body separator
	Done, // Select, for, and while/until closer
	Fi, // If statement closer
	Esac, // Case statement closer
	Subshell, // Subshells, look (like this)
	SQuote, // 'Single quoted strings'
	DQuote, // "Double quoted strings"
	Escaped, // Used to denote an escaped character like \a
	Redirect, // >, <, <<, <<<, 1>&2, 2>, etc.
	Comment, // #Comments like this
	Whitespace, // Space or tabs
	CommandSub, // $(Command substitution)
	Operator, // operators
	Separator, // Semicolon or newline to end an invocation
	DeadEnd, // Used for closing keywords like 'fi' and 'done' that demand a separator immediately after
	Invalid // Used when an unexpected state is discovered
}

impl TkState {
	pub fn check_str(slice: &str, context: TkState) -> Self {
		use crate::interp::token::TkState::*;
		match slice {
			// Loop and conditional openers
			"for" if matches!(context, Command) => For,
			"if" if matches!(context, Command) => If,
			"while" if matches!(context, Command) => Loop,
			"until" if matches!(context, Command) => Loop,

			// Conditional separators and terminators
			"then" if matches!(context, If | Elif) => Then,
			"elif" if matches!(context, Then | Elif) => Elif,
			"else" if matches!(context, If | Then | Elif) => Else,
			"fi" if matches!(context, If | Then | Elif | Else) => Fi,

			// Loop terminators
			"do" if matches!(context, For | Loop) => Do,
			"done" if matches!(context, Do) => Done,

			// Case-specific keywords
			"case" if matches!(context, Command) => Case,
			"in" if matches!(context, Case | For | Select) => In,
			"esac" if matches!(context, CaseIn | CaseBlock | CaseBody) => Esac,

			// Select-specific keywords
			"select" if matches!(context, Command) => Select,

			// General flow control
			"in" if matches!(context, For | Case | Select) => In,
			"|" if Self::executable().contains(&context) => Operator,
			"&" if Self::executable().contains(&context) => Operator,

			// Defaults to Ident for non-keyword or unmatched cases
			_ => Ident,
		}
	}
	pub fn executable() -> Vec<Self> {
		use crate::interp::token::TkState::*;
		let mut execs = vec![
			Command,
			Subshell
		];
		execs.extend(Self::openers());
		execs
	}
	pub fn body() -> Vec<Self> {
		use crate::interp::token::TkState::*;
		vec![
			Command,
			Arg,
			Separator,
			Redirect,
			SQuote,
			DQuote,
			CommandSub,
			Subshell
		]
	}
	pub fn openers() -> Vec<Self> {
		use crate::interp::token::TkState::*;
		vec![
			For,
			Loop,
			If,
			Case,
			Select
		]
	}
}

pub struct RshTokenizer {
	input: String,
	char_stream: VecDeque<char>,
	context: TkState,
	pub tokens: Vec<Tk>,
	pub span: Span,
}

impl RshTokenizer {
	pub fn new(input: &str) -> Self {
		let input = input.trim().to_string();
		let char_stream = input.chars().collect::<VecDeque<char>>();
		let tokens = vec![Tk { tk_type: TkType::SOI, wd: WordDesc::empty() }];
		Self { input, char_stream, context: TkState::Command, tokens, span: Span::new() }
	}
	fn advance(&mut self) -> Option<char> {
		self.span.end += 1;
		self.char_stream.pop_front()
	}
	pub fn tokenize(&mut self) -> Result<(),ShellError> {
		use crate::interp::token::TkState::*;
		let mut wd = WordDesc::empty();
		while !self.char_stream.is_empty() {
			self.span.start = self.span.end;
			wd = wd.set_span(self.span);
			if self.context == DeadEnd && !matches!(self.char_stream.front().unwrap(),';' | '\n') {
				return Err(ShellError::from_parse("Expected a semicolon or newline here", self.span))
			}
			match self.char_stream.front().unwrap() {
				'\\' => {
					let escape = self.advance().unwrap();
					wd = wd.add_char(escape);
					let escaped_char = self.advance();
					if let Some(ch) = escaped_char {
						wd = wd.add_char(ch)
					}
				}
				';' | '\n' => {
					self.advance();
					self.tokens.push(Tk::cmdsep(&wd,self.span.end));
					self.context = Command;
					continue
				}
				'#' => self.context = Comment,
				'(' if self.context == Command => self.context = Subshell,
				'{' if self.context == FuncDef => self.context = FuncBody,
				'\'' if matches!(self.context, Command | Arg) => self.context = SQuote,
				'"' if matches!(self.context, Command | Arg) => self.context = DQuote,
				'$' if matches!(self.context, Command | Arg) => {
					let dollar = self.advance().unwrap();
					if self.char_stream.front().is_some_and(|ch| *ch == '(') {
						self.context = CommandSub
					}
					self.char_stream.push_front(dollar);
					self.span.end -= 1;
				}
				' ' | '\t' => {
					self.advance();
					continue
				}
				_ => { /* Do nothing */ }
			}
			match self.context {
				Command => self.command_context(take(&mut wd)),
				Arg => self.arg_context(take(&mut wd)),
				DQuote | SQuote => self.string_context(take(&mut wd)),
				VarDec => self.vardec_context(take(&mut wd))?,
				SingleVarDec => self.vardec_context(take(&mut wd))?,
				ArrDec => self.arrdec_context(take(&mut wd))?,
				Subshell | CommandSub => self.subshell_context(take(&mut wd)),
				FuncBody => self.func_context(take(&mut wd)),
				Case => self.case_context(take(&mut wd))?,
				Comment => {
					while self.char_stream.front().is_some_and(|ch| *ch != '\n') {
						self.advance();
					}
					self.advance(); // Consume the newline too
					self.context = Command
				}
				_ => unreachable!()
			}
		}
		self.tokens.push(Tk::end_of_input(self.input.len()));
		self.clean_tokens();
		Ok(())
	}
	fn command_context(&mut self, mut wd: WordDesc) {
		use crate::interp::token::TkState::*;
		wd = self.complete_word(wd);
		if wd.text.ends_with("()") {
			wd.text = wd.text.strip_suffix("()").unwrap().to_string();
			self.tokens.push(Tk { tk_type: TkType::FuncDef, wd });
			self.context = FuncDef;
		} else if KEYWORDS.contains(&wd.text.as_str()) {
			match wd.text.as_str() {
				"then" | "if" | "elif" | "else" | "do" | "while" | "until" => self.context = Command,
				"for" => self.context = VarDec,
				"case" => self.context = Case,
				"select" => self.context = Select,
				_ => self.context = DeadEnd
			}
			match wd.text.as_str() {
				"if" => self.tokens.push(Tk { tk_type: TkType::If, wd }),
				"then" => self.tokens.push(Tk { tk_type: TkType::Then, wd }),
				"elif" => self.tokens.push(Tk { tk_type: TkType::Elif, wd }),
				"else" => self.tokens.push(Tk { tk_type: TkType::Else, wd }),
				"fi" => self.tokens.push(Tk { tk_type: TkType::Fi, wd }),
				"for" => self.tokens.push(Tk { tk_type: TkType::For, wd }),
				"do" => self.tokens.push(Tk { tk_type: TkType::Do, wd }),
				"done" => self.tokens.push(Tk { tk_type: TkType::Done, wd }),
				"while" => self.tokens.push(Tk { tk_type: TkType::While, wd }),
				"until" => self.tokens.push(Tk { tk_type: TkType::Until, wd }),
				"case" => self.tokens.push(Tk { tk_type: TkType::Case, wd }),
				"select" => self.tokens.push(Tk { tk_type: TkType::Select, wd }),
				_ => unreachable!("text: {}", wd.text)
			}
		} else if matches!(wd.text.as_str(), ";" | "\n") || self.char_stream.is_empty() {
			let flags = match self.context {
				Arg => WdFlags::IS_ARG,
				Command => {
					if BUILTINS.contains(&wd.text.as_str()) {
						WdFlags::BUILTIN
					} else {
						WdFlags::empty()
					}
				}
				_ => unreachable!()
			};
			if wd.text.has_unescaped("=") {
				self.tokens.push(Tk { tk_type: TkType::Assignment, wd });
				self.context = Arg
			} else {
				self.tokens.push(Tk { tk_type: TkType::Ident, wd: wd.reset_flags().add_flag(flags) });
				self.context = Arg
			}
			self.context = Command;
		} else {
			let flags = match self.context {
				Arg => WdFlags::IS_ARG,
				Command => {
					if BUILTINS.contains(&wd.text.as_str()) {
						WdFlags::BUILTIN
					} else {
						WdFlags::empty()
					}
				}
				_ => unreachable!()
			};
			if wd.text.has_unescaped("=") {
				self.tokens.push(Tk { tk_type: TkType::Assignment, wd });
				self.context = Arg
			} else {
				self.tokens.push(Tk { tk_type: TkType::Ident, wd: wd.reset_flags().add_flag(flags) });
				self.context = Arg
			}
		}
	}
	fn arg_context(&mut self, mut wd: WordDesc) {
		wd = self.complete_word(wd);
		match wd.text.as_str() {
			"||" | "&&" | "|" | "|&" => {
				while self.char_stream.front().is_some_and(|ch| *ch == '\n') {
					self.advance(); // Allow line continuation
				}
				// Push the token
			}
			_ => { /* Do nothing */ }
		}
		match wd.text.as_str() {
			"||" => {
				self.tokens.push(Tk { tk_type: TkType::LogicOr, wd: wd.add_flag(WdFlags::IS_OP) });
				self.context = TkState::Command
			}
			"&&" => {
				self.tokens.push(Tk { tk_type: TkType::LogicAnd, wd: wd.add_flag(WdFlags::IS_OP) });
				self.context = TkState::Command
			}
			"|" => {
				self.tokens.push(Tk { tk_type: TkType::Pipe, wd: wd.add_flag(WdFlags::IS_OP) });
				self.context = TkState::Command
			}
			"|&" => {
				self.tokens.push(Tk { tk_type: TkType::PipeBoth, wd: wd.add_flag(WdFlags::IS_OP) });
				self.context = TkState::Command
			}
			"&" => {
				self.tokens.push(Tk { tk_type: TkType::Background, wd: wd.add_flag(WdFlags::IS_OP) });
				self.context = TkState::Command
			}
			";" | "\n" => {
				self.tokens.push(Tk::cmdsep(&wd,wd.span.start));
				self.context = TkState::Command
			}
			_ if REGEX["redirection"].is_match(&wd.text) => {
				let mut fd_out;
				let operator;
				let fd_target;
				if let Some(caps) = REGEX["redirection"].captures(&wd.text) {
					fd_out = caps.name("fd_out").and_then(|fd| fd.as_str().parse::<i32>().ok()).unwrap_or(1);
					operator = caps.name("operator").unwrap().as_str();
					fd_target = caps.name("fd_target").and_then(|fd| fd.as_str().parse::<i32>().ok())
				} else { unreachable!() }
				let op = match operator {
					">" => RedirType::Output,
					">>" => RedirType::Append,
					"<" => RedirType::Input,
					"<<<" => RedirType::Herestring,
					_ => unimplemented!()
				};
				if matches!(op, RedirType::Input | RedirType::Herestring) {
					fd_out = 0
				}
				let redir = Redir {
					fd_source: fd_out,
					op,
					fd_target,
					file_target: None
				};
				self.tokens.push(Tk { tk_type: TkType::Redirection { redir }, wd })
			}
			_ => {
				self.tokens.push(Tk { tk_type: TkType::Ident, wd: wd.add_flag(WdFlags::IS_ARG) });
			}
		}
	}
	fn string_context(&mut self, mut wd: WordDesc) {
		// Pop the opening quote
		self.advance();
		while let Some(ch) = self.advance() {
			match ch {
				'\\' => {
					wd = wd.add_char(ch);
					let next_char = self.advance();
					if let Some(ch) = next_char {
						wd = wd.add_char(ch)
					}
				}
				'"' if self.context == TkState::DQuote => {
					self.context = TkState::Arg;
					break
				}
				'\'' if self.context == TkState::SQuote => {
					self.context = TkState::Arg;
					break
				}
				_ => {
					wd = wd.add_char(ch)
				}
			}
		}
		wd.span = self.span;
		self.tokens.push(Tk { tk_type: TkType::String, wd })
	}
	fn vardec_context(&mut self, mut wd: WordDesc) -> Result<(),ShellError> {
		let mut found = false;
		loop {
			let span = wd.span;
			if self.char_stream.is_empty() {
				return Err(ShellError::from_parse("Did not find an `in` keyword for this statement", span))
			}
			wd = self.complete_word(wd);
			match wd.text.as_str() {
				"in" => {
					if !found {
						return Err(ShellError::from_parse("Did not find a variable for this statement", wd.span))
					}
					self.tokens.push(Tk { tk_type: TkType::In, wd });
					break
				}
				_ => {
					if self.context == TkState::SingleVarDec && found {
						return Err(ShellError::from_parse(format!("Only expected one variable in this statement, found: {}",wd.text).as_str(), wd.span))
					}
					found = true;
					self.tokens.push(Tk { tk_type: TkType::Ident, wd: take(&mut wd) });
					wd = wd.set_span(span);
				}
			}
		}
		self.context = TkState::ArrDec;
		Ok(())
	}
	fn arrdec_context(&mut self, mut wd: WordDesc) -> Result<(),ShellError> {
		let mut found = false;
		while self.char_stream.front().is_some_and(|ch| !matches!(ch, ';' | '\n')) {
			found = true;
			wd = self.complete_word(wd);
			wd.span = self.span;
			self.tokens.push(Tk { tk_type: TkType::Ident, wd: take(&mut wd) });
			wd = wd.set_span(self.span)
		}
		if self.char_stream.front().is_some_and(|ch| matches!(ch, ';' | '\n')) {
			if !found {
				return Err(ShellError::from_parse("Did not find any array elements for this statement", wd.span))
			}
			self.advance();
			self.tokens.push(Tk::cmdsep(&wd,self.span.end + 1))
		}
		self.context = TkState::Command;
		Ok(())
	}
	fn subshell_context(&mut self, mut wd: WordDesc) {
		self.advance();
		if self.context == TkState::CommandSub { self.advance(); }
		let mut paren_stack = vec!['('];
		while let Some(ch) = self.advance() {
			match ch {
				'(' => {
					paren_stack.push(ch);
					wd = wd.add_char(ch)
				}
				')' => {
					paren_stack.pop();
					if paren_stack.is_empty() {
						break
					}
					wd = wd.add_char(ch);
				}
				_ => {
					wd = wd.add_char(ch)
				}
			}
		}
		wd.span = self.span;
		let tk = match self.context {
			TkState::Subshell => {
				Tk {
					tk_type: TkType::Subshell,
					wd
				}
			}
			TkState::CommandSub => {
				Tk {
					tk_type: TkType::CommandSub,
					wd
				}
			}
			_ => unreachable!()
		};
		self.tokens.push(tk);
		self.context = TkState::Arg;
	}
	fn func_context(&mut self, mut wd: WordDesc) {
		self.advance();
		if self.context == TkState::CommandSub { self.advance(); }
		let mut brace_stack = vec!['{'];
		while let Some(ch) = self.advance() {
			match ch {
				'{' => {
					brace_stack.push(ch);
					wd = wd.add_char(ch)
				}
				'}' => {
					brace_stack.pop();
					if brace_stack.is_empty() {
						break
					}
					wd = wd.add_char(ch);
				}
				_ => {
					wd = wd.add_char(ch)
				}
			}
		}
		wd.span = self.span;
		wd.text = wd.text.trim().to_string();
		self.tokens.push(Tk { tk_type: TkType::FuncBody, wd })
	}
	fn case_context(&mut self, mut wd: WordDesc) -> Result<(), ShellError> {
		use crate::interp::token::TkState::*;
		let span = wd.span;
		self.context = SingleVarDec;
		self.vardec_context(take(&mut wd))?;
		if self.char_stream.front().is_some_and(|ch| matches!(*ch, ';' | '\n')) {
			self.advance();
			self.tokens.push(Tk::cmdsep(&wd,span.end + 1));
		}
		while !self.char_stream.is_empty() {
			// Get pattern
			let mut pat = String::new();
			while let Some(ch) = self.advance() {
				if ch == ')' { break }
				pat.push(ch);
			}
			wd.text = pat;
			if wd.text == "esac" {
				self.tokens.push(Tk { tk_type: TkType::Esac, wd: take(&mut wd) });
				break
			}
			let span = wd.span;
			self.tokens.push(Tk { tk_type: TkType::CasePat, wd: take(&mut wd) });

			// Get body
			let mut body = String::new();
			let mut prev_char = None;
			while let Some(ch) = self.advance() {
				if ch == ';' && prev_char == Some(';') {
					break
				}
				prev_char = Some(ch);
				body.push(ch);
			}
			let mut body_tokenizer = RshTokenizer::new(&body);
			body_tokenizer.tokenize()?;
			let len = body_tokenizer.tokens.len();
			let body_tokens = Vec::from(&body_tokenizer.tokens[1..len-1]); // Strip SOI/EOI tokens
			self.tokens.extend(body_tokens);
			wd = wd.set_span(span);
		}
		self.context = DeadEnd;
		Ok(())
	}
	fn complete_word(&mut self, mut wd: WordDesc) -> WordDesc {
			let mut dub_quote = false;
			let mut sng_quote = false;
			while let Some(ch) = self.advance() {
					if matches!(ch, '\'') && !dub_quote {
							// Single quote handling
							sng_quote = !sng_quote;
							wd = wd.add_char(ch);
					} else if matches!(ch, '"') && !sng_quote {
							// Double quote handling
							dub_quote = !dub_quote;
							wd = wd.add_char(ch);
					} else if dub_quote || sng_quote {
							// Inside a quoted string
							wd = wd.add_char(ch);
					} else if !matches!(ch, ' ' | '\t' | '\n' | ';') {
							// Regular character
							wd = wd.add_char(ch);
					} else if matches!(ch, '\n' | ';') {
							// Preserve cmdsep for tokenizing
							self.char_stream.push_front(ch);
							self.span.end -= 1;
							wd.span = self.span;
							break;
					} else {
							// Whitespace handling
							self.char_stream.push_front(ch);
							while self.char_stream.front().is_some_and(|c| matches!(c, ' ' | '\t')) {
									self.advance();
							}
							break;
					}
			}
			wd
	}
	fn clean_tokens(&mut self) {
		let mut buffer = VecDeque::new();
		let mut tokens = VecDeque::from(take(&mut self.tokens));
		while let Some(token) = tokens.pop_front() {
			if matches!(token.tk_type, TkType::SOI | TkType::EOI | TkType::Cmdsep) || !token.text().is_empty() {
				buffer.push_back(token);
			}
		}
		self.tokens.extend(buffer.drain(..));
	}
}
