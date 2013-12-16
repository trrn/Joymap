//
//  AdminHelper.m
//  Joymap
//
//  Created by gli on 2013/11/11.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import "AdminHelper.h"

#import "Env.h"

@implementation AdminHelper

+ (BOOL)isAdmin;
{
    return Env.enableEdit;
//    return [DefaultsUtil bool:DEF_SET_ADMIN];
}

+ (void)toggle:(BOOL)yn;
{
    [DefaultsUtil setBool:yn key:DEF_SET_ADMIN];
}

@end
