//
//  JWContentView.m
//  JWScrollPageView
//
//  Created by djw on 2016/11/10.
//  Copyright © 2016年 DJW. All rights reserved.
//

#import "JWContentView.h"
#import "UIView+Frame.h"

@interface JWContentView ()<UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource> {
    CGFloat _oldOffSetX; //上一个 X 的偏移量
    BOOL    _isFirstLoadView; //是否第一次加载
}

/**
 顶部标签页
 */
@property (nonatomic, weak) JWScrollSegmentView     *segmentView;

/**
 显示和重用的 collection
 */
@property (nonatomic, strong) JWCollectionView      *collectionView;

/**
 collection 的布局
 */
@property (nonatomic, strong) UICollectionViewFlowLayout    *collectionViewLayout;

/**
 父控制器
 */
@property (nonatomic, weak) UIViewController    *parentViewController;

/**
 是否需要处理超过两 View 的 滚动计算。当为 YES 的时候不需要
 */
@property (nonatomic, assign) BOOL      forbidTouchToAdjustPosition;

/**
 标签的数目
 */
@property (nonatomic, assign) NSInteger     itemsCount;

/**
 存储控制器的字典
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, UIViewController<JWScrollPageChildVCDelegate> *> *childVCDict;

/**
 当前展示的子控制器
 */
@property (nonatomic, strong) UIViewController<JWScrollPageChildVCDelegate>     *currentController;

/**
 当前显示的下标
 */
@property (nonatomic, assign) NSInteger currentIndex;

/**
 上一个子控制器下标
 */
@property (nonatomic, assign) NSInteger oldIndex;

/**
 是否需要管理生命周期
 */
@property (nonatomic, assign) BOOL  needManageLifeCycle;

/**
 是否变化的动画
 */
@property (nonatomic, assign) BOOL changeAnimated;

@end

@implementation JWContentView

# define collectionCellID   @"collectionCell"

static NSString *const  kContentOssSetOffKey = @"contentOffSet";

#pragma  mark - creatSelf

-(instancetype)initWithFrame:(CGRect)frame segmentView:(JWScrollSegmentView *)segmentView parentViewController:(UIViewController *)parentViewController delegate:(id<JWScrollPageViewDelegate>)delegate {
    self = [super initWithFrame:frame];
    if (self) {
        self.segmentView = segmentView;
        self.delegate = delegate;
        self.parentViewController = parentViewController;
        _needManageLifeCycle = ![parentViewController shouldAutomaticallyForwardAppearanceMethods];
        if (!_needManageLifeCycle) {
            /**
             请注意: 如果你希望所有的子控制器的view的系统生命周期方法被正确的调用
             请重写 parentViewController 的'shouldAutomaticallyForwardAppearanceMethods'方法 并且返回NO
             当然如果你不做这个操作, 子控制器的生命周期方法将不会被正确的调用
             如果你仍然想利用子控制器的生命周期方法, 请使用'ZJScrollPageViewChildVcDelegate'提供的代理方法
             或者'ZJScrollPageViewDelegate'提供的代理方法
             */

        }
        [self commonInit];
        [self addNotification];
    }
    return self;
}

/**
 创建（重置）所有的子控件、属性赋值
 */
