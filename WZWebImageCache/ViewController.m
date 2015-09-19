//
//  ViewController.m
//  WZWebImageCache
//
//  Created by z on 15/9/17.
//  Copyright (c) 2015年 SatanWoo. All rights reserved.
//

#import "ViewController.h"
#import "WZImageManager.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *URL = [NSURL URLWithString:@"http://img3.qianzhan123.com/news/201509/16/20150916-9ccb63cba06e5872_600x5000.jpeg"];
    
    [[WZImageManager sharedManager] fetchImageWithURL:URL
                                           decompress:NO
                                             progress:^(CGFloat receivedLength, CGFloat expectedLength) {
                                                 NSLog(@"receivedLength is %g", receivedLength);
    } success:^(UIImage *image, NSError *error) {
        if (!error) {
            self.imageView.image = image;
        }
    } failure:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
