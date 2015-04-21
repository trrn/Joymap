//
//  RouteViewController.m
//  Joymap
//
//  Created by faith on 2013/12/15.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import "RouteViewController.h"

#import "Pin.h"
#import "RouteSelectViewController.h"

@interface RouteViewController ()
@property (weak, nonatomic) IBOutlet UILabel *fromLabel;
@property (weak, nonatomic) IBOutlet UILabel *toLabel;
@property (weak, nonatomic) IBOutlet UIButton *googleMapsButton;
@property (weak, nonatomic) IBOutlet UIButton *appleMapsButton;

@property (weak, nonatomic) IBOutlet UITableViewCell *fromCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *toCell;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;

@end

@implementation RouteViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [Theme setTableViewCellBackgroundColor:_fromCell];
    [Theme setTableViewCellBackgroundColor:_toCell];
    [Theme setTableViewCellSelectedBackgroundColor:_fromCell];
    [Theme setTableViewCellSelectedBackgroundColor:_toCell];
    
    if (![self googleMapInstalled]) {
        _googleMapsButton.enabled = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    // work around for deselect row, when swipe back. (probably ios7's bug)
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:animated];
    
    [super viewWillAppear:animated];

    _fromLabel.text = _from ? _from.name : NSLocalizedString(@"Current Location", nil);
    _toLabel.text = _to ? _to.name : NSLocalizedString(@"Current Location", nil);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    DLog();
}

#pragma mark - TableView

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 3: {
            UIView *v = UIView.new;
            v.frame = CGRectMake(0, 0, tableView.width, tableView.rowHeight);
            UIButton *b = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            b.translatesAutoresizingMaskIntoConstraints = NO;
            b.titleLabel.font = [UIFont systemFontOfSize:19];
            [b setTitle:NSLocalizedString(@"Route in Google Maps",nil) forState:UIControlStateNormal];
            [b addTarget:self action:@selector(routeByGoogleMaps:) forControlEvents:UIControlEventTouchUpInside];
            [b sizeToFit];
            [v addSubview:b];
            [b centerInView:v];
            b.enabled = [self googleMapInstalled];
            return v;
        }
        case 4: {
            UIView *v = UIView.new;
            v.frame = CGRectMake(0, 0, tableView.width, tableView.rowHeight * 3);
            UIButton *b = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            b.translatesAutoresizingMaskIntoConstraints = NO;
            b.titleLabel.font = [UIFont systemFontOfSize:19];
            [b setTitle:NSLocalizedString(@"Route in Apple Maps",nil) forState:UIControlStateNormal];
            [b addTarget:self action:@selector(routeByAppleMaps:) forControlEvents:UIControlEventTouchUpInside];
            [b sizeToFit];
            [v addSubview:b];
            [b centerInView:v];
            return v;
        }
    }
    
    return [super tableView:tableView viewForHeaderInSection:section];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"routeFrom"]) {
        RouteSelectViewController *vc = segue.destinationViewController;
        vc.title = NSLocalizedString(@"From", nil);
        __weak typeof(self) _self = self;
        vc.selectHandler = ^(Pin *pin) {
            _self.from = pin;
        };
    } else if ([[segue identifier] isEqualToString:@"routeTo"]) {
        RouteSelectViewController *vc = segue.destinationViewController;
        vc.title = NSLocalizedString(@"To", nil);
        __weak typeof(self) _self = self;
        vc.selectHandler = ^(Pin *pin) {
            _self.to = pin;
        };
    }
}

- (void)direction:(NSString *)url
{
    NSString *from = @"";
    NSString *to = @"";
    
    if (_from) {
        from = _from.coordinateStr;
    }
    
    if (_to) {
        to = _to.coordinateStr;
    }
    
    NSString *path = [NSString stringWithFormat:url, from, to];
    
    DLog(@"direction start %@", path);
    
    [UIApplication.sharedApplication openURL:path.URL];
}

- (IBAction)routeByGoogleMaps:(id)sender {
    [self direction:@"comgooglemaps://?saddr=%@&daddr=%@"];
}

- (IBAction)routeByAppleMaps:(id)sender {
    [self direction:@"http://maps.apple.com/?saddr=%@&daddr=%@"];
}

- (IBAction)cancel:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)googleMapInstalled
{
    if ([UIApplication.sharedApplication canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
        return YES;
    }
    return NO;
}

@end
