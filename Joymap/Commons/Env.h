//
//  Env.h
//  Joymap
//
//  Created by gli on 2013/10/14.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Env : NSObject

+ (NSString *)homeUrl;

+ (NSString *)downloadUrl;

+ (NSString *)jdbIdHeader;

+ (NSString *)googleMapsApiKey;

+ (NSString *)googleBrowserApiKey;

+ (NSString *)googleMapsImageApiKey;

+ (BOOL)enableEdit;


+ (NSURLRequest *)downloadRequest;

+ (NSString *)user;
+ (NSString *)map;
+ (NSString *)updateCheckActionUrl;

+ (NSInteger)JDBInitialVersion;

+ (UIColor *)SearchedMarkerColor;

@end
