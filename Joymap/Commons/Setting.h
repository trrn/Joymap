//
//  Setting.h
//  RenaiSpot
//
//  Created by Faith on 2014/10/30.
//  Copyright (c) 2014年 faith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Setting : NSObject

+ (NSInteger)lastSelectedSortIndexForList;
+ (void)setLastSelectedSortIndexForList:(NSInteger)index;

+ (BOOL)lastSelectedSortOrderForList;
+ (void)setLastSelectedSortOrderForList:(BOOL)asc;

+ (NSDate *)lastJDBUpdateCanceledDate;
+ (void)setlastJDBUpdateCanceledDate:(NSDate *)date;

@end
