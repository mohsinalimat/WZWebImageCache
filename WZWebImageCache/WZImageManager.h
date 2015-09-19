//
//  WZImageManager.h
//  WZWebImageCache
//
//  Created by z on 15/9/19.
//  Copyright (c) 2015年 SatanWoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WZImageDownloader.h"

@interface WZImageManagerFetchOperation : NSObject
@property (nonatomic, assign, readonly) BOOL isCancelled;

- (instancetype)initWithOperation:(WZImageDownloadOperation *)operation;
- (void)cancelFetch;
@end

typedef void(^WZImageFetchCompletionBlock)(UIImage *, NSError *);

@interface WZImageManager : NSObject

+ (WZImageManager *)sharedManager;
- (WZImageManagerFetchOperation *)fetchImageWithURL:(NSURL *)URL
               decompress:(BOOL)decompress
                 progress:(WZImageDownloadProgressBlock)progress
                  success:(WZImageFetchCompletionBlock)completion
                  failure:(WZImageDownloadFailureBlock)failure;

- (void)reset;

@end
