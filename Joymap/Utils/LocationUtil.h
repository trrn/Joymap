//
//  LocationUtil.h
//  Joymap
//
//  Created by gli on 2013/11/03.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocationUtil : NSObject

+ (void)currentLocationWithTimeout:(NSTimeInterval)sec handler:(void (^)(CLLocationCoordinate2D *))handler;

@end
