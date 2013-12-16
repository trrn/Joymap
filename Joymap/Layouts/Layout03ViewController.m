//
//  Layout03ViewController.m
//  Joymap
//
//  Created by gli on 2013/10/26.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import "Layout03ViewController.h"

#import "Item.h"
#import "Layout.h"

#import <UIView+AutoLayout.h>

@interface Layout03ViewController ()

@end

@implementation Layout03ViewController
{
    UIView *v1_;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self layoutItem:[self itemAtOrderNo:1]];
}

- (void)layoutItem:(Item *)item
{
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.view removeConstraints:self.view.constraints];
    v1_ = nil;
    
    if (!item)
        return;
    
    if (item.isAsText) {
        UITextView *v = UITextView.autoLayoutView;
        [self setTextView:v item:item];
        v1_ = v;
    } else if (item.isImageOrMovie) {
        UIView *v = UIView.autoLayoutView;
        [self setImageOrMovieView:v item:item];
        v1_ = v;
    } else if (item.isWebPage) {
        UIWebView *v = UIWebView.autoLayoutView;
        NSURL *url = item.url;
        NSURLRequest *req = [NSURLRequest requestWithURL:url];
        [v loadRequest:req];
        v1_ = v;
    }
    
    if (v1_) {
        [self.view addSubview:v1_];
        [v1_ pinToSuperviewEdges:JRTViewPinAllEdges inset:0.0];
    }
}

- (void)editDone
{
    if ([v1_ isMemberOfClass:UITextView.class]) {
        UITextView *tv = (UITextView *)v1_;
        [self setItem:ITEM_TYPE_TEXT resource1:tv.text orderNo:1];
    }
    [super editDone];
}

- (void)removeImageOrMovie:(id)sender
{
    Item *item = [self itemAtOrderNo:1];
    if (item && item.isImageOrMovie) {
        [self.layout.items removeObject:item];
        [v1_ removeFromSuperview];
        [v1_.superview removeConstraints:v1_.superview.constraints];
    }
}

- (void)setImageOrMovie:(id)sender info:(NSDictionary *)info
{
    if (sender == v1_) {
        Item *item = [self setItemWithMediaInfo:info orderNo:1];
        [self layoutItem:item];
    }
}

@end
