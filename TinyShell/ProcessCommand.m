//
//  ProcessCommand.m
//  TinyShell
//
//  Created by Tien Long on 8/10/20.
//  Copyright © 2020 Tit muoi. All rights reserved.
//

#import "ProcessCommand.h"
#include <assert.h>
#include <errno.h>
#include <stdbool.h>
#include <sys/sysctl.h>
#include <pthread.h>

@implementation ProcessCommand

- (instancetype)init {
    self= [super init];
    if (self) {
        [self setListOfCom];
    }
    return self;
}

- (void)setSplitedInput:(NSArray *)splitedInput
{
    _splitedInput=splitedInput;
    [self setNumOfArgs:(int)[_splitedInput count]];
}
- (void)setListOfCom:(NSArray *)listOfCom
{
    _listOfCom = listOfCom;
}
- (void)setListOfCom
{
    @autoreleasepool {
        NSArray *coms = @[@"all", @"child", @"find", @"suspend", @"resume",@"kill", @"fore", @"back"];
        _listOfCom= coms;
    }
}
- (void)setNumOfArgs:(int)numOfArgs
{
    _numOfArgs = numOfArgs;
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

- (int)getBSDProcessList:(kinfo_proc **)procList
     withNumberOfProcess:(size_t *)procCount
{
    int err;
    kinfo_proc * result;
    bool done ;
    static const int name[] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
    size_t length;
    
    // a valid pointer procList holder should be passed
    assert( procList != NULL );
    // But it should not be pre-allocated
    assert( *procList == NULL );
    // a valid pointer to procCount should be passed
    assert( procCount != NULL );
    
    *procCount = 0;
    result = NULL;
    done = false;
    
    do{
        assert(result==NULL);
        
        // Call sysctl with a NULL buffer to get proper length
        length = 0;
        err = sysctl((int *)name,(sizeof(name)/sizeof(*name))-1,NULL,&length,NULL,0);
        if( err == -1 )
            err = errno;
        // Now, proper length is optained
        if( err == 0 )
        {
            result = malloc(length);
            if( result == NULL )
                err = ENOMEM;   // not allocated
        }
        
        if( err == 0 )
        {
            err = sysctl( (int *)name, (sizeof(name)/sizeof(*name))-1, result, &length, NULL, 0);
            if( err == -1 )
                err = errno;
            
            if( err == 0 )
                done = true;
            else if( err == ENOMEM )
            {
                assert( result != NULL );
                free( result );
                result = NULL;
                err = 0;
            }
        }
    }while (err==0 && !done);
    
    // clean up and establish post condition
    if (err!=0 && result != NULL) {
        free(result);
        result = NULL;
    }
    
    *procList = result; // will return the result as procList
    if (err == 0)
        *procCount = length / sizeof( kinfo_proc );
    
    assert( (err == 0) == (*procList != NULL ) );
    
    return err;
}

- (void)all
{
    int i;
    kinfo_proc *allProc=0;
    size_t numProcs;
    
    int err = [self getBSDProcessList:&allProc
                  withNumberOfProcess:&numProcs];
    if (err) {
        perror("error on /CTL_KERN/KERN_PROC/KERN_PROC_ALL");
        allProc = NULL;
        numProcs = -1;
        return;
    }
    
    NSLog(@"%-50@%-20@%-20@\n",@"Process Name",@"Process ID",@"Parent Process ID");
    NSLog(@"-----------------------------------------------\n");
    for (i = 0; i< numProcs; ++i) {
            NSLog(@"%-50s%-20d%-20d\n",allProc[i].kp_proc.p_comm, allProc[i].kp_proc.p_pid,allProc[i].kp_eproc.e_ppid);
    }
    
    free(allProc);
};

- (void)child
{
    if (self.numOfArgs<3) {
        NSLog(@"Argument required\n");
        return;
    } else {
        @autoreleasepool {
            int i;
            kinfo_proc *allProc=0;
            size_t numProcs;
            kinfo_proc tempProc;
            pid_t parentPid = [self.splitedInput[2] intValue];
            
            int err = [self getBSDProcessList:&allProc withNumberOfProcess:&numProcs];
            if (err) {
                perror("error on /CTL_KERN/KERN_PROC/KERN_PROC_ALL");
                allProc = NULL;
                numProcs = -1;
                return;
            }
            
            NSLog(@"%-50@%-20@%-20@\n",@"Process Name",@"Process ID",@"Parent Process ID");
            NSLog(@"-----------------------------------------------\n");
            for (i = 0; i< numProcs; ++i) {
                tempProc = allProc[i];
                if (parentPid== tempProc.kp_eproc.e_ppid) {
                    NSLog(@"%-50s%-20d%-20d\n",tempProc.kp_proc.p_comm, tempProc.kp_proc.p_pid,tempProc.kp_eproc.e_ppid);
                }
            }
        }
    }
};

- (void)find
{
    if (self.numOfArgs<3) {
        NSLog(@"Argument required\n");
        return;
    } else {
        @autoreleasepool {
            kinfo_proc *allProc=0;
            size_t numProcs;
            int i;
            const char *processName;
            NSMutableString *process = [[NSMutableString alloc] init];
            
            int err = [self getBSDProcessList:&allProc withNumberOfProcess:&numProcs];
            if (err) {
                perror("error on /CTL_KERN/KERN_PROC/KERN_PROC_ALL");
                allProc = NULL;
                numProcs = -1;
                return;
            }
            
            processName = [self combineName:process];

            NSLog(@"%-50@%-20@%-20@\n",@"Process Name",@"Process ID",@"Parent Process ID");
            NSLog(@"-----------------------------------------------\n");
            
            for(i=0;i<numProcs;++i){
                if(!strcmp(allProc[i].kp_proc.p_comm,processName) ){
                    NSLog(@"%-50s%-20d%-20d\n",allProc[i].kp_proc.p_comm, allProc[i].kp_proc.p_pid,allProc[i].kp_eproc.e_ppid);
                }
            }
        }
    }
};

- (void)suspend
{
    if (self.numOfArgs<3) {
        NSLog(@"Argument required\n");
        return;
    } else {
        @autoreleasepool {
            const char *pidStop = [self.splitedInput[2] UTF8String];
            int status;
            pid_t pid= fork();
            if (pid == 0) {
                if(execl("/bin/kill","kill","-STOP",pidStop, NULL)==-1){
                    NSLog(@"Suspend Failed\n");
                }
            } else if (pid > 0) {
                waitpid(pid,&status,0);
            } else {
                NSLog(@"Cannot Do This Command\n");
            }
        }
    }
};

- (void)resume
{
    if (self.numOfArgs<3) {
        NSLog(@"Argument required\n");
        return;
    } else {
        @autoreleasepool {
            const char *pidResume = [self.splitedInput[2] UTF8String];
            int status;
            pid_t pid= fork();
            if (pid == 0) {
                if(execl("/bin/kill","kill","-CONT",pidResume, NULL)==-1){
                    NSLog(@"Resume Failed\n");
                }
            } else if (pid > 0) {
                waitpid(pid,&status,0);
            } else{
                NSLog(@"Cannot Do This Command\n");
            }
        }
    }
};

- (void)kill
{
    if (self.numOfArgs<3) {
        NSLog(@"Argument required\n");
        return;
    } else {
        NSMutableString *auxiliaryProcessName = [[NSMutableString alloc] init];
        const char* processName = [self combineName:auxiliaryProcessName];
        pid_t pid = fork();
        if (pid==0) {
            if (execl("/usr/bin/killall", "killall", processName,NULL)==-1) {
                NSLog(@"Kill Failed\n");
            }
        } else if (pid>0) {
            int status;
            waitpid(pid, &status, 0);
        } else {
            NSLog(@"Cannot Proceed to Stop Process\n");
        }
    }
};

- (void)fore
{
    if (self.numOfArgs<3) {
        NSLog(@"Argument required\n");
        return;
    } else {
        @autoreleasepool {
            NSMutableString *auxiliaryProcessName = [[NSMutableString alloc] init];
            const char *processName = [self combineName:auxiliaryProcessName];
            strcpy(foreProc, processName);
            pid_t pid;
            int status;
            
            pid = fork();
            if (pid>0) {
                waitpid(pid, &status, 0);
            } else if (pid==0) {
                if (execl("/usr/bin/open","open","-W","-a",processName,NULL)==-1) {
                    NSLog(@"Open Failed\n");
                }
            } else {
                perror("Error When Fork\n");
            }
        }
    }
};

// wait the child opening background process to terminate
- (void)waitBackProcess:(NSObject *)infoBackProc
{
    InfoBackProc *info = (InfoBackProc *)infoBackProc;
    int status;
    // NSLog(@"Thread is waiting background process\n");
    waitpid([info pid], &status, 0);
//    [self checkStatus:status];
    [openedBackProc removeObject:[info procName]];
    // NSLog(@"Thread Done\n");
};


- (void)back
{
    if (self.numOfArgs<3) {
        NSLog(@"Argument required\n");
        return;
    } else {
        @autoreleasepool {
            NSMutableString *auxiliaryProcessName = [[NSMutableString alloc] init];
            const char *processName ;
            pid_t pid;

            processName =[self combineName:auxiliaryProcessName];

            pid = fork();
            if (pid>0) {
                [openedBackProc addObject:auxiliaryProcessName];
                InfoBackProc *infoBackProc= [[InfoBackProc alloc] initWithPid:pid
                                                                     procName:[[NSString alloc] initWithUTF8String:processName]];
                NSThread *waitChildThread =
                [[NSThread alloc] initWithTarget:self
                                        selector:@selector(waitBackProcess:)
                                          object:(NSObject*)infoBackProc];
                [waitChildThread start];
            } else if (pid==0) {
                signal(SIGINT, SIG_IGN);
                if (execl("/usr/bin/open","open","-W","-a",processName,NULL)==-1) {
                    NSLog(@"Open Failed\n");
                }
            } else {
                perror("Error When Fork\n");
            }
        }
    }
};

// combine to arguments from input to get a complete name of process
- (const char *)combineName:(NSMutableString*)process
{
    int i;
    [process appendString:self.splitedInput[2]];
    for (i=3;i<self.numOfArgs;++i) {
        [process appendString:@" "];
        [process appendString:self.splitedInput[i]];
    }
    return [process UTF8String];
}

// check status of terminated child process
- (void)checkStatus:(int)status
{
    if (WIFEXITED (status))
        NSLog(@"Normal termination with exit status=%d\n", WEXITSTATUS (status));
    
    if (WIFSIGNALED (status))
        NSLog(@"Killed by signal=%d%s\n" ,WTERMSIG (status), WCOREDUMP (status) ? " (dumped core)" : "" );
    if (WIFSTOPPED (status))
        NSLog(@"Stopped by signal=%d\n", WSTOPSIG (status));
    
    if (WIFCONTINUED (status))
        NSLog(@"Continued\n" );
}

- (void)exit
{
    pid_t pid;
    int status;
    {
        NSArray *backGroundProc = [openedBackProc allObjects];
        for (NSMutableString *processRunning in backGroundProc) {
            pid = fork();
        
            if(pid>0){
                waitpid(pid, &status, 0);
                NSLog(@"Process %@ Is Stopped\n", processRunning);
            } else if (pid==0) {
                const char *processName = [processRunning UTF8String];
                NSLog(@"Stopping %@\n", processRunning);
                if (execl("/usr/bin/killall", "killall", processName, NULL)==-1) {
                    NSLog(@"Cannot Stop Process %@\n", processRunning);
                    return;
                }
                return ;
            } else {
                perror("Cannot Proceed to Stop Process\n");
            }
        }
    }
    NSLog(@"All Background Process Is Stopped\n");
    sleep(3);
    exit(0);
};

- (void)operate
{
    @autoreleasepool {
        SEL selectComd = NULL;
        IMP imp;
        BOOL isSelected = false;
        if ([self.splitedInput[0]  isEqualToString:@"exit"]) {
            selectComd = NSSelectorFromString(@"exit");
            isSelected = true;
        } else {
            for (NSString *comd in _listOfCom) {
                //            NSLog(@"%@ comparing to %@\n", _splitedInput[0], comd);
                if ([self.splitedInput[1] isEqualToString:comd ]) {
                    selectComd = NSSelectorFromString(self.splitedInput[1]);
                    isSelected = true;
                    break;
                }
            }
        }
        // the next 3 lines code is to dispose of the warning :
        // performSelector may cause a leak because its selector is unknown
        if (isSelected) {
            imp = [self methodForSelector:selectComd];
            void (*func)(id, SEL) = (void *)imp;
            func(self, selectComd);
        } else {
            NSLog(@"Process Command not found\n");
        }
    }

}

@end

@implementation InfoBackProc

- (instancetype)initWithPid:(pid_t)pid
                   procName:(NSString *)procName
{
    self = [super init];
    if(self){
        [self setPid:pid];
        [self setProcName:procName];
    }
    return self;
}

- (void)setPid:(pid_t)pid
{
    _pid = pid;
}
- (void)setProcName:(NSString *)procName
{
    _procName = procName;
}

- (pid_t)pid
{
    return _pid;
}
- (NSString *)procName
{
    return _procName;
}

@end
