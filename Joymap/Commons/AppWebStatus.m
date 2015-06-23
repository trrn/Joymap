//
//  AppWebStatus.m
//  Joymap
//
//  Created by Faith on 2015/06/11.
//  Copyright (c) 2015年 sekken. All rights reserved.
//

#import "AppWebStatus.h"

#define APP_WEB_STATUS @"APP_WEB_STATUS"

@implementation AppWebStatus

+ (instancetype)shared;
{
    static AppWebStatus *_shared = nil;
    static dispatch_once_t once;

    dispatch_once(&once, ^{
        if (!_shared) {
            _shared = self.new;
            _shared.status = [DefaultsUtil obj:APP_WEB_STATUS];
        }
    });

    return _shared;
}

- (void)sync
{
    DLog(@"Env.adUnitIDActionUrl %@", Env.adUnitIDActionUrl);

    if ([StringUtil empty:Env.adUnitIDActionUrl] ||
        [StringUtil empty:Env.user] ||
        [StringUtil empty:Env.map]) {
        return;
    }

    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager manager];
    [manager POST:Env.adUnitIDActionUrl
       parameters:@{@"user":Env.user, @"map":Env.map}
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              Log(@"response: %@", responseObject);

              if ([responseObject isKindOfClass:NSDictionary.class]) {
                  [DefaultsUtil setObj:responseObject key:APP_WEB_STATUS];
                  self.status = responseObject;
              }

              [self notify];

          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              DLog(@"Error: %@", error);
          }];
}

- (void)notify
{
    NSNotification *notification =
    [NSNotification notificationWithName:APP_WEB_STATUS_UPDATED
                                  object:nil
                                userInfo:nil];
    [NSNotificationCenter.defaultCenter postNotification:notification];
}

@end
