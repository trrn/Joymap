//
//  JdbManager.m
//  Joymap
//
//  Created by Faith on 2014/09/09.
//  Copyright (c) 2014年 sekken. All rights reserved.
//

#import "JdbManager.h"

#import "DataSource.h"
#import "RegionMonitor.h"
#import "UpdateCheckManager.h"

#define JDB_VERSION_HEDAER @"X-Joymap-JDB-Version"

@interface JdbManager ()
@property (nonatomic, copy) void (^progressHandler)(double);
@property (nonatomic) BOOL canceled;
@end

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

- (void)downloadWithRequest:(NSURLRequest *)request progress:(void(^)(double))progress finished:(void(^)())finished;
{
    _progressHandler = progress;
    _canceled = NO;

    NSProgress* p = nil;
    DLog(@"%@", request);
    NSURLSessionDownloadTask *task =
    [self downloadTaskWithRequest:request
              progress:&p
           destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
               @try {
                   if (!targetPath) {
                       return nil;
                   }
                   
                   NSFileManager *manager = NSFileManager.defaultManager;
                   NSDictionary *attribute = [manager attributesOfItemAtPath:targetPath.path error:nil];
                   if (attribute) {
                       if ([[attribute objectForKey:NSFileSize] integerValue] == 0) {
                           return nil;
                       }
                   }

                   if (targetPath) {
                       [DataSource validateSqliteFile:targetPath.absoluteString];
                       NSString *to = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
                       to = [to stringByAppendingPathComponent:JDB_FILE_NAME];
                       [NSFileManager.defaultManager removeItemAtPath:to error:nil];
                       return to.fileURL;
                   }
               }
               @catch (NSException *e) {
                   ELog(@"%@", e);
                   Alert(NSLocalizedString(@"Error", nil), @"%@", NSLocalizedString(@"download err", nil));
               }
               return nil;
           } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {

               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

               @try {
                   if (error) {
                       if (_canceled) {
                           DLog(@"canceled");
                       } else {
                           ELog(@"%@", error);
                           Alert(NSLocalizedString(@"Error", nil), @"%@", NSLocalizedString(@"download err", nil));
                       }
                   } else if (httpResponse.statusCode == 304) {
                       Alert(nil, @"%@", NSLocalizedString(@"already up-to-date", nil));
                       
                   } else {  // success
                       NSLog(@"File downloaded to: %@", filePath);
                       
                       // save jdb version
                       NSNumber *ver = httpResponse.allHeaderFields[JDB_VERSION_HEDAER];
                       if (ver) {
                           [DefaultsUtil setInt:[ver integerValue] key:JDB_VERSION];
                       }
                       
                       [self notifySuccess];
                       
                       if (filePath) {
                           [RegionMonitor.shared refresh];
                           [DefaultsUtil setObj:NSDate.date key:DEF_SET_JDB_LAST_UPDATED];
                           [DataSource needReload];
                       } else {
                           NSLog(@"size 0");
                       }
                   }
               }
               @catch (NSException *e) {
                   ELog(@"update failed. %@", e);
               }

               if (finished) {
                   finished();
               }
               _progressHandler = nil;
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
        //NSLog(@"Progress… %f", progress.fractionCompleted);
        if (_progressHandler) {
            _progressHandler(progress.fractionCompleted);
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)notifySuccess
{
    NSNotification *notification =
    [NSNotification notificationWithName:JDB_DOWNLOAD_SUCCEEDED
                                  object:nil
                                userInfo:nil];
    [NSNotificationCenter.defaultCenter postNotification:notification];
}

- (void)cancel
{
    for (NSURLSessionDownloadTask *task in self.tasks) {
        [task cancel];
        _canceled = YES;
        DLog(@"task canceled");
    }
}

@end
