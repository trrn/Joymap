//
//  Setting.m
//  RenaiSpot
//
//  Created by Faith on 2014/10/30.
//  Copyright (c) 2014年 faith. All rights reserved.
//

#import "Setting.h"

#define LAST_SELECTED_SORT_INDEX_FOR_LIST @"LAST_SELECTED_SORT_INDEX_FOR_LIST"
#define LAST_SELECTED_SORT_ORDER_FOR_LIST @"LAST_SELECTED_SORT_ORDER_FOR_LIST"
#define LAST_JDB_UPDATE_CANCELED_DATE @"LAST_JDB_UPDATE_CANCELED_DATE"

@implementation Setting

+ (NSInteger)lastSelectedSortIndexForList;
{
    return [DefaultsUtil int:LAST_SELECTED_SORT_INDEX_FOR_LIST];
}

+ (void)setLastSelectedSortIndexForList:(NSInteger)index;
{
    [DefaultsUtil setInt:index key:LAST_SELECTED_SORT_INDEX_FOR_LIST];
}

+ (BOOL)lastSelectedSortOrderForList;
{
    return [DefaultsUtil bool:LAST_SELECTED_SORT_ORDER_FOR_LIST];
}

+ (void)setLastSelectedSortOrderForList:(BOOL)asc;
{
    [DefaultsUtil setBool:asc key:LAST_SELECTED_SORT_ORDER_FOR_LIST];
}

+ (NSDate *)lastJDBUpdateCanceledDate;
{
    return [DefaultsUtil obj:LAST_JDB_UPDATE_CANCELED_DATE];
}

+ (void)setLastJDBUpdateCanceledDate:(NSDate *)date;
{
    [DefaultsUtil setObj:date key:LAST_JDB_UPDATE_CANCELED_DATE];
}

@end
