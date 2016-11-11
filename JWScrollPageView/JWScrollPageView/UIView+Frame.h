//
//  UIView+Frame.h
//  JWScrollPageView
//
//  Created by djw on 2016/11/9.
//  Copyright © 2016年 DJW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Frame)

/**
 view 的 x 起点
 */
@property (nonatomic, assign) CGFloat x;

/**
 view 的 y 起点
 */
@property (nonatomic, assign) CGFloat y;

/**
 view 的宽度
 */
@property (nonatomic, assign) CGFloat width;

/**
 view 的高度
 */
@property (nonatomic, assign) CGFloat height;

/**
 view 的大小
 */
@property (nonatomic, assign) CGSize  size;

/**
 view 的横向中心
 */
@property (nonatomic, assign) CGFloat centerX;

/**
 view 的纵向中心
 */
@property (nonatomic, assign) CGFloat centerY;

/**
 view 的底部坐标
 
 @return view 的底部坐标
 */
- (CGFloat)bottom;

/**
 移除 view 上所有的子 view
 */
- (void)removeAllSubViews;

@end
