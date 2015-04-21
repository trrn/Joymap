//
//  FileUtil.m
//  Joymap
//
//  Created by faith on 2013/10/20.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import "FileUtil.h"

@implementation FileUtil

+ (BOOL)moveForce:(NSString *)from to:(NSString *)to error:(NSError **)error
{
    NSFileManager *manager = NSFileManager.defaultManager;
    NSError *err = nil;
    
    if ([manager fileExistsAtPath:to isDirectory:NO]) {
        if (![manager removeItemAtPath:to error:&err]) {
            if (error) {
                *error = err;
            }
            return NO;
        }
    }
    
    DLog(@"%@, %@", from, to);
    
    if (![manager moveItemAtPath:from toPath:to error:&err]) {
        if (error) {
            *error = err;
        }
        return NO;
    }
    return YES;
}

+ (BOOL)existsFile:(NSString *)path
{
    NSFileManager *manager = NSFileManager.defaultManager;

    if ([manager fileExistsAtPath:path isDirectory:NO]) {
        return YES;
    }
    return NO;
}

@end
