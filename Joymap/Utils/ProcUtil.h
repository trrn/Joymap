//
//  ProcUtil.h
//  Joymap
//
//  Created by gli on 2013/10/19.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProcUtil : NSObject

+ (void)syncMainq:(void (^)())block;

+ (void)asyncMainq:(void (^)())block;

+ (void)asyncMainqDelay:(float)sec block:(void (^)())block;

+ (void)asyncGlobalq:(void (^)())block;

@end
