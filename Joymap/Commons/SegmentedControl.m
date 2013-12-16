//
//  SegmentedControl.m
//  Joymap
//
//  Created by gli on 2013/11/04.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import "SegmentedControl.h"

@implementation SegmentedControl

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // do action when the same index tapped (when did not change value)

    [super touchesEnded:touches withEvent:event];
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
}

@end
