//
//  JdbDownloadController.m
//  Joymap
//
//  Created by gli on 2013/10/19.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import "JdbDownloadController.h"

#import "JdbDownload.h"

#import <UIView+AutoLayout.h>

@interface JdbDownloadController ()
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@end

@implementation JdbDownloadController
{
    JdbDownload *dl_;
}

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

    dl_ = JdbDownload.singleton;
    dl_.progressHandler = ^(double progress){
        _self.progressBar.hidden = NO;
        _self.progressBar.progress = progress;
    };
    dl_.completionHandler = ^{
        [_self dismissViewControllerAnimated:YES completion:nil];
    };
    [dl_ start];
}
#pragma mark - UIButton

- (IBAction)cancel:(id)sender {
    [dl_ cancel];
}

@end
