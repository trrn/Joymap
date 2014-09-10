//
//  NSString+Sekken.h
//  masd
//
//  Created by gli on 2014/03/16.
//  Copyright (c) 2014年 sekken. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Sekken)

- (NSURL *)URL;

- (NSURL *)fileURL;

- (NSString *)encodeURI;

- (NSString *)decodeURI;

@end
