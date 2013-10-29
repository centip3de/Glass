**Working version 0.3.0 updates:**

WARNING: LARGE UPDATE (Though most messages are a bit redundent)!

General:
* Abstracted the lexer/parser from just CPU.d, now in the file parser.d
* Added in abstracted error catching for ease and modularity, (errors.d)
* Added in working stack-tracing for each error (errors.d/stack.d)
* Added in basic stack-frames/call-stacks
* Added MANY more example programs into the /examples, though some are not as commented as others.
* Officially released/picked the name of this toy language, 'Glass'!
* Made an official repository for Glass!
* Nested if-statements are now 100% working! 
* Reorganized most things (though the same organization scheme was kept), source files are in /src, binaries in /bin, etc. 
* Updated the makefile to work with new files and layout 
* Variables are now officially mutable (though you cannot redefine them, or set them equal to anything. You can however, increment/decrement, etc.)!

README.md:
* Added future plans section
* Updated to reflect new changes

Makefile:
* Fixed a bug that caused an object file to be left in the bin folder

Build.sh:
* Fixed a bug that would cause an error if /bin already existed. 
* Now preforms both make clean and make all

CPU.d:
* Added imports to both errors.d and parser.d
* Added quite a bit more debug messages. The vast majority of which have better debug messages, including current variable status, assignments, etc.  
* Added scopes variable to keep track of the current scope
* Added IMPRT skeleton to allow for importing new files (does not work at the moment, just the skeleton of it is included)
* Added function isLabel() to detect whether the next token is indeed a label or not
* Added function isVariable() to detect whether the next token is indeed a variable or not
* Added function getVarStr() to return the value of a string variable
* Added function getVarInt() to return the value of an integer variable
* Added function getVarType() to return the type of the variable, (0 = none, 1 = integer, 2 = string)
* Added DEF OPCode to execute() switch statement to allow for better variable creation 
* Added EOB OPCode to execute() switch statement to allow for better if-statement-scoping
* Moved token struct to parser.d
* Removed function decode() and placed in parser.d
* Removed all error messages and replaced with the more modular error() function, located in errors.d 
* Removed all old code of jumping/calling. Now using basic-scopes (if-statement only), allowing for nested if-statements 
* Removed the capability for CALL to jump to token numbers. Now it only works with labels. 
* Removed old, unnecessary code in run()
* Updated getNextInt() to allow the fetching of integer variables
* Updated INC to work properly with new variables
* Updated DEC to work properly with new variables
* Updated CMP to work properly with new variables 
* Updated REGSET to work properly with new variables
* Updated POP to work properly with new variables
* Updated PUSH to work properly with new variables
* Updated IFE to work properly with new scoping system
* Updated IFNE to work properly with new scoping system
* Updated EOB to work properly with new scoping system 
* Updated JMP/RET/CALL OPCodes to make the use of stack-frames
* Updated run() to work with new parsing system.
* Updated run() to actually report and detect errors when working with an invalid filetype
* Updated executeInterrupt() to work properly with the new error-reporting-system

Registers.d:
* Added imports to errors.d
* Reorganized much of the code, allowing for it to read easier
* Removed the vast majority of imports, as they were completely unnecessary
* Updated setReg() to work properly with new error-reporting-system
* Updated setReg() (the other one) to work properly with new error-reporting-system
* Updated getData() to work properly with new error-reporting-system 
* Updated isRegEmpty() to work properly with new error-reporting-system
* Updated toReg() to be a pure function (purely functional), allowing for it to be optimized even further
* Updated isRegister() to be a pure function (purely functional), allowing for it to be optimized even further 

Main.d:
* Added import to errors.d
* Removed unnecessary imports
* Updated main to work with new error-reporting system
 
Stack.d:
* Added in detection and error reporting for stack-underflows
* Added function stackTrace() to quickly and efficiently run a stack-trace
* Added import to errors.d
* Removed unnecessary imports

Errors.d:
* Description: Errors.d is meant to further modularize and abstract error reporting, cut down on unnecessary lines of code, and make the whole process quite a bit easier. In the future, pretty-printing may be thought about as a feature, but at the moment it is not. 

Parser.d:
* Description: Parser.d is meant to further modularize and abstract the parsing and lexing processes with the hope that both the compiler and interpreter can use the same lexer/parser.

