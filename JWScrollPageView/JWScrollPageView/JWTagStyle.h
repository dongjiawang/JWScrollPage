//
//  JWTagStyle.h
//  JWScrollPageView
//
//  Created by djw on 2016/11/9.
//  Copyright © 2016年 DJW. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, TagImagePosotion) {
    TagImagePosotion_Left,
    TagImagePosotion_Right,
    TagImagePosotion_Top,
    TagImagePosotion_Center
};

@interface JWTagStyle : NSObject

/**
 是否显示遮盖 默认为 NO
 */
@property (nonatomic, assign, getter=isShowCover) BOOL      showCover;

/**
 是否显示滚动条 默认为 NO
 */
@property (nonatomic, assign, getter=isShowLine) BOOL       showline;

/**
 是否显示图片 默认为 NO
 */
@property (nonatomic, assign, getter=isShowImage) BOOL      showImage;

/**
 是否显示附加按钮 默认为 NO
 */
@property (nonatomic, assign, getter=isShowExtraButton) BOOL    showExtraButton;

/**
 是否缩放标签文字 默认为 NO
 */
@property (nonatomic, assign, getter=isScaleTitle) BOOL    scaleTitle;

/**
 是否滚动标签文字 默认为 YES
 设置为 NO 的时候所有标签不再滚动，并且宽度平分
 建议如果标签数目少，整体不会超过屏幕宽度的时候设置为 NO
 */
@property (nonatomic, assign, getter=isScrollTitle) BOOL    scrollTitle;

/**
 是否有弹性 默认为 YES
 */
@property (nonatomic, assign, getter=isTagBounces) BOOL     tagBounces;

/**
 contentView 是否有弹性 默认为 NO
 */
@property (nonatomic, assign, getter=isContentViewBounces) BOOL     contentViewBounces;

/**
 是否渐变颜色 默认为 NO
 */
@property (nonatomic, assign, getter=isGradualChangeTitleColor) BOOL    gradualChangeTitleColor;

/**
 是否可以滑动页面 默认为 YES
 */
@property (nonatomic, assign, getter=isScrollContentView) BOOL      scrollContentView;

/**
 点击标签切换页面的时候是否有动画 默认为 YES
 */
@property (nonatomic, assign, getter=isAnimatedSwitchPageWhenTagClicked) BOOL   animatedSwitchPageWhenTagClicked;

/**
 当标签的宽度小于 scrllView 的宽度时候是否平分宽度  默认为 NO
 */
@property (nonatomic, assign, getter=isAdjustTagWidth) BOOL     adjustTagWidth;

/**
 是否开始滚动的时候调整标签 默认为 NO
 */
@property (nonatomic, assign, getter=isAdjustTagWhenBeginDrag) BOOL     adjustTagWhenBeginDrag;

/**
 是否自动调整遮盖或者滚动条的宽度
 */
@property (nonatomic, assign, getter=isAdjustCoverOrLineWidth) BOOL     adjustCoverAndLineWidth;

/**
 附加按钮背景图片 默认为 nil
 */
@property (nonatomic, strong) NSString      *extraBackgroundImageName;

/**
 滚动条高度 默认为 2
 */
@property (nonatomic, assign) CGFloat       scrollLineHeight;

/**
 滚动条颜色 默认为 redColor
 */
@property (nonatomic, strong) UIColor       *scrollLineColor;

/**
 遮盖的颜色
 */
@property (nonatomic, strong) UIColor       *coverColor;

/**
 遮盖的圆角 默认为 14
 */
@property (nonatomic, assign) CGFloat       coverRadius;

/**
 遮盖高度 默认为 28
 */
@property (nonatomic, assign) CGFloat       coverHeight;

/**
 标签的间隔 默认为 15
 */
@property (nonatomic, assign) CGFloat       tagMargin;

/**
 字体 默认为 14
 */
@property (nonatomic, strong) UIFont        *tagTitleFont;

/**
 标签缩放倍数 默认为 1.3
 */
@property (nonatomic, assign) CGFloat       tagScale;

/**
 一般状态的文字颜色
 */
@property (nonatomic, strong) UIColor       *normalTitleColor;

/**
 选中状态文字颜色
 */
@property (nonatomic, strong) UIColor       *selectedTitleColor;

/**
 标签 view 的高度 默认为 44
 */
@property (nonatomic, assign) CGFloat       tagViewHeight;

/**
 标签图片位置 显示图片的时候再设置
 */
@property (nonatomic, assign) TagImagePosotion      imagePosition;


@end
