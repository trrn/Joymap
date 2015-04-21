//
//  NSURLRequest+Sekken.m
//  masd
//
//  Created by faith on 2014/03/16.
//  Copyright (c) 2014年 sekken. All rights reserved.
//

#import "NSURLRequest+Sekken.h"

@implementation NSURLRequest (Sekken)

- (NSURLRequest *)noCache;
{
    NSMutableURLRequest *req = self.mutableCopy;
    req.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    [req setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];
    return req;
}

@end
