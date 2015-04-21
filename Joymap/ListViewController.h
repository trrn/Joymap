//
//  ListViewController.h
//  Joymap
//
//  Created by faith on 2013/10/21.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Pin;

@interface ListViewController : BaseTableViewController
- (void)reload;
- (void)tapCellButton:(Pin *)pin;
@end
