//
//  TabBarController.m
//  Joymap
//
//  Created by faith on 2013/10/13.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import "TabBarController.h"

#import "AppDelegate.h"
#import "GoogleMapsViewController.h"
#import "JdbManager.h"
#import "JdbDownloadController.h"
#import "UpdateCheckManager.h"

#import <NIKFontAwesomeIconFactory.h>
#import <NIKFontAwesomeIconFactory+iOS.h>

@interface TabBarController ()

@end

@implementation TabBarController

- (void)awakeFromNib
{
    [super awakeFromNib];

    AppDelegate *appDelegate = (AppDelegate *)UIApplication.sharedApplication.delegate;
    appDelegate.openURLHandler = self;

    if ([StringUtil present:Env.googleMapsApiKey]) {
        self.viewControllers = @[
             [UIStoryboard viewControllerWithID:@"GoogleMapsNavigationController"],
             [UIStoryboard viewControllerWithID:@"ListNavigationController"],
             [UIStoryboard viewControllerWithID:@"SettingNavigationController"],
             ];
    } else {
        self.viewControllers = @[
             [UIStoryboard viewControllerWithID:@"AppleMapsNavigationController"],
             [UIStoryboard viewControllerWithID:@"ListNavigationController"],
             [UIStoryboard viewControllerWithID:@"SettingNavigationController"],
             ];
    }

    NIKFontAwesomeIconFactory *factory = [NIKFontAwesomeIconFactory tabBarItemIconFactory];
    UITabBarItem *item;
    
    NSInteger i = 0;
    
    item = self.tabBar.items[i++];
    item.image = [factory createImageForIcon:NIKFontAwesomeIconMapMarker];
    
    item = self.tabBar.items[i++];
    item.image = [factory createImageForIcon:NIKFontAwesomeIconList];
    
    item = self.tabBar.items[i++];
    item.image = [factory createImageForIcon:NIKFontAwesomeIconCog];
    
    [Theme setTabBarColor:self.tabBar];

    [NSNotificationCenter.defaultCenter
     addObserver:self
     selector:@selector(jdbNeedUpdate)
     name:JDB_NEED_UPDATE
     object:nil];
    
    [NSNotificationCenter.defaultCenter
     addObserver:self
     selector:@selector(jdbUpdated)
     name:JDB_DOWNLOAD_SUCCEEDED
     object:nil];
    
    [NSNotificationCenter.defaultCenter
     addObserver:self
     selector:@selector(selectPinBy:)
     name:TAP_NOTIFICATION_AREA
     object:nil];
}

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)selectPin:(id)pin;
{
    self.selectedIndex = 0; // map
    UINavigationController *nvc = self.viewControllers[0];
    GoogleMapsViewController *gvc = (GoogleMapsViewController *)nvc.topViewController;
    [gvc selectPin:pin];
}

- (void)selectPinBy:(NSNotification *)notification;
{
    if (notification && notification.userInfo && notification.userInfo[@"id"]) {
        self.selectedIndex = 0; // map
        UINavigationController *nvc = self.viewControllers[0];
        if ([nvc.topViewController isMemberOfClass:GoogleMapsViewController.class]) {
            GoogleMapsViewController *gvc = (GoogleMapsViewController *)nvc.topViewController;
            [gvc selectPinByID:[notification.userInfo[@"id"] integerValue]];
        }
    }
}

- (void)jdbNeedUpdate
{
    NSDate *lastCanceled = [Setting lastJDBUpdateCanceledDate];

    if (lastCanceled && ([NSDate.date timeIntervalSinceDate:lastCanceled] < (60*60*24))) {  // 1day
        DLog(@"update alert skipped");
        return;
    }

    [ProcUtil asyncMainqDelay:1 block:^{
        UIAlertView *alertView = [UIAlertView.alloc initWithTitle:nil
                message:NSLocalizedString(@"Spot data has been updated. Do you want to update now?", nil)
               delegate:self
      cancelButtonTitle:NSLocalizedString(@"No", nil)
      otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
        [alertView show];
    }];
}

-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: {   // No
            [Setting setLastJDBUpdateCanceledDate:NSDate.date];
            break;
        }
        case 1: {   // Yes
            JdbDownloadController *vc = [UIStoryboard viewControllerWithID:@"JdbDownloadController"];
            vc.request = Env.downloadRequest;
            [self presentViewController:vc animated:YES completion:^{
                [Setting setLastJDBUpdateCanceledDate:nil];
            }];
            break;
        }
    }
}

- (void)jdbUpdated
{
//    [ProcUtil asyncMainqDelay:1 block:^{
//        UITabBarItem *item = [self.tabBar.items objectAtIndex:2];
//        item.badgeValue = nil;
//    }];
}

#pragma mark - open url handler

- (void)handleURL:(NSURL *)url
{
    DLog(@"%@", url);
    if ([url.host isEqualToString:@"download_jdb"] && [StringUtil present:url.query]) {
        JdbDownloadController *vc = [UIStoryboard viewControllerWithID:@"JdbDownloadController"];
        vc.request = [Env downloadRequestWithHash:url.query];
        [self presentViewController:vc animated:YES completion:nil];
    }
}

@end
