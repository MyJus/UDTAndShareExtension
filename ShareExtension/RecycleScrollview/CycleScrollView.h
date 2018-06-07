//
//  CycleScrollView.h
//  ShareExtension
//
//  Created by peony on 2018/6/6.
//  Copyright © 2018年 peony. All rights reserved.
//


#import <UIKit/UIKit.h>

typedef enum {
    CycleDirectionPortait,          // 垂直滚动
    CycleDirectionLandscape         // 水平滚动
}CycleDirection;

@protocol CycleScrollViewDelegate;

@interface CycleScrollView : UIView


/**
 初始化方法

 @param frame 展示的位置
 @param direction 滑动方向
 @param pictureArray 图片数据源，（支持URLString、NSURL、ImageData、Image，支持多样混合）
 @param delegate 代理（用于手机循环滚动图片的点击之间）
 @return 返回实例
 */
- (id)initWithFrame:(CGRect)frame cycleDirection:(CycleDirection)direction pictures:(NSArray *)pictureArray delegate:(id<CycleScrollViewDelegate>)delegate;


/**
 重置循环滚动的数据源

 @param pictureArray 图片数据源
 */
- (void)resetScrollViewImages:(NSArray *)pictureArray;

@end

@protocol CycleScrollViewDelegate <NSObject>
@optional

/**
 代理回调方法，点击选择

 @param cycleScrollView 调用代理的类
 @param index 选择的下标，从1开始。比如数据源数组有三张图片，返回的index数值可能是1、2、3
 */
- (void)cycleScrollViewDelegate:(CycleScrollView *)cycleScrollView didSelectImageView:(int)index;
/**
 代理回调方法，scrollView滚动到第几张图片
 
 @param cycleScrollView 调用代理的类
 @param index 滚动到的下标，从1开始。比如数据源数组有三张图片，返回的index数值可能是1、2、3
 */
- (void)cycleScrollViewDelegate:(CycleScrollView *)cycleScrollView didScrollImageView:(int)index;

@end
