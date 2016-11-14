//
//  JWScrollSegmentView.m
//  JWScrollPageView
//
//  Created by djw on 2016/11/9.
//  Copyright © 2016年 DJW. All rights reserved.
//

#import "JWScrollSegmentView.h"
#import "UIView+Frame.h"
#import "JWTagView.h"

@interface JWScrollSegmentView ()<UIScrollViewDelegate> {
    CGFloat     _currentWidth;//当前页面的宽度
    NSUInteger  _currentIndex; //当前显示标签的下标
    NSUInteger  _oldIndex; //上一个标签下标
}

/**
 滚动条
 */
@property (nonatomic, strong) UIView    *scrollLine;

/**
 遮盖
 */
@property (nonatomic, strong) UIView    *coverLayer;

/**
 底部滚动的 scrollView
 */
@property (nonatomic, strong) UIScrollView  *scrollView;

/**
 底部图片
 */
@property (nonatomic, strong) UIImageView   *backgroundImageView;

/**
 附加按钮
 */
@property (nonatomic, strong) UIButton  *extraBtn;

/**
 颜色渐变的时候的 RGB 差值
 */
@property (nonatomic, strong) NSArray   *deltaRGB;

/**
 选中标签的 RGB
 */
@property (nonatomic, strong) NSArray   *selectedRGB;

/**
 一般状态的 RGB
 */
@property (nonatomic, strong) NSArray   *normalRGB;

/**
 标签数据
 */
@property (nonatomic, strong) NSMutableArray    *tagViews;

/**
 记录所有标签的宽度
 */
@property (nonatomic, strong) NSMutableArray    *tagWidths;

/**
 点击标签
 */
@property (nonatomic, copy) TagBtnClicked   tagBtnClicked;

@end

@implementation JWScrollSegmentView

static CGFloat const xGap = 5.0; // 遮盖的横向间隔
static CGFloat const wGap = 2 * xGap; //间隔宽度
static CGFloat const contentSizeOff = 20.0;//scrollView 添加 20 的滚动范围

- (instancetype)initWithFrame:(CGRect)frame segementStyle:(JWTagStyle *)segementStyle delegate:(id<JWScrollPageViewDelegate>)delegate tagArray:(NSArray *)tagArray tagDidClicked:(TagBtnClicked)tagBtnClicked {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.segmentStyle = segementStyle;
        self.tagArray = tagArray;
        self.tagBtnClicked = tagBtnClicked;
        self.delegate = delegate;
        
        _currentIndex = 0;
        _oldIndex = 0;
        _currentWidth = frame.size.width;
        
        if (!self.segmentStyle.isScrollTitle) { // 不能滚动的时候就不要把缩放和遮盖或者滚动条同时使用
            self.segmentStyle.scaleTitle = !(self.segmentStyle.isShowCover || self.segmentStyle.isShowLine);
        }
        
        if (self.segmentStyle.isShowImage) { //不要有以下的显示效果
            self.segmentStyle.scaleTitle = NO;
            self.segmentStyle.showCover = NO;
            self.segmentStyle.gradualChangeTitleColor = NO;
        }
        
        [self setupSubviews];
        [self setUpUI];
    }
    
    return self;
}

#pragma mark - addSubviews
/**
 添加子控件
 */
- (void)setupSubviews {
    [self creatTagLabels];
    
    // 是否添加滚动条
    if (self.segmentStyle.isShowLine) {
        [self.scrollView addSubview:self.scrollLine];
    }
    // 是否添加遮盖
    if (self.segmentStyle.isShowCover) {
        [self.scrollView insertSubview:self.coverLayer atIndex:0];
        
    }
    // 是否添加附加按钮
    if (self.segmentStyle.isShowExtraButton) {
        [self addSubview:self.extraBtn];
    }
}

/**
 创建标签 label
 */
