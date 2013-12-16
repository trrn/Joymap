//
//  TextViewController.m
//  Joymap
//
//  Created by gli on 2013/12/15.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import "TextViewController.h"

@interface TextViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;
@end

@implementation TextViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _textView.attributedText = _text;
}

@end
