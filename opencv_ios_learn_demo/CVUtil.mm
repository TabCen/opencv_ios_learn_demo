//
//  CVUtil.m
//  ScanDemo
//
//  Created by David on 2018/10/11.
//  Copyright © 2018 火柴小不点. All rights reserved.
//

#import "CVUtil.h"

@implementation CVUtil
+ (UIImage *)imageConvert:(CMSampleBufferRef)sampleBuffer
{
    
    if (CMSampleBufferIsValid(sampleBuffer)) {
        return nil;
    }
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    
    UIImage *image = [UIImage imageWithCIImage:ciImage];
    return image;
}

#pragma mark - 将CMSampleBufferRef转为cv::Mat
+(cv::Mat)bufferToMat:(CMSampleBufferRef) sampleBuffer{
//    CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
//    CVPixelBufferLockBaseAddress( pixelBuffer, 0 );
//
//    //Processing here
//    int bufferWidth = (int)CVPixelBufferGetWidth(pixelBuffer);
//    int bufferHeight = (int)CVPixelBufferGetHeight(pixelBuffer);
//    unsigned char *pixel = (unsigned char *)CVPixelBufferGetBaseAddress(pixelBuffer);
//
//    //put buffer in open cv, no memory copied
//    cv::Mat mat = cv::Mat(bufferHeight,bufferWidth,CV_8UC4,pixel,CVPixelBufferGetBytesPerRow(pixelBuffer));
//
//    //End processing
//    CVPixelBufferUnlockBaseAddress( pixelBuffer, 0 );
//
//    cv::Mat matGray;
//    cvtColor(mat, matGray, CV_BGR2GRAY);
//
//    return matGray;
    
    CVImageBufferRef imgBuf = CMSampleBufferGetImageBuffer(sampleBuffer);

    //锁定内存
    CVPixelBufferLockBaseAddress(imgBuf, 0);
    // get the address to the image data
    void *imgBufAddr = CVPixelBufferGetBaseAddress(imgBuf);

    // get image properties
    int w = (int)CVPixelBufferGetWidth(imgBuf);
    int h = (int)CVPixelBufferGetHeight(imgBuf);

    // create the cv mat
    cv::Mat mat(h, w, CV_8UC4, imgBufAddr, 0);
    //    //转换为灰度图像
    //    cv::Mat edges;
    //    cv::cvtColor(mat, edges, CV_BGR2GRAY);

    //旋转90度
    cv::Mat transMat;
    cv::transpose(mat, transMat);

    //翻转,1是x方向，0是y方向，-1位Both
    cv::Mat flipMat;
    cv::flip(transMat, flipMat, 1);

    CVPixelBufferUnlockBaseAddress(imgBuf, 0);

    return flipMat;
}

//#pragma mark =========== 寻找最大边框 ===========
//int findLargestSquare(const std::vector<std::vector<cv::Point> >& squares, std::vector<cv::Point>& biggest_square)
//{
//    if (!squares.size()) return -1;
//    
//    int max_width = 0;
//    int max_height = 0;
//    int max_square_idx = 0;
//    for (int i = 0; i < squares.size(); i++)
//    {
//        cv::Rect rectangle = boundingRect(cv::Mat(squares[i]));
//        if ((rectangle.width >= max_width) && (rectangle.height >= max_height))
//        {
//            max_width = rectangle.width;
//            max_height = rectangle.height;
//            max_square_idx = i;
//        }
//    }
//    biggest_square = squares[max_square_idx];
//    return max_square_idx;
//}
///**
// 根据三个点计算中间那个点的夹角   pt1 pt0 pt2
// */
//double getAngle(cv::Point pt1, cv::Point pt2, cv::Point pt0)
//{
//    double dx1 = pt1.x - pt0.x;
//    double dy1 = pt1.y - pt0.y;
//    double dx2 = pt2.x - pt0.x;
//    double dy2 = pt2.y - pt0.y;
//    return (dx1*dx2 + dy1*dy2)/sqrt((dx1*dx1 + dy1*dy1)*(dx2*dx2 + dy2*dy2) + 1e-10);
//}


+ (cv::Mat)cvMatFromUIImage:(UIImage *)image{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    CGContextRef contextRef = CGBitmapContextCreate(
                                                    cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |kCGBitmapByteOrderDefault
                                                    ); // Bitmap info flags
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    return cvMat;
}

- (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    cv::Mat cvMat(rows, cols, CV_8UC1); // 8 bits per component, 1 channels
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    return cvMat;
}

-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    return finalImage;
}


@end


@implementation UIImageView (CVUtil)

- (UIImage *)clipAnyShapeImageAtPath:(NSMutableArray *)penPaths
atRect:(CGRect)rect {
    // 防止线画出UIImageView范围之外
    CGFloat width= self.frame.size.width;
    CGFloat rationScale = (width / self.image.size.width);
    CGFloat origX = (rect.origin.x - self.frame.origin.x) / rationScale;
    CGFloat origY = (rect.origin.y - self.frame.origin.y) / rationScale;
    CGFloat oriWidth = rect.size.width / rationScale;
    CGFloat oriHeight = rect.size.height / rationScale;
    
    if (origX < 0) {
        oriWidth = oriWidth + origX;
        origX = 0;
    }
    
    if (origY < 0) {
        oriHeight = oriHeight + origY;
        origY = 0;
    }
    
    // 绘制图片到点的矩形范围内
    CGRect myRect = CGRectMake(origX, origY, oriWidth, oriHeight);
    CGImageRef  imageRef = CGImageCreateWithImageInRect(self.image.CGImage, myRect);
    
    UIGraphicsBeginImageContextWithOptions(myRect.size, NO, self.image.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextDrawImage(context, myRect, imageRef);
    UIImage * newImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    UIGraphicsEndImageContext();
    
    // 任意形状截取图片
    // clip any path
    for (int i = 0; i < penPaths.count; i++) {
        NSValue *valueI = penPaths[i];
        CGPoint pointI = [valueI CGPointValue];
        pointI.x -= myRect.origin.x;
        pointI.y -= myRect.origin.y;
        
        if (pointI.x < 0) {
            pointI.x = 0;
        }
        
        if (pointI.y < 0) {
            pointI.x = 0;
        }
        
        penPaths[i] = [NSValue valueWithCGPoint:pointI];
    }
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, self.image.scale);
    context = UIGraphicsGetCurrentContext();
    NSValue *value0 = penPaths[0];
    CGPoint point0 = [value0 CGPointValue];
    CGContextMoveToPoint(context, point0.x, point0.y);
    
    for (int i = 1; i < penPaths.count; i++) {
        NSValue *valueI = penPaths[i];
        CGPoint pointI = [valueI CGPointValue];
        CGContextAddLineToPoint(context, pointI.x, pointI.y);
    }
    CGContextAddLineToPoint(context, point0.x, point0.y);
    CGContextClip(context);
    [newImage drawInRect:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    CGContextDrawPath(context, kCGPathFill);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end

