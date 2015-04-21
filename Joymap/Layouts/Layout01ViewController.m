//
//  Layout01ViewController.m
//  Joymap
//
//  Created by faith on 2013/10/23.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import "Layout01ViewController.h"

#import "Item.h"
#import "Layout.h"

@interface Layout01ViewController ()
@property (weak, nonatomic) IBOutlet UIView     *v1;
@property (weak, nonatomic) IBOutlet UITextView *v2;
@property (weak, nonatomic) IBOutlet UITextView *v3;
@end

@implementation Layout01ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setImageOrMovieView:self.v1 item:[self itemAtOrderNo:1]];
    [self setTextView:self.v2 item:[self itemAtOrderNo:2]];
    [self setTextView:self.v3 item:[self itemAtOrderNo:3] bottomPadding:20.0];
    
    self.v3.layer.cornerRadius = 5;
    self.v3.clipsToBounds = true;
}

- (void)editDone
{
    [self setItem:ITEM_TYPE_TEXT resource1:_v2.text orderNo:2];
    [self setItem:ITEM_TYPE_TEXT resource1:_v3.text orderNo:3];

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
