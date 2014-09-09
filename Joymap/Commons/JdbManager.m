//
//  JdbManager.m
//  Joymap
//
//  Created by Faith on 2014/09/09.
//  Copyright (c) 2014年 sekken. All rights reserved.
//

#import "JdbManager.h"

@implementation JdbManager

+ (instancetype)shared;
{
    static JdbManager *_shared = nil;
    static dispatch_once_t once;

    dispatch_once(&once, ^{
        if (!_shared) {
            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
            _shared = [[self alloc] initWithSessionConfiguration:configuration];
        }
    });
    
    return _shared;
}

- (void)downloadWithProgress:(void(^)(double))progress finished:(void(^)())finished;
{
    NSProgress* p = nil;
    NSURLSessionDownloadTask *task =
    [self downloadTaskWithRequest:Env.downloadRequest
              progress:&p
           destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
               NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
               return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
           } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
               NSLog(@"File downloaded to: %@", filePath);
           }];
    
    [task resume];
    
    [p addObserver:self
               forKeyPath:@"fractionCompleted"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"fractionCompleted"]) {
        NSProgress *progress = (NSProgress *)object;
        NSLog(@"Progress… %f", progress.fractionCompleted);
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
