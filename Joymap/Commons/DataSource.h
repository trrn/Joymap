//
//  DataSource.h
//  Joymap
//
//  Created by gli on 2013/10/14.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Jdb.h"
#import "Pin.h"
#import "Layout.h"
#import "Kategory.h"
#import "Item.h"

@interface DataSource : NSObject

+ (void)validateSqliteFile:(NSString *)path;

+ (NSArray *)pins;
+ (NSArray *)pinsOrderByID:(BOOL)asc;
+ (NSArray *)pinsOrderByName:(BOOL)asc;
+ (NSArray *)pinsOrderByDistanceFrom:(CLLocationCoordinate2D *)co;
+ (Pin *)pinByID:(NSInteger)iD;

+ (NSArray *)searchPinsByName:(NSString *)str;
+ (NSArray *)searchPinsByKeyword:(NSString *)str;

+ (NSMutableArray *)layouts:(Pin *)pin;
+ (NSMutableArray *)items:(Layout *)layout;
+ (Item *)itemForSubtitle:(Pin *)pin;
+ (Item *)itemForThumbnail:(Pin *)pin;

+ (id)save:(Pin *)pin;
+ (id)delete:(Pin *)pin;

+ (void)needReload;
+ (NSDate *)updatedDate;

@end
