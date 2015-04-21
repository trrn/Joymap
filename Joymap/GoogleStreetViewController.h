//
//  GoogleStreetViewController.h
//  Joymap
//
//  Created by faith on 2013/10/13.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@class GMSMarker;

@interface GoogleStreetViewController : BaseViewController

@property (assign) CLLocationCoordinate2D coord;
@property (nonatomic, weak) NSArray *pins;
@property (nonatomic, weak) GMSMarker *searchedMarker;

@end
