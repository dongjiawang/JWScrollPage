//
//  JWTagStyle.m
//  JWScrollPageView
//
//  Created by djw on 2016/11/9.
//  Copyright © 2016年 DJW. All rights reserved.
//

#import "JWTagStyle.h"

@implementation JWTagStyle

- (instancetype)init {
    self = [super init];
    if (self) {
        _showCover = NO;
        _showline = NO;
        _showImage = NO;
        _showExtraButton = NO;
        _scaleTitle = NO;
        _scrollTitle = YES;
        _tagBounces = YES;
        _contentViewBounces = NO;
        _gradualChangeTitleColor = NO;
        _scrollContentView = YES;
        _animatedSwitchPageWhenTagClicked = YES;
        _adjustTagWidth = NO;
        _adjustTagWhenBeginDrag = NO;
        _adjustCoverAndLineWidth = YES;
        _extraBackgroundImageName = nil;
        _scrollLineHeight = 2.0;
        _scrollLineColor = [UIColor redColor];
        _coverRadius = 14.0;
        _coverHeight = 28.0;
        _tagMargin = 15.0;
        _tagTitleFont = [UIFont systemFontOfSize:14.0];
        _tagScale = 1.3;
        _normalTitleColor =  [UIColor colorWithRed:51.0/255.0 green:53.0/255.0 blue:75/255.0 alpha:1.0];
        _selectedTitleColor = _selectedTitleColor = [UIColor colorWithRed:255.0/255.0 green:0.0/255.0 blue:121/255.0 alpha:1.0];
        _tagViewHeight = 44.0;
    }
    return self;
}


@end
