module stack;

import errors;

import std.stdio;
import std.string;
import std.container;

auto stackP = SList!string([""]);

void push(string element)
{
	stackP.insert(element);
}

string pop()
{
	if(stackP.empty)
	{
		error(StackUnderflow, 0, false);
	}
	string data = stackP.front;
	stackP.removeFront(1);
	return data;
}

void stackTrace()
{
	int i = 0;
	
	writeln("---- Begin Stack Trace ----");
	while(stackP.empty != true)
	{
		string data = stackP.front;
		stackP.removeFront(1);
		writefln("[%d]: %s", i, data);
	}
	writeln("---- End Stack Trace ----");
}
