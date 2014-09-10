//
//  Item.m
//  Joymap
//
//  Created by gli on 2013/10/14.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import "Item.h"

@implementation Item

- (id)copyWithZone:(NSZone *)zone
{
    typeof(self) copy = self.class.new;

    if (copy) {
        copy.id = _id;
        copy.type = _type;
        copy.resource1 = _resource1;
        copy.resource2 = _resource2;
        copy.layoutId = _layoutId;
        copy.layoutItemId = _layoutItemId;
        copy.orderNo = _orderNo;
    }
    return copy;
}

- (BOOL)isAsText
{
    switch (_type) {
        case ITEM_TYPE_TEXT :
        case ITEM_TYPE_TEL  :
        case ITEM_TYPE_ADDR :
        case ITEM_TYPE_URL  :
        case ITEM_TYPE_EMAIL:
            return YES;
            break;
    }
    return NO;
}

- (BOOL)isAsThumbnail
{
    return self.isImageOrMovie;
}

- (BOOL)isImageOrMovie
{
    switch (_type) {
        case ITEM_TYPE_IMAGE:
        case ITEM_TYPE_MOVIE:
            return YES;
            break;
    }
    return NO;
}

- (BOOL)isWebPage
{
    switch (_type) {
        case ITEM_TYPE_WEB:
            return YES;
            break;
    }
    return NO;
}

- (UIImage *)image;
{
    if (self.type == ITEM_TYPE_IMAGE) {
        if (_localUrl) {
            return [UIImage imageWithContentsOfFile:_localUrl]; // local image (editing)

        } else if (self.resource2 && self.resource2.length) {   // binary TODO validate image binary
            return [UIImage imageWithData:self.resource2];

        } else if (self.resource1 && self.resource1.length) {   // url
            NSData *data = [NSData dataWithContentsOfURL:self.resource1.URL];
            return [UIImage.alloc initWithData:data];

        } else {
            ELog(@"no image resource %ld", self.id);
        }
    }

    return nil;
}

- (NSURL *)url
{
    if (_localUrl)
        return _localUrl.fileURL;

    if ([self isImageOrMovie]) {
        if (!_resource2 || !_resource2.length) {
            if (_resource1 && _resource1.length)
                return _resource1.URL;
        }
    }

    return nil;
}

#pragma mark - persistence

- (void)beforeSave
{
    if (!_resource1)
        _resource1 = @"";
}

@end
