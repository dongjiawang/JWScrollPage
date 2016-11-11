//
//  JWContentView.h
//  JWScrollPageView
//
//  Created by djw on 2016/11/10.
//  Copyright © 2016年 DJW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+jwScrollPageViewController.h"
#import "JWScrollPageViewDelegate.h"
#import "JWScrollSegmentView.h"
#import "JWCollectionView.h"

@interface JWContentView : UIView

/**
 设置代理
 */
@property (nonatomic, weak) id<JWScrollPageViewDelegate> delegate;

/**
 被复用的 collection，子控制的页面放在上面，只读
 */
//@property (nonatomic, strong, readonly) JWCollectionView  *collectionView;

/**
 初始化方法

 @param frame frame
 @param segmentView 标签的 view
 @param parentViewController 父控制器
 @param delegate 遵循代理
 @return 初始化结果
 */
- (instancetype)initWithFrame:(CGRect)frame segmentView:(JWScrollSegmentView *)segmentView parentViewController:(UIViewController *)parentViewController delegate:(id<JWScrollPageViewDelegate>)delegate;

/**
 外界修改 contentView offset 的入口

 @param offset 需要移动的距离
 @param animated 是否动画
 */
- (void)setContentViewOffSet:(CGPoint)offset animated:(BOOL)animated;

/**
 重新加载内容
 */
- (void)reload;

@end
