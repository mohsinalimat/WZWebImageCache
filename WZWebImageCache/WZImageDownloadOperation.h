//
//  WZImageDownloadTask.h
//  WZWebImageCache
//
//  Created by z on 15/9/18.
//  Copyright (c) 2015年 SatanWoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    WZImageDownloadOperationStatusReady = 0,
    WZImageDownloadOperationStatusDownloading = 1,
    WZImageDownloadOperationStatusDone = 2,
    WZImageDownloadOperationStatusFailed = 3,
    WZImageDownloadOperationStatusCancelled = 4
} WZImageDownloadOperationStatus;

typedef void(^WZImageDownloadProgressBlock)(CGFloat receivedLength, CGFloat expectedLength);
typedef void(^WZImageDownloadSuccessBlock) (NSData *data);
typedef void(^WZImageDownloadFailureBlock) (NSError *error);

@interface WZImageDownloadOperation : NSOperation
@property (nonatomic, assign, readonly) WZImageDownloadOperationStatus status;

- (instancetype)initWithImageURL:(NSURL *)URL
                        progress:(WZImageDownloadProgressBlock)progressBlock
                         success:(WZImageDownloadSuccessBlock)successBlock
                         failure:(WZImageDownloadFailureBlock)failureBlock;

- (void)cancelDownload;

@end
