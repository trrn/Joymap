//
//  Layout.h
//  Joymap
//
//  Created by gli on 2013/10/14.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Layout : NSObject <NSCopying>

@property (nonatomic) NSInteger id;
@property (nonatomic) NSInteger pinId;
@property (nonatomic) NSInteger kind;
@property (nonatomic) NSInteger orderNo;
@property (nonatomic) NSMutableArray  *items;

- (void)summaryForCell:(UITableViewCell *)cell;

#pragma mark - persistence

- (void)beforeSave;

@end
