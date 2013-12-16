//
//  DefaultsUtil.h
//  Joymap
//
//  Created by gli on 2013/10/20.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DefaultsUtil : NSObject

+ (NSInteger)int:(NSString *)key;
+ (NSString *)str:(NSString *)key;
+ (id)obj:(NSString *)key;
+ (BOOL)bool:(NSString *)key;

+ (void)setInt:(NSInteger)i key:(NSString *)key;
+ (void)setObj:(id)obj key:(NSString *)key;
+ (void)setBool:(BOOL)yn key:(NSString *)key;

@end
