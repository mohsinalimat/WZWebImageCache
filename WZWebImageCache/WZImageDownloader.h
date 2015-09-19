//
//  WZImageDownloader.h
//  WZWebImageCache
//
//  Created by z on 15/9/18.
//  Copyright (c) 2015年 SatanWoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WZImageDownloadOperation.h"

@interface WZImageDownloader : NSObject

@property (nonatomic, assign) NSUInteger maxConcurrentDownloadingTask;

+ (WZImageDownloader *)sharedDownloader;

- (instancetype)initWithConcurrentCapacity:(NSUInteger)count;


- (void)addOperation:(WZImageDownloadOperation *)operation;
- (WZImageDownloadOperation *)addTask:(NSURL *)imageURL
                             progress:(WZImageDownloadProgressBlock)progressBlock
                              success:(WZImageDownloadSuccessBlock)successBlock
                              failure:(WZImageDownloadFailureBlock)failureBlock;

- (void)cancelAllTasks;
- (void)cancelOperation:(WZImageDownloadOperation *)operation;

- (void)pause;
- (void)resume;

- (NSUInteger)currentDownloadingTasks;
- (NSUInteger)currentScheduledTasks;

@end