- (void)creatTagLabels {
    if (self.tagArray.count == 0) {
        return;
    }
    
    for (int index = 0; index < self.tagArray.count; index++) {
        JWTagView *tagView = [[JWTagView alloc] initWithFrame:CGRectZero];
        tagView.tag = index;
        tagView.font = self.segmentStyle.tagTitleFont;
        tagView.textColor = self.segmentStyle.normalTitleColor;
        tagView.text = [self.tagArray objectAtIndex:index];
        tagView.imagePosition = self.segmentStyle.imagePosition;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(setUpTagView:forIndex:)]) {
            [self.delegate setUpTagView:tagView forIndex:index];
        }
        // 给标签添加点击手势，模仿按钮点击
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagLabelClicked:)];
        [tagView addGestureRecognizer:tapGesture];
        //存储标签的宽度，只计算这一次
        CGFloat tagLabelWidth = [tagView tagViewWidth];
        [self.tagWidths addObject:@(tagLabelWidth)];
        // 存储标签
        [self.tagViews addObject:tagView];
        //添加 标签到 scrollview 上
        [self.scrollView addSubview:tagView];
    }
}

#pragma mark - load UI

/**
 设置整体的 UI
 */
- (void)setUpUI {
    if (self.tagArray.count == 0) {
        return;
    }
    
    [self setUpTagView];
    [self setUpScrollLineAndCover];
    
    if (self.segmentStyle.isScrollTitle) {
        JWTagView *lastTagView = (JWTagView *)self.tagViews.lastObject;
        if (lastTagView) {
            self.scrollView.contentSize = CGSizeMake(CGRectGetMaxX(lastTagView.frame) + contentSizeOff, 0);
        }
    }
}

#pragma mark - setUpTag
/**
 设置标签的 frame
 */
- (void)setUpTagView {
    CGFloat tagX = 0.0;
    CGFloat tagY = 0.0;
    CGFloat tagW = 0.0;
    CGFloat tagH = self.height - self.segmentStyle.scrollLineHeight;
    
    if (!self.segmentStyle.isScrollTitle) { // 标题不能滚动，平分宽度
        tagW = self.scrollView.width / self.tagViews.count;
        
        for (int index = 0; index < self.tagViews.count; index++) {
            tagX = index * tagW;
            JWTagView *tagView = [self.tagViews objectAtIndex:index];
            tagView.frame = CGRectMake(tagX, tagY, tagW, tagH);
            
            if (self.segmentStyle.isShowImage) {
                [tagView adjustSubviewFrame];
            }
        }
    }
    else {
        CGFloat lastTagMaxX = self.segmentStyle.tagMargin;//最后一个间隙
        CGFloat addMargin = 0.0; // 调整之后的标签间隔
        
        if (self.segmentStyle.isAdjustTagWidth) {
            // 自动调整标签宽度，计算所有标签宽度之和，判断是否需要增加标签间隔
            CGFloat allTagWidth = self.segmentStyle.tagMargin; // 默认是第一个间隔
            for (int i = 0; i < self.tagArray.count; i++) {
                allTagWidth = allTagWidth + [self.tagWidths[i] floatValue] + self.segmentStyle.tagMargin;
            }
            
            //当标签总宽度小于 scroll 宽度的时候添加）
            addMargin = allTagWidth < self.scrollView.width ? (self.scrollView.width - allTagWidth) / self.tagWidths.count : 0;
        }
        
        for (int index = 0; index < self.tagViews.count; index++) {
            tagW = [self.tagWidths[index] floatValue];
            tagX = lastTagMaxX + addMargin / 2;
            lastTagMaxX += (tagW + addMargin + self.segmentStyle.tagMargin);
            
            JWTagView *tagView = self.tagViews[index];
            tagView.frame = CGRectMake(tagX, tagY, tagW, tagH);
            
            if (self.segmentStyle.isShowImage) {
                [tagView adjustSubviewFrame];
            }
        }
        
        JWTagView *tagView = (JWTagView *)self.tagViews[_currentIndex];
        if (tagView) {
            tagView.selected = self.segmentStyle.isShowImage ? YES : NO;
            tagView.textColor = self.segmentStyle.selectedTitleColor;
            tagView.currentTransformSx = self.segmentStyle.isScaleTitle ? self.segmentStyle.tagScale : 1.0;
        }
    }
}

/**
 设置滚动条和遮盖
 */
