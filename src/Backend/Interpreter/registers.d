module registers;

import errors;
import cpu;

import std.stdio;
import std.string;
import std.c.stdlib;
import std.conv;

struct register 
{
	string cData = null;
	int nData;
}

alias to!(string) toString;

const int REG = 10;
register reg[REG];
register PC;

/* Registers start at 0xF0 and we want the register number in 0-9, rather than 0xF0-0xF9 */
pure int toReg(int data)
{
	return data - 0xF0;
}

int toInt(string data)
{
	return to!int(strtoul(toStringz(data), null, 10));
}


void displayReg()
{
	for(int i = 0; i < 10; i++)
	{
		if(reg[i].nData)
		{
			writefln("REG %d: %d", i, reg[i].nData);
		}
		else
		{
			writefln("REG %d: %s", i, reg[i].cData); 
		}
	}
}

void setReg(int regNum, string data)
{
	if(!isRegister(regNum))
	{
		error(NotValidRegister, 0, false, regNum.toString()); 
	}
	regNum = toReg(regNum);
	reg[regNum].nData = 0; /* Clearing out the numerical side of the register */
	reg[regNum].cData = data; /* Assigning the string */
}

void setReg(int regNum, int data)
{
	if(!isRegister(regNum))
	{
		error(NotValidRegister, 0, false, regNum.toString());
	}
	regNum = toReg(regNum);
	reg[regNum].cData = "";
	reg[regNum].nData = data;
}

string getData(int regNum)
{
	if(!isRegister(regNum))
	{
		error(NotValidRegister, 0, false, regNum.toString());
	}

	regNum = toReg(regNum);
	if(reg[regNum].nData == 0)
	{ 
		return reg[regNum].cData;
	} 
	return reg[regNum].nData.toString();
}


bool isRegEmpty(int regNum)
{
	if(isRegister(regNum))
	{
		if(reg[regNum].nData == 0 && reg[regNum].cData == null)
		{
			return true;
		}
	}
	else
	{
		error(NotValidRegister, 0, false, regNum.toString());
	}
	return false;
}

pure bool isRegister(int regNum)
{
	return regNum >= REG0 && regNum <= REG9;
}
