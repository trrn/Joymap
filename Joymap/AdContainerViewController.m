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
@property (weak, nonatomic) IBOutlet UIView *bannerViewPlaceholder;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bannerViewHeightConstraint;

@property (nonatomic) GADBannerView *bannerView;
@end

@implementation AdContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
    DLog(@"%@", unitID);
    
    if ([StringUtil present:unitID]) {
        [ProcUtil asyncMainq:^{
            if (self.bannerView) {
                if ([self.bannerView.adUnitID isEqualToString:unitID]) {
                    DLog(@"not changed");
                    return;
                }
                self.bannerView.delegate = nil;
            }
            DLog(@"re-create");
            self.bannerView = [GADBannerView autoLayoutView];
            [self.bannerViewPlaceholder addSubview:self.bannerView];
            [self.bannerView centerInView:self.bannerViewPlaceholder];
            [self.bannerView constrainToSize:CGSizeMake(320.0,50.0)];
            self.bannerView.adUnitID = unitID;
            self.bannerView.rootViewController = self;
            [self.bannerView loadRequest:[GADRequest request]];
            [self showBanner];
        }];
    } else {
        DLog(@"hide");
        [ProcUtil asyncMainq:^{
            [self hideBanner];
            if (self.bannerView) {
                self.bannerView.delegate = nil;
                self.bannerView = nil;
            }
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