- (void)setUpScrollLineAndCover {
    JWTagView *firstTag = (JWTagView *)self.tagViews[0];
    CGFloat coverX = firstTag.x;
    CGFloat coverW = firstTag.width;
    CGFloat coverH = self.segmentStyle.coverHeight;
    CGFloat coverY = (self.height - coverH) / 2;
    // 显示滚动条
    if (self.scrollLine) {
        // 如果是可以滚动标签
        if (self.segmentStyle.isScrollTitle) {
            // 自动调整滚动条宽度，从缓存中读取标签宽度,  不自动，则宽度为第一个标签
            self.scrollLine.frame = CGRectMake(coverX, self.height - self.segmentStyle.scrollLineHeight, coverW, self.segmentStyle.scrollLineHeight);
        }
        else {
            if (self.segmentStyle.isAdjustCoverOrLineWidth) {
                // 滚动条的宽度随着标签宽度改变
                coverW = [self.tagWidths[_currentIndex] floatValue];
                coverX = (firstTag.width - coverW) / 2;
            }
            self.scrollLine.frame = CGRectMake(coverX, self.height - self.segmentStyle.scrollLineHeight, coverW, self.segmentStyle.scrollLineHeight);
        }
    }
    // 显示遮盖
    if (self.coverLayer) {
        // 如果是可以滚动标签
        if (self.segmentStyle.isScrollTitle) {
            self.coverLayer.frame = CGRectMake(coverX - xGap, coverY, coverW + wGap, coverH);
            // 逻辑与滚动条类似
        }
        else {
            if (self.segmentStyle.isScrollTitle) {
                coverW = [self.tagWidths[_currentIndex] floatValue];
                coverX = (firstTag.width - coverW) / 2;
                self.coverLayer.frame = CGRectMake(coverX, coverY, coverW, coverH);
            }
            else {
                self.coverLayer.frame = CGRectMake(coverX - xGap, coverY, coverW + wGap, coverH);
            }
        }
    }
}

#pragma mark - 标签的点击、滑动
- (void)setSelectedIndex:(NSInteger)index animated:(BOOL)animated {
    
    if (index < 0 || index >= self.tagArray.count) {
        NSLog(@"标签下标数组越界");
        return;
    }
    
    _currentIndex = index;
    [self adjustUIWhenTagClickedWithAnimated:animated taped:NO];
}

/**
 更新标签的 UI

 @param animated 是否动画
 @param taped  是点击的标签
 */
- (void)adjustUIWhenTagClickedWithAnimated:(BOOL)animated taped:(BOOL)taped {
    if (_currentIndex == _oldIndex && taped) {
        // 如果两次点击的标签一样 （taped YES 是点击）
        return;
    }
    
    JWTagView *oldTagView = (JWTagView *)self.tagViews[_oldIndex];
    JWTagView *currentTagView = (JWTagView *)self.tagViews[_currentIndex];
    
    CGFloat animationDur = animated ? 0.3 : 0;
    
    __weak typeof(self) weakSelf = self;
    
    [UIView animateWithDuration:animationDur animations:^{
        // 更换文字颜色
        oldTagView.textColor = weakSelf.segmentStyle.normalTitleColor;
        currentTagView.textColor = weakSelf.segmentStyle.selectedTitleColor;
        // 更换选中状态
        oldTagView.selected = NO;
        currentTagView.selected = YES;
        // 更换缩放
        if (weakSelf.segmentStyle.isScaleTitle) {
            oldTagView.currentTransformSx = 1.0;
            currentTagView.currentTransformSx = weakSelf.segmentStyle.tagScale;
        }
        
        // 更换滚动条或者遮盖状态
        // 如果是滚动标签 或者 不是自动设置滚动条和遮盖的宽度，则滚动条和遮盖宽度是标签的宽度
        if (weakSelf.segmentStyle. isScrollTitle || !weakSelf.segmentStyle.isAdjustCoverOrLineWidth) {
            if (weakSelf.scrollLine) {
                weakSelf.scrollLine.x = currentTagView.x;
                weakSelf.scrollLine.width = currentTagView.width;
            }
            if (weakSelf.coverLayer) {
                weakSelf.coverLayer.x = currentTagView.x - xGap;
                weakSelf.coverLayer.width = currentTagView.width + wGap;
            }
        }
        else{
            if (weakSelf.scrollLine) {
                CGFloat scrollLineW = [self.tagWidths[_currentIndex] floatValue] + xGap;
                CGFloat scrollLineX= currentTagView.x + (currentTagView.width - scrollLineW) / 2;
                weakSelf.scrollLine.x = scrollLineX;
                weakSelf.scrollLine.width = scrollLineW;
            }
            if (weakSelf.coverLayer) {
                CGFloat coverW = [self.tagWidths[_currentIndex] floatValue] + wGap;
                CGFloat coverX = currentTagView.x + (currentTagView.width - coverW) * 0.5;
                weakSelf.coverLayer.x = coverX;
                weakSelf.coverLayer.width = coverW;
            }
            
        }
        
    } completion:^(BOOL finished) {
        [weakSelf adjustTagOffSetToCurrentIndex:_currentIndex];
    }];
    
    // 调用标签点击的 block
    if (self.tagBtnClicked) {
        self.tagBtnClicked(currentTagView, _currentIndex);
    }
}

