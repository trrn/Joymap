//
//  RouteSelectViewController.m
//  Joymap
//
//  Created by gli on 2013/12/15.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import "RouteSelectViewController.h"

#import "DataSource.h"
#import "Pin.h"

@interface RouteSelectViewController () <UISearchDisplayDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation RouteSelectViewController
{
    NSArray *pins_;
    NSMutableArray *searchedPins_;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    pins_ = @[];
    searchedPins_ = @[].mutableCopy;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // hide search bar
    [self.tableView setContentOffset:CGPointMake(0.0f, self.searchDisplayController.searchBar.frame.size.height)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    pins_ = [DataSource pinsOrderByID:YES];
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
    static NSString *CellIdentifier = @"RouteSelectCell";
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

    _selectHandler(pin);
    [self.navigationController popViewControllerAnimated:YES];
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

#pragma mark - UIBarButtonItem target

- (IBAction)here:(id)sender {
    _selectHandler(nil);
    [self.navigationController popViewControllerAnimated:YES];
}

@end
