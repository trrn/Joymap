//
//  StringUtil.m
//  Joymap
//
//  Created by faith on 2013/10/20.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import "StringUtil.h"

@implementation StringUtil

+ (BOOL)empty:(NSString *)s
{
    return [s isKindOfClass:NSString.class] && (s.length == 0);
}

+ (BOOL)blank:(NSString *)s
{
    return ![self present:s];
}

+ (BOOL)present:(NSString *)s
{
    return [s isKindOfClass:NSString.class] && (s.length > 0);
}

@end
