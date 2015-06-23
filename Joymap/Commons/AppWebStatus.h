//
//  AppWebStatus.h
//  Joymap
//
//  Created by Faith on 2015/06/11.
//  Copyright (c) 2015年 sekken. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

#define APP_WEB_STATUS_UPDATED @"APP_WEB_STATUS_UPDATED"

@interface AppWebStatus : AFHTTPRequestOperationManager

@property (nonatomic) NSDictionary *status;

+ (instancetype)shared;

- (void)sync;

@end
