//
//  UpdateCheckManager.h
//  Joymap
//
//  Created by Faith on 2014/11/18.
//  Copyright (c) 2014年 sekken. All rights reserved.
//

#import <AFNetworking.h>

#define JDB_NEED_UPDATE @"JDB_NEED_UPDATE"
#define JDB_VERSION @"JDB_VERSION"

@interface UpdateCheckManager : AFHTTPRequestOperationManager

+ (void)check;

@end
