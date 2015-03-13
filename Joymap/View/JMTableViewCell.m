//
//  JMTableViewCell.m
//  Renai
//
//  Created by Faith on 2014/09/12.
//  Copyright (c) 2014年 faith. All rights reserved.
//

#import "JMTableViewCell.h"

#import <UIImage+ProportionalFill.h>

#import <NIKFontAwesomeIconFactory.h>
#import <NIKFontAwesomeIconFactory+iOS.h>

#define PAD 4

@interface JMTableViewCell ()
@property (nonatomic) UIButton *button;
@end

@implementation JMTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [Theme setTableViewCellSelectedBackgroundColor:self];
    }
    return self;
}

- (void)awakeFromNib
{
    [Theme setTableViewCellSelectedBackgroundColor:self];
    
    const CGFloat BUTTON_SIZE = 32.0f;

    self.button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.button.frame = CGRectMake(257.0f, 14.0f, BUTTON_SIZE, BUTTON_SIZE);
    NIKFontAwesomeIconFactory *factory = [NIKFontAwesomeIconFactory tabBarItemIconFactory];
    [self.button setImage:[factory createImageForIcon:NIKFontAwesomeIconMapMarker] forState:UIControlStateNormal];
    [self.contentView addSubview:self.button];
    self.button.tintColor = UIColorFromRGB(0xf76459);
    [self.button addTarget:self action:@selector(tapButton) forControlEvents:UIControlEventTouchUpInside];
    [self.button addTarget:self action:@selector(highlightBorder) forControlEvents:UIControlEventTouchDown];
    [self.button addTarget:self action:@selector(unhighlightBorder) forControlEvents:UIControlEventTouchCancel|UIControlEventTouchUpOutside|UIControlEventTouchDragExit|UIControlEventTouchDragOutside];

    self.button.layer.cornerRadius = BUTTON_SIZE / 2;
    self.button.layer.borderColor = [UIColorFromRGB(0xf76459) CGColor];
    self.button.layer.borderWidth = 1.2f;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(PAD,PAD,JM_LIST_THUMBNAIL_SIZE,JM_LIST_THUMBNAIL_SIZE);
    float limgW =  self.imageView.image.size.width;
    if(limgW > 0) {
        self.textLabel.frame = CGRectMake(PAD + JM_LIST_THUMBNAIL_SIZE + PAD,self.textLabel.frame.origin.y,self.textLabel.frame.size.width,self.textLabel.frame.size.height);
        self.detailTextLabel.frame = CGRectMake(PAD + JM_LIST_THUMBNAIL_SIZE + PAD,self.detailTextLabel.frame.origin.y,self.detailTextLabel.frame.size.width,self.detailTextLabel.frame.size.height);
    }
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
}

- (void)highlightBorder
{
    self.button.layer.borderColor = [UIColorFromRGB(0xfee4e2) CGColor];
}

- (void)tapButton
{
    [self unhighlightBorder];
    [_listViewController tapCellButton:self.pin];
}

- (void)unhighlightBorder
{
    self.button.layer.borderColor = [UIColorFromRGB(0xf76459) CGColor];
}

@end
