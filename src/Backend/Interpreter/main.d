import std.stdio;

import errors;
import cpu;

int main(string[] args)
{
	if(args.length != 2)
	{
		error(NotEnoughArgs, 0, false);
	}
	run(args[1]);
	return 0;
}

