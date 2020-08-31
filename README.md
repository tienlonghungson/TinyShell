# TinyShell For MacOS
This is my TinyShell project for MACOS, written in Objective C

To run this project, compile it to executable file first : 
clang -fobjc-arc main.m BuiltInCommand.m ProcessCommand.m -o TinyShell
Or import it to Xcode Project and run.

This Shell can execute the following command:
1. Built-in Command : help, ls, cd, pwd, date, env
2. Process Command : all, child , find, suspend, resume, kill, fore, back, exit( turn of this process and all background processes opened by this one)

To accomplish this project,  I had guidance from Doctor Pham Dang Hai and consulted from the following links:
https://github.com/Bk-San1201/Tiny_Shell
https://brennan.io/2015/01/16/write-a-shell-in-c/
https://vimentor.com/vi/lesson/quan-ly-tien-trinh
https://www.gnu.org/software/libc/manual/html_node/Processes.html
https://jongampark.wordpress.com/2008/01/26/a-simple-objectie-c-class-for-checking-if-a-specific-process-is-running/
