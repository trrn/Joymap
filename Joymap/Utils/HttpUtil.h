//
//  HttpUtil.h
//  Joymap
//
//  Created by gli on 2013/10/15.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpUtil : NSObject

+ (NSString *)encodeURI:(NSString *)s;

+ (NSString *)decodeURI:(NSString *)s;

+ (NSDictionary *)jsonDataToDict:(NSData *)data error:(NSError **)error;

@end
