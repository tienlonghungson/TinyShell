//
//  BuiltInCommand.h
//  TinyShell
//
//  Created by Tien Long on 8/8/20.
//  Copyright © 2020 Tit muoi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BuiltInCommand : NSObject

{
    NSFileManager *_filemgr;
    NSString *_currentPath;
    NSString *_currentDirectory;
    NSArray *_splitedInput;
    int _numOfArgs;
    NSArray *_listOfCom;
}

@property NSFileManager *filemgr;
@property NSString *currentPath;
@property NSString *currentDirectory;
@property NSArray *splitedInput;
@property NSArray *listOfCom;

- (instancetype) init;

//getter
- (NSFileManager *)filemgr;
- (NSString *)currentPath;
- (NSString *)currentDirectory;
- (NSArray *)splitedInput;
- (NSArray *) listOfCom;
- (int)numOfArgs;
//setter
- (void)setFilemgr:(NSFileManager *)filemgr;
- (void)setCurrentPath:(NSString *)currentPath;
- (void)setCurrentDirectory:(NSString *) currentDirectory;
- (void)setSplitedInput:(NSArray *) splitedInput;
- (void)setListOfCom:(NSArray *)listOfCom;
- (void)setListOfCom;
- (void)setNumOfArgs:(int)numOfArgs;

- (void)help;
- (void)cd;
- (void)ls;
- (void)date;
- (void)pwd;
- (void)env;
- (void)operate;


@end

NS_ASSUME_NONNULL_END
