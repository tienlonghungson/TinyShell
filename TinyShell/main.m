//
//  main.m
//  HelloObjectiveC
//
//  Created by Tien Long on 8/7/20.
//  Copyright © 2020 Tit muoi. All rights reserved.
//
//  clang -fobjc-arc main.m BuiltInCommand.m ProcessCommand.m -o TinyShell

#import <Foundation/Foundation.h>
#import "BuiltInCommand.h"
#import "ProcessCommand.h"

void sigIntHandler(int sig_num);
void start(void);
void loop(void);
void execute(NSFileManager *filemgr, NSString *currentPath, NSString *currentDirectory, NSArray *splitedInput, ProcessCommand *processCommand, BuiltInCommand *builtInCommand);
void end(void);

NSMutableSet *openedBackProc;
char foreProc[30]="\0";

int main(int argc, const char * argv[]) {
    
    signal(SIGINT, sigIntHandler);
    start();
    loop();
    end();
    return 0;
}

void sigIntHandler(int sig_num)
{
//    NSLog(@"Fore Is %s\n", foreProc);
    if (strcmp(foreProc, "\0"))
    {
        @autoreleasepool {
            ProcessCommand *processCommand = [[ProcessCommand alloc] init];
            NSArray *signalComd = @[@"ps",@"kill",[[NSString alloc] initWithUTF8String:foreProc]];
            [processCommand setSplitedInput:signalComd];
            [processCommand kill];
        }
    }

    signal(SIGINT, sigIntHandler);
    return;
}


void start(){
    NSLog(@"--------------------------------------------------------------------------------------------------\n");
    NSLog(@"--------------------------------------Here comes the Shell ---------------------------------------\n");
    NSLog(@"--------------------------------------------------------------------------------------------------\n\n");
}

void loop(){
    @autoreleasepool{
        
        ProcessCommand *processCommand = [[ProcessCommand alloc] init];
        BuiltInCommand *builtInCommand = [[BuiltInCommand alloc] init];
        openedBackProc = [[NSMutableSet alloc] init];
        
        NSFileManager *filemgr;
        NSString *currentPath;
        NSArray *splitedPath;
        NSString *currentDirectory;
        
        filemgr = [[NSFileManager alloc] init];
        
        NSFileHandle *input;
        NSData *inputData ;
        NSString *preLineInput;
        NSString *lineInput;
        NSArray *splitedInput;
        while (1) {
            
            // get current path and current directory
            filemgr = [NSFileManager defaultManager];
            currentPath = [filemgr currentDirectoryPath];
            splitedPath = [currentPath componentsSeparatedByString:@"/"];
            currentDirectory = [splitedPath lastObject];
            
            NSLog(@"(Aquashell) %@>", currentDirectory);
            
            // read input
            input = [NSFileHandle fileHandleWithStandardInput];
            inputData = [NSData dataWithData: [input availableData]];
            preLineInput = [[NSString alloc] initWithData:inputData
                                                 encoding:NSUTF8StringEncoding];
            lineInput = [preLineInput substringToIndex:[preLineInput length]-1];
            
            // preprocess input
            if([preLineInput isEqualToString: @"\n"]){
                continue;
            }
            
            splitedInput = [lineInput componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            splitedInput = [splitedInput filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]]; // eliminate whitespace
            
            // executing command
            execute(filemgr, currentPath, currentDirectory,splitedInput, processCommand, builtInCommand);
            
        }
    }
}

void execute(NSFileManager *filemgr, NSString *currentPath, NSString *currentDirectory, NSArray *splitedInput, ProcessCommand *processCommand, BuiltInCommand *builtInCommand){
    @autoreleasepool {

        if(([splitedInput[0] isEqual:@"ps"])||([splitedInput[0] isEqual:@"exit"])){
            [processCommand setSplitedInput:splitedInput];
            [processCommand operate];
        }
        else{
            [builtInCommand setFilemgr:filemgr];
            [builtInCommand setCurrentPath:currentPath];
            [builtInCommand setCurrentDirectory:currentDirectory];
            [builtInCommand setSplitedInput:splitedInput];
            [builtInCommand operate];
        }
    }
}


void end(){
    NSLog(@"Process ends\n");
}
