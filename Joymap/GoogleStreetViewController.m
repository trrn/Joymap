//
//  GoogleStreetViewController.m
//  Joymap
//
//  Created by gli on 2013/10/13.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import "GoogleStreetViewController.h"

#import "Pin.h"

#import <GoogleMaps/GoogleMaps.h>

@interface GoogleStreetViewController() <GMSPanoramaViewDelegate>

@end

@implementation GoogleStreetViewController
{
    GMSPanoramaView *panoView_;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    DLog();

    panoView_ = [GMSPanoramaView panoramaWithFrame:CGRectZero nearCoordinate:self.coord];
    self.view = panoView_;
    panoView_.delegate = self;

    for (Pin *p in self.pins) {
        if (p.marker) {
            GMSMarker *marker = p.marker;
            marker.panoramaView = panoView_;
        }
    }
    if (_searchedMarker) {
        _searchedMarker.panoramaView = panoView_;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    DLog();
}

- (IBAction)close:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - GMSPanoramaViewDelegate

- (BOOL)panoramaView:(GMSPanoramaView *)panoramaView didTapMarker:(GMSMarker *)marker
{
    DLog();
    
    self.title = marker.title;
    
    return NO;
}

@end
