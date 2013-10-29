**Glass**

* Reason: This is just a little toy-language that I've been working on in my spare time. Currently, it's only an interpreter for my turing complete byte-code. However in the future, there are plans of making a high-level-language that compiles down to the byte-code (similar to Java).  

* Updates: All updates and bug fixes can be found in "UPDATES.md"

* Language: Everything thus far has been (and intends to stay) written in D, though all examples are written in Glass.  

* OS: I used Ubuntu 12.10 with AwesomeWM to work on this program, as well as MAC OS X using the default DE/WM. 

* Compiling:
	* Automated: ./build.sh
	* Manual: dmd -ofbin/intr main.d stack.d registers.d cpu.d parser.d errors.d

* Help: Check out the /examples folder for example programs.

* Future plans:
	* Abstract the parser/lexer so that it can parse/lex either the byte-code or the HLL
	* Begin writing the compiler
	* Compose wiki-like page for information on each opcode
	* Finish up the interpreter
	* Finish up writing the AST
	
  


