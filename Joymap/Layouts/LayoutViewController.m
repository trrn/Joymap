//
//  LayoutViewController.m
//  Joymap
//
//  Created by gli on 2013/10/23.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import "LayoutViewController.h"

#import "Item.h"
#import "Layout.h"
#import "Pin.h"
#import "PinViewController.h"

#import <IDMPhotoBrowser.h>
#import <UIView+AutoLayout.h>
#import <STKDataSource.h>

#import <MobileCoreServices/MobileCoreServices.h>

@interface LayoutViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, STKAudioPlayerDelegate>

@end

@implementation LayoutViewController {
    id              avplaybackObserver_;
    UIActionSheet  *photoActionSheet_;
    id              tapped_;
    BOOL            stop_;
    
    NSTimer *timer_;
    NSString *soundURL_;
    STKDataSource *soundDataSource_;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (_edit) {
        self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
        UIBarButtonItem *ok = [UIBarButtonItem.alloc initWithTitle:NSLocalizedString(@"OK", nil)
                                                             style:UIBarButtonItemStylePlain
                                                            target:self action:@selector(editDone)];
        self.navigationItem.rightBarButtonItem = ok;
    }
}

- (void)dealloc
{
    if (self.audioPlayer) {
        self.audioPlayer.delegate = nil;
    }
}

