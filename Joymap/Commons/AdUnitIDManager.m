//
//  AdUnitIDManager.m
//  Joymap
//
//  Created by Faith on 2015/04/14.
//  Copyright (c) 2015年 sekken. All rights reserved.
//

#import "AdUnitIDManager.h"

@implementation AdUnitIDManager

+ (void)check
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
              
              NSString *unitID = @"";
              if ([StringUtil present:responseObject[@"unit_id"]]) {
                  unitID = responseObject[@"unit_id"];
              }
              [DefaultsUtil setObj:unitID key:AD_UNIT_ID];
              [self notify];

                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              DLog(@"Error: %@", error);
          }];
}

+ (void)notify
{
    NSNotification *notification =
    [NSNotification notificationWithName:AD_UNIT_ID_NEED_UPDATE
                                  object:nil
                                userInfo:nil];
    [NSNotificationCenter.defaultCenter postNotification:notification];
}

@end
