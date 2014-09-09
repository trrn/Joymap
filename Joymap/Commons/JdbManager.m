//
//  JdbManager.m
//  Joymap
//
//  Created by Faith on 2014/09/09.
//  Copyright (c) 2014年 sekken. All rights reserved.
//

#import "JdbManager.h"

#import <AFJSONRequestOperation.h>

@implementation JdbManager

+ (instancetype)shared;
{
    static JdbManager *_shared = nil;
    static dispatch_once_t once;

    dispatch_once(&once, ^{
        if (!_shared) {
            _shared = self.new;
        }
    });
    
    return _shared;
}

- (void)downloadWithProgress:(void(^)(double))progress finished:(void(^)())finished;
{
    AFHTTPRequestOperation *ope =[AFHTTPRequestOperation.alloc initWithRequest:Env.downloadRequest.noCache];
    
    [ope setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        if (progress) {
            progress(totalBytesRead / totalBytesExpectedToRead);
        }
    }];
    
    [ope setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        DLog(@"download size %@", responseObject);

        // TODO

        
        if (finished) {
            finished();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        ELog(@"download failed. %@", error);
        if (finished) {
            finished();
        }
    }];
    
    [self enqueueHTTPRequestOperation:ope];
}

@end
