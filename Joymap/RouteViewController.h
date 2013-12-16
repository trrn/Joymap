//
//  RouteViewController.h
//  Joymap
//
//  Created by gli on 2013/12/15.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Pin;

@interface RouteViewController : UITableViewController
@property (nonatomic) Pin *from;
@property (nonatomic) Pin *to;
@end
