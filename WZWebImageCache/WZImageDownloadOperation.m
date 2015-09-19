//
//  WZImageDownloadTask.m
//  WZWebImageCache
//
//  Created by z on 15/9/18.
//  Copyright (c) 2015年 SatanWoo. All rights reserved.
//

#import "WZImageDownloadOperation.h"

@interface WZImageDownloadOperation() <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableURLRequest *request;
@property (nonatomic, strong) NSMutableData *receivedData;

@property (nonatomic, copy)   WZImageDownloadProgressBlock progressBlock;
@property (nonatomic, copy)   WZImageDownloadSuccessBlock  successBlock;
@property (nonatomic, copy)   WZImageDownloadFailureBlock  failureBlock;

@property (nonatomic, assign) CGFloat receivedLength;
@property (nonatomic, assign) CGFloat expectedLength;
@property (nonatomic, assign, readwrite) WZImageDownloadOperationStatus status;
@end

@implementation WZImageDownloadOperation

- (instancetype)initWithImageURL:(NSURL *)URL progress:(WZImageDownloadProgressBlock)progressBlock success:(WZImageDownloadSuccessBlock)successBlock failure:(WZImageDownloadFailureBlock)failureBlock
{
    self = [super init];
    if (self) {
        self.imageURL = URL;
        self.progressBlock = progressBlock;
        self.successBlock = successBlock;
        self.failureBlock = failureBlock;
        
        self.request = [NSMutableURLRequest requestWithURL:self.imageURL
                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                           timeoutInterval:30];
        
        self.status = WZImageDownloadOperationStatusReady;
        self.receivedLength = 0.0;
        self.expectedLength = 0.0;
    }
    return self;
}

- (void)dealloc
{
    [self cleanUp];
}

- (void)cancelDownload
{
    [self cancel];
    [self cleanUp];
}

#pragma mark - Override
- (BOOL)isExecuting
{
    return self.status == WZImageDownloadOperationStatusDownloading;
}

- (BOOL)isCancelled
{
    return self.status == WZImageDownloadOperationStatusFailed;
}

- (BOOL)isFinished
{
    return self.status == WZImageDownloadOperationStatusCancelled ||
    self.status == WZImageDownloadOperationStatusDone ||
    self.status == WZImageDownloadOperationStatusFailed;
}

- (void)cancel
{
    [self willChangeValueForKey:@"isCancelled"];
    self.status = WZImageDownloadOperationStatusCancelled;
    [self didChangeValueForKey:@"isCancelled"];
}

- (BOOL)isAsynchronous
{
    return YES;
}

- (void)updateStatus:(WZImageDownloadOperationStatus)status
{
    [self.connection cancel];
    
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    _status = status;
    
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
}

- (void)start
{
    if (![NSURLConnection canHandleRequest:self.request]) {
        NSError *error = [NSError errorWithDomain:@"com.satanwoo.url.error" code:1 userInfo:nil];
        [self updateStatus:WZImageDownloadOperationStatusFailed];
        if (self.failureBlock) self.failureBlock(error);

        return;
    }
    
    self.connection = [[NSURLConnection alloc] initWithRequest:self.request
                                                      delegate:self
                                              startImmediately:NO];
    
    if (!self.connection || self.isCancelled) {
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    self.status = WZImageDownloadOperationStatusDownloading;
    [self didChangeValueForKey:@"isExecuting"];
    
    self.receivedData = [[NSMutableData alloc] init];
    
    NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
    [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
    [self.connection scheduleInRunLoop:runLoop
                               forMode:NSDefaultRunLoopMode];
    
    [self.connection start];
    [runLoop run];
}

#pragma mark - NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (self.failureBlock) {
        self.failureBlock(error);
    }
}

#pragma mark - NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.expectedLength = [response expectedContentLength];
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if (httpResponse.statusCode >= 400) {
        [self.connection cancel];
        
        if (self.failureBlock) {
            NSError *error = [NSError errorWithDomain:@"com.satanwoo.response.error"
                                                 code:httpResponse.statusCode
                                             userInfo:nil];
            
            self.failureBlock(error);
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.receivedData appendData:data];
    self.receivedLength += [data length];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.progressBlock) {
            self.progressBlock(self.receivedLength, self.expectedLength);
        }
    });
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if ([self isExecuting]) {
        [self updateStatus:WZImageDownloadOperationStatusDone];
        
        if (self.successBlock) {
            self.successBlock(self.receivedData);
        }
    }
}

#pragma mark - Private

- (void)cleanUp
{
    [self.connection cancel];
    self.connection = nil;
    
    self.progressBlock = nil;
    self.successBlock = nil;
    self.failureBlock = nil;
    self.receivedData = nil;
}


@end
