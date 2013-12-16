//
//  Cache.h
//  Joymap
//
//  Created by gli on 2013/10/23.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Cache : NSObject

- (void)set:(id)obj key:(id)key;
- (void)setObject:(id)object forKeyedSubscript:(id)key;

- (id)get:(id)key;
- (id)objectForKeyedSubscript:(id)key;

- (void)clear;

@end
