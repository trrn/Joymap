//
//  GoogleMapsViewController.h
//  Joymap
//
//  Created by gli on 2013/10/13.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Pin;

@interface GoogleMapsViewController : BaseViewController

- (void)selectPin:(Pin *)pin;
- (void)hideKeyboard;
- (void)selectPinByID:(NSInteger)pinID;

@end
