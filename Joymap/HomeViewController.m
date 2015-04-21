//
//  HomeViewController.m
//  Joymap
//
//  Created by faith on 2013/10/13.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController ()
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    NSURL *url = Env.homeUrl.URL;
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:req];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    DLog();
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView*)webView
{
    UIApplication.sharedApplication.networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView*)webView
{
    UIApplication.sharedApplication.networkActivityIndicatorVisible = NO;
    [_indicator stopAnimating];
}

@end
