//
//  Version.m
//  RenaiSpot
//
//  Created by Faith on 2014/09/25.
//  Copyright (c) 2014年 faith. All rights reserved.
//

#import "Version.h"

@implementation Version

// http://dev.classmethod.jp/references/ios8-version-distinction/

+ (BOOL)greaterThanOrEqualMajorVersion:(NSInteger)majorVersion minorVersion:(NSInteger)minorVersion patchVersion:(NSInteger)patchVersion
{
    // NSProcessInfo#isOperatingSystemAtLeastVersion による判別
    if ([NSProcessInfo.processInfo respondsToSelector:@selector(isOperatingSystemAtLeastVersion:)]) {
        NSOperatingSystemVersion version = {majorVersion, minorVersion, patchVersion};
        return [NSProcessInfo.processInfo isOperatingSystemAtLeastVersion:version];
    }
    // UIDevice#systemVersion による判別
    NSString *targetVersion = shortedVersionNumber([NSString stringWithFormat:@"%lu.%lu.%lu", majorVersion, minorVersion, patchVersion]);
    NSString *systemVersion = shortedVersionNumber(UIDevice.currentDevice.systemVersion);
    return [systemVersion compare:targetVersion options:NSNumericSearch] != NSOrderedAscending;
}

static NSString *shortedVersionNumber(NSString *version) {
    NSString *suffix = @".0";
    NSString *shortedVersion = version;
    while ([shortedVersion hasSuffix:suffix]) {
        NSUInteger endIndex = shortedVersion.length - suffix.length;
        shortedVersion = [shortedVersion substringToIndex:endIndex];
    }
    return shortedVersion;
}

@end
