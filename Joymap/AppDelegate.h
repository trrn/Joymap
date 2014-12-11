//
//  AppDelegate.h
//  Joymap
//
//  Created by gli on 2013/10/13.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SettingViewController.h"

#define TAP_NOTIFICATION_AREA @"TAP_NOTIFICATION_AREA"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (copy) void (^backgroundSessionCompletionHandler)();

@end

@interface UserEmailStubWorkaround : NSObject
@property(nonatomic, readonly) NSString *userEmail;
@end
