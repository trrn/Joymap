//
//  GoogleMapsHelper.m
//  Joymap
//
//  Created by faith on 2013/11/09.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import "GoogleMapsHelper.h"

#import "Env.h"

@implementation GoogleMapsHelper

+ (NSArray *)mapTypesSource
{
    NSArray *types = @[
                       @{ @"name" : @"Normal",      @"type" : @(kGMSTypeNormal)     },
                       @{ @"name" : @"Hybrid",      @"type" : @(kGMSTypeHybrid)     },
                       @{ @"name" : @"Satellite",   @"type" : @(kGMSTypeSatellite)  },
                       @{ @"name" : @"Terrain",     @"type" : @(kGMSTypeTerrain)    },
                       ];
    return types;
}

+ (NSArray *)mapTypes
{
    return [self.mapTypesSource valueForKeyPath:@"type"];
}

+ (NSArray *)mapTypeNames
{
    return [self.mapTypesSource valueForKeyPath:@"name"];
}

+ (GMSMapViewType)mapType
{
    NSArray *types = self.mapTypes;
    NSInteger idx = [DefaultsUtil int:DEF_SET_MAP_TYPE];

    if (idx < 0 && idx >= types.count) {
        return [types[0] integerValue];
    }

    return [types[idx] integerValue];
}

+ (NSString *)mapTypeName
{
    NSArray *names = self.mapTypeNames;
    NSInteger idx = [DefaultsUtil int:DEF_SET_MAP_TYPE];

    if (idx < 0 && idx >= names.count) {
        return names[0];
    }

    return names[idx];
}

+ (void)setMapType:(NSInteger)i;
{
    [DefaultsUtil setInt:i key:DEF_SET_MAP_TYPE];
}

+ (NSInteger)mapTypeIndex;
{
    return [DefaultsUtil int:DEF_SET_MAP_TYPE];
}

+ (NSString *)mapImageURLWithCoordinate2D:(CLLocationCoordinate2D)co color:(NSString *)color;
{
    NSString *coord = [GeoUtil coordinate2DtoStr:co];

    return [NSString stringWithFormat:
            @"http://maps.googleapis.com/maps/api/staticmap"
            "?center=%@"
            "&zoom=19"
            "&size=320x160"
            "&scale=2"
            "&maptype=roadmap"
            "&sensor=false"
            "&language=%@"
            "&markers=%@"
            "&key=%@",
            [HttpUtil encodeURI:coord],
            [HttpUtil encodeURI:GeoUtil.GoogleGeoLangCodeByLang],
            [HttpUtil encodeURI:[NSString stringWithFormat:@"color:%@|%@", color, coord]],
            [HttpUtil encodeURI:Env.googleMapsImageApiKey]];
}

@end
