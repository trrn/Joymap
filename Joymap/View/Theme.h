//
//  Theme.h
//  Joymap
//
//  Created by Faith on 2014/10/30.
//  Copyright (c) 2014年 sekken. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Theme : NSObject

+ (void)setup;

+ (void)setTabBarColor:(UITabBar *)tabBar;

+ (void)setNavigationBarColor:(UINavigationBar *)bar;

+ (void)setBackgroundColor:(UIView *)view;

+ (void)setTableViewCellBackgroundColor:(UITableViewCell *)cell;
+ (void)setTableViewCellSelectedBackgroundColor:(UITableViewCell *)cell;

+ (void)setSoundButtonPlay:(UIButton *)button;
+ (void)setSoundButtonPause:(UIButton *)button;

+ (void)setSearchBarTextFieldBackground:(UISearchBar *)searchBar;
+ (void)setSearchBarNavigationButton:(UISearchBar *)searchBar;

+ (void)setListSegmentedControl:(UISegmentedControl *)segmentedControl;

@end
