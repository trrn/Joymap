//
//  Env.m
//  Joymap
//
//  Created by gli on 2013/10/14.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import "Env.h"

#import "HttpUtil.h"

@implementation Env

+ (NSDictionary *)dict
{
    NSDictionary *_dict = nil;

    if (_dict)
        return _dict;

    NSString *path = [NSBundle.mainBundle pathForResource:@"Env" ofType:@"plist"];

    if (![NSFileManager.defaultManager fileExistsAtPath:path]) {
        Log(@"%@", NSLocalizedString(@"Env.plist not found", nil));
    }

    _dict = [NSDictionary dictionaryWithContentsOfFile:path];
    return _dict;
}

+ (NSString *)homeUrl
{
    return self.dict[@"HomeURL"];
}

+ (NSString *)downloadUrl
{
    NSURL *url = [NSURL URLWithString:self.dict[@"ManagerURL"]];
    url = [url URLByAppendingPathComponent:self.dict[@"DownloadAction"]];

    NSString *param = [NSString stringWithFormat:@"?user=%@&map=%@",
                       [HttpUtil encodeURI:self.dict[@"User"]],
                       [HttpUtil encodeURI:self.dict[@"Map"]]];
    
    url = [NSURL URLWithString:param relativeToURL:url];
    
    return [url absoluteString];
}

+ (NSString *)jdbIdHeader
{
    return self.dict[@"JDBIdentifyHeaderName"];
}

+ (NSString *)googleMapsApiKey
{
    return self.dict[@"GoogleMapsAPIKey"];
}

+ (NSString *)googleMapsImageApiKey
{
    return self.dict[@"GoogleMapsImageAPIKey"];
}

+ (BOOL)enableEdit;
{
    return NO;
//    return [self.dict[@"EnableEdit"] boolValue];
}

@end