- (void)adjustUIWithProgress:(CGFloat)progress oldIndex:(NSInteger)oldIndex currentIndex:(NSInteger)currentIndex {
    if (oldIndex  < 0) {
        return;
    }
    if (oldIndex >= self.tagViews.count) {
        return;
    }
    if (currentIndex < 0) {
        return;
    }
    if (currentIndex >= self.tagViews.count) {
        return;
    }
    
    _oldIndex = currentIndex;
    
    JWTagView *oldTagView = (JWTagView *)self.tagViews[oldIndex];
    JWTagView *currentTagView = (JWTagView *)self.tagViews[currentIndex];
    // X 和 宽度 的差值
    CGFloat distanceX = currentTagView.x - oldTagView.x;
    CGFloat distanceW = currentTagView.width - oldTagView.width;
    // 更换滚动条或者遮盖状态
    // 如果是滚动标签 或者 不是自动设置滚动条和遮盖的宽度，滚动条和遮盖宽度是标签的宽度。否则计算差值
    if (self.segmentStyle.isScrollTitle || !self.segmentStyle.isAdjustCoverOrLineWidth) {
        if (self.scrollLine) {
            self.scrollLine.x  = oldTagView.x + distanceX * progress;
            self.scrollLine.width = oldTagView.width + distanceW * progress;
        }
        if (self.coverLayer) {
            self.coverLayer.x = oldTagView.x + distanceX * progress;
            self.coverLayer.width = oldTagView.width + distanceW * progress;
        }
    }
    else {
        CGFloat oldW = [self.tagWidths[oldIndex] floatValue] + wGap;
        CGFloat currentW = [self.tagWidths[currentIndex] floatValue] + wGap;
        distanceW = currentW - oldW;
        
        CGFloat oldX = oldTagView.x + (oldTagView.width - oldW) * 0.5;
        CGFloat currentX = currentTagView.x + (currentTagView.width - currentW) * 0.5;
        distanceX = currentX - oldX;
        if (self.scrollLine) {
            self.scrollLine.x = oldX + distanceX * progress;
            self.scrollLine.width = oldW + distanceW * progress;
        }
        
        if (self.coverLayer) {
            self.coverLayer.x = oldX + distanceX * progress;
            self.coverLayer.width = oldW + distanceW * progress;
        }
    }
    
    // 渐变色
    if (self.segmentStyle.isGradualChangeTitleColor) {
        // 旧的颜色从选中渐变为正常
        oldTagView.textColor = [UIColor colorWithRed:[self.selectedRGB[0] floatValue] + [self.deltaRGB[0] floatValue] * progress
                                               green:[self.selectedRGB[1] floatValue] + [self.deltaRGB[1] floatValue] * progress
                                                blue:[self.selectedRGB[2] floatValue] + [self.deltaRGB[2] floatValue] * progress
                                               alpha:1.0];
        // 选中的标签从 正常渐变为 选中
        currentTagView.textColor = [UIColor colorWithRed:[self.normalRGB[0] floatValue] - [self.deltaRGB[0] floatValue] * progress
                                                   green:[self.normalRGB[1] floatValue] - [self.deltaRGB[1] floatValue] * progress
                                                    blue:[self.normalRGB[2] floatValue] - [self.deltaRGB[2] floatValue] * progress
                                                   alpha:1.0];
        
    }
    // 缩放状态的改变
    if (self.segmentStyle.isScaleTitle) {
        CGFloat deltaScale = self.segmentStyle.tagScale - 1.0;
        oldTagView.currentTransformSx = self.segmentStyle.tagScale - deltaScale * progress;
        currentTagView.currentTransformSx = 1.0 + deltaScale * progress;
    }
}

