//
//  GeoSearch.h
//  Joymap
//
//  Created by gli on 2013/11/02.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GeoSearch : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id srcViewController;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, copy) void (^didTapRowCallback)(CLLocationCoordinate2D, NSString *);

- (void)searchByStr:(NSString *)str;

@end
