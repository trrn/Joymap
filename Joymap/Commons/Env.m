//
//  Env.m
//  Joymap
//
//  Created by faith on 2013/10/14.
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
    NSURL *url = ((NSString *)self.dict[@"ManagerURL"]).URL;
    url = [url URLByAppendingPathComponent:self.dict[@"DownloadAction"]];

    NSString *param = [NSString stringWithFormat:@"?user=%@&map=%@",
                       [HttpUtil encodeURI:self.dict[@"User"]],
                       [HttpUtil encodeURI:self.dict[@"Map"]]];
    
    url = [NSURL URLWithString:param relativeToURL:url];
    
    return [url absoluteString];
}

+ (NSURLRequest *)downloadRequest
{
    NSMutableURLRequest *req = self.downloadURL.request.mutableCopy;
    req.HTTPMethod = @"POST";
    NSString *param = [NSString stringWithFormat:@"user=%@&map=%@",
                       [HttpUtil encodeURI:self.dict[@"User"]],
                       [HttpUtil encodeURI:self.dict[@"Map"]]];

    DLog(@"param:%@", param);
    
    req.HTTPBody = [param dataUsingEncoding:NSUTF8StringEncoding];
    return req;
}

+ (NSURLRequest *)downloadRequestWithHash:(NSString *)hash;
{
    NSMutableURLRequest *req = [self.downloadByHashURL.absoluteString stringByAppendingPathComponent:hash].URL.request.mutableCopy;
    req.HTTPMethod = @"GET";
    return req;
}

+ (NSURL *)downloadURL
{
    NSURL *url = [NSURL URLWithString:self.dict[@"ManagerURL"]];
    return [url URLByAppendingPathComponent:self.dict[@"DownloadAction"]];
}

+ (NSURL *)downloadByHashURL
{
    NSURL *url = [NSURL URLWithString:self.dict[@"ManagerURL"]];
    return [url URLByAppendingPathComponent:self.dict[@"DownloadByHashAction"]];
}

+ (NSString *)jdbIdHeader
{
    return self.dict[@"JDBIdentifyHeaderName"];
}

+ (NSString *)googleMapsApiKey
{
    return self.dict[@"GoogleMapsAPIKey"];
}

+ (NSString *)googleBrowserApiKey;
{
    return self.dict[@"GoogleBrowserAPIKey"];
}

+ (NSString *)googleMapsImageApiKey
{
    return self.dict[@"GoogleMapsImageAPIKey"];
}

+ (NSString *)adUnitIDActionUrl;
{
    NSURL *url = [NSURL URLWithString:self.dict[@"ManagerURL"]];
    return [url URLByAppendingPathComponent:self.dict[@"AdUnitIDAction"]].absoluteString;
}

+ (BOOL)enableEdit;
{
    return NO;
//    return [self.dict[@"EnableEdit"] boolValue];
}

+ (NSString *)user
{
    return self.dict[@"User"];
}

+ (NSString *)map
{
    return self.dict[@"Map"];
}

+ (NSString *)updateCheckActionUrl
{
    NSURL *url = [NSURL URLWithString:self.dict[@"ManagerURL"]];
    return [url URLByAppendingPathComponent:self.dict[@"UpdateCheckAction"]].absoluteString;
}

+ (NSInteger)JDBInitialVersion;
{
    NSNumber *n = self.dict[@"JDBInitialVersion"];
    return n ? [n integerValue] : 0;
}

+ (UIColor *)SearchedMarkerColor;
{
    NSString *colorStr = self.dict[@"SearchedMarkerColor"];
    
    if ([StringUtil empty:colorStr]) {
        return UIColor.blueColor;
    } else if ([colorStr rangeOfString:@"red" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return UIColor.redColor;
    } else if ([colorStr rangeOfString:@"blue" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return UIColor.blueColor;
    } else if ([colorStr rangeOfString:@"yellow" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return UIColor.yellowColor;
    } else if ([colorStr rangeOfString:@"green" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return UIColor.greenColor;
    } else if ([colorStr rangeOfString:@"cyan" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return UIColor.cyanColor;
    } else if ([colorStr rangeOfString:@"magenta" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return UIColor.magentaColor;
    } else if ([colorStr rangeOfString:@"orange" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return UIColor.orangeColor;
    } else if ([colorStr rangeOfString:@"purple" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return UIColor.purpleColor;
    } else if ([colorStr rangeOfString:@"black" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return UIColor.blackColor;
    } else if ([colorStr rangeOfString:@"darkGray" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return UIColor.darkGrayColor;
    } else if ([colorStr rangeOfString:@"lightGray" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return UIColor.lightGrayColor;
    } else {
        return UIColor.blueColor;
    }
}

@end
