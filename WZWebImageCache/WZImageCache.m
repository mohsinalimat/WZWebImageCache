//
//  WZImageCache.m
//  WZWebImageCache
//
//  Created by z on 15/9/17.
//  Copyright (c) 2015年 SatanWoo. All rights reserved.
//

#import "WZImageCache.h"
#import "NSString+MD5.h"
#import "UIImage+Data.h"

static NSString *const WZImageCacheDefaultDiskPath = @"com.satanwoo.cache";
static NSInteger const WZCacheDefaultMaxAge = 60 * 60 * 24 * 7; // 1 week

@interface WZImageCache()
@property (nonatomic, strong) dispatch_queue_t diskQueue;
@property (nonatomic, strong) NSCache *memoryCache;
@property (nonatomic, copy)   NSString *diskPath;

@property (nonatomic, assign, readwrite) NSUInteger maxMemoryCost;
@property (nonatomic, assign, readwrite) NSUInteger maxMemoryUnitCount;
@property (nonatomic, assign, readwrite) NSUInteger maxCacheAge;
@property (nonatomic, assign, readwrite) NSUInteger maxCacheSize;

@property (nonatomic, assign, setter=setDirectoryExist:) BOOL isDirectoryExist;
@end

@implementation WZImageCache

+ (WZImageCache *)sharedImageCache
{
    static dispatch_once_t once;
    static WZImageCache *cache = nil;
    dispatch_once(&once, ^{
        cache = [[WZImageCache alloc] init];
    });
    return cache;
}

- (instancetype)init
{
    return self = [self initWithDiskDirectoryName:WZImageCacheDefaultDiskPath];
}

- (instancetype)initWithDiskDirectoryName:(NSString *)name
{
    self = [super init];
    if (self) {
        self.diskPath = [[self cacheDirectory] stringByAppendingPathComponent:name];
        self.diskQueue = dispatch_queue_create("com.satanwoo.diskIO", DISPATCH_QUEUE_SERIAL);
        
        self.memoryCache = [[NSCache alloc] init];
        self.memoryCache.name = @"com.satanwoo.cache";
        self.maxCacheAge = WZCacheDefaultMaxAge;
    }
    return self;
}

#pragma mark - Override
- (BOOL)isDirectoryExist
{
    if (_isDirectoryExist) return YES;
    return [[NSFileManager defaultManager] fileExistsAtPath:self.diskPath];
}

#pragma mark - Public Method
- (UIImage *)getImageForKey:(NSString *)key
{
    UIImage *result = nil;
    result = [self imageInCacheForKey:key];
    if (result) {
        return result;
    }
    
    result = [self imageInDiskForKey:key];
    if (result) {
        [self.memoryCache setObject:[result decodedImage] forKey:key];
    }
    
    return result;
}

- (void)saveImage:(UIImage *)image forKey:(NSString *)key
{
    [self saveImage:image forKey:key autoCache:NO];
}

- (void)saveImage:(UIImage *)image forKey:(NSString *)key autoCache:(BOOL)cache
{
    if (cache) {
        [self cacheImage:image forKey:key];
    }
    
    dispatch_async(self.diskQueue, ^{
        if (!self.isDirectoryExist) {
            [[NSFileManager defaultManager] createDirectoryAtPath:self.diskPath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:NULL];
        }
        
        NSString *filePath = [self filePathInDiskForKey:key];
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:[image dataFromImage] attributes:nil];
    });
}

- (void)cacheImage:(UIImage *)image forKey:(NSString *)key
{
    [self.memoryCache setObject:image forKey:key];
}

- (void)removeImageInCacheForKey:(NSString *)key
{
    [self.memoryCache removeObjectForKey:key];
}

- (void)removeImageInDiskForKey:(NSString *)key
{
    dispatch_async(self.diskQueue, ^{
        [[NSFileManager defaultManager] removeItemAtPath:[self filePathInDiskForKey:key] error:nil];
    });
}

- (void)cleanCache
{
    [self.memoryCache removeAllObjects];
}

- (void)smartCleanDisk
{
    dispatch_async(self.diskQueue, ^{
        NSURL *diskURL = [NSURL fileURLWithPath:self.diskPath isDirectory:YES];
        
        NSArray *resourceKeys = @[NSURLIsDirectoryKey, NSURLContentModificationDateKey];
        NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:diskURL
                                                                     includingPropertiesForKeys:resourceKeys
                                                                                        options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                                   errorHandler:nil];
        
        NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-self.maxCacheAge];
        NSMutableArray *toDeleteFiles = [NSMutableArray new];
        
        for (NSURL *url in fileEnumerator) {
            NSDictionary *resourceMetaData = [url resourceValuesForKeys:resourceKeys error:NULL];
            if ([resourceMetaData[NSURLIsDirectoryKey] boolValue]) continue;
            
            NSDate *lastModifiedDate = resourceMetaData[NSURLContentModificationDateKey];
            if ([lastModifiedDate compare:expirationDate] == NSOrderedAscending) {
                [toDeleteFiles addObject:url];
            }
        }
        
        for (NSURL *toDeleteURL in toDeleteFiles) {
            [[NSFileManager defaultManager] removeItemAtURL:toDeleteURL error:NULL];
        }
    });
}

- (void)destructiveCleanDisk
{
    [self setDirectoryExist:NO];
    
    dispatch_async(self.diskQueue, ^{
        [[NSFileManager defaultManager] removeItemAtPath:self.diskPath error:nil];
    });
}

#pragma mark - Private Method
- (NSString *)cacheDirectory
{
    static dispatch_once_t token;
    static NSString *cacheDirectory = nil;
    dispatch_once(&token, ^{
        cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    });
    
    return cacheDirectory;
}

- (NSString *)fileNameForKey:(NSString *)key
{
    return [key MD5String];
}

- (NSString *)filePathInDiskForKey:(NSString *)key
{
    return [self.diskPath stringByAppendingPathComponent:[self fileNameForKey:key]];
}

- (UIImage *)imageInCacheForKey:(NSString *)key
{
    return [self.memoryCache objectForKey:key];
}

- (UIImage *)imageInDiskForKey:(NSString *)key
{
    NSString *filePath = [self filePathInDiskForKey:key];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    
    return [UIImage imageWithData:data];
}

@end
