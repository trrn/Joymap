//
//  Setting.m
//  RenaiSpot
//
//  Created by Faith on 2014/10/30.
//  Copyright (c) 2014年 faith. All rights reserved.
//

#import "Setting.h"

#define LAST_SELECTED_SORT_INDEX_FOR_LIST @"LAST_SELECTED_SORT_INDEX_FOR_LIST"
@implementation Setting

+ (NSInteger)lastSelectedSortIndexForList;
{
    return [DefaultsUtil int:LAST_SELECTED_SORT_INDEX_FOR_LIST];
}

+ (void)setLastSelectedSortIndexForList:(NSInteger)index;
{
    [DefaultsUtil setInt:index key:LAST_SELECTED_SORT_INDEX_FOR_LIST];
}

@end