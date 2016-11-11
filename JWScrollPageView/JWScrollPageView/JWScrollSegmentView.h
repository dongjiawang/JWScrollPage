//
//  JWScrollSegmentView.h
//  JWScrollPageView
//
//  Created by djw on 2016/11/9.
//  Copyright © 2016年 DJW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JWTagStyle.h"
#import "JWScrollPageViewDelegate.h"
@class JWTagStyle;
@class JWTagView;

@interface JWScrollSegmentView : UIView

/**
 点击标签的按钮
 
 @param tagView 被点击的标签
 @param index 标签的下标
 */
typedef void(^TagBtnClicked)(JWTagView *tagView, NSInteger index);

/**
 点击了附加按钮
 
 @param extraBtn 附加按钮
 */
typedef void(^ExtraBtnClicked)(UIButton *extraBtn);

/**
 标签的数组
 */
@property (nonatomic, strong) NSArray   *tagArray;

/**
 标签的各种属性
 */
@property (nonatomic, strong) JWTagStyle    *segmentStyle;

/**
 附加按钮的 block
 */
@property (nonatomic, copy) ExtraBtnClicked extraBtnBlock;

/**
 代理
 */
@property (nonatomic, weak) id<JWScrollPageViewDelegate>delegate;

/**
 背景图片
 */
@property (strong, nonatomic) UIImage *backgroundImage;


/**
 创建顶部的滚动标签的 view
 
 @param frame frame
 @param segementStyle 标签的样式类型
 @param delegate 遵循的代理
 @param tagArray 标签数据
 @param tagBtnClicked 点击标签的 block 回调
 @return 标签 view
 */
- (instancetype)initWithFrame:(CGRect)frame segementStyle:(JWTagStyle *)segementStyle delegate:(id<JWScrollPageViewDelegate>)delegate tagArray:(NSArray *)tagArray tagDidClicked:(TagBtnClicked)tagBtnClicked;

/**
 重新载入标签数据，并刷新

 @param tagArray 新的标签数据
 */
- (void)reloadTagsWithNewTagArray:(NSArray *)tagArray;

/**
 设置选中下标的标签

 @param index 下标
 @param animated 是否动画效果
 */
- (void)setSelectedIndex:(NSInteger)index animated:(BOOL)animated;

/**
 选中的标签移动到对应的下标

 @param currentIndex 选中的下标
 */
- (void)adjustTagOffSetToCurrentIndex:(NSInteger)currentIndex;

/**
 根据滑动的距离，更新标签的 UI

 @param progress 滑动的距离
 @param oldIndex 上一个标签下标
 @param currentIndex 当前下标
 */
- (void)adjustUIWithProgress:(CGFloat)progress oldIndex:(NSInteger)oldIndex currentIndex:(NSInteger)currentIndex;
@end
