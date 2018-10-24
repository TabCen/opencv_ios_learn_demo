//
//  TBBaseViewController.m
//  opencv_ios_learn_demo
//
//  Created by David on 2018/10/23.
//  Copyright © 2018 火柴小不点. All rights reserved.
//

#import "TBBaseViewController.h"

#import "CVUtil.h"

@interface TBBaseViewController ()

@end

@implementation TBBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.originImage.image = [UIImage imageNamed:@"test1"];
    
}


- (IBAction)btnclicked:(id)sender {
    UIButton *btn = (UIButton *)sender;
    switch (btn.tag) {
        case 0:{
            [self processImage];
        }break;
            
        default:
            break;
    }
}

-(void)processImage{
//    UIImage *image = [UIImage imageNamed:@"test1"];
    
    ///image -> mat
    cv::Mat mat;
//    UIImageToMat(image, mat);
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"Image" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSString *path = [bundle pathForResource:@"test2.jpg" ofType:nil];
    
    cv::String fileName = [path cStringUsingEncoding:NSUTF8StringEncoding];
    mat = cv::imread(fileName);
    
    
    NSLog(@"%d",mat.channels());
    
    ///mat -> image
    self.outImage.image = MatToUIImage(mat);
    
    
    
    
    
}

@end
