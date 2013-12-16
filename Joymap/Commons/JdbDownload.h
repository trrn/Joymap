//
//  JdbDownload.h
//  Joymap
//
//  Created by gli on 2013/10/23.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JdbDownload : NSObject

@property (nonatomic, copy) void (^progressHandler)(double);
@property (nonatomic, copy) void (^completionHandler)();

+ (JdbDownload *)singleton;

- (void)start;
- (void)cancel;

@end
