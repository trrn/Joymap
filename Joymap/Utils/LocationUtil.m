//
//  LocationUtil.m
//  Joymap
//
//  Created by gli on 2013/11/03.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import "LocationUtil.h"

#import <CoreLocation/CoreLocation.h>

#define LOCATION_UTIL_TIMEOUTSEC 10

static volatile BOOL _updated = NO;
static CLLocationCoordinate2D _lastCoordinate;

@interface LocationUtil() <CLLocationManagerDelegate>
@end

@implementation LocationUtil

+ (void)currentLocationWithTimeout:(NSTimeInterval)sec handler:(void (^)(CLLocationCoordinate2D *))handler
{
    CLLocationManager *manager = self.manager;

    if (!manager) {
        handler(NULL);
        return;
    }

    [ProcUtil asyncGlobalq:^{
        @try {
            manager.desiredAccuracy = kCLLocationAccuracyKilometer;
            manager.distanceFilter = 100;
            [manager startUpdatingLocation];
            NSDate *timeout = [NSDate dateWithTimeIntervalSinceNow:sec];
            _updated = NO;
            while ([NSDate.date compare:timeout] == NSOrderedAscending) {
                if (_updated) {
                    handler(&_lastCoordinate);
                    return;
                }
                usleep(100 * 1000); // 0.1 sec
            }
            DLog(@"time out");
            handler(NULL);
        }
        @finally {
            [manager stopUpdatingLocation];
        }
    }];
}

#pragma mark - private

+ (LocationUtil *)singleton
{
    static dispatch_once_t once;
    static LocationUtil *singleton = nil;
    
    dispatch_once(&once, ^{
        singleton = self.new;
    });
    
    return singleton;
}

+ (CLLocationManager *)manager
{
    static dispatch_once_t once;
    static CLLocationManager *manager = nil;

    if (!CLLocationManager.locationServicesEnabled)
        return nil;

    dispatch_once(&once, ^{
        manager = CLLocationManager.new;
        manager.delegate = self.singleton;
    });

    return manager;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = locations.lastObject;
    _lastCoordinate = location.coordinate;
    _updated = YES;
    [manager stopUpdatingLocation];
}

@end
