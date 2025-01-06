Bash limitations:
1. Data structures
	- Arrays are extremely clunky to make use of and have extremely specific syntax symantics in regards to indexing for instance
	- Essentially no native support for dictionaries
	- JSON parsing and manipulation requires tools like jq which themselves have their own syntax rules to learn. Requiring these external tools could be eliminated entirely by simply having support for JSON-like structures

2. Error handling
	- Error handling in bash is another pain point for the language.
	- Propagating errors is entirely manual and modern shells mainly use exit codes to communicate errors, which for codes beyond 0 and 1 are essentially meaningless to all but the most dedicated shell users.
	- Essentially no tracebacks, and no good way to pinpoint where and when an error occurs.
	- This could be fixed by taking queues from python or rust with their very robust error handling paradigms
	- Solving this problem alone would vastly improve developer experience with shell scripting

3. String operation
	- String operation in bash often requires the use of external tools such as awk, sed, or cut which each have their own syntax rules that you need to memorize. I mean, awk is literally it's own programming language.
	- No multiline strings except with heredocs, which are an extremely clunky and incompatible method of doing so as heredocs can only be used with input redirection to something else.
	- rush could include builtins similar to most modern languages like split, format, etc

4. Syntax
  - Syntax in bash is often extremely mind-numbing to read. Even string operations of a moderate complexity (e.g. a cat into a sed into an awk) will require you to remember how to read syntax semantics and remember what individual flags do for several different commands as you try to mentally parse the pipeline.
	- This can easily be cleaned up by having builtins with consistent syntax for the most common operations that are usually outsourced to external commands.

5. Types
  - Everything in bash is a string, there are no types. This often makes script behavior difficult to predict.
	- Since everything is a string, it's difficult for your script to know if it's working with the right kind of data without overly verbose conditional checks.
	- A typing system will make scripts far easier to reason about, far easier to maintain, and far easier to debug

6. Builtins
	- If you've ever used bash on a very minimal system, you'll find that it is woefully limited with just the core gnu utils installed.
	- Much of the functionality of modern bash comes from external binaries like grep, awk, and sed. This raises issues when running scripts on systems that may not have these binaries installed.
	- Many of the functionalities most commonly afforded by external commands could easily be adapted into a standard library of sorts.

7. Prone to errors
	- Bash syntax is riddled with pitfalls and gotchas
	- Quoting rules, working with elements in arrays, passing arguments to functions, the list goes on
	- Making the quoting and escaping rules clearer and also allowing functions to be defined like 'function(arg1,arg2) {}' would make it leagues easier to work with.

8. Concurrency and Async
	- While bash allows you to run processes in the background non-blockingly, the support for this functionality is woefully minimal.
	- There is essentially no native support for async programming beyond forking processes.

9. Error messages
	- Bash can be extremely frustrating to work with at times. Error messages are often extremely unhelpful, usually just canned responses rather than anything specific to the code being run.
	- A single unclosed delimiter in a long script becomes a hunt for a needle in a haystack.
	- This is actually a pretty simple fix too

10. Portability issues
	- It is very often that bash scripts will work on one machine and not on another. This is because shells in general are very dependent upon state, which is obviously not shared between machines. The dependency on external tools and environment state leads to unpredictability across machines and platforms.
	- A decent approach for this might be to check for the availability of each command specified in a script and then produce an error message listing the missing commands, rather than running it and having the script actually execute code until it reaches something that it can't do, leading to unpredictable, half-finished logic

11. No real way to test code
	- The best you can really do is create a separate script that sources another script and then create test functions in the second file. This is of course a very clunky way to test code and sourcing the other file can have unintended side effects.


# Main Feature Ideas

1. Detailed error messages, fine grained error handling
	- In order to bring shell scripting to the modern age, error messages and error handling must be on par with that of Rust or Python.
	- Line/Column numbers, "try except" blocks, the whole 9 yards

2. Multiple shebangs in one script
	- Shell scripting has limitations, just like every other language. When you run into something that isn't well suited to shell scripting, your only option is to either suck it up and do it in bash anyway, or create an entire separate file to solve that one problem and then execute it in your script
	- This could be solved by allowing users to write shebangs in subshells, allowing the script to dynamically switch interpreters to execute code in other languages in said subshells. This way you could get the granular input/output control of shell scripting alongside the power of higher order languages like python.

3. Macros
	- Think macros in Rust, but brought to shell scripting. The syntax would be something like this: `split!echo "hello world" -> ["hello","world"]` or `replace("world","rush")!echo "hello world" -> "hello rush"`.
	- This would allow for users to dynamically create operations that can be applied to any command that produces the expected output

4. Types
	- Shell scripting to this day still has no real support for types. This feature alone would be groundbreaking for shell scripting.
	- Adding not only proper native support for booleans and floats, but also higher order data structures such as dictionaries or sets would revolutionize what shell scripting is capable of.

5. Standard Library
	- The GNU core utils alone provide woefully incomplete utility. Bash often relies on external commands like `sed`, `awk`, or `grep` in order to perform many of it's main features. This produces a lack of portability as scripts have to make many assumptions about the end user's environment.
	- This could be fixed by simply including many of the most common operations performed in bash (pattern searching, regex operations, field extraction) into macros that are built into rush. This would not only increase portability, it would also unify syntax, reducing the mental overhead associated with needing to learn many different bespoke flags and syntaxes for various commands, especially in the case of `awk` and `sed`.
	- This is probably the most ambitious part of this project, so I should most like try to get the above ideas implemented before I even begin to approach this.


# Opinionation of Features

