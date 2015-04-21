//
//  FileUtil.h
//  Joymap
//
//  Created by faith on 2013/10/20.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileUtil : NSObject

+ (BOOL)moveForce:(NSString *)from to:(NSString *)to error:(NSError **)error;

+ (BOOL)existsFile:(NSString *)path;

@end
