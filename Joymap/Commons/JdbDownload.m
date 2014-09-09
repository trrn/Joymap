//
//  JdbDownload.m
//  Joymap
//
//  Created by gli on 2013/10/23.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import "JdbDownload.h"

#import "AppDelegate.h"
#import "DataSource.h"
#import "RegionMonitor.h"

#define JDBID @"JDBID"

@interface JdbDownload () <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDownloadDelegate>
@end

@implementation JdbDownload
{
    NSURLSession             *session_;      //singleton
    NSURLSessionDownloadTask *task_;
    UIBackgroundFetchResult   result_;
}

+ (JdbDownload *)singleton
{
    static dispatch_once_t once;
    static JdbDownload *singleton = nil;
    
    dispatch_once(&once, ^{
        singleton = self.new;
    });

    return singleton;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self backgroundSession];
        task_ = nil;
    }
    return self;
}

- (void)start
{
//#ifdef DEBUG
//    // TODO TEST
//    [DefaultsUtil setObj:@"test" key:JDBID];
//#endif
    
    if (task_) {
        return;
    }

    UIApplication.sharedApplication.networkActivityIndicatorVisible = YES;
    task_ = [session_ downloadTaskWithURL:[NSURL URLWithString:self.class.jdbUrl]];
    [task_ resume];
}

- (BOOL)running
{
    return task_ ? YES : NO;
}

- (void)cancel
{
    [task_ cancel];
}

+ (NSString *)jdbUrl
{
    NSString *url = Env.downloadUrl;
    NSString *iD = [DefaultsUtil str:JDBID];
    if (iD) {
        url = [NSString stringWithFormat:@"%@&jdbid=%@", url, [HttpUtil encodeURI:iD]];
    }
    DLog(@"%@", url);
    return url;
}

- (void)backgroundSession
{
    // singleton NSURLSession
    
    static dispatch_once_t once;

    dispatch_once(&once, ^{
        NSURLSessionConfiguration *conf = [NSURLSessionConfiguration backgroundSessionConfiguration:NSStringFromClass(self.class)];
        session_ = [NSURLSession sessionWithConfiguration:conf delegate:self delegateQueue:nil];
    });
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    // required
    
    DLog();
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    // update progress bar
    
    if (downloadTask == task_) {
        
        double progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
        DLog(@"[progress] %f", progress);
        
        if (self.progressHandler) {
            [ProcUtil asyncMainq:^{
                self.progressHandler(progress);
            }];
        }
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    // replace local jdbfile to downloaded one.
    
    DLog(@"%@", downloadTask.response);
    
    @try {
        if (![downloadTask.response isKindOfClass:NSHTTPURLResponse.class]) {
            @throw Err(@"not http response but %@", downloadTask.response.class);
        }
        
        // check status code
        NSHTTPURLResponse *res = (NSHTTPURLResponse *)downloadTask.response;
        if (res.statusCode == 304) {
            result_ = UIBackgroundFetchResultNoData;
            return;
        }
        if (res.statusCode != 200) {
            @throw Err(@"status code is not 200 but %d", res.statusCode);
        }
        
        DLog(@"path [%@]. size %@", location.absoluteString, [self size:location.path]);
        
        [DataSource validateSqliteFile:location.path];
        
        NSString *to = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        to = [to stringByAppendingPathComponent:JDB_FILE_NAME];
        NSError *err = nil;
        if (![FileUtil moveForce:location.path to:to error:&err]) {
            @throw Err(@"move err. %@", err);
        }
        
        // remember downloaded identifier
        NSString *iD = res.allHeaderFields[Env.jdbIdHeader];
        [DefaultsUtil setObj:iD key:JDBID];
        
        result_ = UIBackgroundFetchResultNewData;
        Log(@"jdb update done. jdb_id=%@", iD);

        [RegionMonitor refresh];
        [DefaultsUtil setObj:NSDate.date key:DEF_SET_JDB_LAST_UPDATED];
        [DataSource needReload];
    }
    @catch (NSException *e) {
        ELog(@"update failed. %@", e);
        result_ = UIBackgroundFetchResultFailed;
    }
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    // called after didFinishDownloadingToURL
    
    UIApplication.sharedApplication.networkActivityIndicatorVisible = NO;
    
    @try {
        if (error) {
            if (error.code == -999) {
                DLog(@"cancelled");
                return;
            }
            result_ = UIBackgroundFetchResultFailed;
            ELog(@"%@", error);
        } else {
            Log("download done");
        }
        
        switch (result_) {
            case UIBackgroundFetchResultNoData:
                Alert(nil, @"%@", NSLocalizedString(@"already up-to-date", nil));
                break;
                
            case UIBackgroundFetchResultFailed:
                Alert(NSLocalizedString(@"Error", nil), @"%@", NSLocalizedString(@"download err", nil));
                break;
                
            default:
                break;
        }
    }
    @finally {
        if (self.completionHandler) {
            [ProcUtil asyncMainqDelay:1.0 block:^{
                self.completionHandler();
            }];
        }
        task_ = nil;
    }
}

#pragma mark - NSURLSessionDelegate

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    // called at last, when background
    
    //
    // NOTICE
    //
    // this method is never called, when using google maps sdk with background modes (location upadates) is on.
    //
    
    DLog();
    
    AppDelegate *appDelegate = (AppDelegate *)UIApplication.sharedApplication.delegate;
    
    if (appDelegate.backgroundSessionCompletionHandler) {
        void (^completionHandler)() = appDelegate.backgroundSessionCompletionHandler;
        appDelegate.backgroundSessionCompletionHandler = nil;
        
        // The completion handler to call when you finish processing the events.
        // Calling this completion handler lets the system know that your app's
        // user interface is updated and a new snapshot can be taken.
        completionHandler();
    }
}

#pragma mark - debug

- (NSNumber *)size:(NSString *)path
{
    NSError *err = nil;
    NSFileManager *manager = NSFileManager.defaultManager;
    
    NSDictionary *attr = [manager attributesOfItemAtPath:path error:&err];
    if (!attr || !attr[NSFileSize]) {
        ELog(@"unknown download size. %@", [err localizedDescription]);
    }
    return attr[NSFileSize];
}

@end
