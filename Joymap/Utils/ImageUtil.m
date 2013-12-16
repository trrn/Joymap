//
//  ImageUtil.m
//  Joymap
//
//  Created by gli on 2013/10/23.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import "ImageUtil.h"

@implementation ImageUtil

+ (UIImage *)image:(UIImage *)image size:(CGSize)size
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(size);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,size.width,size.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}

@end
