//
//  TimeUtil.m
//  Joymap
//
//  Created by faith on 2013/10/15.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import "TimeUtil.h"

@implementation TimeUtil

+ (NSString *)format:(NSString *)fmt date:(NSDate *)date
{
    NSDateFormatter *f = NSDateFormatter.new;
    [f setDateFormat:fmt];

    return [f stringFromDate:date];
}

+ (BOOL)earlier:(NSDate *)date than:(NSDate *)than
{
    if (date && than) {
        if (date == [than earlierDate:date]) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)later:(NSDate *)date than:(NSDate *)than
{
    if (date && than) {
        if (date == [than laterDate:date]) {
            return YES;
        }
    }
    return NO;
}

@end
