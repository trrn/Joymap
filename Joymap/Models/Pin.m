//
//  Pin.m
//  Joymap
//
//  Created by gli on 2013/10/14.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import "Pin.h"

#import "DataSource.h"
#import "Cache.h"

#import <UIImage+ProportionalFill.h>

static Cache *thumbnailCache_ = nil;
static Cache *subtitleCache_ = nil;

@implementation Pin

- (id)copyWithZone:(NSZone *)zone
{
    typeof(self) copy = self.class.new;

    if (copy) {
        copy.id = _id;
        copy.latitude = _latitude;
        copy.longitude = _longitude;
        copy.name = _name;
        copy.kategoryId = _kategoryId;
        if (_layouts) {
            copy.layouts = [NSMutableArray.alloc initWithArray:_layouts copyItems:YES];
        }
        copy.marker = _marker;
    }
    return copy;
}

- (void)thumbnail:(UITableViewCell *)cell
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        thumbnailCache_ = Cache.new;
    });

    cell.imageView.image = [UIImage imageNamed:@"thumbnail_nothing.png"];
    
    [ProcUtil asyncGlobalq:^{
        UIImage *img = thumbnailCache_[@(self.id)];
        if (img) {
            //DLog(@"image cache hit %@", self.name);
        } else {
            Item *item = [DataSource itemForThumbnail:self];
            if (!item) {
                return;
            }
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
                thumbnailCache_[@(self.id)] = img;
            }
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

- (void)subtitle:(UITableViewCell *)cell
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        subtitleCache_ = Cache.new;
    });
    
    cell.detailTextLabel.text = @"";

    NSString *str = subtitleCache_[@(self.id)];
    if (str) {
        //DLog(@"subtitle cache hit %@", self.name);
    } else {
        Item *item = [DataSource itemForSubtitle:self];
        if (item) {
            str = item.resource1;
            subtitleCache_[@(self.id)] = str;
        }
    }
    if (str) {
        cell.detailTextLabel.text = str;
    }
}

- (CLLocationCoordinate2D)coordinate;
{
    CLLocationCoordinate2D co = { _latitude, _longitude };
    return co;
}

- (NSString *)coordinateStr;
{
    return [GeoUtil coordinate2DtoStr:self.coordinate];
}

+ (void)clearCache;
{
    DLog();

    [thumbnailCache_ clear];
    [subtitleCache_ clear];
}

- (NSMutableArray *)layouts
{
    if (!_layouts) {
        _layouts = [DataSource layouts:self];
    }
    return _layouts;
}

#pragma mark - persistence

- (void)beforeSave
{
    if (!_name)
        _name = @"";

    for (Layout *lay in _layouts) {
        [lay beforeSave];
    }
}

@end
