//
//  ViewController.m
//  JWScrollPageView
//
//  Created by djw on 2016/11/9.
//  Copyright © 2016年 DJW. All rights reserved.
//

#import "ViewController.h"
#import "UIView+Frame.h"
#import "JWTagStyle.h"
#import "TestViewController.h"

@interface ViewController ()

@property (nonatomic, strong) JWTagStyle        *style;

@property (nonatomic, strong) UISwitch          *showCoverSwitch;
@property (nonatomic, strong) UISwitch          *showlineSwitch;
@property (nonatomic, strong) UISwitch          *showImageSwitch;
@property (nonatomic, strong) UISwitch          *showExtraButtonSwitch;
@property (nonatomic, strong) UISwitch          *scaleTitleSwitch;
@property (nonatomic, strong) UISwitch          *scrollTitleSwitch;
@property (nonatomic, strong) UISwitch          *tagBouncesSwitch;
@property (nonatomic, strong) UISwitch          *contentViewBouncesSwitch;
@property (nonatomic, strong) UISwitch          *gradualChangeTitleColorSwitch;
@property (nonatomic, strong) UISwitch          *scrollContentViewSwitch;
@property (nonatomic, strong) UISwitch          *animatedSwitchPageWhenTagClickedSwitch;
@property (nonatomic, strong) UISwitch          *adjustTagWidthSwitch;
@property (nonatomic, strong) UISwitch          *adjustTagWhenBeginDragSwitch;
@property (nonatomic, strong) UISwitch          *adjustCoverAndLineWidthSwitch;



@property (nonatomic, strong) UIScrollView      *backgroundScroll;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.style = [[JWTagStyle alloc] init];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"预览" style:UIBarButtonItemStyleDone target:self action:@selector(clickedButton)];
    
    self.backgroundScroll = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.backgroundScroll];
    
    NSArray<NSString *> *styleArray = @[@"遮盖",
                                        @"滚动条",
                                        @"显示图片",
                                        @"显示附加按钮",
                                        @"缩放文字",
                                        @"滚动文字",
                                        @"标签是否弹性",
                                        @"页面是否弹性",
                                        @"是否渐变色",
                                        @"页面是否滚动",
                                        @"切换页面动画",
                                        @"固定标签宽度",
                                        @"开始滚动时调整标签",
                                        @"自动调整滚动条宽度",
                                        ];
    
    [self initLabelWithStyleArray:styleArray];
    
    self.showCoverSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(260, 20, 44, 44)];
    self.showCoverSwitch.on = NO;
    [self.backgroundScroll addSubview:self.showCoverSwitch];
    
    self.showlineSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(260, 64, 44, 44)];
    self.showlineSwitch.on = YES;
    [self.backgroundScroll addSubview:self.showlineSwitch];
    
    self.showImageSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(260, 108, 44, 44)];
    self.showImageSwitch.on = NO;
    [self.backgroundScroll addSubview:self.showImageSwitch];
    
    self.showExtraButtonSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(260, 152, 44, 44)];
    self.showExtraButtonSwitch.on = NO;
    [self.backgroundScroll addSubview:self.showExtraButtonSwitch];
    
    self.scaleTitleSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(260, 196, 44, 44)];
    self.scaleTitleSwitch.on = NO;
    [self.backgroundScroll addSubview:self.scaleTitleSwitch];
    
    self.scrollTitleSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(260, 240, 44, 44)];
    self.scrollTitleSwitch.on = YES;
    [self.backgroundScroll addSubview:self.scrollTitleSwitch];
    
    self.tagBouncesSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(260, 284, 44, 44)];
    self.tagBouncesSwitch.on = YES;
    [self.backgroundScroll addSubview:self.tagBouncesSwitch];
    
    self.contentViewBouncesSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(260, 328, 44, 44)];
    self.contentViewBouncesSwitch.on = NO;
    [self.backgroundScroll addSubview:self.contentViewBouncesSwitch];
    
    self.gradualChangeTitleColorSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(260, 372, 44, 44)];
    self.gradualChangeTitleColorSwitch.on = NO;
    [self.backgroundScroll addSubview:self.gradualChangeTitleColorSwitch];

    self.scrollContentViewSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(260, 416, 44, 44)];
    self.scrollContentViewSwitch.on = YES;
    [self.backgroundScroll addSubview:self.scrollContentViewSwitch];
    
    self.animatedSwitchPageWhenTagClickedSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(260, 460, 44, 44)];
    self.animatedSwitchPageWhenTagClickedSwitch.on = YES;
    [self.backgroundScroll addSubview:self.animatedSwitchPageWhenTagClickedSwitch];
    
    self.adjustTagWidthSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(260, 504, 44, 44)];
    self.adjustTagWidthSwitch.on = NO;
    [self.backgroundScroll addSubview:self.adjustTagWidthSwitch];

    self.adjustTagWhenBeginDragSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(260, 548, 44, 44)];
    self.adjustTagWhenBeginDragSwitch.on = NO;
    [self.backgroundScroll addSubview:self.adjustTagWhenBeginDragSwitch];
    
    self.adjustCoverAndLineWidthSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(260, 588, 44, 44)];
    self.adjustCoverAndLineWidthSwitch.on = YES;
    [self.backgroundScroll addSubview:self.adjustCoverAndLineWidthSwitch];
    
    self.backgroundScroll.contentSize = CGSizeMake(0, 650);
}

- (void)initLabelWithStyleArray:(NSArray *)styleArray {
    if (styleArray.count <= 0) {
        return;
    }
    
    CGFloat labelY = 20;
    for (int i = 0; i < styleArray.count; i++) {
        NSString *str = styleArray[i];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, labelY, 250, 44)];
        label.textColor = [UIColor blackColor];
        label.text = str;
        [self.backgroundScroll addSubview:label];
        labelY += 44;
    }
}

- (void)clickedButton {
    
    self.style.showCover = self.showCoverSwitch.on;
    self.style.showline = self.showlineSwitch.on;
    self.style.showImage = self.showImageSwitch.on;
    self.style.showExtraButton = self.showExtraButtonSwitch.on;
    self.style.scaleTitle = self.scaleTitleSwitch.on;
    self.style.scrollTitle = self.scrollTitleSwitch.on;
    self.style.tagBounces = self.tagBouncesSwitch.on;
    self.style.contentViewBounces = self.contentViewBouncesSwitch.on;
    self.style.gradualChangeTitleColor = self.gradualChangeTitleColorSwitch.on;
    self.style.scrollContentView = self.scrollContentViewSwitch.on;
    self.style.animatedSwitchPageWhenTagClicked = self.animatedSwitchPageWhenTagClickedSwitch.on;
    self.style.adjustTagWidth = self.adjustTagWidthSwitch.on;
    self.style.adjustTagWhenBeginDrag = self.adjustTagWhenBeginDragSwitch.on;
    self.style.adjustCoverAndLineWidth = self.adjustCoverAndLineWidthSwitch.on;
    
//    self.style.normalTitleColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
//    self.style.selectedTitleColor = [UIColor colorWithRed:1 green:0.5 blue:0 alpha:1.0];
    self.style.coverColor = [UIColor blueColor];
    
    TestViewController *testCtrl = [[TestViewController alloc] init];
    testCtrl.tagStyle = self.style;
    [self.navigationController pushViewController:testCtrl animated:YES];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
