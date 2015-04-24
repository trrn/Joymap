//
//  SettingViewController.m
//  Joymap
//
//  Created by faith on 2013/10/13.
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

@property (weak, nonatomic) IBOutlet UITableViewCell *notifyCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *updateCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *autoPlayCell;

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
    
    [Theme setTableViewCellBackgroundColor:_notifyCell];
    [Theme setTableViewCellBackgroundColor:_updateCell];
    [Theme setTableViewCellBackgroundColor:_autoPlayCell];
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
    } else if ([[segue identifier] isEqualToString:@"JdbDownloadController"]) {
        JdbDownloadController *vc = segue.destinationViewController;
        vc.request = Env.downloadRequest;
    }
}

- (NSString *)updateDateStr:(NSDate *)date
{
    if (!date) {
        return @"--";
    }

    NSString *str = [NSString stringWithFormat:@"%@ %@", [TimeUtil format:@"yyyy/MM/dd HH:mm:ss" date:date], NSLocalizedString(@"updated", nil)];

    return str;
}

#pragma mark - action

- (IBAction)tapNotifySwitch:(id)sender {

    [DefaultsUtil setBool:_notifySwitch.on key:DEF_SET_NOTIFY_SPOT];

    [RegionMonitor.shared refresh];
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

@end
