//
//  AppleMapsViewController.m
//  Joymap
//
//  Created by Faith on 2015/04/21.
//  Copyright (c) 2015年 sekken. All rights reserved.
//

#import "AppleMapsViewController.h"

#import "DataSource.h"
#import "Env.h"
#import "GeoSearch.h"
#import "PageViewController.h"
#import "Pin.h"
#import "SearchOnMap.h"
#import "MapAnnotation.h"

#import <UIView+AutoLayout.h>

@import MapKit;

@interface AppleMapsViewController () <MKMapViewDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *searchBarBaseView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *addPinTitleLabel;
//@property (nonatomic) GMSMarker *searchedMarker;
@end

@implementation AppleMapsViewController
{
    NSArray    *pins_;
    
    SearchOnMap *searchOnMap_;
    BOOL        searchBarShouldBeginEditing_;   // search bar clear button control
    
//    GMSMarker  *addMarker_;
    
    NSDate     *lastReloaded_;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
//    _searchedMarker = nil;
    searchBarShouldBeginEditing_ = YES;
    
//    addMarker_ = nil;
    
    lastReloaded_ = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [Theme setSearchBarTextFieldBackground:self.searchBar];

    [self reload];
    
    [self moveCameraToAnyPin];
}

- (void)moveCameraToAnyPin
{
    NSDictionary *config = DataSource.jdbConfig;
    CLLocationCoordinate2D co = CLLocationCoordinate2DMake(35.681382, 139.766084);
    float zoom = 13.0;

    if (config[@"init_zoom"]) {
        NSString *str = [NSString.alloc initWithData:config[@"init_zoom"] encoding:NSUTF8StringEncoding];
        zoom = str.floatValue;
    }

    if (config[@"init_latitude"] && config[@"init_longitude"]) {
        NSString *lat = [NSString.alloc initWithData:config[@"init_latitude"] encoding:NSUTF8StringEncoding];
        NSString *lng = [NSString.alloc initWithData:config[@"init_longitude"] encoding:NSUTF8StringEncoding];
        co.latitude = lat.doubleValue;
        co.longitude = lng.doubleValue;
    }

    _mapView.centerCoordinate = co;

    DLog(@"zoom %f", zoom);
    
    // adjust google maps's ratio(zoom level)
    NSUInteger exp = 0;
    if (zoom >= 0 && zoom < 21) {
        exp = 21 - zoom - 1;
    }
    double delta = 0.001 * pow(1.8, exp);
    DLog(@"delta %f", delta);
    
    MKCoordinateRegion region = _mapView.region;
    region.span.longitudeDelta = delta;
    region.span.latitudeDelta = delta;
    _mapView.region = region;


//    GMSCameraUpdate *upd =
//    [GMSCameraUpdate setTarget:co zoom:zoom];
//    [_mapView animateWithCameraUpdate:upd];
}

- (void)reload
{
    [_mapView removeAnnotations:_mapView.annotations];
    pins_ = DataSource.pins;
    
    for (Pin *p in pins_) {
        MapAnnotation *m = MapAnnotation.new;
        m.coordinate = CLLocationCoordinate2DMake(p.latitude, p.longitude);
        m.title = p.name;
        m.userData = p;
        [_mapView addAnnotation:m];
        p.marker = m;
    }
    
    lastReloaded_ = NSDate.date;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    DLog();
}


- (void)mapView:(MKMapView *)mapView
regionDidChangeAnimated:(BOOL)animated
{
    DLog(@"longitudeDelta %f", mapView.region.span.longitudeDelta);
    DLog(@"latitudeDelta  %f", mapView.region.span.latitudeDelta);
}

@end
