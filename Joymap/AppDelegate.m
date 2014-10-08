//
//  AppDelegate.m
//  Joymap
//
//  Created by gli on 2013/10/13.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import "AppDelegate.h"

#import "RegionMonitor.h"

#import <AFNetworkActivityIndicatorManager.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.

    // background fetch
    //[UIApplication.sharedApplication setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];

    [self firstlaunched];
    
    AFNetworkActivityIndicatorManager.sharedManager.enabled = YES;
    
    [RegionMonitor.shared refresh];

    return YES;
}

- (void)firstlaunched
{
    static NSString *_key = @"FIRST_LAUNCHED";
    
    DLog(@"%d", [DefaultsUtil bool:_key]);
    
    if (![DefaultsUtil bool:_key]) {
        
        // initialize
     
        [DefaultsUtil setBool:NO key:DEF_SET_ETC_AUTOPLAY];
        
        [LocationUtil setup];

        [DefaultsUtil setBool:YES key:_key];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.

    UIApplication.sharedApplication.applicationIconBadgeNumber = -1;
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    //
    // NOTICE
    //
    // this method is never called, when using google maps sdk with background modes (location upadates) is on.
    //
    
    DLog();
    self.backgroundSessionCompletionHandler = completionHandler;
}

//- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
//
//    DLog();
//
//    if (self.settingViewController) {
//        // TODO present self.settingViewController
////        [self.settingViewController jdbUpdateFromBackground];
//    }
//
//    completionHandler(UIBackgroundFetchResultNoData);
//}

@end
