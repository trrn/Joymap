//
//  GMSMapViewController.m
//  Joymap
//
//  Created by faith on 2013/11/16.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import "GMSMapViewController.h"

#import "Pin.h"

#import <GoogleMaps/GoogleMaps.h>

@interface GMSMapViewController () <GMSMapViewDelegate>
@property (strong, nonatomic) IBOutlet GMSMapView *mapView;
@end

@implementation GMSMapViewController
{
    GMSMarker *marker_;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _mapView.myLocationEnabled = YES;
    _mapView.settings.compassButton = YES;
    _mapView.settings.myLocationButton = YES;
    _mapView.delegate = self;

    CLLocationCoordinate2D co = { _pin.latitude, _pin.longitude };

    marker_ = GMSMarker.new;
    marker_.icon = [GMSMarker markerImageWithColor:
                    _pin.id == 0 ? UIColor.blueColor : UIColor.redColor];
    marker_.position = co;
    marker_.map = _mapView;
    marker_.draggable = YES;

    _mapView.camera = [GMSCameraPosition cameraWithTarget:co zoom:19];
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate;
{
    marker_.position = coordinate;
}

- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate;
{
    marker_.position = coordinate;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    DLog();
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ChangeLocationDone"]) {
        _pin.latitude = marker_.position.latitude;
        _pin.longitude = marker_.position.longitude;
    }
}

@end
