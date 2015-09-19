//
//  WZImageManager.h
//  WZWebImageCache
//
//  Created by z on 15/9/19.
//  Copyright (c) 2015年 SatanWoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WZImageDownloader.h"

typedef void(^WZImageFetchCompletionBlock)(UIImage *, NSError *);

@interface WZImageManager : NSObject

+ (WZImageManager *)sharedManager;
- (void)fetchImageWithURL:(NSURL *)URL
               decompress:(BOOL)decompress
                 progress:(WZImageDownloadProgressBlock)progress
                  success:(WZImageFetchCompletionBlock)completion
                  failure:(WZImageDownloadFailureBlock)failure;

- (void)reset;

@end