* Type declarations
	- I want rush to be both backwards compatible with bash while also giving greater utility as a scripting language.
	- This means that variable declarations such as `var=value` should remain valid. Bash is weakly typed by default, so the normal variable declaration syntax should work that way.
	- However, I also wish to include new shell builtins that allow for strongly typing variables. Stuff like `int var=10` or `string var="hello"` so that the benefits of strong typing (robustness, predictability) can be reaped for longer/more complex scripts.
	- For arrays, I want to keep them as they are and also maintain the usual gross syntax for working with them, just for backwards compatibility as a legacy feature. Eventually I want to implement a better type for this similar to Python's lists.

* Macros
	- I want to implement macros in a way that makes sense in the context of shell scripting. I'll include several macros that are in sort of a standard library, but each macro will essentially be a command expansion. This is how I want it to work: `split @ echo "hello world" = ["hello", "world"]` would internally be the same as writing `echo "hello world" | tr ' ' '\n'`. Macros would be defined using a syntax like `macro split { "$cmd" | tr ' ' '\n' }` and there would even be support for macros with arguments.
	- My idea for handling arguments is to do keep parameters passed before the '@' as positional params for the macro, and then pass input from following commands into a variable '$~'.
	- The argument for macros as a feature is to provide a middleground between aliases and functions. There are many cases where aliases are too limited and functions are somewhat overkill, like in the case of the above split macro.
	- The main use case will mainly be code *injection* rather than code *execution*. This allows for dynamic generation of code, such as generating many function definitions. This can heavily reduce boilerplate and make scripts more expressive.
	- Macros provide inline substitution while functions produce a brand new scope in a subshell. Macros are more suited to logic that can be easily written on one line, and are therefore too simple to really justify an entire function definition, but are slightly too complex to be put into an alias, while still being an operation that is performed frequently.

* Builtins
	- Many core functionalities of shell scripting are actually offloaded to external commands like awk, grep, and sed. While these tools are *extremely* powerful, they are mostly used for extremely simple tasks. I can probably count on one hand the amount of times I've had to make real use of awk's full capabilities rather than just using it for field extraction, for instance. These *simple* functionalities can easily be implemented as builtins, and users could utilize the corresponding external commands if they require their more advanced functionalities.
	- Including these as builtins opens the door for having a library of builtin macros such as split!, find("pattern")!, or extract(' ',[1,3])! for instance.

* Many Interpreters
	- Shell scripting is powerful, but not perfect. There are many cases where you will run into a problem in a script that shell scripting struggles with but Python handles effortlessly, for instance. The builtins I wish to include will most likely not cover these bases.
	- Therefore, I wish to expand subshell syntax to allow users to declare a shebang in subshells to dynamically offload subshell content to a secondary interpreter. Here's an example:
```
#!/usr/bin/env rush

echo "Greetings from rush!"

(
	#!/usr/bin/env python3
	print("Greetings from python!")
)
```
	- To achieve a similar functionality in bash, you have to use heredocs which are a clunky and archaic feature that is incompatible with modern development for many reasons, most of which being that heredocs exist entirely as a string until runtime, meaning that IDEs and language servers are completely unable to reason about them.
	- A language server for rush would be able to dynamically update syntax highlighting in subshells to match the chosen interpreter, ideally.
	- This centralization of concerns would allow users to utilize the system-level power of the shell and programmatic power of modern scripting languages all in the same place with a simple and intuitive syntax
	- *Note: Have to figure out how to move variables from the outer shell to the inner one. Probably just expanding them during the tokenization I guess.*

* Shebangs
	- Shebangs can be expanded upon to make handling arguments much clearer and self-documenting. For instance: `#!/usr/bin/env rush arg1 arg2=default arg3`, and then reference the args in the script like `$arg1`, `$arg2`, `$arg3`, calling the script like `./script arg1 arg2 arg3`. This is much easier to reason about than the usual `$1`, `$2`, etc. syntax and heavily reduces the boilerplate usually included in scripts used to improve readability
	- Rush could additionally validate the arguments at runtime, raising an error if any are missing.
	- If no args are specified in the shebang, Rush would default to using traditional positional variable syntax.
	- This could even be extended to include the strong typing system mentioned earlier: `#!/usr/bin/env rush int:arg1 string:arg2="default" list:arg3`
	- Scripts that require certain arguments but accept further arguments could be written like: `#!/usr/bin/env rush arg1 arg2 ...` and then the extra positional args could be accessed using the original "$@" syntax or something like "$args"

## Macro ideas

	- `split !` -> splits a string, optionally takes an arg as a delimiter like `split "," ! echo "foo,bar,baz"`
	- `replace <word1> <word2> !` -> simple find and replace in a string or file
	- `range <int1> <int2> !` -> needs work, but this idea is useful
	- `filter <pattern> !` -> only print lines from cmd output with <pattern>
	- `toupper/tolower !` -> change all text to upper or lower case
	- `wordcount/linecount/charcount !` -> self explanatory
	- `sum/max/average/othermathstuff !` -> simple math operations
	- `waitall !` -> wait for all background operations to finish

### newer version
	- called like `macro <args> @ <input_source>?` because the exclamation point looks too much like a pipe
	- Insert code to be executed once it is reached
	- Can be used to generate function definitions dynamically
	- Or reduce boilerplate for error handling, etc

## Types to include

	from python:
	- ints
	- floats
	- booleans
	- lists
	- dictionaries

	new types:
	- file: stores a file in a variable. will have builtins that allow for more fine grained control than simply storing the path as a string in a variable
	- bytes: raw data, essentially an abstraction over a Vec<u8> in rust.

## Misc feature ideas
- Some way to tell if you terminal is in an ssh session or a nested shell? Alternate prompt or color scheme?
- Actually having color scheme support in the first place
- Fuzzy finder autocompletion window
- Fuzzy finder integrated as builtin?
- A way to run scripts/programs in a totally clean environment, similar to nix package building
- Terminal display layers (sounds painful)
