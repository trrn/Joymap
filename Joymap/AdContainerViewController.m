//
//  AdContainerViewController.m
//  Joymap
//
//  Created by Faith on 2015/04/14.
//  Copyright (c) 2015年 sekken. All rights reserved.
//

#import "AdContainerViewController.h"

#import "AdUnitIDManager.h"

@import GoogleMobileAds;

@interface AdContainerViewController () <GADBannerViewDelegate>
@property (weak, nonatomic) IBOutlet GADBannerView *bannerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bannerViewHeightConstraint;
@end

@implementation AdContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.bannerView.rootViewController = self;
    self.bannerView.delegate = self;
    [self hideBanner];
    [self updateUnitID];

    [NSNotificationCenter.defaultCenter
     addObserver:self
     selector:@selector(updateUnitID)
     name:AD_UNIT_ID_NEED_UPDATE
     object:nil];
}

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
    self.bannerView.delegate = nil;
}

- (void)updateUnitID
{
    NSString *unitID = [DefaultsUtil str:AD_UNIT_ID];
    if ([StringUtil present:unitID]) {
        [ProcUtil asyncMainq:^{
            [self showBanner];
            self.bannerView.adUnitID = unitID;
            [self.bannerView loadRequest:[GADRequest request]];
        }];
    } else {
        [ProcUtil asyncMainq:^{
            [self hideBanner];
        }];
    }
}

- (void)hideBanner
{
    self.bannerViewHeightConstraint.constant = 0;
}

- (void)showBanner
{
    self.bannerViewHeightConstraint.constant = 50;
}

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
    Log(@"adViewDidReceiveAd");
    [self showBanner];
}

- (void)adView:(GADBannerView *)bannerView
    didFailToReceiveAdWithError:(GADRequestError *)error {
    ELog(@"adView:didFailToReceiveAdWithError:%@", [error localizedDescription]);
    [self hideBanner];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
