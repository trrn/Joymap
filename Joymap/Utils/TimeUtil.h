//
//  TimeUtil.h
//  Joymap
//
//  Created by faith on 2013/10/15.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeUtil : NSObject

+ (NSString *)format:(NSString *)fmt date:(NSDate *)date;

+ (BOOL)earlier:(NSDate *)date than:(NSDate *)than;

+ (BOOL)later:(NSDate *)date than:(NSDate *)than;

@end
