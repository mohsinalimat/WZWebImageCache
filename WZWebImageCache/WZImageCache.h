//
//  WZImageCache.h
//  WZWebImageCache
//
//  Created by z on 15/9/17.
//  Copyright (c) 2015年 SatanWoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^WZFindImageCompletionBlock) (UIImage *);
typedef void(^WZSaveImageCompletionBlock) (NSURL *saveURL);

@interface WZImageCache : NSObject

@property (nonatomic, assign, readonly) NSUInteger maxCacheAge;

+ (WZImageCache *)sharedImageCache;

- (instancetype)initWithDiskDirectoryName:(NSString *)name;

- (UIImage *)getImageForKey:(NSString *)key;

- (void)saveImage:(UIImage *)image forKey:(NSString *)key;
- (void)saveImage:(UIImage *)image forKey:(NSString *)key autoCache:(BOOL)cache;
- (void)cacheImage:(UIImage *)image forKey:(NSString *)key;

- (void)removeImageInCacheForKey:(NSString *)key;
- (void)removeImageInDiskForKey:(NSString *)key;

// Remove Cache
- (void)cleanCache;

// Remove Image Due To Expiration
- (void)smartCleanDisk;

// Directly Remove Whole Directory
- (void)destructiveCleanDisk;

@end
