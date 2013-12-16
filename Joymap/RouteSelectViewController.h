//
//  RouteSelectViewController.h
//  Joymap
//
//  Created by gli on 2013/12/15.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Pin;

@interface RouteSelectViewController : UITableViewController
@property (nonatomic, copy) void (^selectHandler)(Pin *);
@end