- (void)adjustTagOffSetToCurrentIndex:(NSInteger)currentIndex {
    _oldIndex = currentIndex;
    // 重置标签的颜色、缩放等等
    for (int index = 0; index < self.tagViews.count; index++) {
        JWTagView *tagView = (JWTagView *)self.tagViews[index];
        if (index == currentIndex) {
            tagView.textColor = self.segmentStyle.selectedTitleColor;
            if (self.segmentStyle.isScaleTitle) {
                tagView.currentTransformSx = self.segmentStyle.tagScale;
            }
            tagView.selected = YES;
        }
        else {
            tagView.textColor = self.segmentStyle.normalTitleColor;
            if (self.segmentStyle.isScaleTitle) {
                tagView.currentTransformSx = 1.0;
            }
            tagView.selected = NO;
        }
    }
    // scroll 的滚动范围与宽度不一致，需要滚动
    if (self.scrollView.contentSize.width != self.scrollView.width + contentSizeOff) {
        JWTagView *currentTagView = (JWTagView *)self.tagViews[currentIndex];
        
        CGFloat offSetX = currentTagView.centerX - _currentWidth / 2;
        offSetX = offSetX < 0 ? 0 : offSetX;
        
        CGFloat extraBtnW = self.extraBtn ? self.extraBtn.width : 0;
        CGFloat maxoffSetX = self.scrollView.contentSize.width - (_currentWidth - extraBtnW);
        
        maxoffSetX = maxoffSetX < 0 ? 0 : maxoffSetX;
        
        offSetX = offSetX > maxoffSetX ? maxoffSetX : offSetX;
        
        // 将 scrollView 滚动到标签位置
        [self.scrollView setContentOffset:CGPointMake(offSetX, 0) animated:YES];
    }
}

- (void)reloadTagsWithNewTagArray:(NSArray *)tagArray {
    [self.scrollView removeAllSubViews];
    [self removeAllSubViews];
    
    self.tagArray = nil;
    self.tagWidths = nil;
    self.tagViews = nil;
    self.tagArray = [tagArray copy];
    if (self.tagArray.count == 0) {
        return;
    }
    
    [self setupSubviews];
    [self setUpUI];
    [self setSelectedIndex:0 animated:YES];
}

#pragma mark - button action

- (void)tagLabelClicked:(UITapGestureRecognizer *)gesture {
    JWTagView *currentLabel = (JWTagView *)gesture.view;
    if (currentLabel == nil) {
        return;
    }
    
    _currentIndex = currentLabel.tag;

    // 根据点击的 label 自动调整标签页的布局
    [self adjustUIWhenTagClickedWithAnimated:YES taped:YES];
}

- (void)extraButtonClicked:(UIButton *)extraBtn {
    if (self.extraBtnBlock) {
        self.extraBtnBlock(extraBtn);
    }
}


#pragma mark - setter getter

- (UIView *)scrollLine {
    if (!self.segmentStyle.isShowLine) {
        return nil;
    }
    
    if (_scrollLine == nil) {
        _scrollLine = [[UIView alloc] init];
        _scrollLine.backgroundColor = self.segmentStyle.scrollLineColor;
    }
    return _scrollLine;
}

- (UIView *)coverLayer {
    if (!self.segmentStyle.isShowCover) {
        return nil;
    }
    
    if (_coverLayer == nil) {
        _coverLayer = [[UIView alloc] init];
        _coverLayer.backgroundColor = self.segmentStyle.coverColor;
        _coverLayer.layer.cornerRadius = self.segmentStyle.coverRadius;
        _coverLayer.layer.masksToBounds = YES;
    }
    return _coverLayer;
}

