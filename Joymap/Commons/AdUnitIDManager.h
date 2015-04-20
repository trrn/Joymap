//
//  AdUnitIDManager.h
//  Joymap
//
//  Created by Faith on 2015/04/14.
//  Copyright (c) 2015年 sekken. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

#define AD_UNIT_ID @"AD_UNIT_ID"
#define AD_UNIT_ID_NEED_UPDATE @"AD_UNIT_ID_NEED_UPDATE"

@interface AdUnitIDManager : AFHTTPRequestOperationManager

+ (void)check;

@end
