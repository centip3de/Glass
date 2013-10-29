module cpu;

import registers;
import stack;
import parser;
import errors;

import std.stdio;
import std.string;
import std.file;
import std.path : extension;
import std.c.stdlib;
import std.array;
import std.ascii;
import std.conv;

enum : int
{
	/* OPCODES */
	NOP = 0x0,
	SWP = 0x1,
	ADD = 0x2,
	SUB = 0x3,
	MUL = 0x4,
	DIV = 0x5,
	LSHIFT = 0x6,
	RSHIFT = 0x7,
	NOT = 0x8,
	AND = 0x9,
	OR = 0xA,
	XOR = 0xB,
	CMP = 0xC,
	PUSH = 0xD, 
	POP = 0xE, 
	REGSET = 0xF, 
	REGSHOW = 0x10, 
	MEMSHOW = 0x11, 
	DEBUG = 0x12, 
	INTERRUPT = 0x13,
	FLAGSHOW = 0x14, 
	IFE = 0x15, 			/* If equal */
	IFNE = 0x16, 			/* If not equal */
	INC = 0x17,
	DEC = 0x18,   
	JMP = 0x19,
	DEF = 0x20,
	LBL = 0x21,			// Label 
	CALL = 0x22,
	RET = 0x23,
	IMPRT = 0x24,
	EOC = 0x25,			//End of code

	/* Symbols */
	NL = 0xC0,				//New line
	EOB = 0xC1, 			//End of block
	COM = 0xC2, 			//Comment
	STR = 0xC3, 			//String identifier, i.e. ' " '

	/* Registers */
	REG0 = 0xF0,
	REG1 = 0xF1,
	REG2 = 0xF2, 
	REG3 = 0xF3, 
	REG4 = 0xF4, 
	REG5 = 0xF5, 
	REG6 = 0xF6, 
	REG7 = 0xF7, 
	REG8 = 0xF8, 
	REG9 = 0xF9
}

/* Hash tabel for variables */
int[string] intVariable;
string[string] strVariable;

/* Hash tabel for labels */
int[string] labels;

/* Debug bit */
bool debug_bit = false; 

/* Flag registers */
int flagA = 0;
int flagB = 0;

/* Program memory */
token mem[];

/* How many scopes (as in if-statements that resulted in false) we're currently in */
int scopes = 0;

void dPrint(string message)
{
	if(debug_bit)
	{
		writeln("DEBUG: " ~ message);
	}
	return;
}

bool isInterrupt()
{
	dPrint("In isInterrupt()");
	if(reg[0].nData == 1)
	{
		dPrint("isInterrupt() returning true for exit interrupt");
		return true;
	}
	else if(reg[0].nData == 2 && reg[1].cData != null && reg[2].cData != null || reg[2].nData != 0)
	{
		dPrint("isInterrupt() returning true for write interrupt");
		return true;
	}
	else if(reg[0].nData == 3 && reg[1].cData != null && reg[2].nData != 0)
	{
		dPrint("isInterrupt() returning true for read interrupt");
		return true;
	}
	dPrint("isInterrupt() returning false");
	return false;
}

void executeInt()
{
	dPrint("In executeInt()");
	if(reg[0].nData == 1)
	{
		dPrint("Executing exit interrupt!");
		exit(reg[1].nData);
	}
	if(reg[0].nData == 2 && reg[1].cData != null && (reg[2].cData != null || reg[2].nData != 0))
	{
		dPrint("Executing write interrupt!");
		if(reg[1].cData == "stdout")
		{
			dPrint("Writing to stdout");

			if(reg[2].nData != 0)
			{
				if(reg[2].nData == NL)
				{
					writeln("");
					return;
				}
				writef("%d", reg[2].nData);
			}
			else
			{
				writef("%s", getData(REG2));
			}
		}
		else
		{
			dPrint("Writing to file");
			string fileName = reg[1].cData;
			string text = reg[2].cData;
			std.file.write(fileName, text);
		}
		return; 
	}

	if(reg[0].nData == 3 && reg[1].cData != null && reg[2].nData != 0)
	{
		dPrint("Executing read interrupt!");
		if(reg[1].cData == "stdin")
		{
			dPrint("Reading from stdin");
			string buf;
			if((buf = stdin.readln()) !is null) /* If it's not null (!= gave a conflicting types error) */ 
			{
				setReg(REG4, chop(buf));
			}
			else
			{
				error(ReadDataError, 0, false);
			}
		}
		else
		{
			dPrint("Reading from file");
			string fileName = reg[1].cData;
			auto text = read(fileName, reg[2].nData);
			setReg(4, cast(string)text);
		}
		return;
	}
	dPrint("executeInt() has ran, but nothing was executed.");
}

