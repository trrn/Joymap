//
//  ProcUtil.m
//  Joymap
//
//  Created by faith on 2013/10/19.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import "ProcUtil.h"

@implementation ProcUtil

+ (void)syncMainq:(void (^)())block
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        if (block) {
            block();
        }
    });
}

+ (void)asyncMainq:(void (^)())block
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (block) {
            block();
        }
    });
}

+ (void)asyncMainqDelay:(float)sec block:(void (^)())block
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, sec * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (block) {
            block();
        }
    });
}

+ (void)asyncGlobalq:(void (^)())block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (block) {
            block();
        }
    });
}

@end
