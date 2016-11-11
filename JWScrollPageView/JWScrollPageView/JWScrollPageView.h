//
//  JWScrollPageView.h
//  JWScrollPageView
//
//  Created by djw on 2016/11/10.
//  Copyright © 2016年 DJW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Frame.h"
#import "JWContentView.h"
#import "JWTagView.h"

typedef void(^extraBtnClicked)(UIButton *extraBtn);

@interface JWScrollPageView : UIView

/**
 附加按钮点击回调
 */
@property (nonatomic, copy) extraBtnClicked extraBtnClicked;

/**
 显示内容的 content
 */
@property (nonatomic, strong) JWContentView *contentView;

/**
 标签页
 */
@property (nonatomic, strong) JWScrollSegmentView *segmentView;

@property (nonatomic, weak) id<JWScrollPageViewDelegate>delegate;


/**
 初始化

 @param frame frame
 @param tagStyle 标签 style
 @param tagArray 标签数组
 @param parentController 父控制器
 @param delegate 代理
 @return page
 */
- (instancetype)initWithFrame:(CGRect)frame segmentStyle:(JWTagStyle *)tagStyle tagArray:(NSArray<NSString *> *)tagArray parentController:(UIViewController *)parentController delegate:(id<JWScrollPageViewDelegate>)delegate;

/**
 给外界设置选中的下标的方法

 @param selectedIndex 选中下标
 @param animated 是否动画
 */
- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated;

/**
 外界重新设置的标题的方法

 @param newTitles 新的标签数据
 */
- (void)reloadWithNewTitles:(NSArray<NSString *> *)newTitles;

@end
