//
//  Cache.h
//  Joymap
//
//  Created by faith on 2013/10/23.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import "Cache.h"

@implementation Cache
{
    NSMutableDictionary *d_;
}

- (id)init
{
    self = [super init];
    if (self) {
        d_ = @{}.mutableCopy;
    }
    return self;
}

- (void)set:(id)obj key:(id)key;
{
    if (!obj || !key)
        return;

    @synchronized(self) {
        d_[key] = obj;
    }
}

- (void)setObject:(id)object forKeyedSubscript:(id)key;
{
    [self set:object key:key];
}

- (id)get:(id)key;
{
    if (!key)
        return nil;

    @synchronized(self) {
        return d_[key];
    }
}

- (id)objectForKeyedSubscript:(id)key;
{
    return [self get:key];
}

- (void)clear;
{
    @synchronized(self) {
        [d_ removeAllObjects];
    }
}

@end
