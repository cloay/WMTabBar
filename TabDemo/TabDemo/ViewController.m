//
//  ViewController.m
//  TabDemo
//
//  Created by cloay on 2016/11/7.
//  Copyright © 2016年 TIANCAI. All rights reserved.
//

#import "ViewController.h"
#import "WMTabBar.h"

@interface ViewController ()<WMTabBarDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) WMTabBar     *tabBar;
@property (nonatomic, strong) UISwitch     *sh;
@property (nonatomic, strong) UIScrollView *scrollV;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50, 30, 120, 20)];
    [label setText:@"开启放大效果"];
    [self.view addSubview:label];
    
    self.sh = [[UISwitch alloc] initWithFrame:CGRectMake(200, 24, 60, 40)];
    [self.sh addTarget:self action:@selector(switchDidChanged) forControlEvents:UIControlEventValueChanged];
    [self.sh setOn:NO];
    [self.view addSubview:self.sh];
    
    NSArray *tabs = @[@"头条", @"热点啊", @"体育", @"科技新闻"];
    self.tabBar = [[WMTabBar alloc] initWithFrame:CGRectMake(60, 70, self.view.frame.size.width - 120, 36) withTabs:tabs withNormalColor:[UIColor lightGrayColor] withHighlightColor:[UIColor greenColor] withNormalFont:[UIFont systemFontOfSize:15]];
    [self.tabBar setDelegate:self];
    //设置选中字体放大的值，在正常的基础上增加的大小
    [self.tabBar setScaleSize:2];
    //设置标线的高度
    [self.tabBar setLineHeight:2];
    //隐藏底部标线
    //    [self.tabBar showLine:NO];
    [self.view addSubview:self.tabBar];
    
    self.scrollV = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 107, self.view.frame.size.width, self.view.frame.size.height - 107)];
    [self.scrollV setShowsHorizontalScrollIndicator:NO];
    [self.scrollV setPagingEnabled:YES];
    [self.scrollV setContentSize:CGSizeMake(4 * self.view.frame.size.width, 0)];
    [self.scrollV setDelegate:self];
    for (int i = 0 ; i < 4; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i * self.scrollV.frame.size.width + 5, 0, self.scrollV.frame.size.width - 10, self.scrollV.frame.size.height)];
        [label setText:tabs[i]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setTextColor:[UIColor lightGrayColor]];
        [label setBackgroundColor:[UIColor colorWithRed:245 / 255.f green:245 / 255.f blue:245 / 255.f alpha:1.f]];
        [self.scrollV addSubview:label];
    }
    [self.view addSubview:self.scrollV];
}

- (void)switchDidChanged{
    [self.tabBar setScaleSelectedTab:self.sh.isOn];
}

#pragma mark - TCTabBarDelegate
- (void)didSelectedTab:(NSInteger)index title:(NSString *)title{
    NSLog(@"index = %ld, title = %@", (long)index, title);
    [self.scrollV setContentOffset:CGPointMake(index * self.scrollV.frame.size.width, 0)];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.tabBar didScrollWithPageWidth:scrollView.frame.size.width offsetX:scrollView.contentOffset.x];
}

@end
