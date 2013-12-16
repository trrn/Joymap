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

static CLLocationManager *_manager;
static RegionMonitor *_instance;

@interface RegionMonitor() <CLLocationManagerDelegate>
@end

@implementation RegionMonitor

+ (void)refresh;
{
    [self runSilently:YES];
}

+ (void)refreshWithAlertIfCannot;
{
    [self runSilently:NO];
}

+ (BOOL)deviceSupported
{
    return [CLLocationManager isMonitoringAvailableForClass:CLCircularRegion.class];
}

+ (void)runSilently:(BOOL)silently
{
    DLog();

    if (([DefaultsUtil bool:DEF_SET_NOTIFY_SPOT]) && ([self canRunSilently:silently])) {
        [self start];
    } else {
        [self stop];
    }
}

+ (void)start
{
    if (!_manager)
        _manager = CLLocationManager.new;

    DLog("monitoring %d regions", _manager.monitoredRegions.count)

    if (!_instance) {
        _instance = self.new;
    }

    _manager.delegate = _instance;

    _manager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    _manager.distanceFilter = kCLDistanceFilterNone;
    [_manager startMonitoringSignificantLocationChanges];
    DLog(@"startMonitoringSignificantLocationChanges");
    [_manager startUpdatingLocation];
    DLog(@"startUpdatingLocation");
}

+ (void)stop;
{
    if (!_manager)
        _manager = CLLocationManager.new;

    DLog("monitoring %d regions", _manager.monitoredRegions.count)

    [_manager stopUpdatingLocation];
    DLog(@"stopUpdatingLocation");
    [_manager stopMonitoringSignificantLocationChanges];
    DLog(@"stopMonitoringSignificantLocationChanges");
    for (CLRegion *region in _manager.monitoredRegions) {
        [_manager stopMonitoringForRegion:region];
    }
    DLog(@"delete regions");
}

+ (BOOL)canRunSilently:(BOOL)silently
{
    if (!self.deviceSupported) {
        if (!silently) {
            Alert(nil, NSLocalizedString(@"This device do not support region monitoring.", nil));
        }
        return NO;
    }
    
    if (CLLocationManager.authorizationStatus != kCLAuthorizationStatusAuthorized) {
        if (!silently) {
            Alert(nil, NSLocalizedString(@"This application is not authorized to use location services.", nil));
        }
        return NO;
    }
    
    if (!CLLocationManager.locationServicesEnabled) {
        if (!silently) {
            Alert(nil, NSLocalizedString(@"Location services are not enabled on this device.", nil));
        }
        return NO;
    }

    return YES;
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
        [_manager stopUpdatingLocation];
        DLog(@"stopUpdatingLocation");
        
        // delete all
        for (CLRegion *region in _manager.monitoredRegions) {
            [_manager stopMonitoringForRegion:region];
        }
        DLog(@"delete regions");
        
        // registor regions
        CLLocationCoordinate2D co = [locations.lastObject coordinate];
        NSArray *pins = [DataSource pinsOrderByDistanceFrom:&co];
        NSInteger n = 0;
        for (Pin *pin in [pins objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, REGION_MONITORING_MAX)]]) {
            CLCircularRegion *region = [CLCircularRegion.alloc initWithCenter:pin.coordinate radius:REGION_MONITORING_RADIUS_METERS identifier:[NSString stringWithFormat:@"%d", pin.id]];
            [_manager startMonitoringForRegion:region];
            ++n;
        }
        DLog(@"add %d regions", n);
        
        for (CLRegion *region in _manager.monitoredRegions) {
            [_manager requestStateForRegion:region];
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

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    DLog();
    if (UIApplication.sharedApplication.applicationState == UIApplicationStateBackground) {
        [self.class runSilently:YES];
    }
}

#pragma mark - Debug

+ (void)debugOutRegions;
{
    CLLocationManager *manager = CLLocationManager.new;

    NSString *str = @"";
    NSInteger n = 0;
    for (CLRegion *region in manager.monitoredRegions) {
        Pin *pin = [DataSource pinByID:region.identifier.integerValue];
        NSString *tmp = [NSString stringWithFormat:@"%d:%@\n", n, pin.name];
        str = [str stringByAppendingString:tmp];
        ++n;
    }

    Alert(nil, @"%@", str);
}

@end
