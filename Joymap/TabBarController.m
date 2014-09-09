//
//  TabBarController.m
//  Joymap
//
//  Created by gli on 2013/10/13.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import "TabBarController.h"

#import "GoogleMapsViewController.h"

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

@end
