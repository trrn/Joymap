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

    self.button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.button.frame = CGRectMake(250.0f, 8.0f, 40.0f, 40.0f);
    NIKFontAwesomeIconFactory *factory = [NIKFontAwesomeIconFactory tabBarItemIconFactory];
    [self.button setImage:[factory createImageForIcon:NIKFontAwesomeIconMapMarker] forState:UIControlStateNormal];
    [self.contentView addSubview:self.button];
    self.button.tintColor = UIColorFromRGB(0xf76459);
    [self.button addTarget:self action:@selector(tapButton) forControlEvents:UIControlEventTouchUpInside];
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

- (void)tapButton
{
    [_listViewController tapCellButton:self.pin];
}

@end
