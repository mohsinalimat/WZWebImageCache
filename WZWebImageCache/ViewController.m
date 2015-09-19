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

@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;
@property (weak, nonatomic) IBOutlet UIImageView *imageView3;
@property (weak, nonatomic) IBOutlet UIImageView *imageView4;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *URL1 = [NSURL URLWithString:@"http://img3.qianzhan123.com/news/201509/16/20150916-9ccb63cba06e5872_600x5000.jpeg"];
    NSURL *URL2 = [NSURL URLWithString:@"http://www.hinews.cn/pic/0/17/79/96/17799649_713076.jpg"];
    NSURL *URL3 = [NSURL URLWithString:@"http://www.123meiyan.com/sysimg/allimg/150814/20_150814153153_1.jpg"];
    
    WZImageManagerFetchOperation* op1 = [[WZImageManager sharedManager] fetchImageWithURL:URL1
                                           decompress:NO
                                             progress:^(CGFloat receivedLength, CGFloat expectedLength) {
                                                 NSLog(@"receivedLength is %g", receivedLength);
    } success:^(UIImage *image, NSError *error) {
        if (!error) {
            self.imageView1.image = image;
        }
    } failure:nil];
    
    [op1 cancelFetch];
    
    WZImageManagerFetchOperation* op2 = [[WZImageManager sharedManager] fetchImageWithURL:URL1
                                                                               decompress:NO
                                                                                 progress:^(CGFloat receivedLength, CGFloat expectedLength) {
                                                                                     NSLog(@"receivedLength is %g", receivedLength);
                                                                                 } success:^(UIImage *image, NSError *error) {
                                                                                     if (!error) {
                                                                                         self.imageView2.image = image;
                                                                                     }
                                                                                 } failure:nil];
    
    //[op2 cancelFetch];
    
    WZImageManagerFetchOperation* op3 = [[WZImageManager sharedManager] fetchImageWithURL:URL2
                                                                               decompress:NO
                                                                                 progress:^(CGFloat receivedLength, CGFloat expectedLength) {
                                                                                     NSLog(@"receivedLength is %g", receivedLength);
                                                                                 } success:^(UIImage *image, NSError *error) {
                                                                                     if (!error) {
                                                                                         self.imageView3.image = image;
                                                                                     }
                                                                                 } failure:nil];
    
    WZImageManagerFetchOperation* op4 = [[WZImageManager sharedManager] fetchImageWithURL:URL3
                                                                               decompress:NO
                                                                                 progress:^(CGFloat receivedLength, CGFloat expectedLength) {
                                                                                     NSLog(@"receivedLength is %g", receivedLength);
                                                                                 } success:^(UIImage *image, NSError *error) {
                                                                                     if (!error) {
                                                                                         self.imageView4.image = image;
                                                                                     }
                                                                                 } failure:nil];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
