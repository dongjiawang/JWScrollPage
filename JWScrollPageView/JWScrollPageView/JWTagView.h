//
//  JWTagView.h
//  JWScrollPageView
//
//  Created by djw on 2016/11/9.
//  Copyright © 2016年 DJW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JWTagStyle.h"

@interface JWTagView : UIView

/**
 缩放的倍数
 */
@property (nonatomic, assign) CGFloat   currentTransformSx;

/**
 图片的位置
 */
@property (nonatomic, assign) TagImagePosotion  imagePosition;

/**
 标签文字
 */
@property (nonatomic, strong) NSString      *text;

/**
 文字颜色，使用 style 的文字颜色，这里只是调用 setter 方法
 */
@property (nonatomic, strong) UIColor       *textColor;

/**
 label 的字体，这里只是在创建的时候调用一次 setter 方法
 */
@property (nonatomic, strong) UIFont        *font;

/**
 是否被选中
 */
@property (nonatomic, assign, getter=isSelected) BOOL       selected;

/**
 一般状态的图片
 */
@property (strong, nonatomic) UIImage *normalImage;

/**
 选中状态图片
 */
@property (strong, nonatomic) UIImage *selectedImage;

/**
 标签文字的宽度
 
 @return 宽度
 */
- (CGFloat)tagViewWidth;

/**
 如果显示图片，调用此方法，修改标签的样式
 */
- (void)adjustSubviewFrame;


@end
