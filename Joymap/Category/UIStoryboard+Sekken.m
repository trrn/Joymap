//
//  UIStoryboard+Sekken.m
//  masd
//
//  Created by gli on 2014/03/16.
//  Copyright (c) 2014年 sekken. All rights reserved.
//

#import "UIStoryboard+Sekken.h"

@implementation UIStoryboard (Sekken)

+ (id)viewControllerWithID:(NSString *)identifier
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:identifier];
}

@end