- (void)commonInit {
    _oldIndex = -1;
    _currentIndex = 0;
    _oldOffSetX = 0.0f;
    _forbidTouchToAdjustPosition = NO;
    _isFirstLoadView = YES;
    // 获取子控制器的个数
    if ([self.delegate respondsToSelector:@selector(numberOfChildViewControllers)]) {
        self.itemsCount = [self.delegate numberOfChildViewControllers];
    }
    
    [self addSubview:self.collectionView];
    // 获取导航控制器(父控制器（pageController）的父控制器)
    UINavigationController *navigation = (UINavigationController *)self.parentViewController.parentViewController;
    
    if ([navigation isKindOfClass:[UINavigationController class]]) {
        // 如果导航控制器上只有一个控制器，说明就是子控制器
        if (navigation.viewControllers.count == 1) {
            return;
        }
        // 支持右滑返回上一层
        if (navigation.interactivePopGestureRecognizer) {
            __weak typeof(self) weakSelf = self;
            [self.collectionView setupScrollViewShouldBeginPanGesture:^BOOL(JWCollectionView *collectionView, UIPanGestureRecognizer *panGesture) {
                //获取手势滑动的 X 的距离
                CGFloat transionX = [panGesture translationInView:panGesture.view].x;
                // 如果是从页面最左边边缘开始滑动，说明是侧滑返回，否则是向上一个标签
                if (collectionView.contentOffset.x <= 5 && transionX > 0) {
                    // 可以侧滑返回
                    navigation.interactivePopGestureRecognizer.enabled = YES;
                }
                else {
                    // 不可以返回
                    navigation.interactivePopGestureRecognizer.enabled = NO;
                }
                
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(scrollPageController:contentScrollView:shouldBeginPanGesture:)]) {
                    [weakSelf.delegate scrollPageController:weakSelf.parentViewController contentScrollView:collectionView shouldBeginPanGesture:panGesture];
                }
                else {
                    return YES;
                }
                return YES;
            }];
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.currentController) {
        self.currentController.view.frame = self.bounds;
    }
}

- (void)dealloc {
    self.parentViewController = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - pubilc

- (void)setContentViewOffSet:(CGPoint)offset animated:(BOOL)animated {
    self.forbidTouchToAdjustPosition = YES;
    // 修改后的下标
    NSInteger   currentIndex = offset.x / self.collectionView.width;
    _oldIndex = _currentIndex;
    self.currentIndex = currentIndex;
    _changeAnimated = YES;
    
    if (animated) {
        CGFloat delta = offset.x - self.collectionView.contentOffset.x;
        // 需要滚动的页数
        NSInteger page = fabs(delta) / self.collectionView.width;
        // 需要滚动的距离超过 2 页时候，跳过中间动画
        if (page > 2) {
            _changeAnimated = NO;
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (strongSelf) {
                    [strongSelf.collectionView setContentOffset:offset animated:NO];
                }
            });
        }
        else {
            [self.collectionView setContentOffset:offset animated:animated];
        }
    }
    else {
        [self.collectionView setContentOffset:offset animated:animated];
    }
}

- (void)reload {
    // 遍历存储子控制器的字典,移除所有子控制器
    [self.childVCDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, UIViewController<JWScrollPageChildVCDelegate> * _Nonnull obj, BOOL * _Nonnull stop) {
        [JWContentView removeChildVc:obj];
        obj = nil;
    }];
    self.childVCDict = nil;
    [self.collectionView reloadData];
    // 重置属性和数据
    [self commonInit];
}

#pragma mark private 

/**
 将 contentView 从下标 1 移动到下标 2

 @param fromIndex 起始下标
 @param toIndex 目标下标
 @param progress 移动进度
 */
- (void)contentViewDidMoveFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress {
    if (self.segmentView) {
        [self.segmentView adjustUIWithProgress:progress oldIndex:fromIndex currentIndex:toIndex];
    }
}

/**
 segement 移动到指定下标

 @param index 指定下标
 */
- (void)adjustSegmentTagOffSetToCurrentIndex:(NSInteger)index {
    if (self.segmentView) {
        [self.segmentView adjustTagOffSetToCurrentIndex:index];
    }
}

-(void)willAppearWithIndex:(NSInteger)index {
    UIViewController<JWScrollPageChildVCDelegate> *controller = [self.childVCDict valueForKey:[NSString stringWithFormat:@"%ld", index]];
    if (controller) {
        if ([controller respondsToSelector:@selector(jw_viewWillAppearForIndex:)]) {
            [controller jw_viewWillAppearForIndex:index];
        }
        if (_needManageLifeCycle) {
            [controller beginAppearanceTransition:YES animated:NO];
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(scrollPageController:childViewControllerWillAppear:forIndex:)]) {
            [self.delegate scrollPageController:self.parentViewController childViewControllerWillAppear:controller forIndex:index];
        }
    }
}

