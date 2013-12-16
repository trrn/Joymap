//
//  SelectViewController.m
//  Joymap
//
//  Created by gli on 2013/11/09.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import "SelectViewController.h"

@interface SelectViewController ()

@end

@implementation SelectViewController {
    NSInteger selectedIdx_;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    selectedIdx_ = _initialSelectedIndex;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // move to selected index
    if (selectedIdx_ >= 0 && selectedIdx_ < _dataSource.count) {
        NSIndexPath *indexPath =
        [NSIndexPath indexPathForRow:selectedIdx_ inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath
                              atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
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
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SelectViewCell"];

    NSDictionary *e = _dataSource[indexPath.row];
    cell.imageView.image = e[@"image"];
    cell.textLabel.text = e[@"label"];
    cell.detailTextLabel.text = e[@"detail"];

    if (selectedIdx_ == indexPath.row)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (selectedIdx_ != indexPath.row) {

        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        NSIndexPath *oldIdx = [NSIndexPath indexPathForRow:selectedIdx_ inSection:0];
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIdx];
        oldCell.accessoryType = UITableViewCellAccessoryNone;

        selectedIdx_ = indexPath.row;
    }

    _selectHandler(indexPath.row);

    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
