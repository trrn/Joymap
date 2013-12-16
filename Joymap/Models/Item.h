//
//  Item.h
//  Joymap
//
//  Created by gli on 2013/10/14.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ITEM_TYPE_TEXT    1
#define ITEM_TYPE_IMAGE   2
#define ITEM_TYPE_MOVIE   3
#define ITEM_TYPE_SOUND   4
#define ITEM_TYPE_TEL     5
#define ITEM_TYPE_ADDR    6
#define ITEM_TYPE_URL     7
#define ITEM_TYPE_EMAIL   8
#define ITEM_TYPE_WEB   100

@interface Item : NSObject <NSCopying>

@property (nonatomic) NSInteger id;
@property (nonatomic) NSInteger type;
@property (nonatomic) NSString *resource1;
@property (nonatomic) NSData   *resource2;

@property (nonatomic) NSInteger layoutId;
@property (nonatomic) NSInteger layoutItemId;
@property (nonatomic) NSInteger orderNo;

#pragma mark - local tmp data

@property (nonatomic) NSString *localUrl;

- (NSURL *)url;

#pragma mark - 

- (BOOL)isAsText;
- (BOOL)isAsThumbnail;
- (BOOL)isImageOrMovie;
- (BOOL)isWebPage;
- (UIImage *)image;

#pragma mark - persistence

- (void)beforeSave;

@end
