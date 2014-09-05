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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchResultCell"];
    
    Pin *p = _result[indexPath.row];
    
    cell.textLabel.text = p.name;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    @synchronized(self) {
        tableView.hidden = YES;
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        if (_didTapRowCallback)
            _didTapRowCallback(_result[indexPath.row]);
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

    @synchronized(self) {
        NSArray *res = [DataSource searchPinsByKeyword:str];
        if (no < seq_)      // newer request was sent
            return;
        self.result = res ?: @[];
        [ProcUtil asyncMainq:^{
            [self.tableView reloadData];
        }];
    }
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
