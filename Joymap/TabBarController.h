//
//  TabBarController.h
//  Joymap
//
//  Created by faith on 2013/10/13.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OpenURLHandler
@required
- (void)handleURL:(NSURL *)url;
@end

@interface TabBarController : UITabBarController <OpenURLHandler>
- (void)selectPin:(id)pin;
- (void)selectPinBy:(NSNotification *)notification;
@end