**Working version 0.2.9 updates:**

General:
* Added the ability to perform string comparisons! 
* Added labels! (Label syntax is as follows, "0x21 LABEL_NAME ..(your code here).. 0xC1")
* Added in static string variables! (Variable syntax is as you would expect "0x20 StringVariable 0xC3 I'm a string! 0xC3")
* Added in the CALL OPCode! You can now call labels much like you would a function! (Syntax is "0x22 LABEL_NAME")
* Added in the RET OPCode! You can now return from a label execution! (Syntax is "0x21 LABEL_NAME ..(your code here).. 0xC1 0x23")
* Added more examples (Comparisons.gl, Labels.gl, CallRet.gl, IfStatements.gl)
* Moved EOC opcode to 0x24
* Changed MOV to 'SWP' because RegSet (0xF) already does what x86 ASM mov does and we needed a SWP OPcode anyway. Syntax: '0x1 destination source' where both destionation and source are registers. 
* Fixed syntax errors from recent push request
* Fixed formatting errors
* Fixed minor gramatical errors
* Removed old unused code

CPU.d:
* Reworked the entire comparison logic, now quite a bit clearer and more efficient
* Can now compare strings using the comparison opcode
* Added a better error message for unknown tokens 
* Added LBL (label) to CPU execute() to not execute label code until the label is called
* Actually using the builtin types set during parsing, instead of hacking it together
* Shortened jump code considerably 
* Edited find/replace code in decode() to account for string variable detection as well as integer variable detection

Main.d:
* Added usage statement when incorrect number of arguments are used

Reisters.d:
* Fixed formatting bug that caused regShow() to crash
* Removed unnecessary calls to 'toString'


**Working version 0.2.8 updates:**

General:
* Added more comments to the enums, for clarity sake.
* Added the ability to write comments in code!
* Added new symbol to the enum (0xC2) for comments. 
* Added the ability to write and use basic static integer-only variables!
* Added new opcode for defining variables (0x20)
* Added new opcode for string symbol ' " ' (0xC3)
* Added stack usage example to /examples (Stack.gl)
* Added variable usage example to /examples (Variables.gl)
* Added comment usage example to /examples (Comments.gl)
* Added comments to every line of every example, for clarity sake.
* Moved EOC opcode to 0x21 from 0x20
* Reworked stack algorithm. It is now implemented in a linked list. 
* The stack can now grow large as your computer can contain!
* You can now pop and push numbers, as well as strings. 
* You MUST now surround all strings in the string symbol opcode (0xC3)

CPU.d:
* Added 'variable', an associative array to hold all variables
* Added new if statements to 'execute()' for comments
* Changed 'decode()' to allow for variable definition
* Changed 'decode()' to allow for variable find-and-replace
* Changed 'decode()' to allow for associative array key finding
* Changed quite a bit of code in 'execute()' to force new string symbol use
* Removed previous debug code from CMP OPCode

Stack.d:
* Significantly reduced the code size
* Added std.container import, in order to use D's builtin linked lists
* Reworked 'push()' to work with the new stack
* Reworked 'pop()' to work with the new stack
* Removed 'stackIsEmpty()' function, as it's no longer needed
* Removed stack struct, as it's no longer needed

**Working version 0.2.7 updates:**

General:
* Updated README.md, to reflect changes to D
* Added examples folder, for example programs. 
* Memory is now dynamically allocated so programs of unlimited length scripts are allowed
* You can now output both numbers and strings from the write interrupt
* You can now output newlines by setting register 2 to "0xC0" and calling a write interrupt.
* Changed syntax for registers (again), now all registers are specified by the OPCODE 0xF0-0xF9. For instances, to get to register 0, it's 0xF0. For register 1 it's 0xF1, and so on. 
* Added the INC OPCODE to increment registers
* Added the DEC OPCODE to decrement registers
* Added the NL (new line) OPCODE to allow printing new lines easier
* Added the EOB (end of block) OPCODE to allow printing in conditional statements 
* Removed the IFGT and IFLT OPCODE's, it's now just IFE and IFNE, making loops much easier
* ADD/SUB/MUL/DIV can now take a register as either or both of the arguments
* Fixed bug that wouldn't allow you to access the 9th register
* Fixed bug that appeneded a new line after every write
* Fixed bug that wouldn't allow 0.2.6 to compile through DMD, only through GDC
* Fixed bug where interrupts weren't properly found and flagged
* Fixed bug where EOC's weren't injected properly, causing non-existent NOPS to be read
* Fixed bug in memory size that would restrict you to 64 tokens

