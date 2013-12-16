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

+ (NSString *)googleMapsImageApiKey;

+ (BOOL)enableEdit;

@end
