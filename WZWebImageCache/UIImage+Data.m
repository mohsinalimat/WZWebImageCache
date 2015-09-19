//
//  UIImage+Data.m
//  WZWebImageCache
//
//  Created by z on 15/9/18.
//  Copyright (c) 2015年 SatanWoo. All rights reserved.
//

#import "UIImage+Data.h"

// PNG signature bytes and data (below)
static unsigned char kPNGSignatureBytes[8] = {0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A};
static NSData *kPNGSignatureData = nil;

@implementation UIImage (Data)

- (NSData *)dataFromImage
{
    int alphaInfo = CGImageGetAlphaInfo(self.CGImage);
    BOOL hasAlpha = !(alphaInfo == kCGImageAlphaNone ||
                      alphaInfo == kCGImageAlphaNoneSkipFirst ||
                      alphaInfo == kCGImageAlphaNoneSkipLast);
    BOOL imageIsPng = hasAlpha;
    
    if (imageIsPng) {
        return UIImagePNGRepresentation(self);
    } else {
        return UIImageJPEGRepresentation(self, (CGFloat)1.0);
    }
}

- (UIImage *)decodedImage
{
    if (self.images) return self;
    
    CGImageRef imageRef = self.CGImage;
    
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(imageRef);
    BOOL anyAlpha = (alpha == kCGImageAlphaFirst ||
                     alpha == kCGImageAlphaLast ||
                     alpha == kCGImageAlphaPremultipliedFirst ||
                     alpha == kCGImageAlphaPremultipliedLast);
    
    if (anyAlpha) return self;
    
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    // current
    CGColorSpaceModel imageColorSpaceModel = CGColorSpaceGetModel(CGImageGetColorSpace(imageRef));
    CGColorSpaceRef colorspaceRef = CGImageGetColorSpace(imageRef);
    
    bool unsupportedColorSpace = (imageColorSpaceModel == 0 || imageColorSpaceModel == -1 || imageColorSpaceModel == kCGColorSpaceModelIndexed);
    if (unsupportedColorSpace)
        colorspaceRef = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(NULL, width,
                                                 height,
                                                 CGImageGetBitsPerComponent(imageRef),
                                                 0,
                                                 colorspaceRef,
                                                 kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
    
    // Draw the image into the context and retrieve the new image, which will now have an alpha layer
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGImageRef imageRefWithAlpha = CGBitmapContextCreateImage(context);
    UIImage *imageWithAlpha = [UIImage imageWithCGImage:imageRefWithAlpha];
    
    if (unsupportedColorSpace)
        CGColorSpaceRelease(colorspaceRef);
    
    CGContextRelease(context);
    CGImageRelease(imageRefWithAlpha);
    
    return imageWithAlpha;
}

@end
