//
//  GoogleMapsViewController.m
//  Joymap
//
//  Created by gli on 2013/10/13.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import "GoogleMapsViewController.h"

#import "AdminHelper.h"
#import "DataSource.h"
#import "Env.h"
#import "GeoSearch.h"
#import "GoogleMapsHelper.h"
#import "GoogleStreetViewController.h"
#import "PageViewController.h"
#import "Pin.h"
#import "SearchOnMap.h"

#import <GoogleMaps/GoogleMaps.h>
#import <UIView+AutoLayout.h>

@interface GoogleMapsViewController () <GMSMapViewDelegate, UISearchBarDelegate>
@property (strong, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *searchBarBaseView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *addPinTitleLabel;
@property (nonatomic) GMSMarker *searchedMarker;

@end

@implementation GoogleMapsViewController
{
    NSArray    *pins_;
    

    SearchOnMap *searchOnMap_;
    BOOL        searchBarShouldBeginEditing_;   // search bar clear button control

    GMSMarker  *addMarker_;
    BOOL        editMode_;

    BOOL        isAdmin_;
    NSDate     *lastReloaded_;
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    [GMSServices provideAPIKey:Env.googleMapsApiKey];

    _searchedMarker = nil;
    searchBarShouldBeginEditing_ = YES;

    addMarker_ = nil;
    editMode_ = NO;

    lastReloaded_ = nil;
    isAdmin_ = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _mapView.myLocationEnabled = YES;
    _mapView.settings.compassButton = YES;
    _mapView.settings.myLocationButton = YES;
    _mapView.delegate = self;
    
    // register search table view's row tap action
    _searchedMarker = GMSMarker.new;
    __weak typeof(self) _self = self;
    
    searchOnMap_ = SearchOnMap.new;
    searchOnMap_.srcViewController = self;
    self.tableView.delegate = searchOnMap_;
    self.tableView.dataSource = searchOnMap_;
    searchOnMap_.tableView = self.tableView;
    searchOnMap_.didTapRowCallback = ^(id resOrPin) {
        [_self mapViewGestures:YES];
        _self.searchBar.showsCancelButton = NO;
        [_self.searchBar resignFirstResponder];
        [_self setAdminControl];
        if ([resOrPin isKindOfClass:Pin.class]) {
            [_self selectPin:resOrPin];
        } else {  // searched geo location
            _self.searchedMarker.map = nil; // hide
            _self.searchedMarker = GMSMarker.new;
            CLLocationCoordinate2D co;
            [GeoUtil strToCoordinate2D:resOrPin[@"latlng"] co:&co];
            _self.searchedMarker.position = co;
            _self.searchedMarker.icon = [GMSMarker markerImageWithColor:Env.SearchedMarkerColor];
            _self.searchedMarker.title = resOrPin[@"title"] ?: resOrPin[@"addr"];
            _self.searchedMarker.map = _self.mapView;
            [_self focusMarker:_self.searchedMarker];
        }
    };

    [self.view bringSubviewToFront:self.tableView];
    self.tableView.hidden = YES;

    searchBarShouldBeginEditing_ = YES;

    [Theme setSearchBarTextFieldBackground:self.searchBar];
    
    [self setAdminControl];

    [self reload];
    
    [self moveCameraToAnyPin];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if ([TimeUtil earlier:lastReloaded_ than:DataSource.updatedDate]) {
        [self reload];
    }

    if (isAdmin_ != AdminHelper.isAdmin) {
        [self setAdminControl];     // call if mode changed
        isAdmin_ = AdminHelper.isAdmin;
    }

    _mapView.trafficEnabled = [DefaultsUtil bool:DEF_SET_MAP_TRAFFIC];
    _mapView.mapType = GoogleMapsHelper.mapType;
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

    GMSCameraUpdate *upd =
    [GMSCameraUpdate setTarget:co zoom:zoom];
    [_mapView animateWithCameraUpdate:upd];
}

- (void)reload
{
    [_mapView clear];
    pins_ = DataSource.pins;
    
    for (Pin *p in pins_) {
        GMSMarker *m = GMSMarker.new;
        //m.icon = [GMSMarker markerImageWithColor:UIColor.magentaColor];
        m.position = CLLocationCoordinate2DMake(p.latitude, p.longitude);
        DLog(@"%f, %f", p.latitude, p.longitude);
        //m.icon = [GMSMarker markerImageWithColor:UIColor.blueColor];
        m.title = p.name;
        m.map = _mapView;
        m.userData = p;
        m.icon = [UIImage imageNamed:@"pin"];
        p.marker = m;
    }
    
    lastReloaded_ = NSDate.date;
}

// customize marker info window
//- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
//
//    UIView *view = UIView.new;
//    view.frame = CGRectMake(0, 0, 170, 70);
//
//    UIImageView *iv = UIImageView.new;
//    UIImage *balloon = [UIImage imageNamed:@"balloon"];
//    UIImage *strechableBalloon = [balloon resizableImageWithCapInsets:UIEdgeInsetsMake(38, 5, 38, 5) resizingMode:UIImageResizingModeStretch];
//
//    iv.image = strechableBalloon;
//
//    iv.frame = view.bounds;
//    [view addSubview:iv];
//
//    return view;
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    DLog();
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showDetailFromMap"]) {
        GMSMarker *marker = sender;
        Pin *p = marker.userData;
        [[segue destinationViewController] setPin:p.copy];
    } else if([segue.identifier isEqualToString:@"editPinFromMap"]) {
        GMSMarker *marker = sender;
        if (marker.userData) {
            Pin *p = marker.userData;
            [segue.destinationViewController setPin:p.copy];
        } else {
            Pin *p = Pin.new;
            p.latitude = marker.position.latitude;
            p.longitude = marker.position.longitude;
            [segue.destinationViewController setPin:p];
        }
    }
}

