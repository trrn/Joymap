//
//  Pin.h
//  Joymap
//
//  Created by faith on 2013/10/14.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Pin : NSObject <NSCopying>

@property (nonatomic) NSInteger  id;
@property (nonatomic) double     latitude;
@property (nonatomic) double     longitude;
@property (nonatomic) NSString  *name;
@property (nonatomic) NSInteger  kategoryId;
@property (nonatomic) NSMutableArray *layouts;

@property(nonatomic, weak) id marker;

- (void)thumbnail:(UITableViewCell *)cell;
- (void)subtitle:(UITableViewCell *)cell;

- (CLLocationCoordinate2D)coordinate;
- (NSString *)coordinateStr;

+ (void)clearCache;

#pragma mark - persistence

- (void)beforeSave;

@end
