//
//  SearchOnMap.h
//  Joymap
//
//  Created by Faith on 2014/09/05.
//  Copyright (c) 2014年 sekken. All rights reserved.
//

#import <Foundation/Foundation.h>

@import MapKit;

@class Pin;

@interface SearchOnMap : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id srcViewController;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, copy) void (^didTapRowCallback)(id);
@property (nonatomic) MKCoordinateRegion region;

- (void)searchByStr:(NSString *)str;

@end
