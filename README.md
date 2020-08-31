# TinyShell
This is my TinyShell project for MACOS

To run this project, compile it to executable file first : clang -fobjc-arc main.m BuiltInCommand.m ProcessCommand.m -o TinyShell, or just import it to Xcode Project and run.

This Shell can execute the following command:
1. Built-in Command : help, ls, cd, pwd, date, env
2. Process Command : all, child , find, suspend, resume, kill, fore, back, exit( turn of this process and all background processes opened by this one)
