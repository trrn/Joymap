//
//  GeoUtil.m
//  Joymap
//
//  Created by gli on 2013/11/02.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import "GeoUtil.h"

#define GEOLANG @"GEOUTIL_GOOGLE_GEO_LANG"

@implementation GeoUtil

+ (NSString *)GoogleGeoLangName
{
    NSInteger idx = [DefaultsUtil int:GEOLANG];
    return self.GoogleGeoLangs[idx][0];
}

+ (NSString *)GoogleGeoLangCode
{
    NSInteger idx = [DefaultsUtil int:GEOLANG];
    return self.GoogleGeoLangs[idx][1];
}

+ (NSString *)GoogleGeoLangCodeByLang
{
    static NSString *_last_lang = nil;
    static NSString *_last_code = nil;

    NSString *lang = [NSLocale preferredLanguages][0];

    if ([lang isEqualToString:_last_lang]) {
        DLog(@"hit cashe");
        return _last_code;
    }
    _last_code = nil;
    _last_lang = lang;

    NSArray *glangs = [self.GoogleGeoLangs valueForKeyPath:@"code"];

    if ([lang isEqualToString:@"zh-hans"])
        _last_code = @"zh-CN";
    else if ([lang isEqualToString:@"zh-hant"])
        _last_code = @"zh-TW";

    NSUInteger idx = [glangs indexOfObject:lang];
    if (idx != NSNotFound)
        _last_code = glangs[idx];

    NSString *pre = [lang substringToIndex:2];
    idx = [glangs indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj hasPrefix:pre])
            return *stop = YES;
        return NO;
    }];
    if (idx != NSNotFound)
        _last_code = glangs[idx];

    if (!_last_code) {
        _last_code = @"en";
    }

    return _last_code;
}

+ (NSArray *)GoogleGeoLangs
{
    static NSArray *ary = nil;
    
    if (ary) {
        return ary;
    }

    ary = @[
            @{ @"name" : @"Auto"                    , @"code" : @""      },
            @{ @"name" : @"ARABIC"                  , @"code" : @"ar"    },
            @{ @"name" : @"BASQUE"                  , @"code" : @"eu"    },
            @{ @"name" : @"BULGARIAN"               , @"code" : @"bg"    },
            @{ @"name" : @"BENGALI"                 , @"code" : @"bn"    },
            @{ @"name" : @"CATALAN"                 , @"code" : @"ca"    },
            @{ @"name" : @"CZECH"                   , @"code" : @"cs"    },
            @{ @"name" : @"DANISH"                  , @"code" : @"da"    },
            @{ @"name" : @"GERMAN"                  , @"code" : @"de"    },
            @{ @"name" : @"GREEK"                   , @"code" : @"el"    },
            @{ @"name" : @"ENGLISH"                 , @"code" : @"en"    },
            @{ @"name" : @"ENGLISH (AUSTRALIAN)"    , @"code" : @"en-AU" },
            @{ @"name" : @"ENGLISH (GREAT BRITAIN)" , @"code" : @"en-GB" },
            @{ @"name" : @"SPANISH"                 , @"code" : @"es"    },
            @{ @"name" : @"BASQUE"                  , @"code" : @"eu"    },
            @{ @"name" : @"FARSI"                   , @"code" : @"fa"    },
            @{ @"name" : @"FINNISH"                 , @"code" : @"fi"    },
            @{ @"name" : @"FILIPINO"                , @"code" : @"fil"   },
            @{ @"name" : @"FRENCH"                  , @"code" : @"fr"    },
            @{ @"name" : @"GALICIAN"                , @"code" : @"gl"    },
            @{ @"name" : @"GUJARATI"                , @"code" : @"gu"    },
            @{ @"name" : @"HINDI"                   , @"code" : @"hi"    },
            @{ @"name" : @"CROATIAN"                , @"code" : @"hr"    },
            @{ @"name" : @"HUNGARIAN"               , @"code" : @"hu"    },
            @{ @"name" : @"INDONESIAN"              , @"code" : @"id"    },
            @{ @"name" : @"ITALIAN"                 , @"code" : @"it"    },
            @{ @"name" : @"HEBREW"                  , @"code" : @"iw"    },
            @{ @"name" : @"JAPANESE"                , @"code" : @"ja"    },
            @{ @"name" : @"KANNADA"                 , @"code" : @"kn"    },
            @{ @"name" : @"KOREAN"                  , @"code" : @"ko"    },
            @{ @"name" : @"LITHUANIAN"              , @"code" : @"lt"    },
            @{ @"name" : @"LATVIAN"                 , @"code" : @"lv"    },
            @{ @"name" : @"MALAYALAM"               , @"code" : @"ml"    },
            @{ @"name" : @"MARATHI"                 , @"code" : @"mr"    },
            @{ @"name" : @"DUTCH"                   , @"code" : @"nl"    },
            @{ @"name" : @"NORWEGIAN"               , @"code" : @"no"    },
            @{ @"name" : @"POLISH"                  , @"code" : @"pl"    },
            @{ @"name" : @"PORTUGUESE"              , @"code" : @"pt"    },
            @{ @"name" : @"PORTUGUESE (BRAZIL)"     , @"code" : @"pt-BR" },
            @{ @"name" : @"PORTUGUESE (PORTUGAL)"   , @"code" : @"pt-PT" },
            @{ @"name" : @"ROMANIAN"                , @"code" : @"ro"    },
            @{ @"name" : @"RUSSIAN"                 , @"code" : @"ru"    },
            @{ @"name" : @"SLOVAK"                  , @"code" : @"sk"    },
            @{ @"name" : @"SLOVENIAN"               , @"code" : @"sl"    },
            @{ @"name" : @"SERBIAN"                 , @"code" : @"sr"    },
            @{ @"name" : @"SWEDISH"                 , @"code" : @"sv"    },
            @{ @"name" : @"TAGALOG"                 , @"code" : @"tl"    },
            @{ @"name" : @"TAMIL"                   , @"code" : @"ta"    },
            @{ @"name" : @"TELUGU"                  , @"code" : @"te"    },
            @{ @"name" : @"THAI"                    , @"code" : @"th"    },
            @{ @"name" : @"TURKISH"                 , @"code" : @"tr"    },
            @{ @"name" : @"UKRAINIAN"               , @"code" : @"uk"    },
            @{ @"name" : @"VIETNAMESE"              , @"code" : @"vi"    },
            @{ @"name" : @"CHINESE (SIMPLIFIED)"    , @"code" : @"zh-CN" },   // zh-hans
            @{ @"name" : @"CHINESE (TRADITIONAL)"   , @"code" : @"zh-TW" },   // zh-hant
    ];

    return ary;
}

