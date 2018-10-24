//
//  CVUtil.h
//  ScanDemo
//
//  Created by David on 2018/10/11.
//  Copyright © 2018 火柴小不点. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CVUtil : NSObject

+ (UIImage *)imageConvert:(CMSampleBufferRef)sampleBuffer;
+(cv::Mat)bufferToMat:(CMSampleBufferRef) sampleBuffer;
/**
 UIImage转mat
 
 @param image image description
 @return return value description
 */
+ (cv::Mat)cvMatFromUIImage:(UIImage *)image;

/**
 UIImage转matGray
 
 @param image image description
 @return return value description
 */
- (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image;

/**
 mat转UIImage
 
 @return return value description
 */
-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat;

@end


@interface UIImageView (CVUtil)
- (UIImage *)clipAnyShapeImageAtPath:(NSMutableArray *)penPaths
                              atRect:(CGRect)rect;
@end

NS_ASSUME_NONNULL_END
