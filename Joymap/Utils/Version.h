//
//  Version.h
//  RenaiSpot
//
//  Created by Faith on 2014/09/25.
//  Copyright (c) 2014年 faith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Version : NSObject

+ (BOOL)greaterThanOrEqualMajorVersion:(NSInteger)majorVersion minorVersion:(NSInteger)minorVersion patchVersion:(NSInteger)patchVersion;

@end
