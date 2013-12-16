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

//    UIEdgeInsets insets = { 0.0, -10.0, -10.0, -5.0 };
//    for (UIBarItem *i in self.tabBar.items) {
//        i.imageInsets = insets;
//    }

    NIKFontAwesomeIconFactory *factory = [NIKFontAwesomeIconFactory tabBarItemIconFactory];
    UITabBarItem *item;
    
    item = self.tabBar.items[0];
    item.image = [factory createImageForIcon:NIKFontAwesomeIconHome];
    
    item = self.tabBar.items[1];
    item.image = [factory createImageForIcon:NIKFontAwesomeIconMapMarker];
    
    item = self.tabBar.items[2];
    item.image = [factory createImageForIcon:NIKFontAwesomeIconList];
    
    item = self.tabBar.items[3];
    item.image = [factory createImageForIcon:NIKFontAwesomeIconCog];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)selectPin:(id)pin;
{
    self.selectedIndex = 1;
    UINavigationController *nvc = self.viewControllers[1];
    GoogleMapsViewController *gvc = (GoogleMapsViewController *)nvc.topViewController;
    [gvc selectPin:pin];
}

@end