void memShow()
{
	dPrint("In memShow()");
	for(int i = 0; i < mem.length; i++)
	{
		if(mem[i].type == 0)
		{
			writefln("[%d]: %d", i, mem[i].opcode);
		}
		else if(mem[i].type == 1)
		{
			writefln("[%d]: %d", i, mem[i].nData);
		}
		else
		{
			writefln("[%d]: %s", i, mem[i].cData);
		}
	}
}

int toHexadecimal(string data)
{
	return to!int(strtoul(toStringz(data), null, 16));
}

void setRegOnOp(ref int i, int delegate(int,int) operation)
{
	int arg = mem[++i].nData;
	int regNum = mem[++i].opcode;
	int reg = toInt(getData(regNum));

	setReg(regNum, operation(reg, arg));
}

int getNextInt(ref int i)
{
	i++;
	if(isRegister(mem[i].opcode))
	{
		return toInt(getData(mem[i].opcode));
	}
	else if(mem[i].type == 2 && isVariable(mem[i].cData))
	{
		return intVariable[mem[i].cData];
	}
	return mem[i].nData;
}

bool isLabel(string lblName)
{
	if(lblName in labels)
	{
		return true;
	}
	return false;
}

bool isVariable(string varName)
{
	if(varName in intVariable || varName in strVariable)
	{
		return true;
	}
	return false;
}

string getVarStr(string varName)
{
	return strVariable[varName];
}

int getVarInt(string varName)
{
	return intVariable[varName];
}

int getVarType(string varName) /* 0 = Doesn't exist, 1 = Integer, 2 = String */
{
	if(varName in intVariable)
	{
		return 1;
	}
	else if(varName in strVariable)
	{
		return 2;
	}	
	else
	{
		return 0;
	}
}