- (void)setImageOrMovieView:(UIView *)superView item:(Item *)item
{
    // clear
    [superView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [superView removeConstraints:superView.constraints];
    for (UIGestureRecognizer *ges in superView.gestureRecognizers) {
        [superView removeGestureRecognizer:ges];
    }

    if (!item)
        return;

    // add ActivityIndicator
    UIActivityIndicatorView *indicator = UIActivityIndicatorView.autoLayoutView;
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [superView addSubview:indicator];
    [indicator centerInView:superView];
    [indicator startAnimating];

    // add subview
    switch (item.type) {
        case ITEM_TYPE_IMAGE: {
            UIImageView *v = UIImageView.autoLayoutView;
            v.contentMode = UIViewContentModeScaleAspectFit;
            v.userInteractionEnabled = YES;
            [superView addSubview:v];
            [v pinToSuperviewEdges:JRTViewPinAllEdges inset:0.0];

            UITapGestureRecognizer *tap = UITapGestureRecognizer.new;
            [tap addTarget:self action:@selector(tapImage:)];
            [v addGestureRecognizer:tap];
            v.userInteractionEnabled = YES;

            [ProcUtil asyncGlobalq:^{
                UIImage *img = [item image];
                [ProcUtil asyncMainq:^{
                    [indicator stopAnimating];
                    [indicator removeFromSuperview];
                    v.image = img;
                }];
            }];
            break;
        }
        case ITEM_TYPE_MOVIE: {
            self.mplayer = [MPMoviePlayerController.alloc initWithContentURL:item.url];
            [self.mplayer prepareToPlay];
            self.mplayer.scalingMode = MPMovieScalingModeAspectFit;
            self.mplayer.shouldAutoplay = [DefaultsUtil bool:DEF_SET_ETC_AUTOPLAY];
            self.mplayer.view.clipsToBounds = YES;
            [superView addSubview:self.mplayer.view];
            self.mplayer.view.translatesAutoresizingMaskIntoConstraints = NO;
            [self.mplayer.view pinToSuperviewEdges:JRTViewPinAllEdges inset:0.0];

            if (_edit) {
                UITapGestureRecognizer *tap = UITapGestureRecognizer.new;
                [tap addTarget:self action:@selector(tapImage:)];
                [superView addGestureRecognizer:tap];
                superView.userInteractionEnabled = YES;
            }

            [superView bringSubviewToFront:indicator];
            indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;

            [ProcUtil asyncGlobalq:^{
                while (!self.mplayer.isPreparedToPlay) {
                    usleep(100 * 1000);
                }
                [ProcUtil asyncMainq:^{
                    [indicator stopAnimating];
                    [indicator removeFromSuperview];
                }];
            }];
            break;
        }
    }
}

- (void)setTextView:(UITextView *)textView item:(Item *)item
{
    if (item) {
        textView.text = item.resource1;
    } else {
        textView.text = nil;
    }

    if (_edit) {
        textView.editable = YES;
    }
}

- (void)setTextView:(UITextView *)textView item:(Item *)item bottomPadding:(CGFloat)bottomPadding;
{
    textView.text = item.resource1;
    UIEdgeInsets inset = textView.textContainerInset;
    inset.bottom += bottomPadding;
    textView.textContainerInset = inset;
    if (_edit) {
        textView.editable = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    DLog();
}

#pragma mark - page change

- (void)fadeout
{
    [ProcUtil asyncMainq:^{
        for (double i=1.0; i>0.0; i-=0.1) {
            if (!self.audioPlayer)
                break;
            self.audioPlayer.volume = i;
            usleep(50000);
        }
        if (self.audioPlayer) {
            [self.audioPlayer stop];
        }
    }];
}

- (void)pageClosed
{
    //DLog(@"%d", self.page);

    // sound
    [timer_ invalidate];
    [self fadeout];

    // movie
    [self.mplayer pause];
}

#pragma mark - UITapGestureRecognizer

- (void)tapImage:(UITapGestureRecognizer *)sender
{
    if (_edit) {
        photoActionSheet_ = UIActionSheet.new;
        photoActionSheet_.delegate = self;
        photoActionSheet_.title = @"";
        if (sender.view.subviews.count) {
            [photoActionSheet_ addButtonWithTitle:NSLocalizedString(@"Remove", nil)];
            photoActionSheet_.destructiveButtonIndex = 0;
        }
        [photoActionSheet_ addButtonWithTitle:NSLocalizedString(@"Take a photo", nil)];
        [photoActionSheet_ addButtonWithTitle:NSLocalizedString(@"Pick up from Library", nil)];
        [photoActionSheet_ addButtonWithTitle:NSLocalizedString(@"Pick up from Album", nil)];
        [photoActionSheet_ addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
        photoActionSheet_.cancelButtonIndex = photoActionSheet_.numberOfButtons - 1;
        [photoActionSheet_ showInView:self.view];
        tapped_ = sender;
    } else {
        UIImageView *v = (UIImageView *)sender.view;
        IDMPhoto *photo = [IDMPhoto.alloc initWithImage:v.image];
        IDMPhotoBrowser *viewer = [IDMPhotoBrowser.alloc initWithPhotos:@[photo]];
        [self presentViewController:viewer animated:YES completion:nil];
    }
}

#pragma mark - sound

- (void)prepareSoundWithURL:(NSString *)url
{
    if ([StringUtil empty:url] || self.audioPlayer) {
        return;
    }

    DLog(@"%@", url);
    soundURL_ = url;

    self.audioPlayer = [STKAudioPlayer.alloc initWithOptions:(STKAudioPlayerOptions){.enableVolumeMixer = YES}];
    self.audioPlayer.delegate = self;

    if ([DefaultsUtil bool:DEF_SET_ETC_AUTOPLAY]) {
        [self.audioPlayer queue:soundURL_];
    }
    
    [self updateSoundControl];
    [self setupTimer];
}

- (void)prepareSoundWithData:(NSData *)data;
{
    if (!data) {
        return;
    }

    // work around. StreamKit cannot play NSData, so read from local file as URL.

    NSString *tmp = [NSTemporaryDirectory() stringByAppendingPathComponent:@"sound"];
    [data writeToFile:tmp atomically:NO];

    NSURL *url = [NSURL fileURLWithPath:tmp];
    DLog(@"%@", url.description);

    [self prepareSoundWithURL:url.absoluteString];
}

- (void)pushSoundButton;
{
    if (!self.audioPlayer)
    {
        return;
    }
    
    if (!self.audioPlayer.pendingQueueCount) {  // first tapped
        [self.audioPlayer queue:soundURL_];
    }
    else if (self.audioPlayer.state == STKAudioPlayerStatePaused)  // pausing
    {
        [self.audioPlayer resume];
    }
    else    // playing
    {
        [self.audioPlayer pause];
    }
}

- (void)changeSoundSlider;
{
    if (!self.audioPlayer) {
        return;
    }
    
    [self.audioPlayer seekToTime:self.soundSlider.value];
}

- (void)updateSoundControl
{
	if (self.audioPlayer == nil)
	{
        ;
	}
	else if (self.audioPlayer.state == STKAudioPlayerStatePaused)
	{
        [self.soundButton setTitle:NSLocalizedString(@"Play", nil) forState:UIControlStateNormal];
	}
	else if (self.audioPlayer.state & STKAudioPlayerStatePlaying)
	{
        [self.soundButton setTitle:NSLocalizedString(@"Pause", nil) forState:UIControlStateNormal];
	}
	else
	{
        ;
	}
    
    [self tick];
}

#pragma mark - STKAudioPlayerDelegate

- (void)audioPlayer:(STKAudioPlayer *)audioPlayer didStartPlayingQueueItemId:(NSObject *)queueItemId
{
    DLog(@"Started: %@", [queueItemId description]);
    
	[self updateSoundControl];
}

- (void)audioPlayer:(STKAudioPlayer *)audioPlayer didFinishBufferingSourceWithQueueItemId:(NSObject *)queueItemId
{
    DLog(@"Finish Buffering");
    
    [audioPlayer queue:soundURL_];

	[self updateSoundControl];
}

- (void)audioPlayer:(STKAudioPlayer *)audioPlayer stateChanged:(STKAudioPlayerState)state previousState:(STKAudioPlayerState)previousState
{
    DLog(@"State changed");
    
	[self updateSoundControl];
}

- (void)audioPlayer:(STKAudioPlayer *)audioPlayer didFinishPlayingQueueItemId:(NSObject *)queueItemId withReason:(STKAudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration
{
    DLog(@"Finish Playing");

    [audioPlayer pause];

	[self updateSoundControl];
}

- (void)audioPlayer:(STKAudioPlayer *)audioPlayer unexpectedError:(STKAudioPlayerErrorCode)errorCode
{
    DLog(@"Unexpected Error: %d", errorCode);
    
	[self updateSoundControl];
}

// debug
//- (void)audioPlayer:(STKAudioPlayer *)audioPlayer logInfo:(NSString *)line
//{
//    DLog(@"%@", line);
//}

- (void)tick
{
	if (!self.audioPlayer)
	{
		self.soundSlider.value = 0;
		return;
	}
	
    if (self.audioPlayer.duration != 0)
    {
        self.soundSlider.minimumValue = 0;
        self.soundSlider.maximumValue = self.audioPlayer.duration;
        self.soundSlider.value = self.audioPlayer.progress;
    }
    else
    {
        self.soundSlider.value = 0;
        self.soundSlider.minimumValue = 0;
        self.soundSlider.maximumValue = 0;
    }
}

- (void)setupTimer
{
    if (timer_) {
        [timer_ invalidate];
    }
    
	timer_ = [NSTimer timerWithTimeInterval:0.01 target:self selector:@selector(tick) userInfo:nil repeats:YES];
	
	[[NSRunLoop currentRunLoop] addTimer:timer_ forMode:NSRunLoopCommonModes];
}

#pragma mark - edit

- (void)editDone
{
    if (_editDoneHandler) {             // replace layout
        _editDoneHandler(_layout);
        [self.navigationController popViewControllerAnimated:YES];
    } else {                            // add new layout
        for (UIViewController *vc in self.navigationController.viewControllers) {
            if ([vc isMemberOfClass:PinViewController.class]) {
                PinViewController *pvc = (PinViewController *)vc;
                [pvc.pin.layouts addObject:_layout];
                [self.navigationController popToViewController:pvc animated:YES];
            }
        }
    }
}

- (Item *)setItem:(NSInteger)type resource1:(NSString *)res1 orderNo:(NSInteger)no
{
    Item *item = [self itemAtOrderNo:no];

    if (!item) {
        item = Item.new;
        item.layoutId = self.layout.id;
        item.type = type;
        [self.layout.items addObject:item];
    }
    item.orderNo = no;
    item.resource1 = res1;

    return item;
}

- (Item *)setItemWithMediaInfo:(NSDictionary *)info orderNo:(NSInteger)no
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    NSInteger type = 0;

    if (CFStringCompare((CFStringRef)mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        type = ITEM_TYPE_IMAGE;
    } else if (CFStringCompare((CFStringRef)mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        type = ITEM_TYPE_MOVIE;
    } else {
        [self removeImageOrMovie:tapped_];
        return nil;
    }

    Item *item = [self setItem:type resource1:nil orderNo:no];
    item.localUrl = info[UIImagePickerControllerReferenceURL];

    return item;
}

- (Item *)itemAtOrderNo:(NSInteger)no
{
    for (Item *item in self.layout.items) {
        if (item.orderNo == no)
            return item;
    }
    return nil;
}

- (void)removeItemsAtOrderNo:(NSInteger)no
{
    for (Item *item in self.layout.items) {
        if (item.orderNo == no)
            [self.layout.items removeObject:item];
    }
}

- (void)removeImageOrMovie:(id)sender
{
    ELog(@"must be override");
}

- (void)setImageOrMovie:(id)sender info:(NSDictionary *)info;
{
    ELog(@"must be override");
}

#pragma mark - UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == photoActionSheet_) {
        if (photoActionSheet_.numberOfButtons > 3)
            ++buttonIndex;
        switch (buttonIndex) {
            case 0:
                [self removeImageOrMovie:tapped_];
                break;
            case 1:
                [self pushImagePicker:UIImagePickerControllerSourceTypeCamera];
                break;
            case 2:
                [self pushImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
                break;
            case 3:
                [self pushImagePicker:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
                break;
        }
    }
}

- (void)pushImagePicker:(UIImagePickerControllerSourceType)type
{
    if (![UIImagePickerController isSourceTypeAvailable:type]) {
        Alert(nil, NSLocalizedString(@"device not supported", nil));
        return;
    }
    UIImagePickerController *picker = UIImagePickerController.new;
    picker.sourceType = type;
    picker.delegate = self;
    picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:type];

    // TODO what will output, when camera..
    for (NSString *t in picker.mediaTypes) {
        DLog(@"%@", t);
    }
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];

    [self setImageOrMovie:tapped_ info:info];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController*)picker 
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