- (UIButton *)extraBtn {
    if (!self.segmentStyle.isShowExtraButton) {
        return nil;
    }
    if (_extraBtn == nil) {
        _extraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _extraBtn.frame = CGRectMake((_currentWidth - 44.0), 5, 44.0, 34.0);
        NSString *imageName = self.segmentStyle.extraBackgroundImageName ? self.segmentStyle.extraBackgroundImageName : @"";
        [_extraBtn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        _extraBtn.backgroundColor = [UIColor whiteColor];
        // 阴影
        _extraBtn.layer.shadowColor = [UIColor whiteColor].CGColor;
        _extraBtn.layer.shadowOffset = CGSizeMake(-5, 0);
        _extraBtn.layer.shadowOpacity = 1;
        
    }
    return _extraBtn;
}

- (UIScrollView *)scrollView {
    if (_scrollView == nil) {
        CGRect scrollRecgt;
        if (self.segmentStyle.isShowExtraButton) {
            scrollRecgt = CGRectMake(0.0, 0.0, (_currentWidth - 44.0), self.height);
        }
        else {
            scrollRecgt = CGRectMake(0.0, 0.0, _currentWidth, self.height);
        }
        
        _scrollView = [[UIScrollView alloc] initWithFrame:scrollRecgt];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.scrollsToTop = NO;
        _scrollView.bounces = self.segmentStyle.isTagBounces;
        _scrollView.pagingEnabled = NO;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    return _scrollView;
}

- (UIImageView *)backgroundImageView {
    if (_backgroundImageView == nil) {
        _backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self insertSubview:_backgroundImageView atIndex:0];
    }
    return _backgroundImageView;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    _backgroundImage = backgroundImage;
    if (backgroundImage) {
        self.backgroundImageView.image = backgroundImage;
    }
}

- (NSMutableArray *)tagViews {
    if (_tagViews == nil) {
        _tagViews = [NSMutableArray array];
    }
    return _tagViews;
}

- (NSMutableArray *)tagWidths {
    if (_tagWidths == nil) {
        _tagWidths = [NSMutableArray array];
    }
    return _tagWidths;
}

- (NSArray *)deltaRGB {
    if (_deltaRGB == nil) {
        NSArray *normalColor = self.normalRGB;
        NSArray *selectedColor = self.selectedRGB;
        
        if (normalColor && selectedColor) {
            CGFloat deltaR = [normalColor[0] floatValue] - [selectedColor[0] floatValue];
            CGFloat deltaG = [normalColor[1] floatValue] - [selectedColor[1] floatValue];
            CGFloat deltaB = [normalColor[2] floatValue] - [selectedColor[2] floatValue];
            _deltaRGB = [NSArray arrayWithObjects:@(deltaR), @(deltaG), @(deltaB), nil];
        }
    }
    return _deltaRGB;
}

- (NSArray *)normalRGB {
    if (_normalRGB == nil) {
        _normalRGB = [self getRGBfromColor:self.segmentStyle.normalTitleColor];
        NSAssert(_normalRGB, @"请使用RGB 颜色值");
    }
    return _normalRGB;
}

- (NSArray *)selectedRGB {
    if (_selectedRGB == nil) {
        _selectedRGB = [self getRGBfromColor:self.segmentStyle.selectedTitleColor];
        NSAssert(_selectedRGB, @"请使用RGB 颜色值");
    }
    return _selectedRGB;
}

/**
 从UIColor 中获取 RGB 值

 @param color UIColor
 @return rgb 值
 */
- (NSArray *)getRGBfromColor:(UIColor *)color {
    CGFloat numOfComponents = CGColorGetNumberOfComponents(color.CGColor);
    NSArray *rgbArray = nil;
    if (numOfComponents == 4) {
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        rgbArray = [NSArray arrayWithObjects:@(components[0]), @(components[1]), @(components[2]), nil];
    }
    return rgbArray;
}

@end
