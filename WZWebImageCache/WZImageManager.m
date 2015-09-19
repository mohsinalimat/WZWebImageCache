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

- (void)fetchImageWithURL:(NSURL *)URL
               decompress:(BOOL)decompress
               progress:(WZImageDownloadProgressBlock)progress
                  success:(WZImageFetchCompletionBlock)completion
                  failure:(WZImageDownloadFailureBlock)failure
{
    UIImage *image = [[WZImageCache sharedImageCache] getImageForKey:URL.absoluteString];
    if (image) {
        if (completion) {
            completion(image, nil);
            return;
        }
    }
    
    // Fallback to download
    [[WZImageDownloader sharedDownloader] addTask:URL
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
}

- (void)reset
{
    [[WZImageCache sharedImageCache] cleanCache];
    [[WZImageCache sharedImageCache] destructiveCleanDisk];
}

@end
