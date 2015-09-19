//
//  UIImage+Data.h
//  WZWebImageCache
//
//  Created by z on 15/9/18.
//  Copyright (c) 2015年 SatanWoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Data)

- (NSData *)dataFromImage;
- (UIImage *)decodedImage;

@end