void execute()
{
	dPrint("In execute() function");
	for(int i = 0; i < mem.length; i++)
	{
		switch(mem[i].opcode)
		{
			case EOB:
				dPrint("EOB OPCODE found!");
				i++;
				if(scopes > 0)
				{
					scopes--;
				}
				else
				{
					error(UnexpectedEOB, i, false);
				}
				break;
			case DEF:
				dPrint("DEF OPCODE found!");
				i++;
				string varName = mem[i].cData;
				i++;
				if(isVariable(varName))
				{
					error(VarAlreadDefined, i, false, varName)
				}
				else if(mem[i].type == 1)
				{
					int data = mem[i].nData;
					intVariable[varName] = data;
				}
				else if(mem[i].type == 0)
				{
					string data;
					i++;
					if(mem[i].type == 2)
					{
						while(mem[i].opcode != STR)
						{
							data ~= mem[i].cData ~ " ";
							i++;
						}
						strVariable[varName] = data;
					}
					else
					{
						error(NotValidVarType, i, false);
					}
				}
				break;
			case LBL:
				dPrint("LBL OPCODE found!");
				i++;
				string labelName = mem[i].cData;
				labels[labelName] = i;	
				while(mem[i].opcode != EOB)
				{
					i++;
				}
				break;
			case RET:
				dPrint("RET OPCODE found!");
				i = toInt(pop());
				break;
			case CALL:
				dPrint("CALL OPCODE found!");
				i++;		
				push(toString(i));	
				int data;
				if(isLabel(mem[i].cData))
				{
					data = labels[mem[i].cData];
				}
				else
				{
					error(InvalidJumpLocation, i, false);
				}
				i = data;
				dPrint("CALL: Jumping to token " ~ i.toString());
				break;
			case COM:
				dPrint("COM OPCODE found!");
				i++;
				while(mem[i].opcode != COM)
				{
					i++;
				}
				break;
			case INC:
				dPrint("INC OPCODE found");
				i++;
				if(isVariable(mem[i].cData))
				{
					intVariable[mem[i].cData]++;
					break;
				}
				int regNum = mem[i].opcode;
				dPrint("INC: Incrementing register " ~ regNum.toString());
				dPrint("INC: Register data before = " ~ getData(regNum));
				int data = toInt(getData(regNum));
				data++;
				setReg(regNum, data);
				dPrint("INC: Register data after = " ~ getData(regNum));
				break;
			case DEC:
				dPrint("DEC OPCODE found");
				i++;
				if(isVariable(mem[i].cData))
				{
					intVariable[mem[i].cData]--;
					break;
				}
				int regNum = mem[i].opcode;
				dPrint("DEC: Decrementing register " ~ regNum.toString());
				dPrint("DEC: Register data before = " ~ getData(regNum));
				int data = toInt(getData(regNum));
				data--;
				setReg(regNum, data);
				dPrint("DEC: Register data after = " ~ getData(regNum));
				break;
			case NOP:
				dPrint("NOP OPCODE found, doing nothing.");
				break;
			case JMP:
				dPrint("JMP OPCODE found");
				i++;
				int jmp;
				if(isLabel(mem[i].cData))
				{
					jmp = labels[mem[i].cData];
				}	
				jmp = mem[i].nData;
				dPrint("JMP: Jumping to token " ~ jmp.toString);
				i = jmp;
				break;
			case IFE:
				dPrint("IFE OPCODE found");
				if(flagA != 1)
				{
					scopes++;

					dPrint("IFE: Comparison resulted in inequality, skipping code");
					dPrint("IFE: Current scope is, " ~ scopes.toString());

					while(scopes != 0)
					{
						i++;
						if(mem[i].opcode == CMP)
						{
							dPrint("IFE: Comparison found, leaving to test the condition");
							i--;
							break;
						}
						else if(mem[i].opcode == EOB)
						{
							scopes--;
						}
					}
					dPrint("IFE: Finished skipping code, currently in the outermost scope(" ~ scopes.toString() ~ ") at token number " ~ i.toString);
				}
				flagA = 0;
				break;
			case IFNE:
				dPrint("IFNE OPCODE found");
				if(flagA != 0)
				{
					scopes++;					

					dPrint("IFE: Comparison resulted in equality, skipping code");
					dPrint("IFE: Current scope is, " ~ scopes.toString());

					while(scopes != 0)
					{
						i++;
						if(mem[i].opcode == CMP)
						{
							dPrint("IFE: Comparison found, leaving to test the condition");
							i--;
							break;
						}
						else if(mem[i].opcode == EOB)
						{
							scopes--;
							break;
						}
					}
					dPrint("IFNE: Finished skipping code, currenlty in the outermost scope(" ~ scopes.toString() ~ ") at token number " ~ i.toString);
				}
				flagA = 0;
				break;
			case XOR:
				dPrint("XOR OPCODE found");
				setRegOnOp(i, (x,y) => x ^ y);
				break;
			case OR:
				dPrint("OR OPCODE found");
				setRegOnOp(i, (x,y) => x | y);
				break;
			case AND:
				dPrint("AND OPCODE found");
				setRegOnOp(i, (x,y) => x & y);
				break;
			case RSHIFT:
				dPrint("RSHIFT OPCODE found");
				setRegOnOp(i, (x,y) => x >> y);
				break;
			case LSHIFT:
				dPrint("LSHIFT OPCODE found");
				setRegOnOp(i, (x,y) => x << y);
				break;
			case FLAGSHOW:
				dPrint("FLAGSHOW OPCODE found");
				writefln("Flag A: %d", flagA);
				writefln("Flag B: %d", flagB);
				break;
			case CMP:
				dPrint("CMP OPCODE found");
				i++;

				/* Because all of these get assigned to null or 0 at runtime, if we don't assign them to different values, 
				then they'll still evaluate to true in the comparison below. (If we're testing numbers, then num and num2 
				will differ, but text and text2 will still be evaluated to null, and thus be equal and fuck everything
				up) */
				int num = 0;
				int num2 = 1;
				string text = "text";
				string text2 = "text2";
				
				/* Finding out the first peice of data to compare, and assigning it to the variable */
				if(mem[i].type == 2)
				{
					if(isVariable(mem[i].cData))
					{
						int type = getVarType(mem[i].cData);
						if(type == 1)
						{
							num = intVariable[mem[i].cData];
						}
						else
						{
							text = strVariable[mem[i].cData];
						}
					}
				}
				else if(mem[i].type == 0) /* Must be register or string*/
				{
					if(isRegister(mem[i].opcode))
					{
						string data = getData(mem[i].opcode);	
						dPrint("CMP: First opcode is a register with the data of " ~ data);
						if(isNumeric(data))
						{
							num = toInt(data);
						}
						else
						{
							text = data;
						}
					}
					/* String? */
					else if(mem[i].opcode == STR)
					{
						i++;

						/* Clear out the original random value we had (because we're appending, not assigning below) */
						text = "";

						while(mem[i].opcode != STR)
						{
							text ~= mem[i].cData ~ " ";
							i++;
						}
						dPrint("CMP: First opcode is a string with the data of " ~ text);
					}
				}
				else if(mem[i].type == 1)
				{
					num = mem[i].nData;
					dPrint("CMP: First opcode is a number with the value of " ~ num.toString());
				}
				i++;

				/* Same thing as above, but for the second peice of data */

				if(mem[i].type == 2)
				{
					if(isVariable(mem[i].cData))
					{
						int type = getVarType(mem[i].cData);
						if(type == 1)
						{
							num2 = intVariable[mem[i].cData];
						}
						else if(type == 2)
						{
							text2 = strVariable[mem[i].cData];
						}
					}
				}
				else if(mem[i].type == 0) /* Must be register or string */
				{
					int regNum = toReg(mem[i].opcode);
					if(isRegister(mem[i].opcode))
					{
						string data = getData(regNum);	
						dPrint("CMP: Second opcode is a register with the data of " ~ data);
						if(isNumeric(data))
						{
							num2 = toInt(data);
						}
						else
						{
							text2 = data;
						}
					}
					/* String? */
					else if(mem[i].opcode == STR)
					{
						i++;

						/* Clear out the original random value we had */
						text2 = "";
						while(mem[i].opcode != STR)
						{
							text2 ~= mem[i].cData ~ " ";
							i++;
						}
						dPrint("CMP: Second opcode is a string with the data of " ~ text2);
					}
				}
				else if(mem[i].type == 1)
				{
					num2 = mem[i].nData;
					dPrint("CMP: Second opcode is a number with the value of " ~ num2.toString());
				}

				/* The actual comparison */
				if(num == num2 || text == text2)
				{
					flagA = 1;
					dPrint("CMP: Comparison resulted in true. Assigning flagA to 1");
					break;
				}
				flagA = 0;	
				dPrint("CMP: Comparison resulted in false. Asssigning flagA to 0");
				break;

			case INTERRUPT:
				dPrint("Interrupt OPCODE found");
				if(isInterrupt())
				{
					dPrint("INTERRUPT: Found interrupt");
					executeInt();
				}
				else
				{
					error(NoInterruptFound, i, false);
				}
				break;
			case MEMSHOW:
				dPrint("MEMSHOW OPCODE found");
				memShow();
				break;
			case DEBUG:
				dPrint("DEBUG OPCODE found");
				if(!debug_bit)
				{
				    debug_bit = true;
				    dPrint("DEBUG: Debug mode is now on, prepare to be overloaded.");
				}
				else
				{
				    dPrint("DEBUG: Setting DEBUG to 0, goodbye cruel world!");
				    debug_bit = false;
				}
				writeln("Setting debug bit to: ", debug_bit);
				break;
			case REGSET:
				dPrint("REGSET OPCODE found");
				i++;
				int regA = mem[i].opcode;
				i++;
				if(mem[i].type == 2)
				{
					int type = getVarType(mem[i].cData);
					if(type == 1)
					{
						writeln(intVariable[mem[i].cData]);
						setReg(regA, intVariable[mem[i].cData]);
					}
					else
					{
						setReg(regA, strVariable[mem[i].cData]);
					}
					i++;
				}
				else if(mem[i].opcode == STR)
				{
					i++;
					string data;
					while(mem[i].opcode != STR)
					{
						data ~= mem[i].cData ~ " ";
						i++;
					}
					dPrint("REGSET: Setting register " ~ regA.toString() ~ " to " ~ data);
					setReg(regA, chop(data)); /* Remove the '\n\r' and space */
				}
				else
				{
					int info = mem[i].nData;
					dPrint("REGSET: Setting register " ~ regA.toString() ~ " to " ~ info.toString);
					setReg(regA, info);
				}
				break;
			case SWP:
				dPrint("SWP OPCODE found");
				i++;
				if(mem[i].opcode)
				{
					int regNumA = mem[i].opcode;
					if(mem[i].opcode)
					{
						i++;
						int regNumB = mem[i].opcode;
						string data = getData(regNumB);
						dPrint("SWP: Assigning register " ~ regNumB.toString() ~ "'s data to register " ~ regNumA.toString());
						setReg(regNumA, data);
					}
				}
				break;
            		case REGSHOW:
				dPrint("REGSHOW OPCODE found");
				displayReg();
				break;
			case ADD:
				dPrint("ADD OPCODE found");
				setReg(REG0, getNextInt(i) + getNextInt(i));
				break;
			case SUB:
				dPrint("SUB OPCODE found");
				setReg(REG0, getNextInt(i) - getNextInt(i));
				break;
			case MUL:
				dPrint("MUL OPCODE found");
				setReg(REG0, getNextInt(i) * getNextInt(i));
				break;
			case DIV:
				dPrint("DIV OPCODE found");
				setReg(REG0, getNextInt(i) / getNextInt(i));
				break;
			case PUSH:
				dPrint("PUSH OPCODE found");
				i++;
				string pushString;
				
				if(isVariable(mem[i].cData))
				{
					int type = getVarType(mem[i].cData);
					if(type == 1)
					{
						pushString = toString(intVariable[mem[i].cData]);
					}
					else
					{
						pushString = strVariable[mem[i].cData];
					}
				}
				else if(mem[i].opcode == STR)
				{
					i++;
					while(mem[i].opcode != STR)
					{
						pushString ~= mem[i].cData ~ " ";
						i++;
					}
					dPrint("PUSH: Found a string as the data to push");
				}
				else
				{
					pushString = toString(mem[i].nData);
					dPrint("PUSH: Found a number as the data to push");
				}
				dPrint("PUSH: Pushing " ~ pushString ~ " to the stack.");
				push(pushString);
				break;
			case POP:
				dPrint("POP OPCODE found");
				i++;
				int regNum = mem[i].opcode;
				auto data = pop();
				setReg(regNum, data);
				dPrint("POP: Set register " ~ regNum.toString() ~ " to " ~ data.toString());
				break;
			case EOC:
				dPrint("EOC OPCODE found");
				dPrint("So long and thanks for all the fish!");
				exit(0);
			default:
				error(UnknownToken, i, true, mem[i].opcode.toString());
				break;
		}
	}
}

void run(string filename)
{
	string fileExt = std.path.extension(filename);
	if(fileExt == ".gl")
	{
		auto text = read(filename); /* Reading in the entire file */
		Parser parser = new Parser(cast(string)text);
		parser.start();
		execute();
	}
	else
	{
		error(InvalidFiletype, 0, false);
		exit(1);
	}
}
