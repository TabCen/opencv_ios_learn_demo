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
        case 1:{
            [self grayImage];
        }break;
        case 2:{
            [self blurImage];
        }break;
        case 3:{
            [self remapImage];
        }break;
        case 4:{
            [self scaleImage];
        }break;
        default:
            break;
    }
}

///Image <—> Mat
-(void)processImage{
    //image -> mat 的几种方式
    //方式一
//    cv::Mat mat;
//    UIImage *image = [UIImage imageNamed:@"test1"];
//    UIImageToMat(image, mat);
    
    ///image -> mat
    //方法二
    cv::Mat mat;
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"Image" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSString *path = [bundle pathForResource:@"test2" ofType:@"jpg"];
    cv::String fileName = [path cStringUsingEncoding:NSUTF8StringEncoding];
    
    mat = cv::imread(fileName);
    
    //这样读取的是BGR图片，转化为RGB Mat后再转化为Image对象
    cv::Mat originImgMat;
    cv::cvtColor(mat, originImgMat, CV_BGR2RGB);
    
    ///mat -> image
    self.outImage.image = MatToUIImage(originImgMat);
    
}

///灰度图
-(void)grayImage{
    ///image -> mat
    cv::Mat mat;
    UIImageToMat([UIImage imageNamed:@"test1"], mat);
    
    ///rgb -> gray
    cv::Mat gray;
    cv::cvtColor(mat, gray, CV_RGB2GRAY);
    
    NSLog(@"通道%d",mat.channels());
    NSLog(@"通道%d",gray.channels());
    ///mat -> image
    self.outImage.image = MatToUIImage(gray);
    
}

///模糊
-(void)blurImage{
    
    ///image -> mat
    cv::Mat mat;
    UIImageToMat([UIImage imageNamed:@"test1"], mat);
    
    ///rgb -> gray
    cv::Mat gray;
    cv::cvtColor(mat, gray, CV_RGB2GRAY);

    ///gray -> blur
    cv::Mat blurMat;
    cv::blur(gray, blurMat, cv::Size(15,15));
    
    ///mat -> image
    self.outImage.image = MatToUIImage(blurMat);
    
}

///重映射
-(void)remapImage{
    
    ///UIImage -> mat
    cv::Mat mat;
    UIImageToMat([UIImage imageNamed:@"test1"], mat);
    
    ///
    cv::Mat targetMat(mat.size(),mat.type());
    
    cv::Mat xMat(mat.size(),CV_32FC1);//x方向
    cv::Mat yMat(mat.size(),CV_32FC1);//y方向
    
    int rows = mat.rows; //y
    int cols = mat.cols; //x
    
    for (int i = 0; i < cols; i++) {
        for (int j = 0; j < rows; j++) {
            
            //x坐标变换
            xMat.at<float>(j,i) = i;

            //y坐标变换
//            yMat.at<float>(j,i) = rows - j; //y坐标变换
            yMat.at<float>(j,i) = j + 5*sin(i/M_PI_2); //
            
        }
    }
    
    cv::remap(mat, targetMat, xMat, yMat, CV_INTER_LINEAR);
    
    ///mat -> image
    self.outImage.image = MatToUIImage(targetMat);
}

///缩放
-(void)scaleImage{
    
    ///image -> mat
    cv::Mat mat;
    UIImageToMat([UIImage imageNamed:@"test1"], mat);
    
    ///缩放比例
    
    float xs = 0.5;
    float ys = 0.5;
    
    int rows = mat.rows;
    int cols = mat.cols;
    
    int targetRows = cvRound(rows * ys);
    int targetCols = cvRound(cols * xs);
    
    ///初始化目标mat
    cv::Mat resultMat(targetRows,targetCols,mat.type());
    
    for (int i = 0; i < targetRows; ++i) {
        for (int j = 0; j < targetCols; ++j) {
            int y = static_cast<int>((i+1)/ys+0.5) - 1; //static_cast<int> 显式类型转换
            int x = static_cast<int>((j+1)/xs+0.5) - 1;
            resultMat.at<cv::Vec4b>(i,j) = mat.at<cv::Vec4b>(y,x);
        }
    }
    
//    cv::cvtColor(resultMat, resultMat, CV_BGR2RGB);
    UIImage *targetImage = MatToUIImage(resultMat);
    ///目标
    self.outImage.image = targetImage;
    
}


///翻转






@end
