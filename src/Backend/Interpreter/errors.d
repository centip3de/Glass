module errors;

import stack;

import std.stdio;
import std.c.stdlib;


enum : int
{
	ReadDataError = 1, 
	UnexpectedEOB = 2, 
	NotValidVarType = 3, 
	InvalidJumpLocation = 4, 
	NoInterruptFound = 5, 
	NotValidRegister = 6, 
	NoRegisterSpecified = 7, 
	UnknownToken = 8, 
	VarAlreadyDefined = 9,
	StackUnderflow = 10, 
	InvalidFiletype = 11,
	NotEnoughArgs = 12,
}	

void error(int type, int tokenNum, bool UseStackTrace, string[] args ...)
{
	switch(type)
	{
		case ReadDataError:
			writeln("Error: Something went wrong writing the data");
			break;
		case UnexpectedEOB:
			writeln("Error: Unexpected end of block at token number ", tokenNum); 
			break;
		case NotValidVarType:
			writeln("Error: Not a valid variable type at token number ", tokenNum);
			break;
		case InvalidJumpLocation:
			writeln("Error: Invalid jump location at token number ", tokenNum);
			break;
		case NoInterruptFound:
			writeln("Error: Interrupt signal received, but no interrupt was found at token number ", tokenNum);
			break;
		case NotValidRegister:
			writeln("Error: ", args[0], " is not a valid register");
			break;
		case NoRegisterSpecified:
			writeln("Error: No register specified at token number ", tokenNum);
			break;
		case UnknownToken:
			writeln("Error: Unknown token ", args[0], " at token number ", tokenNum);
			break;
		case VarAlreadyDefined:
			writeln("Error: Variable ", args[0], " already defined at token number ", tokenNum);
			break;
		case StackUnderflow:
			writeln("Error: Stack underflow detected!");
			break;
		case InvalidFiletype:
			writeln("Error: Invalid filetype! Only accepting the filetype of .gl");
			break;
		case NotEnoughArgs:
			writeln("Error: Not enough arguments supplied. Example program: ./intr <inputfile>.gl");
			break;
		default:
			writeln("Error: Something went wrong somewhere... probably.");
			break;
	}
	if(UseStackTrace)
	{
		stackTrace();
	}
	exit(1);
}
