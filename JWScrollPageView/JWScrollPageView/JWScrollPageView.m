//
//  JWScrollPageView.m
//  JWScrollPageView
//
//  Created by djw on 2016/11/10.
//  Copyright © 2016年 DJW. All rights reserved.
//

#import "JWScrollPageView.h"

@interface JWScrollPageView ()

/**
 标签 style
 */
@property (nonatomic, strong) JWTagStyle    *tagStyle;

/**
 所属的控制器
 */
@property (nonatomic, weak)UIViewController     *parentController;

/**
 存储的子控制器
 */
@property (nonatomic, strong) NSArray   *childVCs;

/**
 标签数组
 */
@property (nonatomic, strong) NSArray   *tagArray;

@end

@implementation JWScrollPageView

- (instancetype)initWithFrame:(CGRect)frame segmentStyle:(JWTagStyle *)tagStyle tagArray:(NSArray<NSString *> *)tagArray parentController:(UIViewController *)parentController delegate:(id<JWScrollPageViewDelegate>)delegate {
    self = [super initWithFrame:frame];
    if (self) {
        self.tagStyle = tagStyle;
        self.delegate = delegate;
        self.parentController = parentController;
        self.tagArray = [tagArray copy];
        
        self.segmentView.backgroundColor = [UIColor whiteColor];
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

/** 给外界设置选中的下标的方法 */
- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated {
    [self.segmentView setSelectedIndex:selectedIndex animated:animated];
}

/**  给外界重新设置视图内容的标题的方法 */
- (void)reloadWithNewTitles:(NSArray<NSString *> *)newTitles {
    
    self.tagArray = nil;
    self.tagArray = [newTitles copy];
    
    [self.segmentView reloadTagsWithNewTagArray:self.tagArray];
    [self.contentView reload];
}

#pragma mark - setter getter

- (JWContentView *)contentView {
    if (_contentView == nil) {
        _contentView = [[JWContentView alloc] initWithFrame:CGRectMake(0, self.segmentView.height, self.width, self.height - self.segmentView.height) segmentView:self.segmentView parentViewController:self.parentController delegate:self.delegate];
        [self addSubview:_contentView];
    }
    return _contentView;
}

- (JWScrollSegmentView *)segmentView {
    if (_segmentView == nil) {
        __weak typeof(self) weakSelf = self;
        _segmentView = [[JWScrollSegmentView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.tagStyle.tagViewHeight) segementStyle:self.tagStyle delegate:self.delegate tagArray:self.tagArray tagDidClicked:^(JWTagView *tagView, NSInteger index) {
            [weakSelf.contentView setContentViewOffSet:CGPointMake(weakSelf.contentView.width * index, 0) animated:weakSelf.segmentView.segmentStyle.isAnimatedSwitchPageWhenTagClicked];
        }];
        [self addSubview:_segmentView];
    }
    return _segmentView;
}

- (NSArray *)childVCs {
    if (!_childVCs) {
        _childVCs = [NSArray array];
    }
    return _childVCs;
}

- (NSArray *)tagArray {
    if (!_tagArray) {
        _tagArray = [NSArray array];
    }
    return _tagArray;
}

- (void)setExtraBtnClicked:(extraBtnClicked)extraBtnClicked {
    _extraBtnClicked = extraBtnClicked;
    self.segmentView.extraBtnBlock = extraBtnClicked;
}
@end
