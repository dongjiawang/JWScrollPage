//
//  UIViewController+jwScrollPageViewController.m
//  JWScrollPageView
//
//  Created by djw on 2016/11/10.
//  Copyright © 2016年 DJW. All rights reserved.
//

#import "UIViewController+jwScrollPageViewController.h"
#import "JWScrollPageViewDelegate.h"
#import <objc/runtime.h>

char    JWIndexKey;

@implementation UIViewController (jwScrollPageViewController)

- (UIViewController *)scrollPageController {
    UIViewController    *controller = nil;
    
    while (controller) {
        // 判断哪个控制器遵循这个协议，那么返回的就是这个控制的父控制器
        if ([controller conformsToProtocol:@protocol(JWScrollPageViewDelegate)]) {
            break;
        }
        controller = controller.parentViewController;
    }
    
    return controller;
}

- (void)setScrollCurrentIndex:(NSInteger)scrollCurrentIndex {
    // 利用 runtime 动态的给控制器添加 scrllCurrentIndex 的属性，这个属性对应的 key 为 JWIndexKey
    objc_setAssociatedObject(self, &JWIndexKey, [NSNumber numberWithInteger:scrollCurrentIndex], OBJC_ASSOCIATION_ASSIGN);
}

- (NSInteger)scrollCurrentIndex {
    // 获取 key为 JWIndexKey的动态添加的属性
    return [objc_getAssociatedObject(self, &JWIndexKey) integerValue];
}


@end
