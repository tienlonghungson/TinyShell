//
//  BuiltInCommand.m
//  TinyShell
//
//  Created by Tien Long on 8/8/20.
//  Copyright © 2020 Tit muoi. All rights reserved.
//

#import "BuiltInCommand.h"

@implementation BuiltInCommand

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setListOfCom];
    }
    return self;
}

//setter
- (void)setFilemgr:(NSFileManager *)filemgr
{
    _filemgr = filemgr;
}
- (void)setCurrentPath:(NSString *)currentPath
{
    _currentPath= currentPath;
}
- (void)setCurrentDirectory:(NSString *)currentDirectory
{
    _currentDirectory = currentDirectory;
}
- (void)setSplitedInput:(NSArray *)splitedInput
{
    _splitedInput = splitedInput;
    [self setNumOfArgs:(int)[splitedInput count]];
}
- (void)setListOfCom:(NSArray *)listOfCom
{
    _listOfCom = listOfCom;
}

- (void)setListOfCom
{
    @autoreleasepool {
        NSArray *temp = @[@"help", @"cd", @"ls", @"date",@"pwd",@"env"];
        [self setListOfCom:temp];
    }
}

- (void)setNumOfArgs:(int)numOfArgs
{
    _numOfArgs = numOfArgs;
}

//getter
- (NSFileManager *)filemgr
{
    return _filemgr;
}
- (NSString *)currentPath
{
    return _currentPath;
}
- (NSString *)currentDirectory
{
    return _currentDirectory;
}
- (NSArray *)splitedInput
{
    return _splitedInput;
}
- (NSArray *)listOfCom
{
    return _listOfCom;
}
- (int)numOfArgs
{
    return _numOfArgs;
}

//other methods

- (void)help
{
    if (self.numOfArgs >=3) { //_splitedInput[2]
        NSLog(@"Provides help information for TinyShell command");
        NSLog(@"Syntax :");
        NSLog(@"       ");
        NSLog(@"help -[command]");
        return;
    }
    if (self.numOfArgs==1) {//!_splitedInput[1]
        NSLog(@"Type \"help -[command]\" to understand the command obviously.\n");
        NSLog(@"Suppoted commands:\n");
        for (NSString *comd in self.listOfCom) {
            NSLog(@"%@\n", comd);
        }
    } else if ([self.splitedInput[1] isEqualToString:@"cd"]) {
        NSLog(@"Change the current directory. You must write the new directory after this command.\nEXAMPLE: \"cd Document\"\n");
    } else if ([self.splitedInput[1] isEqualToString:@"date"]) {// _splitedInput[1]
        NSLog(@"Show the current time.\n");
    } else if ([self.splitedInput[1] isEqualToString:@"ls"]) {
        NSLog(@"Show list of files or folders in current folder.\n");
    } else if ([self.splitedInput[1] isEqualToString:@"pwd"]) {
        NSLog(@"Show the path to this directory\n");
    } else if ([self.splitedInput[1] isEqualToString:@"env"]) {
        NSLog(@"Show all environment variables\n");
    } else if ([self.splitedInput[1] isEqualToString:@"ps"]) {
        NSLog(@"Handle Process\nSupported Options:\n");
        NSLog(@"Supported options:\n");
        NSLog(@"%-20s%s", " all", "Show list of all running processes.\n");
        NSLog(@"%-20s%s", " child", "Show list of child processes of a process with specific pid\n");
        NSLog(@"%-20s%s", " find", "Get pid of specific program(s) (by name).\n");
        NSLog(@"%-20s%s", " suspend", "Suspend a program (by pid).\n");
        NSLog(@"%-20s%s", " resume", "Resume a program (by pid).\n");
        NSLog(@"%-20s%s", " kill", "Terminate a program (by name).\n");
        NSLog(@"%-20s%s", " fore", "Run a program in foregound mode (by name).\n");
        NSLog(@"%-20s%s", " back", "Run a program in background mode (by name).\n");
        
    
    } else if ([self.splitedInput[1] isEqualToString:@"exit"]) {
        NSLog(@"Killing All Background Process Opened By This Process\nExiting This Process");
    } else {
        NSLog(@"Command not found!\nType help for more details.\n");
    }
}

- (void)cd
{
    if (self.numOfArgs==1) { //!_splitedInput[1]
        if (![self.filemgr changeCurrentDirectoryPath:@"~"]) {
            NSLog(@"Error when change directory to home directory\n");
        }
        return;
    }
    @autoreleasepool {
        if (![self.filemgr changeCurrentDirectoryPath:self.splitedInput[1]]) { //_splitedInput[1]
            for (NSString *tempComd in self.splitedInput) {
                NSLog(@"%@: ", tempComd);
            }
            NSLog(@"No such file or directory\n");
        }
    }
    
}

- (void)date
{
    if (self.numOfArgs>=2) {//_splitedInput[1]
        NSLog(@"This command does not support any option !\n");
        return;
    }
    @autoreleasepool {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSLog(@"%@\n", [dateFormatter stringFromDate:[NSDate date]]);
    }
}

- (void)ls
{
    if (self.numOfArgs>=2) {//_splitedInput[1]
        NSLog(@"This command does not support any option !\n");
        return;
    }
    @autoreleasepool {
        NSArray *fileList;
        
        fileList = [self.filemgr contentsOfDirectoryAtPath:self.currentPath
                                                     error:nil];
        int count = (int)[fileList count];
        for(int i=0;i<count;++i){
            NSLog(@"%@\n",[fileList objectAtIndex:i]);
        }
    }
}

- (void)pwd
{
    NSLog(@"%@\n", self.currentPath);
}

- (void)env
{
    @autoreleasepool {
        NSDictionary *dictOfEnv = [[NSProcessInfo processInfo] environment];
        if (self.numOfArgs==1) {// !_splitedInput[1]
            for (id key in dictOfEnv) {
                NSLog(@"%@=%@\n", key, [dictOfEnv objectForKey:key]);
            }
            return;
        } else {
            if (self.numOfArgs>=3) {// _splitedInput[2]
                NSLog(@"Redundant argument\n");
                return;
            }
            NSLog(@"%@=%@\n", self.splitedInput[1], [dictOfEnv objectForKey:self.splitedInput[1]]);
        }
    }
    return;
}

- (void)operate
{
    @autoreleasepool {
        SEL selectComd;
        IMP imp;
        BOOL isDone = false;
        for (NSString *comd in self.listOfCom) {
            if ([self.splitedInput[0] isEqualToString:comd ]) {
                selectComd = NSSelectorFromString(self.splitedInput[0]);
                
                // the next 3 lines code is to dispose of the warning :
                // performSelector may cause a leak because its selector is unknown
                imp = [self methodForSelector:selectComd];
                void (*func)(id, SEL) = (void *)imp;
                func(self, selectComd);

//                [self performSelector:selectComd];
                isDone= true;
                break;
            }
        }
        if(!isDone){
            NSLog(@"Built In Command not found\n");
        }
    }
}

@end
