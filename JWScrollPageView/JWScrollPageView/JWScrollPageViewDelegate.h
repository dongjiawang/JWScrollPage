//
//  JWScrollPageViewDelegate.h
//  JWScrollPageView
//
//  Created by djw on 2016/11/9.
//  Copyright © 2016年 DJW. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JWTagView;
@class JWCollectionView;
@class JWContentView;


/**
 子控制的代理，重写的生命周期的方法
 */
@protocol JWScrollPageChildVCDelegate <NSObject>

@optional

/**
 * 如果你希望所有的子控制器的view的系统生命周期方法被正确的调用
 * 请重写父控制器的'shouldAutomaticallyForwardAppearanceMethods'方法 并且返回NO
 * 当然如果你不做这个操作, 子控制器的生命周期方法将不会被正确的调用
 * 如果你仍然想利用子控制器的生命周期方法, 请使用'ZJScrollPageViewChildVcDelegate'提供的代理方法
 * 或者'ZJScrollPageViewDelegate'提供的代理方法
 */
- (void)jw_viewDidLoadForIndex:(NSInteger)index;
- (void)jw_viewWillAppearForIndex:(NSInteger)index;
- (void)jw_viewDidAppearForIndex:(NSInteger)index;
- (void)jw_viewWillDisAppearForIndex:(NSInteger)index;
- (void)jw_viewDidDisAppearForIndex:(NSInteger)index;

@end



/**
  scroll 页面需要遵循的代理，包含了 子控制器页面的切换 和 UI 布局的调整
 */
@protocol JWScrollPageViewDelegate <NSObject>

/**
 获取标签数量

 @return 标签数量
 */
- (NSInteger)numberOfChildViewControllers;

/**
 获取将要显示的控制器

 @param childViewController 获取到控制器（应该先判断是否为 nil，如果为 nil，先创建，再返回）
 @param index 对应的控制器的下标
 @return 返回的控制器
 */
- (UIViewController<JWScrollPageChildVCDelegate> *)childViewController:(UIViewController<JWScrollPageChildVCDelegate> *)childViewController forIndex:(NSInteger)index;

@optional

/**
 调用这个协议，在控制器中修改对应下标的标签的 UI（文字颜色，遮盖，图片等等）

 @param tagView 拿到的标签
 @param index 标签下标
 */
- (void)setUpTagView:(JWTagView *)tagView forIndex:(NSInteger)index;

/**
 pageController 中的 collection 是否使用平移手势

 @param scrollPageController pageController
 @param scrollview 控制器中 collection（scrollView）
 @param panGesture 平移手势
 @return 是否有手势
 */
- (BOOL)scrollPageController:(UIViewController *)scrollPageController contentScrollView:(JWCollectionView *)scrollview shouldBeginPanGesture:(UIPanGestureRecognizer *)panGesture;

/**
 子控制的页面即将显示

 @param scrollPageController 父控制器
 @param childViewController 子控制器
 @param index 对应的下标
 */
- (void)scrollPageController:(UIViewController *)scrollPageController childViewControllerWillAppear:(UIViewController *)childViewController forIndex:(NSInteger)index;

/**
 子控制的页面已经显示的控制器

 @param scrollPageController 父控制器
 @param childViewController 子控制器
 @param index 对应的下标
 */
- (void)scrollPageController:(UIViewController *)scrollPageController childViewControllerDidAppear:(UIViewController *)childViewController forIndex:(NSInteger)index;

/**
 子控制器的页面即将消失

 @param scrollPageController 父控制器
 @param childViewController 子控制器
 @param index 对应的下标
 */
- (void)scrollPageController:(UIViewController *)scrollPageController childViewControllerWillDisAppear:(UIViewController *)childViewController forIndex:(NSInteger)index;

/**
 子控制的页面已经消失

 @param scrollPageController 父控制器
 @param childViewController 子控制器
 @param index 对应的下标
 */
- (void)scrollPageController:(UIViewController *)scrollPageController childViewControllerDidDisAppear:(UIViewController *)childViewController forIndex:(NSInteger)index;

/**
 子控制页面添加到父视图中的显示位置

 @param containerView 父视图
 @return 子控制器的位置
 */
- (CGRect)childVCFrameforContainer:(UIView *)containerView;

@end
