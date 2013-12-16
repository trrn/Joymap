//
//  StringUtil.m
//  Joymap
//
//  Created by gli on 2013/10/20.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import "StringUtil.h"

@implementation StringUtil

+ (BOOL)empty:(NSString *)s
{
    if ((s) && (s.length > 0)) {
        return NO;
    }
    return YES;
}

@end
