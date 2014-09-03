//
//  ListViewController.m
//  Joymap
//
//  Created by gli on 2013/10/21.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import "ListViewController.h"

#import "AdminHelper.h"
#import "DataSource.h"
#import "JdbDownload.h"
#import "PageViewController.h"
#import "PinViewController.h"

#import <NIKFontAwesomeIconFactory.h>
#import <NIKFontAwesomeIconFactory+iOS.h>
#import <UIView+AutoLayout.h>

@interface ListViewController () <UISearchDisplayDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@end

@implementation ListViewController
{
    NSArray *pins_;
    NSMutableArray *searchedPins_;
    NSInteger didChangeIndex_;
    NSInteger preChangeIndex_;
    NSMutableArray *segImages_;

    BOOL        editMode_;
    BOOL        isAdmin_;
    NSDate     *lastReloaded_;
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    pins_ = @[];
    searchedPins_ = @[].mutableCopy;
    editMode_ = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NIKFontAwesomeIconFactory *factory = [NIKFontAwesomeIconFactory tabBarItemIconFactory];
    segImages_ = @[
       // 0 asc/desc,
       // 1 asc image,
       // 2 desc image,

       @[@(YES),
         [factory createImageForIcon:NIKFontAwesomeIconLocationArrow],
         [factory createImageForIcon:NIKFontAwesomeIconLocationArrow],].mutableCopy,
       @[@(YES),
         [factory createImageForIcon:NIKFontAwesomeIconSortAlphaAsc],
         [factory createImageForIcon:NIKFontAwesomeIconSortAlphaDesc],].mutableCopy,
       @[@(YES),
         [factory createImageForIcon:NIKFontAwesomeIconSortNumericAsc],
         [factory createImageForIcon:NIKFontAwesomeIconSortNumericDesc],].mutableCopy,
                   ].mutableCopy;
    [self.segmentedControl setImage:segImages_[0][1] forSegmentAtIndex:0];
    [self.segmentedControl setImage:segImages_[1][1] forSegmentAtIndex:1];
    [self.segmentedControl setImage:segImages_[2][1] forSegmentAtIndex:2];

    //didChangeIndex_ = self.segmentedControl.selectedSegmentIndex;
    didChangeIndex_ = 1;

    // hide search bar
    [self.tableView setContentOffset:CGPointMake(0.0f, self.searchDisplayController.searchBar.frame.size.height)];

    [self setAdminControl];

    [self reload];
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([TimeUtil earlier:lastReloaded_ than:DataSource.updatedDate]) {
        [Pin clearCache];
        [self reload];
    }

    // work around for deselect row, when swipe back. (probably ios7's bug)
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:animated];

    [super viewWillAppear:animated];

    if (isAdmin_ != AdminHelper.isAdmin) {
        [self setAdminControl];     // call if mode changed
        isAdmin_ = AdminHelper.isAdmin;
    }
}

- (void)reload
{
    DLog();

    [self changeSortType:self.segmentedControl];

    lastReloaded_ = NSDate.date;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    DLog();
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return searchedPins_.count;
    }
    return pins_.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ListViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    Pin *p = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        p = searchedPins_[indexPath.row];
    } else {
        p = pins_[indexPath.row];
    }
    [p thumbnail:cell];
    [p subtitle:cell];
    cell.textLabel.text = [p name];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // work around for UISearchDisplayController of storyboard
    // UISearchDisplayController cannot use prepareForSegue

    Pin *pin = nil;

    if (tableView == self.searchDisplayController.searchResultsTableView) {
        pin = searchedPins_[indexPath.row];
    } else {
        pin = pins_[indexPath.row];
    }

    id vc = nil;
    if (AdminHelper.isAdmin && editMode_) {
        vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PinViewController"];
    } else if (pin.layouts.count) {
        vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    [vc setPin:pin.copy];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UISearchDisplayDelegate, UISearchBarDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    NSString *kw = searchString;

    if ([StringUtil empty:kw]) {
        searchedPins_ = @[].mutableCopy;
        return YES;
    }

    NSMutableArray *matches = @[].mutableCopy;

    for (Pin *p in pins_) {
        if ([p.name rangeOfString:kw options:NSCaseInsensitiveSearch].location != NSNotFound) {
            [matches addObject:p];
        }
    }

    searchedPins_ = matches;

    return YES;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    [self.searchBar resignFirstResponder];
}

#pragma mark - UISegmentedControl

- (IBAction)tapSegment:(id)sender {

    UISegmentedControl *seg = sender;

    if (preChangeIndex_ == seg.selectedSegmentIndex) {
        [self changeSortType:sender];
    }
    preChangeIndex_ = seg.selectedSegmentIndex;
}

- (IBAction)changeSortType:(id)sender {

    UISegmentedControl *seg = sender;
    preChangeIndex_ = didChangeIndex_;
    didChangeIndex_ = seg.selectedSegmentIndex;

    // sort by location
    if (didChangeIndex_ == 0) {
        [self pinsSortByLocation];
        return;
    }

    // change image
    BOOL asc = [segImages_[didChangeIndex_][0] boolValue];
    if (preChangeIndex_ == didChangeIndex_) {
        asc = !asc;
        segImages_[didChangeIndex_][0] = @(asc);
    }
    [self.segmentedControl setImage:segImages_[didChangeIndex_][asc ? 1 : 2]
                  forSegmentAtIndex:didChangeIndex_];

    // sort pins
    switch (didChangeIndex_) {
        case 1:
            pins_ = [DataSource pinsOrderByName:asc];
            break;
        case 2:
            pins_ = [DataSource pinsOrderByID:asc];
            break;
    }

    [self.tableView reloadData];
}

#pragma mark - etc

- (void)pinsSortByLocation
{
    pins_ = @[];
    [self.tableView reloadData];

    [LocationUtil currentLocationWithTimeout:10.0 handler:^(CLLocationCoordinate2D *co) {
        if (self.segmentedControl.selectedSegmentIndex == 0) {
            pins_ = [DataSource pinsOrderByDistanceFrom:co];
            [ProcUtil asyncMainq:^{
                [self.tableView reloadData];
            }];
        }
    }];
}

#pragma mark - Admin Mode

- (void)setAdminControl
{
    editMode_ = NO;

    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
    self.navigationItem.backBarButtonItem = nil;
    self.navigationController.navigationBar.backgroundColor = nil;

    if (AdminHelper.isAdmin) {
        UIBarButtonItem *btn = [UIBarButtonItem.alloc initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                           target:self
                                                                           action:@selector(enterEditMode)];
        [self.navigationItem setRightBarButtonItem:btn animated:YES];
    } else {
        [self hideAdminControl];
    }
}

- (void)hideAdminControl
{
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
}


- (void)enterEditMode
{
    if (!AdminHelper.isAdmin) {
        ELog(@"must not happen");
        return;
    }

    editMode_ = YES;
    self.navigationController.navigationBar.backgroundColor = [UIColor blueColor];

    UIBarButtonItem *done = [UIBarButtonItem.alloc initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                        target:self
                                                                        action:@selector(setAdminControl)];
    [self.navigationItem setLeftBarButtonItem:done animated:YES];
    UIBarButtonItem *add = [UIBarButtonItem.alloc initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                         target:self
                                                         action:@selector(addMarker)];
    [self.navigationItem setRightBarButtonItem:add animated:YES];
    self.navigationItem.backBarButtonItem = [UIBarButtonItem.alloc initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)addMarker
{
    if (AdminHelper.isAdmin && editMode_) {
        id vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PinViewController"];
        [vc setPin:Pin.new];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
