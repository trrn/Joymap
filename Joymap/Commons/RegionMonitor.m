//
//  RegionMonitor.m
//  Joymap
//
//  Created by gli on 2013/11/10.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import "RegionMonitor.h"

#import "DataSource.h"

#import <CoreLocation/CoreLocation.h>

#define REGION_MONITORING_MAX 10
#define REGION_MONITORING_RADIUS_METERS 30.0

@interface RegionMonitor() <CLLocationManagerDelegate>
@end

@implementation RegionMonitor

+ (instancetype)shared;
{
    static RegionMonitor *_shared = nil;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        if (!_shared) {
            _shared = self.new;
        }
    });
    
    return _shared;
}


- (void)refresh;
{
    [RegionMonitor.shared runSilently:YES];
}

- (void)refreshWithAlertIfCannot;
{
    [RegionMonitor.shared runSilently:NO];
}

+ (BOOL)deviceSupported
{
    return [CLLocationManager isMonitoringAvailableForClass:CLCircularRegion.class];
}

- (void)runSilently:(BOOL)silently
{
    DLog();

    if ([DefaultsUtil bool:DEF_SET_NOTIFY_SPOT]) {
        if (self.authorized) {
            [RegionMonitor.shared start];
        } else {
            if (!silently) {
                Alert(nil, NSLocalizedString(@"This application is not authorized to use location services.", nil));
            }
        }
    } else {
        [RegionMonitor.shared stop];
    }
}

- (BOOL)authorized
{
    if (CLLocationManager.locationServicesEnabled) {
        if ([Version greaterThanOrEqualMajorVersion:8 minorVersion:0 patchVersion:0]) {
            return CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedAlways;
        } else {
            return CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorized;
        }
    }
    
    return NO;
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        [RegionMonitor.shared runSilently:YES];
    }
}

+ (CLLocationManager *)manager
{
    static dispatch_once_t once;
    static CLLocationManager *_manager;

    dispatch_once(&once, ^{
        if (!_manager) {
            _manager = CLLocationManager.new;
            _manager.delegate = self.shared;
            if ([Version greaterThanOrEqualMajorVersion:8 minorVersion:0 patchVersion:0]) {
                [_manager requestAlwaysAuthorization];
            }
        }
    });

    return _manager;
}

- (void)start
{
    CLLocationManager *manager = RegionMonitor.manager;
    
    DLog("monitoring %ld regions", (unsigned long)manager.monitoredRegions.count)
    
    manager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    manager.distanceFilter = kCLDistanceFilterNone;
    [manager startMonitoringSignificantLocationChanges];
    DLog(@"startMonitoringSignificantLocationChanges");
    [manager startUpdatingLocation];
    DLog(@"startUpdatingLocation");
}

- (void)stop;
{
    CLLocationManager *manager = RegionMonitor.manager;
    
    DLog("monitoring %ld regions", (unsigned long)manager.monitoredRegions.count)

    [manager stopUpdatingLocation];
    DLog(@"stopUpdatingLocation");
    [manager stopMonitoringSignificantLocationChanges];
    DLog(@"stopMonitoringSignificantLocationChanges");
    for (CLRegion *region in manager.monitoredRegions) {
        [manager stopMonitoringForRegion:region];
    }
    DLog(@"delete regions");
}

- (void)notify:(Pin *)pin
{
    UILocalNotification *n = UILocalNotification.new;
    n.alertBody = [NSString stringWithFormat:NSLocalizedString(@"close to a region", nil), pin.name];
    //n.applicationIconBadgeNumber = 1;
    n.timeZone = [NSTimeZone localTimeZone];
    n.soundName = UILocalNotificationDefaultSoundName;
    n.userInfo = @{@"id": @(pin.id)};
    [UIApplication.sharedApplication presentLocalNotificationNow:n];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    @synchronized(self) {
        [manager stopUpdatingLocation];
        DLog(@"stopUpdatingLocation");
        
        // delete all
        for (CLRegion *region in manager.monitoredRegions) {
            [manager stopMonitoringForRegion:region];
        }
        DLog(@"delete regions");
        
        // registor regions
        CLLocationCoordinate2D co = [locations.lastObject coordinate];
        NSArray *pins = [DataSource pinsOrderByDistanceFrom:&co];
        NSInteger n = 0;
        for (Pin *pin in [pins objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, REGION_MONITORING_MAX)]]) {
            CLCircularRegion *region = [CLCircularRegion.alloc initWithCenter:pin.coordinate radius:REGION_MONITORING_RADIUS_METERS identifier:[NSString stringWithFormat:@"%ld", (unsigned  long)pin.id]];
            [manager startMonitoringForRegion:region];
            ++n;
        }
        DLog(@"add %ld regions", (unsigned long)n);
        
        for (CLRegion *region in manager.monitoredRegions) {
            [manager requestStateForRegion:region];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    DLog();
    Pin *pin = [DataSource pinByID:region.identifier.integerValue];
    if (pin) {
        [self notify:pin];
    }
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    ELog(@"%@", error);
}

#pragma mark - Debug

+ (void)debugOutRegions;
{
    CLLocationManager *manager = CLLocationManager.new;

    NSString *str = @"";
    NSInteger n = 0;
    for (CLRegion *region in manager.monitoredRegions) {
        Pin *pin = [DataSource pinByID:region.identifier.integerValue];
        NSString *tmp = [NSString stringWithFormat:@"%ld:%@\n", (unsigned long)n, pin.name];
        str = [str stringByAppendingString:tmp];
        ++n;
    }

    Alert(nil, @"%@", str);
}

@end
