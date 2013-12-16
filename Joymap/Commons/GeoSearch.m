//
//  GeoSearch.m
//  Joymap
//
//  Created by gli on 2013/11/02.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import "GeoSearch.h"

#import "GoogleMapsViewController.h"

#import <CoreLocation/CLLocation.h>

@interface GeoSearch()
@property NSArray *result;
@end

@implementation GeoSearch
{
    NSInteger seq_;
}

- (id)init
{
    self = [super init];
    if (self) {
        seq_ = 0;
    }
    return self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _result.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GeoSearchCell"];
    
    cell.textLabel.text = _result[indexPath.row][@"addr"];

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    @synchronized(self) {
        CLLocationCoordinate2D co = CLLocationCoordinate2DMake(0.0, 0.0);
        if ([GeoUtil strToCoordinate2D:_result[indexPath.row][@"latlng"] co:&co]) {
            tableView.hidden = YES;
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            if (_didTapRowCallback)
                _didTapRowCallback(co, _result[indexPath.row][@"addr"]);
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //DLog(@"%@", scrollView);
    [_srcViewController hideKeyboard];
}

#pragma mark - public

- (void)searchByStr:(NSString *)str
{
    ++seq_;
    __block NSInteger no = seq_;

    if ([StringUtil empty:str]) {
        [self clear];
        return;
    }

    [GeoUtil searchByStr:str handler:^(NSArray *res, NSError *err) {
        if (err) {
            ELog(@"%@", err);
            return;
        }
        if (no < seq_)      // newer request was sent
            return;
        @synchronized(self) {
            self.result = res ? res : @[];
            [ProcUtil asyncMainq:^{
                [self.tableView reloadData];
            }];
        }
    }];
}

- (void)clear
{
    @synchronized(self) {
        self.result = @[];
        [ProcUtil asyncMainq:^{
            [self.tableView reloadData];
        }];
    }
}

@end
