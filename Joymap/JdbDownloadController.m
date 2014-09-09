//
//  JdbDownloadController.m
//  Joymap
//
//  Created by gli on 2013/10/19.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import "JdbDownloadController.h"

#import "JdbManager.h"

#import <UIView+AutoLayout.h>

@interface JdbDownloadController ()
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@end

@implementation JdbDownloadController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.progressBar.hidden = YES;
    self.progressBar.progress = 0.0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    DLog();
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    DLog();
    self.progressBar.progress = 0.0;

    __weak typeof(self) _self = self;

    [JdbManager.shared downloadWithProgress:^(double progress) {
        _self.progressBar.hidden = NO;
        _self.progressBar.progress = progress;
    } finished:^{
        [_self dismissViewControllerAnimated:YES completion:nil];
    }];
}
#pragma mark - UIButton

- (IBAction)cancel:(id)sender {
    //[JdbManager.shared cancelAllHTTPOperationsWithMethod:nil path:nil];
}

@end