+ (BOOL)strToCoordinate2D:(NSString *)str co:(CLLocationCoordinate2D *)co;
{
    if ([StringUtil empty:str] || !co)
        return NO;

    NSArray *sep = [str componentsSeparatedByString:@","];
    if (sep.count < 2)
        return NO;

    *co = CLLocationCoordinate2DMake([sep[0] doubleValue], [sep[1] doubleValue]);
    return YES;
}

+ (NSString *)coordinate2DtoStr:(CLLocationCoordinate2D)co;
{
    return [NSString stringWithFormat:@"%f,%f", co.latitude, co.longitude];
}

+ (void)searchByStrOld:(NSString *)str handler:(void(^)(NSArray *, NSError *))handler;
{
    NSString *code = self.GoogleGeoLangCodeByLang;
    NSString *lang = @"";
    if (![StringUtil empty:code])
        lang = [NSString stringWithFormat:@"&language=%@", [HttpUtil encodeURI:code]];
    NSString *urlstr = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true%@", [HttpUtil encodeURI:str], lang];

    DLog(@"%@", urlstr);

    NSURLSession *session = NSURLSession.sharedSession;
    NSURLRequest *request = [NSURLRequest requestWithURL:urlstr.URL];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!handler)
            return;
        if (error) {
            handler(nil, error);
            return;
        }

        NSError *err = nil;
        NSDictionary *json = [HttpUtil jsonDataToDict:data error:&err];
        if (err || !json) {
            handler(nil, err);
            return;
        }

        if (![json[@"status"] isEqual:@"OK"]) {
            handler(nil, NSERR(@"status not OK, %@", json));
            return;
        }

        if (![json[@"results"] isKindOfClass:NSArray.class]) {
            handler(nil, NSERR(@"no results, %@", json));
            return;
        }

        NSArray *res = [self geoResultsToArray:json[@"results"]];

        handler(res, nil);
    }];
    
    [task resume];
}

+ (NSString *)extractTitle:(NSDictionary *)result;
{
    NSString *title = nil;
    
    NSDictionary *interest_components =
        _.find(result[@"address_components"], ^BOOL (NSDictionary *ac) {
            return _.any(ac[@"types"], ^BOOL (NSString *type) {
                return [type isEqualToString:@"point_of_interest"] || [type isEqualToString:@"premise"];
            });
        });
    
    if (interest_components) {
        title = interest_components[@"long_name"];
        if (!title)
            title = interest_components[@"short_name"];
        
        DLog(@"%@", title);
    }
    
    return title;
}

