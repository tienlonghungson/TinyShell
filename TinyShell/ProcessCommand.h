//
//  ProcessCommand.h
//  TinyShell
//
//  Created by Tien Long on 8/10/20.
//  Copyright © 2020 Tit muoi. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <Carbon/Carbon.h>

typedef struct kinfo_proc kinfo_proc;

extern NSMutableSet * _Nullable openedBackProc;
extern char foreProc[30] ;

NS_ASSUME_NONNULL_BEGIN

@interface ProcessCommand : NSObject
{
    NSArray *_splitedInput;
    int _numOfArgs;
    NSArray *_listOfCom;
}

@property NSArray *splitedInput;
@property int numOfArgs;
@property NSArray *listOfCom;

- (instancetype)init;

//setter
- (void)setSplitedInput:(NSArray *)splitedInput;
- (void)setListOfCom:(NSArray *)listOfCom;
- (void)setNumOfArgs:(int)numOfArgs;

//getter
- (NSArray *)splitedInput;
- (NSArray *) listOfCom;
- (int)numOfArgs;

- (void)all; // list all running process , included BSD process
- (void)child; // get all child of a process identified by its id
- (void)find; // find process id by its name
- (void)suspend; // suspend a process identified by its id
- (void)resume; // resume a process identified by its id
- (void)kill; // terminate a process identified by its name
- (void)fore; // run a process identified by its name at mode foreground
- (void)back; // run a process identified by its name at mode background
- (void)exit; // exit this process
- (void)operate; // choose one of above methods to execute
@end

@interface InfoBackProc : NSObject
{
    pid_t _pid;
    NSString *_procName;
}

@property pid_t pid;
@property NSString *procName;

- (instancetype)initWithPid:(pid_t)pid
                   procName:(NSString *)procName;

- (void)setPid:(pid_t)pid;
- (void)setProcName:(NSString *)procName;

- (pid_t)pid;
- (NSString *)procName;

@end
NS_ASSUME_NONNULL_END
