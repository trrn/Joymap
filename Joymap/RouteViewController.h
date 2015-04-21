//
//  RouteViewController.h
//  Joymap
//
//  Created by faith on 2013/12/15.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Pin;

@interface RouteViewController : BaseTableViewController
@property (nonatomic) Pin *from;
@property (nonatomic) Pin *to;
@end
