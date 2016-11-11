//
//  TestViewController.m
//  JWScrollPageView
//
//  Created by djw on 2016/11/11.
//  Copyright © 2016年 DJW. All rights reserved.
//

#import "TestViewController.h"
#import "TestTableViewController.h"
#import "TestCollectionViewController.h"

@interface TestViewController ()<JWScrollPageViewDelegate>

@property (nonatomic, strong) NSArray<NSString *>   *tagArray;

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO];
    
    self.title = @"效果测试";
    //必要的设置, 如果没有设置可能导致内容显示不正常
    self.automaticallyAdjustsScrollViewInsets = NO;

    
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
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
    return NO;
}

- (NSInteger)numberOfChildViewControllers {
    return self.tagArray.count;
}

- (UIViewController<JWScrollPageChildVCDelegate> *)childViewController:(UIViewController<JWScrollPageChildVCDelegate> *)childViewController forIndex:(NSInteger)index {
    
    UIViewController<JWScrollPageChildVCDelegate> *childVC = childViewController;
    if (childVC == nil) {
        if (index % 2 == 0) {
            childVC = [[TestTableViewController alloc] init];
        }
        else {
            childVC = [[TestCollectionViewController alloc] init];
        }
    }
    
    childVC.title = self.tagArray[index];
    return childVC;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