- (void)mapViewGestures:(BOOL)enable
{
    for (UIGestureRecognizer *g in _mapView.gestureRecognizers) {
        g.enabled = enable;
    }
}

#pragma mark - public

- (void)focusMarker:(GMSMarker *)marker
{
    GMSCameraUpdate *upd =
    [GMSCameraUpdate setTarget:marker.position zoom:_mapView.camera.zoom < 16 ? 16 : _mapView.camera.zoom];
    [_mapView animateWithCameraUpdate:upd];
    [ProcUtil asyncMainqDelay:0.5 block:^{
        _mapView.selectedMarker = marker;
    }];
}

- (void)selectPin0:(Pin *)pin
{
    for (Pin *p in pins_) {
        if (p.id == pin.id) {
            GMSMarker *m = p.marker;
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

- (void)hideKeyboard
{
    //DLog();
    [_searchBar resignFirstResponder];
    [self.view endEditing:YES];
}

#pragma mark - GMSMapViewDelegate

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    // if not set nil, leak memory..
    //_mapView.selectedMarker = nil;

    if (AdminHelper.isAdmin && editMode_) {
        [self performSegueWithIdentifier:@"editPinFromMap" sender:marker];
        return;
    }
    
    if (marker == _searchedMarker) {
        return;
    }

    Pin *pin = marker.userData;
    if (pin && pin.layouts.count) {
        [self performSegueWithIdentifier:@"showDetailFromMap" sender:marker];
    }
}

- (void)moveAddMarker:(CLLocationCoordinate2D)coordinate
{
    if (!addMarker_) {
        addMarker_ = GMSMarker.new;
        addMarker_.map = _mapView;
        addMarker_.draggable = YES;
        addMarker_.appearAnimation = kGMSMarkerAnimationPop;
        addMarker_.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
        addMarker_.title = NSLocalizedString(@"Tap to add Marker", nil);
    }
    addMarker_.position = coordinate;
    [ProcUtil asyncMainqDelay:1.0 block:^{
        [_mapView setSelectedMarker:addMarker_];
    }];
}

- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    if (AdminHelper.isAdmin && editMode_) {
        [self moveAddMarker:coordinate];
    } else {
        NavigationController *nvc = [self.storyboard instantiateViewControllerWithIdentifier:@"StreetViewNavigationController"];
        GoogleStreetViewController *gvc = nvc.viewControllers[0];
        gvc.coord = coordinate;
        gvc.pins = pins_;
        gvc.searchedMarker = _searchedMarker;
        nvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:nvc animated:YES completion:nil];
    }
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate;
{
    if (AdminHelper.isAdmin && editMode_) {
        [self moveAddMarker:coordinate];
    }
}

#pragma mark - UISearchBar Delegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    if (searchBarShouldBeginEditing_) {
        self.searchBar.showsCancelButton = YES;
        self.tableView.hidden = NO;
        [self mapViewGestures:NO];
        [self hideAdminControl];
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
    [self mapViewGestures:YES];
    self.tableView.hidden = YES;
    [self.searchBar resignFirstResponder];
    [self setAdminControl];
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

#pragma mark - Admin Mode

- (void)setAdminControl
{
    editMode_ = NO;

    if (_mapView.selectedMarker == addMarker_) {
        _mapView.selectedMarker = nil;
    }
    _searchBar.hidden = NO;
    _addPinTitleLabel.hidden = YES;
    addMarker_.map = nil;
    addMarker_ = nil;
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.navigationItem.backBarButtonItem = nil;
    self.navigationController.navigationBar.backgroundColor = nil;

    if (AdminHelper.isAdmin) {
        UIBarButtonItem *btn = [UIBarButtonItem.alloc initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                           target:self
                                                                           action:@selector(enterEditMode)];
        [self.navigationItem setRightBarButtonItem:btn animated:YES];
    } else {
        [self hideAdminControl];
    }
}

- (void)hideAdminControl
{
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
}

- (void)enterEditMode
{
    if (!AdminHelper.isAdmin) {
        ELog(@"must not happen");
        return;
    }

    editMode_ = YES;
    self.navigationController.navigationBar.backgroundColor = [UIColor blueColor];

    _searchBar.hidden = YES;
    _addPinTitleLabel.hidden = NO;

    [self.navigationItem setRightBarButtonItem:nil animated:YES];
    UIBarButtonItem *done = [UIBarButtonItem.alloc initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                          target:self
                                                                          action:@selector(setAdminControl)];
    [self.navigationItem setLeftBarButtonItem:done animated:YES];

    self.navigationItem.backBarButtonItem = [UIBarButtonItem.alloc initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)addMarker
{
    [self performSegueWithIdentifier:@"editPinFromMap" sender:addMarker_];
}

@end