CPU.d:
* Organized the OPCODE enum slightly, added sections for future symbolic OPCODES
* Memory is now dynamically allocated in the "decode()" function
* Changed for loop in "execute()" function to take the length of memory, not the length of MEM_SIZE
* Changed for loop in "memShow()" function to take the length of memory, not the length of MEM_SIZE
* Added regTest variables in order to work with the new register syntax checking
* Added "to!int()" to the toHexadecimal() and toInt() functions
* Added 0xF0-0xF9 to the opcode enum
* Added 0xC0 to the opcode enum

Register.d:
* Imported cpu
* Removed MEM_SIZE
* Added toReg() function to convert from 0xF0-0xF9's to 0-9's
* Added toReg() function check to setReg() and getData()


**Working version 0.2.6 updates:**

General:
* Complete rework of all stack-logic.
* Changed syntax for specifying registers. It's now a number, instead of a string:
	Example: "0x1 0 5" = MOV REG0 REG5. 
* Fixed bug in lexing process that would convert blanks to NOP's
* Fixed bug in RegSet OPCode that caused a seg fault
* Fixed bug in MOV OPCode that would set all registers, instead of the one specified
* Fixed bug in MOV OPCode that caused a range error
* Fixed error with toString and toInt functions. 
* Fixed bug in where regset couldn't differentiate between a number and letter
* Fixed bug where one couldn't read from a file. 
* Fixed bug in the stack that prevented any data moving in or out. 

CPU.d:
* Changed logic for getting the specified registers.
* Added the "toHexadecimal" function, for conversion between hex and string values.
* Removed stack declaration from CPU.d and moved it over to Stack.d

Registers.d:
* Added the "toInt()" function and removed the alias. 

