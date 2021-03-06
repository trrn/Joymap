//
//  LayoutViewController.h
//  Joymap
//
//  Created by faith on 2013/10/23.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>

#import <STKAudioPlayer.h>

@class Item, Layout;

@interface LayoutViewController : BaseViewController

@property (nonatomic) NSInteger page;
@property (nonatomic) Layout *layout;
@property (nonatomic) BOOL edit;

#pragma mark - sound

@property (nonatomic) STKAudioPlayer *audioPlayer;
@property (nonatomic) UIButton *soundButton;
@property (nonatomic) UISlider *soundSlider;

- (void)prepareSoundWithURL:(NSString *)url;
- (void)prepareSoundWithData:(NSData *)data;
- (void)pushSoundButton;
- (void)changeSoundSlider;

#pragma mark - movie

@property (nonatomic) MPMoviePlayerController *mplayer;

#pragma mark - prepare view

- (void)setImageOrMovieView:(UIView *)superView item:(Item *)item;
- (void)setTextView:(UITextView *)textView item:(Item *)item;
- (void)setTextView:(UITextView *)textView item:(Item *)item bottomPadding:(CGFloat)bottomPadding;
- (Item *)itemAtOrderNo:(NSInteger)no;

#pragma mark - page change

- (void)pageClosed;

#pragma mark - edit

// update layout
- (void)editDone;
@property (nonatomic, copy) void (^editDoneHandler)(Layout *);

// update item
- (Item *)setItem:(NSInteger)type resource1:(NSString *)res1 orderNo:(NSInteger)no;
- (Item *)setItemWithMediaInfo:(NSDictionary *)info orderNo:(NSInteger)no;

// update view & item
- (void)removeImageOrMovie:(id)sender;
- (void)setImageOrMovie:(id)sender info:(NSDictionary *)info;

@end
