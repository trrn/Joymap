//
//  TabBarController.m
//  Joymap
//
//  Created by gli on 2013/10/13.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import "TabBarController.h"

#import "AppDelegate.h"
#import "GoogleMapsViewController.h"
#import "JdbManager.h"
#import "UpdateCheckManager.h"

#import <NIKFontAwesomeIconFactory.h>
#import <NIKFontAwesomeIconFactory+iOS.h>

@interface TabBarController ()

@end

@implementation TabBarController

- (void)awakeFromNib
{
    [super awakeFromNib];

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
    [ProcUtil asyncMainqDelay:1 block:^{
        UITabBarItem *item = [self.tabBar.items objectAtIndex:2];
        item.badgeValue = @"Update";
    }];
}

- (void)jdbUpdated
{
    [ProcUtil asyncMainqDelay:1 block:^{
        UITabBarItem *item = [self.tabBar.items objectAtIndex:2];
        item.badgeValue = nil;
    }];    
}

@end
