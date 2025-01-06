extern crate proc_macro;
use proc_macro::TokenStream;
use quote::quote;
use syn::{parse_macro_input, DeriveInput};

#[proc_macro_derive(Node)]
pub fn derive_node(input: TokenStream) -> TokenStream {
	let input = parse_macro_input!(input as DeriveInput);

	let name = &input.ident;

	let expanded = quote! {
		impl Node for #name {
			fn span(&self) -> Span {
				self.span
			}

			fn set_span(&mut self, span: Span) {
				self.span = span;
			}

			fn boxed(self) -> Box<Self> {
				Box::new(self)
			}

			fn get_redirs(&self) -> &Vec<Box<dyn Node>> {
				&self.redirs
			}

			fn push_redir(&mut self, redir: Box<dyn Node>) {
				self.redirs.push(redir)
			}

			fn as_any(&self) -> &dyn Any {
				self
			}

			fn tokens(&self) -> &VecDeque<Tk> {
				&self.tokens
			}

			fn flags(&self) -> NdFlags {
				self.flags
			}

			fn mod_flags(&mut self, transform: Box<dyn FnOnce(&mut NdFlags)>) {
				transform(&mut self.flags)
			}
		}
	};

	TokenStream::from(expanded)
}