- (void)didAppearWithIndex:(NSInteger)index {
    UIViewController<JWScrollPageChildVCDelegate> *controller = [self.childVCDict valueForKey:[NSString stringWithFormat:@"%ld", index]];
    if (controller) {
        if ([controller respondsToSelector:@selector(jw_viewDidAppearForIndex:)]) {
            [controller jw_viewDidAppearForIndex:index];
        }
        
        if (_needManageLifeCycle) {
            [controller endAppearanceTransition];
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(scrollPageController:childViewControllerDidAppear:forIndex:)]) {
            [self.delegate scrollPageController:self.parentViewController childViewControllerDidAppear:controller forIndex:index];
        }
    }
}

- (void)willDisAppearWithIndex:(NSInteger)index {
    UIViewController<JWScrollPageChildVCDelegate> *controller = [self.childVCDict valueForKey:[NSString stringWithFormat:@"%ld", index]];
    if (controller) {
        if ([controller respondsToSelector:@selector(jw_viewWillDisAppearForIndex:)]) {
            [controller jw_viewWillDisAppearForIndex:index];
        }
        if (_needManageLifeCycle) {
            [controller beginAppearanceTransition:NO animated:NO];
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(scrollPageController:childViewControllerWillDisAppear:forIndex:)]) {
            [self.delegate scrollPageController:self.parentViewController childViewControllerWillDisAppear:controller forIndex:index];
        }
    }
}

- (void)didDisAppearWithIndex:(NSInteger)index {
    UIViewController<JWScrollPageChildVCDelegate> *controller = [self.childVCDict valueForKey:[NSString stringWithFormat:@"%ld", index]];
    if (controller) {
        if ([controller respondsToSelector:@selector(jw_viewDidDisAppearForIndex:)]) {
            [controller jw_viewDidDisAppearForIndex:index];
        }
        
        if (_needManageLifeCycle) {
            [controller endAppearanceTransition];
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(scrollPageController:childViewControllerDidDisAppear:forIndex:)]) {
            [self.delegate scrollPageController:self.parentViewController childViewControllerDidDisAppear:controller forIndex:index];
        }
    }
}

