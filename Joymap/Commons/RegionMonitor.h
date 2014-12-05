//
//  RegionMonitor.h
//  Joymap
//
//  Created by gli on 2013/11/10.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RegionMonitor : NSObject

+ (instancetype)shared;

- (void)refresh;
- (void)didReceiveLocalNotification:(UILocalNotification *)notification;

+ (BOOL)deviceSupported;
+ (void)debugOutRegions;

@end
