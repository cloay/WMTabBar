//
//  WMTabBar.h
//
//  Created by cloay on 2016/10/14.
//  Copyright © 2016年 TIANCAI. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WMTabBarDelegate <NSObject>
/**
 *  标签被选中时回调
 *
 *  @param index 标签的索引值
 *  @param title 标签的title
 */
- (void)didSelectedTab:(NSInteger)index title:(NSString *)title;
@end

@interface WMTabBar : UIView

@property (nonatomic, assign, readonly) NSInteger        currentTabIndex;
@property (nonatomic, strong, readonly) NSString         *currentTabTitle;

@property (nonatomic, weak) id<WMTabBarDelegate> delegate;

/**
 *  初始化方法
 *
 *  @param frame 大小
 *  @param tabs tab数组
 *
 *  @return WMTabBar
 */
- (instancetype)initWithFrame:(CGRect)frame withTabs:(NSArray *)tabs;

/**
 *  初始化方法
 *
 *  @param frame  大小
 *  @param tabs   标签数组
 *  @param nColor 标签正常状态的颜色
 *  @param hColor 标签选中时高亮颜色
 *  @param nFont  标签正常状态的字体
 *
 *  @return WMTabBar
 */
- (instancetype)initWithFrame:(CGRect)frame withTabs:(NSArray *)tabs withNormalColor:(UIColor *)nColor withHighlightColor:(UIColor *)hColor withNormalFont:(UIFont *)nFont;

/**
 *  设置正常标签颜色
 *
 *  @param color 颜色
 */
- (void)setNormalColor:(UIColor *)color;

/**
 *  设置高亮颜色
 *
 *  @param color 颜色
 */
- (void)setHighlightColor:(UIColor *)color;

/**
 *  设置正常的字体
 *
 *  @param font 字体
 */
- (void)setNormalFont:(UIFont *)font;

/**
 *  选中一个tab
 *
 *  @param index 标签索引
 */
- (void)selectTab:(NSInteger)index;

/**
 *  左右滑动一个Tab
 *
 *  @param pageWidth 分页的的宽度
 *  @param offsetX   X轴偏移量
 */
- (void)didScrollWithPageWidth:(CGFloat)pageWidth offsetX:(CGFloat)offsetX;

/**
 *  根据标签文本获取标签的位置
 *
 *  @param tabText 标签文本
 *
 *  @return 返回标签索引
 */
- (NSInteger)tabIndex:(NSString *)tabText;

/**
 *  设置选中的标签是否加放大效果
 *
 *  @param scaled  默认为 NO
 */
- (void)setScaleSelectedTab:(BOOL)scaled;

/**
 *  设置放大大小
 *
 *  @param size 大小   默认 1
 */
- (void)setScaleSize:(CGFloat)size;

/**
 *  设置标线高度
 *
 *  @param height 高度值  默认1
 */
- (void)setLineHeight:(CGFloat)height;

/**
 *  是否显示底部标线
 *
 *  @param show 是否 默认显示
 */
- (void)showLine:(BOOL)show;
@end
