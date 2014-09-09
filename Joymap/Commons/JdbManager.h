//
//  JdbManager.h
//  Joymap
//
//  Created by Faith on 2014/09/09.
//  Copyright (c) 2014年 sekken. All rights reserved.
//

@interface JdbManager : AFHTTPSessionManager

+ (instancetype)shared;
- (void)downloadWithProgress:(void(^)(double))progress finished:(void(^)())finished;
- (void)cancel;

@end
