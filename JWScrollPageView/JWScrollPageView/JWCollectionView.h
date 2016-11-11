//
//  JWCollectionView.h
//  JWScrollPageView
//
//  Created by djw on 2016/11/10.
//  Copyright © 2016年 DJW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JWCollectionView : UICollectionView

/**
 平移手势的 block

 @param collectionView 手势所在的 clooectionView
 @param panGesture 手势
 @return 返回值
 */
typedef BOOL(^JWScrollViewShouldBeginPanGesturHandler)(JWCollectionView *collectionView, UIPanGestureRecognizer *panGesture);


/**
 获取已经实现的 block 回调

 @param gestureBeginHandler 手势的 block
 */
- (void)setupScrollViewShouldBeginPanGesture:(JWScrollViewShouldBeginPanGesturHandler)gestureBeginHandler;

@end
