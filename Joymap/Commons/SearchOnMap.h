//
//  SearchOnMap.h
//  Joymap
//
//  Created by Faith on 2014/09/05.
//  Copyright (c) 2014年 sekken. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Pin;

@interface SearchOnMap : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id srcViewController;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, copy) void (^didTapRowCallback)(Pin *);

- (void)searchByStr:(NSString *)str;

@end
