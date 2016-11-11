//
//  UIViewController+jwScrollPageViewController.h
//  JWScrollPageView
//
//  Created by djw on 2016/11/10.
//  Copyright © 2016年 DJW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (jwScrollPageViewController)

/**
 所有子控制的父控制器，方便子控制器获取父控制器，可以进行页面的操作
 */
@property (nonatomic, weak, readonly) UIViewController  *scrollPageController;

/**
 控制对应的标签的下标
 */
@property (nonatomic, assign) NSInteger     scrollCurrentIndex;

@end
