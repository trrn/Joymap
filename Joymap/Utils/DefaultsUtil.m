//
//  DefaultsUtil.m
//  Joymap
//
//  Created by gli on 2013/10/20.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import "DefaultsUtil.h"

@implementation DefaultsUtil

+ (NSInteger)int:(NSString *)key;
{
    return [NSUserDefaults.standardUserDefaults integerForKey:key];
}

+ (NSString *)str:(NSString *)key
{
    return [NSUserDefaults.standardUserDefaults stringForKey:key];
}

+ (id)obj:(NSString *)key
{
    return [NSUserDefaults.standardUserDefaults objectForKey:key];
}

+ (BOOL)bool:(NSString *)key
{
    return [NSUserDefaults.standardUserDefaults boolForKey:key];
}

+ (void)setInt:(NSInteger)i key:(NSString *)key
{
    [NSUserDefaults.standardUserDefaults setInteger:i forKey:key];
    [NSUserDefaults.standardUserDefaults synchronize];
}

+ (void)setObj:(id)obj key:(NSString *)key
{
    [NSUserDefaults.standardUserDefaults setObject:obj forKey:key];
    [NSUserDefaults.standardUserDefaults synchronize];
}

+ (void)setBool:(BOOL)yn key:(NSString *)key
{
    [NSUserDefaults.standardUserDefaults setBool:yn forKey:key];
    [NSUserDefaults.standardUserDefaults synchronize];
}

@end
