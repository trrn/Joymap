//
//  JMTableViewCell.h
//  Renai
//
//  Created by Faith on 2014/09/12.
//  Copyright (c) 2014年 faith. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ListViewController.h"

#define JM_LIST_THUMBNAIL_SIZE 52

@interface JMTableViewCell : UITableViewCell
@property (weak, nonatomic) ListViewController *listViewController;
@property (weak, nonatomic) Pin *pin;
@end
