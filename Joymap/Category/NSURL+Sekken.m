//
//  NSURL+Sekken.m
//  masd
//
//  Created by faith on 2014/03/16.
//  Copyright (c) 2014年 sekken. All rights reserved.
//

#import "NSURL+Sekken.h"

@implementation NSURL (Sekken)

- (NSURLRequest *)request;
{
    return [NSURLRequest requestWithURL:self];
}

@end
