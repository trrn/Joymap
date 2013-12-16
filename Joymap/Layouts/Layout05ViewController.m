//
//  Layout05ViewController.m
//  Joymap
//
//  Created by gli on 2013/10/26.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import "Layout05ViewController.h"

#import "Item.h"
#import "Layout.h"

@interface Layout05ViewController ()
@property (weak, nonatomic) IBOutlet UIView *v1;
@property (weak, nonatomic) IBOutlet UIButton *v2button;
@property (weak, nonatomic) IBOutlet UISlider *v2slider;
@property (weak, nonatomic) IBOutlet UITextView *v3;
@end

@implementation Layout05ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setImageOrMovieView:self.v1 item:[self itemAtOrderNo:1]];
    self.soundButton = self.v2button;
    self.soundSlider = self.v2slider;
    [super prepareSound:[self itemAtOrderNo:2].resource1];
    [self setTextView:self.v3 item:[self itemAtOrderNo:3] bottomPadding:20.0];
}

- (IBAction)pushV2button:(id)sender {
    [self pushSoundButton];
}

- (IBAction)changeV2slider:(id)sender {
    [self changeSoundSlider];
}

- (void)editDone
{
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
