//
//  NSString+Sekken.m
//
//  Created by gli on 2014/03/16.
//  Copyright (c) 2014年 sekken. All rights reserved.
//

#import "NSString+Sekken.h"

@implementation NSString (Sekken)

- (NSURL *)URL;
{
    return [NSURL URLWithString:[self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

- (NSURL *)fileURL;
{
    return [NSURL fileURLWithPath:self];
}

- (NSString *)encodeURI
{   return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
             (CFStringRef)self,
             NULL,
             (CFStringRef)@"!*'();:@&=+$,/?%#[]",
             kCFStringEncodingUTF8));
}

- (NSString *)decodeURI
{   return (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(
             NULL,
             (CFStringRef)self,
             CFSTR(""),
             kCFStringEncodingUTF8));
}

@end
