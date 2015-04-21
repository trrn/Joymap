//
//  SelectViewController.h
//  Joymap
//
//  Created by faith on 2013/11/09.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectViewController : BaseTableViewController
@property (nonatomic) NSArray *dataSource;
@property (nonatomic) NSInteger initialSelectedIndex;
@property (nonatomic, copy) void (^selectHandler)(NSInteger);

@end
