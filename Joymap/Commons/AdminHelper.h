//
//  AdminHelper.h
//  Joymap
//
//  Created by faith on 2013/11/11.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AdminHelper : NSObject
+ (BOOL)isAdmin;
+ (void)toggle:(BOOL)yn;
@end
