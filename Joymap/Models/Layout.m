//
//  Layout.m
//  Joymap
//
//  Created by gli on 2013/10/14.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import "Layout.h"

#import "DataSource.h"

#import <UIImage+ProportionalFill.h>

@implementation Layout

- (id)copyWithZone:(NSZone *)zone
{
    typeof(self) copy = self.class.new;

    if (copy) {
        copy.id = _id;
        copy.pinId = _pinId;
        copy.kind = _kind;
        copy.orderNo = _orderNo;
        if (_items) {
            copy.items = [NSMutableArray.alloc initWithArray:_items copyItems:YES];
        }
    }
    return copy;
}

- (void)summaryForCell:(UITableViewCell *)cell;
{
    cell.textLabel.text = nil;
    cell.textLabel.font = [UIFont systemFontOfSize:12.0];
    cell.detailTextLabel.text = nil;
    cell.imageView.image = [UIImage imageNamed:@"thumbnail_nothing.png"];
    BOOL imageSetted = NO;
    for (Item *item in self.items) {
        if (item.isAsText) {
            if (!cell.textLabel.text) {
                cell.textLabel.text = item.resource1;
                continue;
            } else if (!cell.detailTextLabel.text) {
                cell.detailTextLabel.text = item.resource1;
                continue;
            }
        } else if (!imageSetted && item.isAsThumbnail) {
            imageSetted = YES;
            [self thumbnail:cell item:item];
        }
    }
}

- (void)thumbnail:(UITableViewCell *)cell item:(Item *)item
{
    [ProcUtil asyncGlobalq:^{
        UIImage *img = nil;
        switch (item.type) {
            case 2:     // image
                img = [item image];
                break;
            case 3:     // movie
                img = [UIImage imageNamed:@"thumbnail_tv.png"];
                break;
            default:
                break;
        }
        if (img) {
            img = [img imageToFitSize:THUMBNAIL_CGSZ method:MGImageResizeCrop];
        }
        if (img) {
            [ProcUtil asyncMainq:^{
                if (cell) {
                    cell.imageView.image = img;
                }
            }];
        }
    }];
}

- (NSArray *)texts
{
    NSMutableArray *ret = @[].mutableCopy;
    for (Item *i in self.items) {
        if (i.isAsText) {
            [ret addObject:i];
        }
    }
    return ret;
}

- (NSMutableArray *)items
{
    if (!_items) {
        _items = [DataSource items:self];
    }
    return _items;
}

#pragma mark - persistence

- (void)beforeSave;
{
    for (Item *item in _items) {
        [item beforeSave];
    }
}

@end
