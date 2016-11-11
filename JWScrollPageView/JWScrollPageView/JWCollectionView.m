//
//  JWCollectionView.m
//  JWScrollPageView
//
//  Created by djw on 2016/11/10.
//  Copyright © 2016年 DJW. All rights reserved.
//

#import "JWCollectionView.h"

@interface JWCollectionView ()

@property (nonatomic, copy) JWScrollViewShouldBeginPanGesturHandler     gestureBeginHandler;

@end

@implementation JWCollectionView


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    // 如果手势的 block 已经实现，并且手势是在当前的 collectionView 上，就返回 block 的返回值
    if (_gestureBeginHandler && gestureRecognizer == self.panGestureRecognizer) {
        return _gestureBeginHandler(self, (UIPanGestureRecognizer *)gestureRecognizer);
    }
    else {
        return [super gestureRecognizerShouldBegin:gestureRecognizer];
    }
}

- (void)setupScrollViewShouldBeginPanGesture:(JWScrollViewShouldBeginPanGesturHandler)gestureBeginHandler {
    _gestureBeginHandler = [gestureBeginHandler copy];
}

@end
