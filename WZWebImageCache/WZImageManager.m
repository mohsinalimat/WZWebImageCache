//
//  WZImageManager.m
//  WZWebImageCache
//
//  Created by z on 15/9/19.
//  Copyright (c) 2015年 SatanWoo. All rights reserved.
//

#import "WZImageManager.h"
#import "WZImageCache.h"
#import "WZImageDownloader.h"
#import "UIImage+Data.h"

@interface WZImageManagerFetchOperation()
@property (nonatomic, assign, readwrite) BOOL isCancelled;
@property (nonatomic, strong) WZImageDownloadOperation *downloadOperation;
@end

@implementation WZImageManagerFetchOperation

- (instancetype)initWithOperation:(WZImageDownloadOperation *)operation
{
    self = [super init];
    if (self) {
        self.downloadOperation = operation;
    }
    return self;
}

- (void)cancelFetch
{
    self.isCancelled = YES;
    [self.downloadOperation cancelDownload];
}

@end

@implementation WZImageManager

+ (WZImageManager *)sharedManager
{
    static dispatch_once_t predicate;
    static WZImageManager *manager = nil;
    dispatch_once(&predicate, ^{
        manager = [[WZImageManager alloc] init];
    });
    
    return manager;
}

- (WZImageManagerFetchOperation *)fetchImageWithURL:(NSURL *)URL
               decompress:(BOOL)decompress
               progress:(WZImageDownloadProgressBlock)progress
                  success:(WZImageFetchCompletionBlock)completion
                  failure:(WZImageDownloadFailureBlock)failure
{
    WZImageManagerFetchOperation *fetchOperation = [WZImageManagerFetchOperation new];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (!fetchOperation.isCancelled) {
            UIImage *image = [[WZImageCache sharedImageCache] getImageForKey:URL.absoluteString];
            if (image) {
                if (completion) {
                    if (!fetchOperation.isCancelled) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(image, nil);
                        });
                    }
                }
            } else {
                [[WZImageDownloader sharedDownloader] addOperation:fetchOperation.downloadOperation];
            }
        }
    });
    
    // Fallback to download
    WZImageDownloadOperation *operation = [[WZImageDownloadOperation alloc]  initWithImageURL:URL
                                         progress:progress
                                          success:^(NSData *data) {
                                              UIImage *image = [UIImage imageWithData:data];
                                              UIImage *decodedImage = decompress ? [image decodedImage] : image;
                                              [[WZImageCache sharedImageCache] saveImage:image
                                                                                  forKey:URL.absoluteString
                                                                               autoCache:YES completionBlock:^(NSString *filePath) {
                                                                                   NSLog(@"filePath is %@", filePath);
                                                                               }];
                                              if (completion) completion(decodedImage, nil);
                                          } failure:failure];
    fetchOperation.downloadOperation = operation;
    
    return fetchOperation;
}

- (void)reset
{
    [[WZImageCache sharedImageCache] cleanCache];
    [[WZImageCache sharedImageCache] destructiveCleanDisk];
}

@end
