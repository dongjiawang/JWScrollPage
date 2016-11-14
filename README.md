

# JWScrollPageView
![普通滚动条](/demoImage/2016-11-14-JWScrollPage-0.gif)

![缩放滚动条](/demoImage/2016-11-14-JWScrollPage-1.gif)

![有缩放的遮盖](/demoImage/2016-11-14-JWScrollPage-2.gif)

![有文字渐变色的遮盖](/demoImage/2016-11-14-JWScrollPage-3.gif)

![有文字渐变色的滚动条](/demoImage/2016-11-14-JWScrollPage-4.gif)

>JWTagStyle 
> 标签样式的类，
> 是否滚动条、是否遮盖、缩放，文字颜色等等

```objectivec
/**
 是否显示遮盖 默认为 NO
 */
@property (nonatomic, assign, getter=isShowCover) BOOL      showCover;

/**
 是否显示滚动条 默认为 NO
 */
@property (nonatomic, assign, getter=isShowLine) BOOL       showline;

/**
 是否显示图片 默认为 NO
 */
@property (nonatomic, assign, getter=isShowImage) BOOL      showImage;

/**
 是否显示附加按钮 默认为 NO
 */
@property (nonatomic, assign, getter=isShowExtraButton) BOOL    showExtraButton;

/**
 是否缩放标签文字 默认为 NO
 */
@property (nonatomic, assign, getter=isScaleTitle) BOOL    scaleTitle;

/**
 是否滚动标签文字 默认为 YES
 设置为 NO 的时候所有标签不再滚动，并且宽度平分
 建议如果标签数目少，整体不会超过屏幕宽度的时候设置为 NO
 */
@property (nonatomic, assign, getter=isScrollTitle) BOOL    scrollTitle;

/**
 是否有弹性 默认为 YES
 */
@property (nonatomic, assign, getter=isTagBounces) BOOL     tagBounces;

/**
 contentView 是否有弹性 默认为 NO
 */
@property (nonatomic, assign, getter=isContentViewBounces) BOOL     contentViewBounces;

/**
 是否渐变颜色 默认为 NO
 */
@property (nonatomic, assign, getter=isGradualChangeTitleColor) BOOL    gradualChangeTitleColor;

/**
 是否可以滑动页面 默认为 YES
 */
@property (nonatomic, assign, getter=isScrollContentView) BOOL      scrollContentView;

/**
 点击标签切换页面的时候是否有动画 默认为 YES
 */
@property (nonatomic, assign, getter=isAnimatedSwitchPageWhenTagClicked) BOOL   animatedSwitchPageWhenTagClicked;

/**
 当标签的宽度小于 scrllView 的宽度时候是否平分宽度  默认为 NO
 */
@property (nonatomic, assign, getter=isAdjustTagWidth) BOOL     adjustTagWidth;

/**
 是否开始滚动的时候调整标签 默认为 NO
 */
@property (nonatomic, assign, getter=isAdjustTagWhenBeginDrag) BOOL     adjustTagWhenBeginDrag;

/**
 是否自动调整遮盖或者滚动条的宽度
 */
@property (nonatomic, assign, getter=isAdjustCoverOrLineWidth) BOOL     adjustCoverAndLineWidth;

/**
 附加按钮背景图片 默认为 nil
 */
@property (nonatomic, strong) NSString      *extraBackgroundImageName;

/**
 滚动条高度 默认为 2
 */
@property (nonatomic, assign) CGFloat       scrollLineHeight;

/**
 滚动条颜色 默认为 redColor
 */
@property (nonatomic, strong) UIColor       *scrollLineColor;

/**
 遮盖的颜色
 */
@property (nonatomic, strong) UIColor       *coverColor;

/**
 遮盖的圆角 默认为 14
 */
@property (nonatomic, assign) CGFloat       coverRadius;

/**
 遮盖高度 默认为 28
 */
@property (nonatomic, assign) CGFloat       coverHeight;

/**
 标签的间隔 默认为 15
 */
@property (nonatomic, assign) CGFloat       tagMargin;

/**
 字体 默认为 14
 */
@property (nonatomic, strong) UIFont        *tagTitleFont;

/**
 标签缩放倍数 默认为 1.3
 */
@property (nonatomic, assign) CGFloat       tagScale;

/**
 一般状态的文字颜色
 */
@property (nonatomic, strong) UIColor       *normalTitleColor;

/**
 选中状态文字颜色
 */
@property (nonatomic, strong) UIColor       *selectedTitleColor;

/**
 标签 view 的高度 默认为 44
 */
@property (nonatomic, assign) CGFloat       tagViewHeight;

/**
 标签图片位置 显示图片的时候再设置
 */
@property (nonatomic, assign) TagImagePosotion      imagePosition;
```

# demo

## 外部一个控制器，包含标签页和各个标签的子控制器##

```objectivec
self.tagArray = @[@"标题 1",
                      @"标题 2",
                      @"标题 3",
                      @"标题 4",
                      @"标题 5",
                      @"标题 6",
                      @"标题 7",
                      @"标题 8",
                      @"标题 9"
                      ];
    
    JWScrollPageView *scrollPageView = [[JWScrollPageView alloc] initWithFrame:CGRectMake(0, 64, self.view.width, self.view.height - 64) segmentStyle:self.tagStyle tagArray:self.tagArray parentController:self delegate:self];
    [self.view addSubview:scrollPageView];

```

##重写这个方法。并返回 NO ，这样所有子控制器的 view 的生命周期方法会被正确调用##
```objectivec
- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
    return NO;
}
```

## 返回标签和子控制器的个数##

```objectivec
- (NSInteger)numberOfChildViewControllers {
    return self.tagArray.count;
}
```

## 获取或生成对应标签下标的子控制器##

```objectivec
- (UIViewController<JWScrollPageChildVCDelegate> *)childViewController:(UIViewController<JWScrollPageChildVCDelegate> *)childViewController forIndex:(NSInteger)index {
    
    UIViewController<JWScrollPageChildVCDelegate> *childVC = childViewController;
    if (childVC == nil) {
        if (index % 2 == 0) {
            //测试 tableview
            childVC = [[TestTableViewController alloc] init];
        }
        else {
            // 测试 collectionView
            childVC = [[TestCollectionViewController alloc] init];
        }
    }
    
    childVC.title = self.tagArray[index];
    return childVC;
}
```
