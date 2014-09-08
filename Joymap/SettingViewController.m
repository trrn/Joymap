//
//  SettingViewController.m
//  Joymap
//
//  Created by gli on 2013/10/13.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import "SettingViewController.h"

#import "AdminHelper.h"
#import "GoogleMapsHelper.h"
#import "JdbDownloadController.h"
#import "RegionMonitor.h"
#import "SelectViewController.h"
#import "TextViewController.h"

@interface SettingViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *notifySwitch;
@property (weak, nonatomic) IBOutlet UILabel *jdbUpdateDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *mapTypesLabel;
@property (weak, nonatomic) IBOutlet UISwitch *trafficSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *autoPlaySwitch;

@end

@implementation SettingViewController

- (void)viewWillAppear:(BOOL)animated
{
    // work around for deselect row, when swipe back. (probably ios7's bug)
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:animated];

    [super viewWillAppear:animated];

    if (RegionMonitor.deviceSupported) {
        _notifySwitch.enabled = YES;
        _notifySwitch.on = [DefaultsUtil bool:DEF_SET_NOTIFY_SPOT];
    } else {
        [DefaultsUtil setBool:NO key:DEF_SET_NOTIFY_SPOT];
        _notifySwitch.on = NO;
        _notifySwitch.enabled = NO;
    }
    _jdbUpdateDateLabel.text = [self updateDateStr:[DefaultsUtil obj:DEF_SET_JDB_LAST_UPDATED]];
    _mapTypesLabel.text = NSLocalizedString(GoogleMapsHelper.mapTypeName, nil);
    _trafficSwitch.on = [DefaultsUtil bool:DEF_SET_MAP_TRAFFIC];
    _autoPlaySwitch.on = [DefaultsUtil bool:DEF_SET_ETC_AUTOPLAY];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"selectMapType"]) {
        SelectViewController *vc = segue.destinationViewController;
        NSMutableArray *ds = @[].mutableCopy;
        for (NSString *name in GoogleMapsHelper.mapTypeNames) {
            [ds addObject:@{ @"label": NSLocalizedString(name, nil) }];
        }
        vc.dataSource = ds;
        vc.initialSelectedIndex = GoogleMapsHelper.mapTypeIndex;
        vc.selectHandler = ^(NSInteger idx) {
            [GoogleMapsHelper setMapType:idx];
        };
    } else if ([[segue identifier] isEqualToString:@"credit"]) {
        TextViewController *vc = segue.destinationViewController;
        vc.title = NSLocalizedString(@"Credit", nil);
        vc.text = [self credit];
    }
}

- (NSString *)updateDateStr:(NSDate *)date
{
    if (!date) {
        return @"--";
    }

    return [TimeUtil format:@"yyyy/MM/dd HH:mm:ss" date:date];
}

#pragma mark - action

- (IBAction)tapNotifySwitch:(id)sender {

    [DefaultsUtil setBool:_notifySwitch.on key:DEF_SET_NOTIFY_SPOT];

    [RegionMonitor refreshWithAlertIfCannot];
}

- (IBAction)tapTrafficSwitch:(id)sender {
    [DefaultsUtil setBool:_trafficSwitch.on key:DEF_SET_MAP_TRAFFIC];
}

- (IBAction)debugRegions:(id)sender {
    [RegionMonitor debugOutRegions];
}

- (IBAction)tapAutoPlaySwitch:(id)sender {
    [DefaultsUtil setBool:_autoPlaySwitch.on key:DEF_SET_ETC_AUTOPLAY];
}

#pragma mark - credit

- (NSAttributedString *)credit {

    NSMutableAttributedString *str = NSMutableAttributedString.new;
    [str appendAttributedString:[self creditFromTitle:@"Google Maps SDK for iOS" text:GMSServices.openSourceLicenseInfo]];
    [str appendAttributedString:[self creditFromFile:@"AFNetworking"]];
    [str appendAttributedString:[self creditFromFile:@"DACircularProgress"]];
    [str appendAttributedString:[self creditFromFile:@"FMDB"]];
    [str appendAttributedString:[self creditFromFile:@"FontAwesomeIconFactory"]];
    [str appendAttributedString:[self creditFromFile:@"IDMPhotoBrowser"]];
    [str appendAttributedString:[self creditFromFile:@"MGImageUtilities"]];
    [str appendAttributedString:[self creditFromFile:@"SVProgressHUD"]];
    [str appendAttributedString:[self creditFromFile:@"UIView-Autolayout"]];

    return str;
}

- (NSAttributedString *)creditFromFile:(NSString *)title {

    NSMutableAttributedString *str = NSMutableAttributedString.new;
    NSError *err = nil;
    NSString *text = [NSString stringWithContentsOfFile:
                      [NSBundle.mainBundle pathForResource:title ofType:nil] encoding:NSUTF8StringEncoding error:&err];
    if (err) {
        DLog(@"%@ %@", title, err);
        return str;
    }

    [str appendAttributedString:[NSAttributedString.alloc initWithString:@"\n\n"]];
    [str appendAttributedString:[self creditFromTitle:title text:text]];;
    return str;
}

- (NSAttributedString *)creditFromTitle:(NSString *)title text:(NSString *)text {

    NSMutableAttributedString *str = NSMutableAttributedString.new;
    NSDictionary *attr = @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:16.0f] };

    [str appendAttributedString:[NSAttributedString.alloc initWithString:title attributes:attr]];
    [str appendAttributedString:[NSAttributedString.alloc initWithString:@"\n\n"]];
    [str appendAttributedString:[NSAttributedString.alloc initWithString:text]];

    return str;
}

@end
