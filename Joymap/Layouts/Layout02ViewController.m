//
//  Layout02ViewController.m
//  Joymap
//
//  Created by gli on 2013/10/26.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import "Layout02ViewController.h"

#import "Item.h"
#import "Layout.h"

@interface Layout02ViewController ()
@property (weak, nonatomic) IBOutlet UIView *v1;
@property (weak, nonatomic) IBOutlet UITextView *v2;
@end

@implementation Layout02ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setImageOrMovieView:self.v1 item:[self itemAtOrderNo:1]];
    [self setTextView:self.v2 item:[self itemAtOrderNo:2] bottomPadding:20.0];
}

- (void)editDone
{
    [self setItem:ITEM_TYPE_TEXT resource1:_v2.text orderNo:2];

    [super editDone];
}

- (void)removeImageOrMovie:(id)sender
{
    if (sender == _v1) {
        Item *item = [self itemAtOrderNo:1];
        if (item && item.isImageOrMovie) {
            [self.layout.items removeObject:item];
            [_v1.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }
    }
}

- (void)setImageOrMovie:(id)sender info:(NSDictionary *)info
{
    if (sender == _v1) {
        Item *item = [self setItemWithMediaInfo:info orderNo:1];
        [self setImageOrMovieView:_v1 item:item];
    }
}

@end
