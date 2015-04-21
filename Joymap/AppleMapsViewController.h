//
//  AppleMapsViewController.h
//  Joymap
//
//  Created by Faith on 2015/04/21.
//  Copyright (c) 2015年 sekken. All rights reserved.
//

#import "BaseViewController.h"

@class Pin;

@interface AppleMapsViewController : BaseViewController

- (void)selectPin:(Pin *)pin;
- (void)hideKeyboard;
- (void)selectPinByID:(NSInteger)pinID;

@end
