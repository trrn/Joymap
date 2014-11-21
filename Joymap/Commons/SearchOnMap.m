//
//  SearchOnMap.m
//  Joymap
//
//  Created by Faith on 2014/09/05.
//  Copyright (c) 2014年 sekken. All rights reserved.
//

#import "SearchOnMap.h"

#import "DataSource.h"
#import "GoogleMapsViewController.h"
#import "Pin.h"

@interface SearchOnMap()
@property NSArray *result;
@property NSArray *resultGeo;
@end

@implementation SearchOnMap
{
    NSInteger seq_;
}

- (id)init
{
    self = [super init];
    if (self) {
        seq_ = 0;
        _result = @[];
        _resultGeo = @[];
    }
    return self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return _result.count;
    } else {
        return _resultGeo.count;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return _result.count == 0 ? nil : NSLocalizedString(@"Spot", nil);
    } else {
        return _resultGeo.count == 0 ? nil : NSLocalizedString(@"Address", nil);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchResultCell"];
    //[Theme setTableViewCellBackgroundColor:cell];
    [Theme setTableViewCellSelectedBackgroundColor:cell];

    if (indexPath.section == 0) {
        Pin *p = _result[indexPath.row];
        cell.textLabel.text = p.name;
        [p subtitle:cell];
    } else {
        NSDictionary *r = _resultGeo[indexPath.row];
        DLog(@"%@", r);
        if (r[@"title"]) {
            cell.textLabel.text = r[@"title"];
            cell.detailTextLabel.text = r[@"addr"];
        } else {
            cell.textLabel.text = r[@"addr"];
            cell.detailTextLabel.text = @" ";
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (id)resultFromIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return _result[indexPath.row];
    } else {
        return _resultGeo[indexPath.row];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    @synchronized(self) {
        tableView.hidden = YES;
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        if (_didTapRowCallback)
            _didTapRowCallback([self resultFromIndexPath:indexPath]);
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //DLog(@"%@", scrollView);
    [_srcViewController hideKeyboard];
}

#pragma mark - public

- (void)searchPin:(NSString *)str no:(NSInteger)no
{
    NSArray *res = [DataSource searchPinsByKeyword:str];

    @synchronized(self) {
        if (no < seq_)      // newer request was sent
            return;
        self.result = res ?: @[];
        [ProcUtil asyncMainq:^{
            [self.tableView reloadData];
        }];
    }
}

- (void)searchAddr:(NSString *)str no:(NSInteger)no
{
    [GeoUtil searchByStr:str handler:^(NSArray *results, NSError *error) {
        if (error) {
            ELog(@"%@", error);
            return;
        }
        @synchronized(self) {
            if (no < seq_)      // newer request was sent
                return;
            _resultGeo = results ?: @[];
            [ProcUtil asyncMainq:^{
                [self.tableView reloadData];
            }];
        }
    }];
}

- (void)searchByStr:(NSString *)str
{
    @synchronized(self) {
        ++seq_;
    }

    __block NSInteger no = seq_;

    if ([StringUtil empty:str]) {
        [self clear];
        str = @"%";
        [self searchPin:str no:no];
    } else {
        [self searchPin:str no:no];
        [self searchAddr:str no:no];
    }
}

- (void)clear
{
    @synchronized(self) {
        self.result = @[];
        self.resultGeo = @[];
        [ProcUtil asyncMainq:^{
            [self.tableView reloadData];
        }];
    }
}

@end
