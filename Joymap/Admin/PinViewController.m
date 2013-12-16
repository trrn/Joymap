//
//  PinViewController.m
//  Joymap
//
//  Created by gli on 2013/11/14.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import "PinViewController.h"

#import "DataSource.h"
#import "GoogleMapsHelper.h"
#import "Layout.h"
#import "LayoutViewController.h"
#import "Pin.h"

#import "GMSMapViewController.h"

#define PAGES_SECTION    2
#define DELETE_SECTION   3
#define PAGES_ROW        0
#define PAGES_ADD_ROW    1

@interface PinViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UIImageView *mapImageView;

@end

@implementation PinViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.editing = YES;
    
    _nameTextField.text = _pin.name;
    
    self.title = _pin.id == 0 ? NSLocalizedString(@"New Marker", nil) : NSLocalizedString(@"Edit Marker", nil);
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
    [super viewWillAppear:animated];

    if (_pin.latitude == 0.0 && _pin.longitude == 0.0) {    // if new marker, set current location
        [LocationUtil currentLocationWithTimeout:3.0 handler:^(CLLocationCoordinate2D *co) {
            if (co && _pin.latitude == 0.0 && _pin.longitude == 0.0) {
                _pin.latitude = co->latitude;
                _pin.longitude = co->longitude;
            }
            [self setMapImage];
        }];
    } else {
        [self setMapImage];
    }
}

- (void)setMapImage
{
    CLLocationCoordinate2D co = { _pin.latitude, _pin.longitude };
    [ProcUtil asyncGlobalq:^{
        NSString *blue = @"0x8981FF";
        NSData *data = [NSData dataWithContentsOfURL:
                        [NSURL URLWithString:[GoogleMapsHelper mapImageURLWithCoordinate2D:co color:
                                              _pin.id == 0 ? blue : @"red"]]];
        if (data) {
            [ProcUtil asyncMainq:^{
                _mapImageView.image = [UIImage.alloc initWithData:data];
            }];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    DLog();
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self.view endEditing:YES];

    if ([segue.identifier isEqualToString:@"AddPage"]) {
        DLog(@"%d", self.pin.layouts.count);
    } else if ([segue.identifier isEqualToString:@"ChangeLocation"]) {
        [segue.destinationViewController setPin:_pin];
    }
}

- (IBAction)backFromMapView:(UIStoryboardSegue *)segue
{   // change locatioin done
    DLog();
    _mapImageView.image = nil;
}

#pragma mark - Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {

    if (sourceIndexPath.section == proposedDestinationIndexPath.section) {
        if (proposedDestinationIndexPath.row != self.pin.layouts.count) {
            return proposedDestinationIndexPath;
        }
    }
    return sourceIndexPath;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    
    if (section == PAGES_SECTION) {
        if ([self isPageRow:indexPath]) {
            return [super tableView:tableView indentationLevelForRowAtIndexPath:[NSIndexPath indexPathForRow:PAGES_ROW inSection:section]];
        } else {
            return [super tableView:tableView indentationLevelForRowAtIndexPath:[NSIndexPath indexPathForRow:PAGES_ADD_ROW inSection:section]];
        }
    }
    return [super tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;

    if (section == PAGES_SECTION) {
        if ([self isPageRow:indexPath]) {
            return [super tableView:tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:PAGES_ROW inSection:section]];
        } else {
            return [super tableView:tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:PAGES_ADD_ROW inSection:section]];
            
        }
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isPageRow:indexPath]) {
        Layout *layout = self.pin.layouts[indexPath.row];
        NSString *iD = [NSString stringWithFormat:@"Layout%02d", layout.kind];
        LayoutViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:iD];
        vc.layout = layout.copy;
        vc.edit = YES;
        __weak typeof(self) _self = self;
        NSUInteger row = indexPath.row;
        vc.editDoneHandler = ^(Layout *lay) {
            _self.pin.layouts[row] = lay;
        };
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _pin.id == 0 ? DELETE_SECTION : DELETE_SECTION + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == PAGES_SECTION) {
        return self.pin.layouts.count + 1;
    }

    return [super tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    NSInteger section = indexPath.section;

    if (section == PAGES_SECTION) {
        if ([self isPageRow:indexPath]) {
            static NSString *CellIdentifier = @"Dynamic Cell";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            }
            Layout *lay = self.pin.layouts[indexPath.row];
            [lay summaryForCell:cell];
        } else {
            NSIndexPath *path = [NSIndexPath indexPathForRow:PAGES_ADD_ROW inSection:indexPath.section];
            cell = [super tableView:tableView cellForRowAtIndexPath:path];
        }
    } else {
        cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // only layout can be delete

    return [self isPageRow:indexPath];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // only layout can be delete
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if ([self isPageRow:indexPath]) {
            [self.pin.layouts removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSUInteger from = fromIndexPath.row;
    NSUInteger to = toIndexPath.row;

    if ([self isPageRow:toIndexPath]) {
        while (from < to) {
            [self.pin.layouts exchangeObjectAtIndex:from withObjectAtIndex:from + 1];
            from++;
        }
        while (from > to) {
            [self.pin.layouts exchangeObjectAtIndex:from withObjectAtIndex:from - 1];
            from--;
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // only layout can be move

    return [self isPageRow:indexPath];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _pin.name = _nameTextField.text;
}

#pragma mark - etc

- (IBAction)save:(id)sender {
    _pin.name = _nameTextField.text;
    DLog(@"name=%@", _pin.name);

    for (NSInteger i=0; i<self.pin.layouts.count; ++i) {
        [self.pin.layouts[i] setOrderNo:i+1];
    }

    if (![DataSource save:_pin]) {
        // error
        Alert(NSLocalizedString(@"error", nil), NSLocalizedString(@"could not save",nil));
        return;
    }

    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)isPageRow:(NSIndexPath *)indexPath
{
    if (indexPath.section == PAGES_SECTION) {
        if (indexPath.row != self.pin.layouts.count) {
            return YES;
        }
    }
    return NO;
}

@end
