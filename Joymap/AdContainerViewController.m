//
//  AdContainerViewController.m
//  Joymap
//
//  Created by Faith on 2015/04/14.
//  Copyright (c) 2015年 sekken. All rights reserved.
//   
#import "AdContainerViewController.h"

#import "AMoAdView.h"

#import "AppWebStatus.h"

@import GoogleMobileAds;

@interface AdContainerViewController () <GADBannerViewDelegate, AMoAdViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *bannerViewPlaceholder;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bannerViewHeightConstraint;

@property (nonatomic) GADBannerView *gadBannerView;
@property (nonatomic) AMoAdView *amoadView;
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
     name:APP_WEB_STATUS_UPDATED
     object:nil];
}

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
    self.gadBannerView.delegate = nil;
}

- (void)updateUnitID
{
    NSDictionary *status = AppWebStatus.shared.status;

    DLog(@"%@", status);

    if (!status || !status[@"plan_id"]) {
        [self removeBanner];
        return;
    }

    NSInteger plan_id = [status[@"plan_id"] integerValue];

    if ([StringUtil empty:status[@"unit_id"]]) {
        [self removeBanner];
        return;
    }

    if (plan_id > 0) {  // charging
        [self showAdmob:status[@"unit_id"]];
    } else {            // free
        [self showAmoad:status[@"unit_id"]];
    }
}

- (void)showAdmob:(NSString *)Id
{
    [ProcUtil asyncMainq:^{
        if (self.gadBannerView) {
            if ([self.gadBannerView.adUnitID isEqualToString:Id]) {
                DLog(@"not changed");
                return;
            }
            [self.gadBannerView removeFromSuperview];
            self.gadBannerView.delegate = nil;
        }
        if (self.amoadView) {
            [self.amoadView removeFromSuperview];
            self.amoadView.delegate = nil;
            self.amoadView = nil;
        }
        
        DLog(@"create admob view");
        self.gadBannerView = [GADBannerView autoLayoutView];
        self.gadBannerView.adUnitID = Id;
        [self.bannerViewPlaceholder addSubview:self.gadBannerView];
        [self.gadBannerView centerInView:self.bannerViewPlaceholder];
        [self.gadBannerView constrainToSize:CGSizeMake(320.0,50.0)];
        self.gadBannerView.rootViewController = self;
        [self.gadBannerView loadRequest:[GADRequest request]];
        [self showBanner];
    }];
}

- (void)showAmoad:(NSString *)Id
{
    [ProcUtil asyncMainq:^{
        if (self.amoadView) {
            if ([self.amoadView.sid isEqualToString:Id]) {
                DLog(@"not changed");
                return;
            }
            [self.amoadView removeFromSuperview];
            self.amoadView.delegate = nil;
        }
        if (self.gadBannerView) {
            [self.gadBannerView removeFromSuperview];
            self.gadBannerView.delegate = nil;
            self.gadBannerView = nil;
        }
        
        DLog(@"create amoad view");
        self.amoadView = [AMoAdView autoLayoutView];
        self.amoadView.sid = Id;
        [self.bannerViewPlaceholder addSubview:self.amoadView];
        [self.amoadView centerInView:self.bannerViewPlaceholder];
        [self.amoadView constrainToSize:CGSizeMake(320.0,50.0)];
        [self showBanner];
    }];
}

- (void)removeBanner
{
    [ProcUtil asyncMainq:^{
        [self hideBanner];
        if (self.gadBannerView) {
            [self.gadBannerView removeFromSuperview];
            self.gadBannerView.delegate = nil;
            self.gadBannerView = nil;
        }
        if (self.amoadView) {
            [self.amoadView removeFromSuperview];
            self.amoadView.delegate = nil;
            self.amoadView = nil;
        }
    }];
}

- (void)hideBanner
{
    self.bannerViewHeightConstraint.constant = 0;
}

- (void)showBanner
{
    self.bannerViewHeightConstraint.constant = 50;
}

#pragma - mark

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
    Log(@"adViewDidReceiveAd");
    [self showBanner];
}

- (void)adView:(GADBannerView *)bannerView
    didFailToReceiveAdWithError:(GADRequestError *)error {
    ELog(@"adView:didFailToReceiveAdWithError:%@", [error localizedDescription]);
    [self hideBanner];
}

#pragma - mark

- (void)AMoAdViewDidFailToReceiveAd:(AMoAdView *)amoadView error:(NSError *)error
{
    Log(@"AMoAdViewDidFailToReceiveAd");
    [self hideBanner];
}

- (void)AMoAdViewDidReceiveEmptyAd:(AMoAdView *)amoadView
{
    Log(@"AMoAdViewDidReceiveEmptyAd");
    [self hideBanner];
}

- (void)AMoAdViewDidReceiveAd:(AMoAdView *)amoadView
{
    Log(@"AMoAdViewDidReceiveAd");
    [self showBanner];
}

#pragma - mark

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