#pragma mark - UIScrollViewDelegate 

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.forbidTouchToAdjustPosition) {
        return;
    }
    if (scrollView.contentOffset.x <= 0) {
        return;
    }
    if (scrollView.contentOffset.x >= scrollView.contentSize.width - scrollView.width) {
        return;
    }
    CGFloat tempProgress = scrollView.contentOffset.x / self.bounds.size.width;
    NSInteger tempIndex = tempProgress;
    
    CGFloat progress = tempProgress - floor(tempProgress);
    CGFloat deltaX = scrollView.contentOffset.x - _oldOffSetX;
    
    if (deltaX > 0) {// 向右
        if (progress == 0.0) {
            return;
        }
        self.currentIndex = tempIndex+1;
        self.oldIndex = tempIndex;
    }
    else if (deltaX < 0) {
        progress = 1.0 - progress;
        self.oldIndex = tempIndex+1;
        self.currentIndex = tempIndex;
    }
    else {
        return;
    }
    
    [self contentViewDidMoveFromIndex:_oldIndex toIndex:_currentIndex progress:progress];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _oldOffSetX = scrollView.contentOffset.x;
    self.forbidTouchToAdjustPosition = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 滚动减速的时候再更新标签位置
    NSInteger currentIndex = (scrollView.contentOffset.x / self.width);
    [self adjustSegmentTagOffSetToCurrentIndex:currentIndex];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    UINavigationController *nav = (UINavigationController *)self.parentViewController.parentViewController;
    if ([nav isKindOfClass:[UINavigationController class]] && nav.interactivePopGestureRecognizer) {
        nav.interactivePopGestureRecognizer.enabled = YES;
    }
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.itemsCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionCellID forIndexPath:indexPath];
    //移除 cell 的 subviews ，避免复用的时候出现错误
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    _currentController = [self.childVCDict valueForKey:[NSString stringWithFormat:@"%ld", indexPath.row]];
    // 如果子控制器为空，说明第一次加载
    BOOL isFirstLoad = _currentController == nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(childViewController:forIndex:)]) {
        // 子控制器为 nil ，就创建
        if (_currentController == nil) {
            _currentController = [self.delegate childViewController:nil forIndex:indexPath.row];
            if (!_currentController || ![_currentController conformsToProtocol:@protocol(JWScrollPageChildVCDelegate)]) {
                NSAssert(NO, @"子控制器必须遵守JWScrollPageChildVCDelegate协议");
            }
            
            _currentController.scrollCurrentIndex = indexPath.row;
            [self.childVCDict setValue:_currentController forKey:[NSString stringWithFormat:@"%ld", indexPath.row]];
        }
        else {
            [self.delegate childViewController:_currentController forIndex:indexPath.row];
        }
    }
    else {
        NSAssert(NO, @"必须设置代理和实现代理方法");
    }
    // 建立子控制器和父控制器的关系
    if ([_currentController isKindOfClass:[UINavigationController class]]) {
        NSAssert(NO, @"不要添加UINavigationController包装后的子控制器");
    }
    // 当子控制器 的父控制器不是当前view的控制器
    if (_currentController.scrollPageController != self.parentViewController) {
        // 把子控制器添加到父控制器上
        [self.parentViewController addChildViewController:_currentController];
    }
    
    _currentController.view.frame = self.bounds;
    [cell.contentView addSubview:_currentController.view];
    [_currentController didMoveToParentViewController:self.parentViewController];
    
    if (_isFirstLoadView) {
        if (self.forbidTouchToAdjustPosition && !_changeAnimated) {
            [self willAppearWithIndex:_currentIndex];
            if (isFirstLoad) {
                if ([_currentController respondsToSelector:@selector(jw_viewDidLoadForIndex:)]) {
                    [_currentController jw_viewDidLoadForIndex:_currentIndex];
                }
            }
            [self didAppearWithIndex:_currentIndex];
            
        }
        else {
            [self willAppearWithIndex:indexPath.row];
            if (isFirstLoad) {
                if ([_currentController respondsToSelector:@selector(jw_viewDidLoadForIndex:)]) {
                    [_currentController jw_viewDidLoadForIndex:indexPath.row];
                }
            }
            [self didAppearWithIndex:indexPath.row];
        }
        _isFirstLoadView = NO;
    }
    else {
        if (self.forbidTouchToAdjustPosition && !_changeAnimated) {
            [self willAppearWithIndex:_currentIndex];
            if (isFirstLoad) {
                if ([_currentController respondsToSelector:@selector(jw_viewDidLoadForIndex:)]) {
                    [_currentController jw_viewDidLoadForIndex:indexPath.row];
                }
            }
            [self didAppearWithIndex:_currentIndex];
        }
        else {
            [self willAppearWithIndex:indexPath.row];
            if (isFirstLoad) {
                if ([_currentController respondsToSelector:@selector(jw_viewDidLoadForIndex:)]) {
                    [_currentController jw_viewDidLoadForIndex:indexPath.row];
                }
            }
            [self willDisAppearWithIndex:_oldIndex];
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_currentIndex == indexPath.row) {
        // 滚动还没完成
        if (_needManageLifeCycle) {
            UIViewController<JWScrollPageChildVCDelegate> *currentVc = [self.childVCDict valueForKey:[NSString stringWithFormat:@"%ld", _currentIndex]];
            // 开始出现
            [currentVc beginAppearanceTransition:YES animated:NO];
            
            UIViewController<JWScrollPageChildVCDelegate> *oldVc = [self.childVCDict valueForKey:[NSString stringWithFormat:@"%ld", indexPath.row]];
            [oldVc beginAppearanceTransition:NO animated:NO];
            
        }
        [self didAppearWithIndex:_currentIndex];
        [self didDisAppearWithIndex:indexPath.row];
    }
    else {
        if (_oldIndex == indexPath.row) {
            // 滚动完成
            if (self.forbidTouchToAdjustPosition &&!_changeAnimated) {
                [self willDisAppearWithIndex:_oldIndex];
                [self didDisAppearWithIndex:_oldIndex];
            }
            else {
                [self didAppearWithIndex:_currentIndex];
                [self didDisAppearWithIndex:indexPath.row];
            }
        }
        else {
            // 滚动没有完成，又快速反向滑动活点击
            if (_needManageLifeCycle) {
                UIViewController<JWScrollPageChildVCDelegate> *currentVc = [self.childVCDict valueForKey:[NSString stringWithFormat:@"%ld", _oldIndex]];
                // 开始出现
                [currentVc beginAppearanceTransition:YES animated:NO];
                UIViewController<JWScrollPageChildVCDelegate> *oldVc = [self.childVCDict valueForKey:[NSString stringWithFormat:@"%ld", indexPath.row]];
                // 开始消失
                [oldVc beginAppearanceTransition:NO animated:NO];
            }
            [self didAppearWithIndex:_oldIndex];
            [self didDisAppearWithIndex:indexPath.row];
        }
    }
}

