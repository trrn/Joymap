//
//  UIStoryboard+Sekken.m
//  masd
//
//  Created by faith on 2014/03/16.
//  Copyright (c) 2014年 sekken. All rights reserved.
//

#import "UIStoryboard+Sekken.h"

@implementation UIStoryboard (Sekken)

+ (id)viewControllerWithID:(NSString *)identifier
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:identifier];
}

@end
