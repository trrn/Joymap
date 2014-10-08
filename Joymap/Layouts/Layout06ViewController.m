//
//  Layout04aViewController.m
//  Joymap
//
//  Created by Faith on 2014/09/08.
//  Copyright (c) 2014年 sekken. All rights reserved.
//

#import "Layout06ViewController.h"

#import "Item.h"
#import "Layout.h"

@interface Layout06ViewController ()
@property (weak, nonatomic) IBOutlet UIView *v1;
@property (weak, nonatomic) IBOutlet UITextView *v2;
@property (weak, nonatomic) IBOutlet UIButton *v3button;
@property (weak, nonatomic) IBOutlet UISlider *v3slider;
@property (weak, nonatomic) IBOutlet UITextView *v4;
@property (weak, nonatomic) IBOutlet UIButton *v5button;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topMargin;
@end

@implementation Layout06ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setImageOrMovieView:self.v1 item:[self itemAtOrderNo:1]];
    [self setTextView:self.v2 item:[self itemAtOrderNo:2]];
    self.soundButton = self.v3button;
    self.soundSlider = self.v3slider;
    [self setTextView:self.v4 item:[self itemAtOrderNo:4] bottomPadding:20.0];
    
    Item *soundItem = [self itemAtOrderNo:3];
    if (soundItem.resource2) { // binary
        [super prepareSoundWithData:soundItem.resource2];
    } else {    // URL
        [super prepareSoundWithURL:soundItem.resource1];
    }
    
//    if (![Version greaterThanOrEqualMajorVersion:8 minorVersion:0 patchVersion:0]) {
//        self.topMargin.constant = 64;
//    }
}

- (IBAction)pushV3btn:(id)sender {
    DLog();
    [self pushSoundButton];
}

- (IBAction)changeV3slider:(id)sender {
    [self changeSoundSlider];
}

- (IBAction)pushV5btn:(id)sender {
    Item *item = [self itemAtOrderNo:5];
    
    if (item.resource1) {
        [[UIApplication sharedApplication] openURL:item.resource1.URL];
    }
}

- (void)editDone
{
    [self setItem:ITEM_TYPE_TEXT resource1:_v2.text orderNo:2];
    [self setItem:ITEM_TYPE_TEXT resource1:_v4.text orderNo:4];
    
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
