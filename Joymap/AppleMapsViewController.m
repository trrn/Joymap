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

@property (nonatomic) MKPointAnnotation *searchedMarker;
@property (nonatomic) UITableView *tableView;
@end

@implementation AppleMapsViewController
{
    NSArray    *pins_;
    
    SearchOnMap *searchOnMap_;
    BOOL        searchBarShouldBeginEditing_;   // search bar clear button control

    NSDate     *lastReloaded_;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _searchedMarker = nil;
    searchBarShouldBeginEditing_ = YES;

    lastReloaded_ = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _searchedMarker = MKPointAnnotation.new;

    searchOnMap_ = SearchOnMap.new;
    searchOnMap_.srcViewController = self;
    self.tableView = [UITableView autoLayoutView];
    self.tableView.delegate = searchOnMap_;
    self.tableView.dataSource = searchOnMap_;
    [self.view addSubview:self.tableView];
    [self.tableView pinToSuperviewEdges:JRTViewPinAllEdges inset:0.0];

    searchOnMap_.tableView = self.tableView;
    __weak typeof(self) _self = self;
    searchOnMap_.didTapRowCallback = ^(id resOrPin) {
        _self.searchBar.showsCancelButton = NO;
        [_self.searchBar resignFirstResponder];
        if ([resOrPin isKindOfClass:Pin.class]) {
            [_self selectPin:resOrPin];
        } else {  // searched geo location
            if (_self.searchedMarker) {
                [_self.mapView removeAnnotation:_self.searchedMarker];
            }
            _self.searchedMarker = MKPointAnnotation.new;
            CLLocationCoordinate2D co;
            [GeoUtil strToCoordinate2D:resOrPin[@"latlng"] co:&co];
            _self.searchedMarker.coordinate = co;
            _self.searchedMarker.title = resOrPin[@"title"] ?: resOrPin[@"addr"];
            [_self.mapView addAnnotation:_self.searchedMarker];
            [_self focusMarker:_self.searchedMarker];
        }
    };

    [self.view bringSubviewToFront:self.tableView];
    self.tableView.hidden = YES;
    
    searchBarShouldBeginEditing_ = YES;

    [Theme setSearchBarTextFieldBackground:self.searchBar];

    [self reload];

    [self moveCameraToAnyPin];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([TimeUtil earlier:lastReloaded_ than:DataSource.updatedDate]) {
        [self reload];
    }
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showDetailFromAppleMap"]) {
        MapAnnotation *marker = sender;
        Pin *p = marker.userData;
        [[segue destinationViewController] setPin:p.copy];
    }
}

#pragma mark - public

- (void)focusMarker:(MKPointAnnotation *)marker
{
    MKCoordinateRegion region;
    region.center = marker.coordinate;
    
    MKCoordinateSpan span = _mapView.region.span;
    double delta = fmax(span.latitudeDelta, span.longitudeDelta);
    if (delta > 0.06) {
        delta = 0.06;
    }
    span.latitudeDelta = delta;
    span.longitudeDelta = delta;
    region.span = span;

    [_mapView setRegion:region animated:TRUE];
    [_mapView regionThatFits:region];

    [ProcUtil asyncMainqDelay:0.5 block:^{
        [_mapView selectAnnotation:marker animated:YES];
    }];
}

- (void)selectPin0:(Pin *)pin
{
    for (Pin *p in pins_) {
        if (p.id == pin.id) {
            MapAnnotation *m = p.marker;
            [self focusMarker:m];
            break;
        }
    }
}

- (void)selectPin:(Pin *)pin
{
    if (!pin)
        return;
    
    if (pins_) {    // already loaded
        [self selectPin0:pin];
    } else {        // has not been loaded yet
        [ProcUtil asyncMainqDelay:1.0 block:^{
            [self selectPin0:pin];
        }];
    }
}

- (void)selectPinByID:(NSInteger)pinID;
{
    Pin *p = _.find(pins_, ^BOOL(Pin *pin) {
        return pin.id == pinID;
    });
    
    [self selectPin:p];
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control;
{
    MapAnnotation *ano = view.annotation;
    
    if (ano == _searchedMarker) {
        return;
    }
    
    Pin *pin = ano.userData;
    if (pin && pin.layouts.count) {
        [self performSegueWithIdentifier:@"showDetailFromAppleMap" sender:ano];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation;
{
    if (![annotation isKindOfClass:[MapAnnotation class]]) {
        return nil;
    }

    NSString *identifier = @"CustomPinAnnotationView";
    
    MapAnnotation *ano = annotation;
    if (ano.userData) {
        MKPinAnnotationView *view = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (!view) {
            view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                      reuseIdentifier:identifier];
            view.canShowCallout = YES;
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [rightButton addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
            view.rightCalloutAccessoryView = rightButton;
        } else {
            view.annotation = annotation;
        }
        return view;
    }
    return nil;
}

//- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
//{
//    DLog(@"longitudeDelta %f", mapView.region.span.longitudeDelta);
//    DLog(@"latitudeDelta  %f", mapView.region.span.latitudeDelta);
//}

#pragma mark - UISearchBar Delegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    if (searchBarShouldBeginEditing_) {
        self.searchBar.showsCancelButton = YES;
        self.tableView.hidden = NO;
    } else {
        [self searchBarCancelButtonClicked:searchBar];
    }
    
    BOOL ret = searchBarShouldBeginEditing_;
    searchBarShouldBeginEditing_ = YES;
    
    if ([StringUtil empty:searchBar.text]) {
        [searchOnMap_ searchByStr:@""];
    }

    return ret;
}

- (void)searchBarCancelButtonClicked:(UISearchBar*)searchBar
{
    self.searchBar.showsCancelButton = NO;
    self.tableView.hidden = YES;
    [self.searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (![searchBar isFirstResponder]) {
        searchBarShouldBeginEditing_ = NO;
    }
    
    [searchOnMap_ searchByStr:searchText];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    // enable cancel button when row tapped (work around)
    
    for (UIView *v0 in searchBar.subviews) {
        for (UIView *v in v0.subviews) {
            //DLog(@"%@",v);
            if ([v isKindOfClass:UIButton.class]) {
                //DLog(@"%@",v);
                UIButton *b = (UIButton *)v;
                [ProcUtil asyncMainqDelay:0.5 block:^{
                    b.enabled = YES;
                }];
                break;
            }
        }
    }
    return YES;
}

- (void)hideKeyboard
{
    //DLog();
    [_searchBar resignFirstResponder];
    [self.view endEditing:YES];
}
@end
