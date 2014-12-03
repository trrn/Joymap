//
//  UpdateCheckManager.m
//  Joymap
//
//  Created by Faith on 2014/11/18.
//  Copyright (c) 2014年 sekken. All rights reserved.
//

#import "UpdateCheckManager.h"

@implementation UpdateCheckManager

+ (void)check
{
    if ([StringUtil empty:Env.updateCheckActionUrl] ||
        [StringUtil empty:Env.user] ||
        [StringUtil empty:Env.map]) {
        return;
    }

    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager manager];
    [manager POST:Env.updateCheckActionUrl
      parameters:@{@"user":Env.user, @"map":Env.map}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
          Log(@"response: %@", responseObject);
             if ([self needUpdate:responseObject]) {
                 [self notify];
             }
      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          DLog(@"Error: %@", error);
      }];
}

+ (BOOL)needUpdate:(NSDictionary *)json
{
    if (!json) {
        return NO;
    }

    NSNumber *ver = json[@"version"];
    if (!ver) {
        return NO;
    }

    NSInteger remote = [ver integerValue];
    if (remote == 0) {
        return NO;
    }

    if (remote == Env.JDBInitialVersion) {
        return NO;
    }

    NSInteger local = [DefaultsUtil int:JDB_VERSION];

    return remote != local;
}

+ (void)notify
{
    NSNotification *notification =
    [NSNotification notificationWithName:JDB_NEED_UPDATE
                                  object:nil
                                userInfo:nil];
    [NSNotificationCenter.defaultCenter postNotification:notification];
}

@end
