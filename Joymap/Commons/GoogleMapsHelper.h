//
//  GoogleMapsHelper.h
//  Joymap
//
//  Created by faith on 2013/11/09.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <GoogleMaps/GoogleMaps.h>

@interface GoogleMapsHelper : NSObject

+ (NSArray *)mapTypes;
+ (NSArray *)mapTypeNames;
+ (GMSMapViewType)mapType;
+ (NSString *)mapTypeName;
+ (void)setMapType:(NSInteger)i;
+ (NSInteger)mapTypeIndex;
+ (NSString *)mapImageURLWithCoordinate2D:(CLLocationCoordinate2D)co color:(NSString *)color;
@end