#pragma mark - setter getter

- (void)setCurrentIndex:(NSInteger)currentIndex {
    if (_currentIndex != currentIndex) {
        _currentIndex = currentIndex;
        if (self.segmentView.segmentStyle.isAdjustTagWhenBeginDrag) {
            [self adjustSegmentTagOffSetToCurrentIndex:currentIndex];
        }
    }
}

- (JWCollectionView *)collectionView {
    if (_collectionView == nil) {
        _collectionView = [[JWCollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.collectionViewLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.pagingEnabled = YES;
        _collectionView.scrollsToTop = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.bounces = self.segmentView.segmentStyle.isContentViewBounces;
        _collectionView.scrollEnabled = self.segmentView.segmentStyle.isScrollContentView;
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:collectionCellID];
        [self addSubview:_collectionView];
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)collectionViewLayout {
    if (_collectionViewLayout == nil) {
        _collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
        _collectionViewLayout.itemSize = self.bounds.size;
        _collectionViewLayout.minimumLineSpacing = 0;
        _collectionViewLayout.minimumInteritemSpacing = 0;
        _collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return _collectionViewLayout;
}

- (NSMutableDictionary<NSString *,UIViewController<JWScrollPageChildVCDelegate> *> *)childVCDict {
    if (_childVCDict == nil) {
        _childVCDict = [NSMutableDictionary dictionary];
    }
    return _childVCDict;
}

#pragma mark - memoryWarning

/**
 添加内存警告的通知
 */
- (void)addNotification {
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMemoryWarningHander:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

/**
 收到内存警告

 @param noti 内存警告通知
 */
- (void)receiveMemoryWarningHander:(NSNotificationCenter *)noti {
    
    __weak typeof(self) weakSelf = self;
    // 遍历存储子控制器的字典，移除非当前显示的子控制器
    [_childVCDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, UIViewController<JWScrollPageChildVCDelegate> * _Nonnull childVc, BOOL * _Nonnull stop) {
        __strong typeof(self) strongSelf = weakSelf;
        
        if (childVc != strongSelf.currentController) {
            [_childVCDict removeObjectForKey:key];
            [JWContentView removeChildVc:childVc];
        }
    }];
}

/**
 从父控制器上移除子控制，及子控制器的 view

 @param childVc 子控制器
 */
+ (void)removeChildVc:(UIViewController *)childVc {
    [childVc willMoveToParentViewController:nil];
    [childVc.view removeFromSuperview];
    [childVc removeFromParentViewController];
}


@end
