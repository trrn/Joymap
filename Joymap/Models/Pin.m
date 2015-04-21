//
//  Pin.m
//  Joymap
//
//  Created by faith on 2013/10/14.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import "Pin.h"

#import "DataSource.h"
#import "Cache.h"
#import "JMTableViewCell.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <UIImage+Resize.h>
#import <UIImage+RoundedCorner.h>

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
        UIImage *image = thumbnailCache_[@(self.id)];;
        if (!image) {
            Item *item = [DataSource itemForThumbnail:self];
            if (!item) {
                return;
            }
            switch (item.type) {
                case ITEM_TYPE_IMAGE: {
                    if (item.resource2 && item.resource2.length) {  // binary
                        image = [UIImage imageWithData:item.resource2];
                        image = [image thumbnailImage:JM_LIST_THUMBNAIL_SIZE*2 transparentBorder:0 cornerRadius:10 interpolationQuality:kCGInterpolationHigh];
                        thumbnailCache_[@(self.id)] = image;
                    } else if (item.resource1 && item.resource1.length) {   // url
                        cell.imageView.image = [UIImage imageNamed:@"thumbnail_nothing.png"];
                        [ProcUtil asyncMainq:^{
                            [SDWebImageDownloader.sharedDownloader
                             downloadImageWithURL:item.resource1.URL
                             options:0
                             progress:nil
                             completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                 if (!error) {
                                     image = [image thumbnailImage:JM_LIST_THUMBNAIL_SIZE*2 transparentBorder:0 cornerRadius:10 interpolationQuality:kCGInterpolationHigh];
                                     thumbnailCache_[@(self.id)] = image;
                                     cell.imageView.image = image;
                                 }
                             }];
                        }];
                        return;
                    } else {
                        ELog(@"no image resource %ld", (long)self.id);
                    }
                    break;
                }
                case ITEM_TYPE_MOVIE:     // movie
                    image = [UIImage imageNamed:@"thumbnail_tv.png"];
                    image = [image thumbnailImage:JM_LIST_THUMBNAIL_SIZE*2 transparentBorder:0 cornerRadius:10 interpolationQuality:kCGInterpolationHigh];
                    break;
                default:
                    break;
            }
        }
        [ProcUtil asyncMainq:^{
            cell.imageView.image = image;
        }];
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
