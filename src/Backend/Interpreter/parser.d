module parser;

import cpu;
import registers;

import std.stdio; 
import std.string;
import std.regex;

struct token
{
	int type; /* Type 0 = OPCODE, type 1 = Integer, type 2 = string */
	union
	{
		int nData;
		string cData;
		int opcode;
	}
}

class Parser 
{
	private string text;
	private string parse;

	this(string characters, string parse)
	{
		text = characters;
		this.parse = parse;
	}

	void start()
	{
		lex();
	}
	private void lex()
	{
		auto tokens = split(text, regex("[" ~ parse ~ "]"));
		int i;
		mem.length = tokens.length + 2; /* Dynamically allocating the memory, and adding enough extra for the last token
											found, and the EOC token. */
		while(i < tokens.length && tokens[i].ptr != null)
		{
			string currentToken = tokens[i];
			if(indexOf(currentToken, "0x") != -1)
			{
			
				mem[i].type = 0;
				mem[i].opcode = toHexadecimal(currentToken);
			
			}
			else if(isNumeric(currentToken))
			{
				mem[i].type = 1;
				mem[i].nData = toInt(currentToken);
			}
			else
			{
				mem[i].type = 2;
				mem[i].cData = currentToken;
			}
			i++;
		}
		i++;
		mem[i].opcode = EOC;
	}
}
