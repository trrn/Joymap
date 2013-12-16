//
//  GeoUtil.h
//  Joymap
//
//  Created by gli on 2013/11/02.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CLLocation.h>

@interface GeoUtil : NSObject
+ (BOOL)strToCoordinate2D:(NSString *)str co:(CLLocationCoordinate2D *)co;
+ (NSString *)coordinate2DtoStr:(CLLocationCoordinate2D)co;
+ (void)searchByStr:(NSString *)str handler:(void(^)(NSArray *, NSError *))handler;

#pragma mark - Google

+ (NSString *)GoogleGeoLangName;
+ (NSString *)GoogleGeoLangCode;
+ (NSString *)GoogleGeoLangCodeByLang;
+ (NSArray *)GoogleGeoLangs;

@end