+ (NSArray *)geoResultsToArray:(NSArray *)results
{
    NSMutableArray *resArray = @[].mutableCopy;
    
    for (NSDictionary *result in results) {
        NSMutableDictionary *res = @{}.mutableCopy;
        __block NSString *addr = result[@"formatted_address"];
        if (!addr)
            continue;
        _.arrayEach(@[@"日本, ", ], ^(NSString *w) {  // remove from prefix
            if ([addr hasPrefix:w]) {
                addr = [addr substringFromIndex:w.length];
            }
        });
        NSString *title = [self extractTitle:result];
        if (title) {
            res[@"title"] = title;
            if ([addr hasSuffix:title]) {
                addr = [addr substringToIndex:addr.length - title.length];
            }
        }
        res[@"addr"] = addr;
        DLog(@"%@", res[@"addr"]);
        
        id lat = [result valueForKeyPath:@"geometry.location.lat"];
        id lng = [result valueForKeyPath:@"geometry.location.lng"];
        if (![lat isKindOfClass:NSNumber.class] || ![lng isKindOfClass:NSNumber.class])
            continue;
        NSString *latlng = [NSString stringWithFormat:@"%@,%@", lat, lng];
        res[@"latlng"] = latlng;
        [resArray addObject:res];
    }

    return resArray;
}

+ (NSArray *)placeResultsToArray:(NSArray *)results
{
    NSMutableArray *resArray = @[].mutableCopy;
    
    for (NSDictionary *result in results) {
        NSMutableDictionary *res = @{}.mutableCopy;
        __block NSString *addr = result[@"formatted_address"];
        if (!addr)
            continue;
        _.arrayEach(@[@"日本, ", ], ^(NSString *w) {  // remove from prefix
            if ([addr hasPrefix:w]) {
                addr = [addr substringFromIndex:w.length];
            }
        });
        NSString *title = result[@"name"];
        if (title) {
            res[@"title"] = title;
            if ([addr hasSuffix:title]) {
                addr = [addr substringToIndex:addr.length - title.length];
            }
        }
        res[@"addr"] = addr;
        //DLog(@"%@", res[@"addr"]);
        
        id lat = [result valueForKeyPath:@"geometry.location.lat"];
        id lng = [result valueForKeyPath:@"geometry.location.lng"];
        if (![lat isKindOfClass:NSNumber.class] || ![lng isKindOfClass:NSNumber.class])
            continue;
        NSString *latlng = [NSString stringWithFormat:@"%@,%@", lat, lng];
        res[@"latlng"] = latlng;
        [resArray addObject:res];
    }
    
    return resArray;
}

+ (instancetype)shared;
{
    static GeoUtil *_shared;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        if (!_shared) {
            _shared = [self manager];
        }
    });
    
    return _shared;
}

// geo coding api
+ (void)searchByStrGeo:(NSString *)str handler:(void(^)(NSArray *, NSError *))handler;
{
    NSString *code = self.GoogleGeoLangCodeByLang;
    NSMutableDictionary *param = @{@"address":str, @"sensor":@"true"}.mutableCopy;
    if (![StringUtil empty:code])
        param[@"language"] = code;
    
    [self.shared GET:@"https://maps.googleapis.com/maps/api/geocode/json"
          parameters:param
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 if (![responseObject[@"status"] isEqualToString:@"OK"]) {
                     if (handler) {
                         handler(nil, NSERR(@"status not OK, %@", responseObject));
                         return;
                     }
                 }
                 if (![responseObject[@"results"] isKindOfClass:NSArray.class]) {
                     if (handler) {
                         handler(nil, NSERR(@"no results, %@", responseObject));
                         return;
                     }
                 }

                 NSArray *res = [self geoResultsToArray:responseObject[@"results"]];
                 //DLog(@"%@", res);
                 
                 if (handler) {
                     handler(res, nil);
                 }
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 if (handler) {
                     handler(nil, error);
                 };
             }];
}

// place api
+ (void)searchByStr:(NSString *)str handler:(void(^)(NSArray *, NSError *))handler;
{
    NSString *code = self.GoogleGeoLangCodeByLang;
    NSMutableDictionary *param = @{@"key":Env.googleBrowserApiKey, @"query":str, @"sensor":@"true"}.mutableCopy;
    if (![StringUtil empty:code])
        param[@"language"] = code;
    
    [self.shared GET:@"https://maps.googleapis.com/maps/api/place/textsearch/json"
          parameters:param
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 if (![responseObject[@"status"] isEqualToString:@"OK"]) {
                     if (handler) {
                         handler(nil, NSERR(@"status not OK, %@", responseObject));
                         return;
                     }
                 }
                 if (![responseObject[@"results"] isKindOfClass:NSArray.class]) {
                     if (handler) {
                         handler(nil, NSERR(@"no results, %@", responseObject));
                         return;
                     }
                 }
                 
                 //DLog(@"%@", responseObject);
                 NSArray *res = [self placeResultsToArray:responseObject[@"results"]];
                 //DLog(@"%@", res);
                 
                 if (handler) {
                     handler(res, nil);
                 }
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 if (handler) {
                     handler(nil, error);
                 };
             }];
}

@end
