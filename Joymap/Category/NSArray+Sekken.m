//
//  NSArray+Sekken.m
//
//  Created by faith on 2014/03/16.
//  Copyright (c) 2014年 sekken. All rights reserved.
//

#import "NSArray+Sekken.h"

@implementation NSArray (Sekken)

- (NSString *)join;
{
    return [self joinWith:@" "];
}

- (NSString *)joinWith:(NSString *)sep;
{
    NSMutableString *str = @"".mutableCopy;

    for (id e in self) {
        if ([e isKindOfClass:NSString.class]) {
            if (sep && str.length > 0 && [e length] > 0)
                [str appendString:sep];
            [str appendString:e];
        } else if ([e respondsToSelector:@selector(stringValue)]) {
            if (sep && str.length > 0)
                [str appendString:sep];
            [str appendString:[e stringValue]];
        }
    }

    return str;
}

@end
