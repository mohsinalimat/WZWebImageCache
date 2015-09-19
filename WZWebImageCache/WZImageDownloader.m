//
//  WZImageDownloader.m
//  WZWebImageCache
//
//  Created by z on 15/9/18.
//  Copyright (c) 2015年 SatanWoo. All rights reserved.
//

#import "WZImageDownloader.h"

const NSUInteger WZImageDownloaderDefaultCapacity = 4;

@interface WZImageDownloader()
@property (nonatomic, assign) NSUInteger capacity;
@property (nonatomic, strong) NSOperationQueue *downloadingQueue;
@end

@implementation WZImageDownloader

+ (WZImageDownloader *)sharedDownloader
{
    static dispatch_once_t downloaderToken;
    static WZImageDownloader *downloader = nil;
    
    dispatch_once(&downloaderToken, ^{
        downloader = [[WZImageDownloader alloc] initWithConcurrentCapacity:WZImageDownloaderDefaultCapacity];
    });
    
    return downloader;
}

- (instancetype)initWithConcurrentCapacity:(NSUInteger)count
{
    self = [super init];
    if (self) {
        self.capacity = count;
        self.downloadingQueue = [[NSOperationQueue alloc] init];
        self.downloadingQueue.maxConcurrentOperationCount = count;
        self.downloadingQueue.name = @"com.satanwoo.downloading";
    }
    return self;
}

- (WZImageDownloadOperation *)addTask:(NSURL *)imageURL progress:(WZImageDownloadProgressBlock)progressBlock success:(WZImageDownloadSuccessBlock)successBlock failure:(WZImageDownloadFailureBlock)failureBlock
{
    WZImageDownloadOperation *operation = [[WZImageDownloadOperation alloc] initWithImageURL:imageURL
                                                                                    progress:progressBlock
                                                                                     success:successBlock
                                                                                     failure:failureBlock];
    
    [self.downloadingQueue addOperation:operation];
    return operation;
}

- (void)cancelAllTasks
{
    for (WZImageDownloadOperation *operation in self.downloadingQueue.operations) {
        [operation cancelDownload];
    }
    
    [self.downloadingQueue cancelAllOperations];
}

- (void)cancelOperation:(WZImageDownloadOperation *)operation
{
    [operation cancelDownload];
}

- (void)pause
{
    [self.downloadingQueue setSuspended:YES];
}

- (void)resume
{
    [self.downloadingQueue setSuspended:NO];
}

- (NSUInteger)currentDownloadingTasks
{
    NSUInteger result = 0;
    for (WZImageDownloadOperation *operation in self.downloadingQueue.operations) {
        if (operation.status == WZImageDownloadOperationStatusDownloading) {
            result++;
        }
    }
    return result;
}

- (NSUInteger)currentScheduledTasks
{
    return self.downloadingQueue.operationCount;
}

@end
