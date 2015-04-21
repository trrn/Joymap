//
//  TabBarController.h
//  Joymap
//
//  Created by faith on 2013/10/13.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TabBarController : UITabBarController
- (void)selectPin:(id)pin;
- (void)selectPinBy:(NSNotification *)notification;
@end