Stack.d:
* stackP.contents is now a string array
* Removed stackInit() function (D doesn't need it (yay D!))
* Removed stackDestroy() function
* Removed all instances of stackP in function parameters
* Removed isStackFull() (Currently this is unimplemented, though that should change soon.)
* Placed stack decleration at top of file, which all functions now use. 


**Working version 0.2.5 updates:**

Warning, large update incoming (3 updates worth in 1!)

General:
* Ported the entire interpreter to the D Programming language!
* Optimized the entire lexing process by removing the conversion to a text OPCode!
* Changed some of the register logic
* Added the END OF CODE OPCode (0x20)
* Removed the NOT OPCode logic for the time being. 
* Removed all header files
* Reduced code size by almost 50%!
* Updated .gitignore to include certain types of D files

Cpu.d:
* Added in a token struct, for easier and more efficient parsing/lexing
* The memory is now of the token type
* Updated "isInterrupt()" to use 'else if' statements, and changed it's type to bool
* Added OPCODE enum for ease of reading 
* Edited some debug messages 
* Removed the if-else-if tree in executeInt() for the stdout write interrupt.
* Removed remenents from old debugging.
* Removed findCommand() function.
* Updated memShow() to be compatible with new memory type
* Update decode() to work with the new memory type
* Decode() now works in a for loop
* Optimized and shortened decode() code
* Updated execute() command to use a case-switch structure, instead of if-else

Stack.d:
* Moved contents from header file into Stack.d, as a header file isn't needed in D
* Removed stackElementT attribute, and just replaced it with string

Registers.d:
* Moved contents from header file into Registers.d, as a header file isn't needed in D
* Fixed 1 off array indexing error (credit goes to WallShadow)
* Replaced getCData and getNData with "getData()"
* GetData now returns a string with the data in it. 
* GetData now only takes an int, rather than a string
* isRegEmpty() is now of type bool
* isRegEmpty() now takes an int as an argument, rather than a string
* isRegister is now of type bool
* isRegister now takes an int as an argument, rather than a string
* Shortened isRegister code considerably 

**Working version 0.2.2 updates:**
General:
* Registers can now only hold one variable at a time (like normal registers), either numeric or character. 
* Added a few more comments
* We are now turing complete! Wahoo!
* Fixed off-by one error in POP opcode
* Added in JMP OPCode! 
* JMP OPCode syntax: 0x19 (opcode to jump to) Example: "0x2 4 2 0x3 3 2 0x10 0x19 2", this would jump to the subtraction opcode and repeat.

Registers.c:
* Added a new function to grab character data out of a register. (getCData(foo))
* Changed setReg() function slightly to only hold one variable in each register at a time. 

Registers.h:
* Updated to reflect Register.c changes 

**Working version 0.2.1 updates:**

General:
* Now all updates are in the update folder, and the README is an actual README.
* The stack actually does something now!
* Push logic reworked. It pushes a string until a NOP instruction is reached. 
* Pop logic reworked. It pops the value off the stack and places it in whatever register is specified. ("0xE reg0/1/2/3/4/5/6/7/8/9")
* All basic arithmatic logic output is reworked. All output from arithmatic is stored in register 0, instead of output to the screen. 

CPU.c:
* MOV instruction bug fixed. 

**Working version 0.2.0 updates:**

General:
* Added if statements! If statements are as follows: 
* 0x15 = IFE, if a previous comparison resulted in equality
* 0x16 = IFNE, if a previous comparison resulted in NOT equality
* 0x17 = IFGT, if a previous comparison resulted in one number being greater than the other
* 0x18 = IFLT, if a previous comparison resulted in one number being less than the other

**Working version 0.1.9 updates:**

General:
* This is a big update! Hurray!
* Added read interrupt! 
* Added in CMP OPCode as 0x6 (replacing PRINT OPCode). This displays the comparison between two registers, or an integer and a register (A register must be the first argument!). 
* Added in two new flags, "FlagA", and "FlagB". FlagA is currently for displaying the results of a comparison and FlagB has no use at the moment. 
* Added in FLAGSHOW OPCode as 0xE to display whether the flags are currently ticked or not
* Added in all bit shift manipulations! (Right shift, left shift, AND, OR, XOR, NOT)
* All OPCodes past 0x5 have been changed! Please review the code for the changes!
* Expanded write interrupt to be able to write register contents to screen (cData only)
* Increased accuracy in decteding whether a token is referencing a register or not
* Fixed bug with how OPCodes were determined that caused anything with an 'x' in it to be determined as an OPCode 
* Fixed bug where multiple files would be open at once 

CPU.c: 
* Added the skeleton for if statements (which will be next week)
* Changed all instances of accessing the tokens using "mem[foo]", instead of using fetch() to make sure nothing has access to memory besides fetch.  
* Now exclusively using setReg to update and set registers, instead of assigning them directly. 
* Added fclose()'s! 
* Register contents now can be writen to screen
* Changed executeInt() to properly check the correct registers (Was previously checking the wrong part of reg 2)
* Edited executeInt()'s REGSET function to accomidate the new changes in Registers.c
* Added in XOR, AND, OR, NOT, Left Shift, and Right shift operations to findCommand

Registers.c:
* Changed getNData() to be of the integer type, instead of word type. 
* Changed isRegisters from using a integer as an argument, to using a char pointer for better accuracy in detecting whether a token is referencing a register or not. 
* All references to isRegister in other functions (Essentially everything in Registers.c) have also been changed to cooperate with the new isRegister format

Registers.h:
* Updated to reflect Registers.c changes

**Working version 0.1.8 updates:**

General:
* Fixed misspellings in README
* Reorganization, moved /Interpreter/bin to /HexBot/bin. 
* Fixed bugs regarding how input was taken and outputted that would occasionally cause a crash. 
* Compile code now appends -pg to work with Gprof
* Added in another interrupt: Write. 
* Removed print keywords, write can now write to stdin if specified, as well as a file. (All other OPCodes are the same for now, but will change next update)
* Added in a few more debug messages
* Complete rework of registers/register logic. 
* Registers are now their own type, containing both character data (cData) and numerical data (nData)
* Changed all functions to now work properly with the new register setup 

CPU.c:
* Added in written functionality about new write interrupt 
* Changed all references to registers to now work with new register type. 
* Added in the ability to handle text with a '.' in it for file names and such. 
* Memory is now copied over to PC.cData with strcpy, instead of pointed to it by a char * 
* Completely reworked the REGSET command to find either numbers or characters and assign them correctly.
* Edited the MOV command to accommodate the new registers. Note: Can currently only move numbers! Functionality for characters has not been added 

CPU.h: 
* Updated to reflect CPU.c changes

Registers.c:
* Recreated/reworked registers array and PC register. 
* displayReg() Now shows both the numerical and character data for each register. 
* setReg() Now differentiates between numerical and character data and sets each appropriately. Bar has been changed to a void pointer. 
* getData has been removed and replaced with getNData(), no getCData() exists at the moment. 
* isRegEmpty() now checks if both numerical and character data is empty 

Registers.h:
* Updated to reflect Register.c changes
* Added in "registers" type for both 0-9 registers, and the PC register. Registers type can now hold a 400-length string, or a number. 

IRC.py: 
* Updated to reflect new organizational changes. 

**Working version 0.1.7 updates:**
General:
* Instructions are now read in from the PC register instead of directly from memory
* Added in interrupts! Currently working ones are: Exit. 
* Fixed issues with external variable declarations for "PC" and "reg"
* Updated and organized available commands list in CPU.c
* Debug bit now activates debug information spewing!
* Filetypes now matter! Only accepted file type now is '.gl' (foreshadowing to the programming language name? Maybe...)

IRC.py:
* Changed all instances of "input.txt" to "input.gl"

CPU.c:
* Added preliminary filetype check, just to make sure we're actually reading a file we want to read (i.e. not a binary file, etc.)
* Added in exectueInt() to execute interrupts in the script
* Added in isInterrupt() to check if there is an interrupt in the registers
* 0xD is now the interrupt keyword 
* char * PC and int reg are now proper external variables contained in registers.c
* Commented all major variables and functions with their use
* Added a hell of a lot of debug information 

CPU.h:
* Updated to reflect CPU.c changes

Registers.c:
* Commented all major variables and functions with their use
* PC and reg are now housed in this file and are accessed via external call from CPU.c

Registers.h:
* Removed reg declaration and moved it to registers.c
* Commented all major variables and functions with their use

Stack.c:
* Commented all major variables and functions with their use

Stack.h:
* Commented all major variables and functions with their use

**Working version 0.1.6 updates:**
General:
* Now -Wall complaint
* Added header guards to all .h files
* Removed unnecessary includes
* Slight reorganization in directory layout
* No longer need specific input. (0x02, 0x2, 0x000002, all work for the same function)
* Fixed lots of bugs, including certain string bugs that crashed the program
* 0x3E8 and above are now reserved for user input parsing
* Added and updated compile flags in README

CPU.c:
* Removed unneeded includes
* Now converts input to hex
* Updated findCommand to switch/case statement 
* findCommand now takes a secondary parameter of a string during parsing
* Fixed bugs with string comparison, now all string comparison uses strcmp
* Fixed bug with 0x6 (print) crashing program
* Removed unnecessary variables from previous versions
* Added isalpha detection

CPU.h:
* Updated to reflect CPU.c changes
* Added header guard and removed unnecessary includes

Registers.c:
* Updated isRegister and displayReg functions to print instead of writing
* Removed and updated multiple variables and functions 
* Fixed bug where displayReg would not output anything
* Fixed bug where displayReg would display the PC bit
* Fixed comparison bug in isRegister function

Registers.h:
* Updated to reflect Registers.c changes
* Added header guard and removed unnecessary includes

Stack.h:
* Added header guard and removed unnecessary includes

Main.c:
* Added in headers that should never have been deleted

**Working version 0.1.5 updates:**

General:
* Interpreter now can work as stand-alone application 
* Bot now interfaces with interpreter via PIPES (except input file) rather than only files
* Bot now prints all new output on a single line only

IRC.py:
* Removed all file writing code (except for input file)
* Added PIPES for communicating with interpreter 
* Added parsing the PIPE output to put it on one line

CPU.c:
* No longer works in an infinite halt loop, now works until all of the file is read
* Remove unnecessary error codes
* Debug bit now switches on and off, although the rest of the code is currently unimplemented

CPU.h:
* Updated prototype for run()

Registers.c:
* Removed 5 registers, now registers only 0 - 9 + PC

Registers.h:
* Updated prototypes and defines to match registers.c



