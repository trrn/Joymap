//
//  HttpUtil.m
//  Joymap
//
//  Created by faith on 2013/10/15.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import "HttpUtil.h"

@implementation HttpUtil

+ (NSString *)encodeURI:(NSString *)s
{   return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                 (CFStringRef)s,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                 kCFStringEncodingUTF8));
}

+ (NSString *)decodeURI:(NSString *)s
{   return (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(
                                                                                                 NULL,
                                                                                                 (CFStringRef)s,
                                                                                                 CFSTR(""),
                                                                                                 kCFStringEncodingUTF8));
}

+ (NSDictionary *)jsonDataToDict:(NSData *)data error:(NSError **)error
{
    NSError *err = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                         options:NSJSONReadingAllowFragments
                                                           error:&err];
    if (err && error) {
        *error = err;
        return nil;
    }

    return dict;
}

@end
