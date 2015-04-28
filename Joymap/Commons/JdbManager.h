//
//  JdbManager.h
//  Joymap
//
//  Created by Faith on 2014/09/09.
//  Copyright (c) 2014年 sekken. All rights reserved.
//

@interface JdbManager : AFHTTPSessionManager

#define JDB_DOWNLOAD_SUCCEEDED @"JDB_DOWNLOAD_SUCCEEDED"

+ (instancetype)shared;
- (void)downloadWithRequest:(NSURLRequest *)request progress:(void(^)(double))progress finished:(void(^)())finished;
- (void)cancel;

@end
