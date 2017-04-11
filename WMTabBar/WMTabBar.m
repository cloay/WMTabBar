//
//  WMTabBar.m
//
//  Created by cloay on 2016/10/14.
//  Copyright © 2016年 TIANCAI. All rights reserved.
//

#import "WMTabBar.h"

#define WM_RGB_COLOR(r, g, b) [UIColor colorWithRed:r / 255.f green:g / 255.f blue:b / 255.f alpha:1.f]

#define WM_SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define WM_SCALE_FACTOR WM_SCREEN_WIDTH / 375.f

//标签间隔宽度
#define WM_DIVIDER_WIDTH 12 * WM_SCALE_FACTOR
#define WM_BASE_TAG 1001

@interface WMTabBar()

@property (nonatomic, strong) UIColor        *nColor;
@property (nonatomic, strong) UIColor        *hColor;
@property (nonatomic, strong) UIFont         *nFont;
@property (nonatomic, strong) UIFont         *hFont;

@property (nonatomic, strong) NSMutableArray *tabArr;
@property (nonatomic, strong) UIScrollView   *scrollV;
@property (nonatomic, strong) UIView         *containerV;
@property (nonatomic, strong) UIView         *lineV;

@property (nonatomic, strong) UIButton       *currentTabBtn;

@property (nonatomic, assign) BOOL           scaled;
@property (nonatomic, assign) CGFloat        sSize;
@property (nonatomic, assign) CGFloat        lineHeight;
@end

@implementation WMTabBar

- (instancetype)initWithFrame:(CGRect)frame withTabs:(NSArray *)tabs{
    self = [super initWithFrame:frame];
    if (self) {
        [self tcInit];
        
        [self.tabArr addObjectsFromArray:tabs];
        [self initTabs];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame withTabs:(NSArray *)tabs withNormalColor:(UIColor *)nColor withHighlightColor:(UIColor *)hColor withNormalFont:(UIFont *)nFont{
    self = [super initWithFrame:frame];
    if (self) {
        [self tcInit];
        [self.tabArr addObjectsFromArray:tabs];
        
        self.nColor = nColor;
        self.hColor = hColor;
        self.nFont = nFont;
        
        [self.lineV setBackgroundColor:self.hColor];
        [self initTabs];
    }

    return self;
}

/**
 *  初始化和默认配置
 */
- (void)tcInit{
    _sSize = 1 * WM_SCALE_FACTOR;
    _lineHeight = _sSize;
    [self setNormalColor:WM_RGB_COLOR(211, 211, 211)];
    [self setHighlightColor:WM_RGB_COLOR(79, 179, 253)];
    [self setNormalFont:[UIFont systemFontOfSize:16 * WM_SCALE_FACTOR]];
    [self setHighLightFont:[UIFont systemFontOfSize:17 * WM_SCALE_FACTOR]];
    _currentTabIndex = 0;

    self.tabArr = [[NSMutableArray alloc] init];
    
    self.scrollV = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self.scrollV setShowsHorizontalScrollIndicator:NO];
    
    self.containerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self.scrollV addSubview:self.containerV];
    
    self.lineV = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - self.lineHeight, 0, self.lineHeight)];
    [self.lineV setBackgroundColor:self.hColor];
    [self.lineV setTag:1000];
    [self.containerV addSubview:self.lineV];
    
    [self addSubview:self.scrollV];
}

/**
 *  初始化标签
 */
- (void)initTabs{
    NSInteger tabCount = self.tabArr.count;
    if (tabCount == 0)
        return;
    
    //上个tab的x轴
    CGFloat lastTabX = 0;
    for (int i = 0; i < tabCount; i++) {
        NSString *tabText = [self.tabArr objectAtIndex:i];
        CGFloat tabWidth = [self tabTextWidth:tabText] + WM_DIVIDER_WIDTH;
        [self addTabWithText:tabText withX:lastTabX withTabWidth:tabWidth withTag:WM_BASE_TAG + i];
        lastTabX += tabWidth;
    }
    
    [self resetLayout:lastTabX];
    
    self.currentTabBtn = [self.containerV viewWithTag:self.currentTabIndex + WM_BASE_TAG];
    _currentTabTitle = self.currentTabBtn.currentTitle;
    [self selectTab:0];
}

- (CGFloat)tabTextWidth:(NSString *)text {
    CGSize size = [text sizeWithAttributes:@{NSFontAttributeName:self.nFont}];
    return size.width + 6 * WM_SCALE_FACTOR;
}

- (void)addTabWithText:(NSString *)tabText withX:(CGFloat)x withTabWidth:(CGFloat)tabWidth withTag:(NSInteger)tag{
    CGFloat tabHeight = self.frame.size.height - self.lineHeight;
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(x, 0, tabWidth, tabHeight)];
    [btn.titleLabel setFont:self.nFont];
    [btn setTag:tag];
    [btn setTitle:tabText forState:UIControlStateNormal];
    [btn setTitle:tabText forState:UIControlStateHighlighted];
    [btn setTitleColor:self.nColor forState:UIControlStateNormal];
    [btn setTitleColor:self.hColor forState:UIControlStateSelected];
    [btn addTarget:self action:@selector(tabDidTaped:) forControlEvents:UIControlEventTouchUpInside];
    [self.containerV addSubview:btn];
}

- (void)resetLayout:(CGFloat)containerViewWidth{
    NSInteger count = self.tabArr.count;
    //如果当前标签总长度小于标签组件的宽度就均分
    if (containerViewWidth <= self.frame.size.width) {
        float dividerW = (self.frame.size.width - containerViewWidth) / (count + 1);
        float lastX = dividerW;
        for (int i = 0; i < count; i++) {
            UIButton *item = [self.containerV viewWithTag:i + WM_BASE_TAG];
            CGRect frame = item.frame;
            frame.origin.x = lastX;
            [item setFrame:frame];
            lastX += frame.size.width + dividerW;
        }
    } else {
        [self.containerV setFrame:CGRectMake(0, 0, containerViewWidth, self.containerV.frame.size.height)];
        [self.scrollV setContentSize:CGSizeMake(containerViewWidth, 0)];
    }
    [self.scrollV setScrollEnabled:containerViewWidth > self.frame.size.width];
}

- (NSInteger)tabIndex:(NSString *)tabText{
    return [self.tabArr indexOfObject:tabText];
}

- (void)setScaleSelectedTab:(BOOL)scaled{
    self.scaled = scaled;
    
    [self.currentTabBtn.titleLabel setFont: self.scaled ? self.hFont : self.nFont];
}

- (void)setScaleSize:(CGFloat)size{
    if (size > 5 * WM_SCALE_FACTOR) {
        size = 4 * WM_SCALE_FACTOR;
    }
    _sSize = size;
    UIFontDescriptor *fontDescriptor = [self.nFont fontDescriptor];
    _hFont = [UIFont fontWithDescriptor:fontDescriptor size:self.nFont.pointSize + self.sSize];
    [self.currentTabBtn.titleLabel setFont: self.scaled ? self.hFont : self.nFont];
}

- (void)setLineHeight:(CGFloat)height{
    _lineHeight = height;
    
    CGRect lFrame = self.lineV.frame;
    lFrame.origin.y = self.frame.size.height - height;
    lFrame.size.height = height;
    self.lineV.frame = lFrame;
}

- (void)showLine:(BOOL)show{
    [self.lineV setHidden:!show];
}

#pragma mark - 设置颜色字体
- (void)setNormalColor:(UIColor *)color{
    _nColor = color;
    
    for(UIView *v in self.containerV.subviews){
        if ([v isKindOfClass: [UIButton class]]) {
            UIButton *tabBtn = (UIButton*)v;
            [tabBtn setTitleColor:self.nColor forState:UIControlStateNormal];
        }
    }
}

- (void)setHighlightColor:(UIColor *)color{
    _hColor = color;
    [self.lineV setBackgroundColor:self.hColor];
    for(UIView *v in self.containerV.subviews){
        if ([v isKindOfClass: [UIButton class]]) {
            UIButton *tabBtn = (UIButton*)v;
            [tabBtn setTitleColor:self.nColor forState:UIControlStateSelected];
        }
    }
}

- (void)setNormalFont:(UIFont *)font{
    _nFont = font;
    UIFontDescriptor *fontDescriptor = [font fontDescriptor];
    _hFont = [UIFont fontWithDescriptor:fontDescriptor size:self.nFont.pointSize + self.sSize];
    for(UIView *v in self.containerV.subviews){
        if ([v isKindOfClass: [UIButton class]]) {
            UIButton *tabBtn = (UIButton*)v;
            if (tabBtn == self.currentTabBtn && self.scaled) {
                [tabBtn.titleLabel setFont:self.hFont];
            } else {
                [tabBtn.titleLabel setFont:self.nFont];
            }
        }
    }
}

- (void)setHighLightFont:(UIFont *)hightLightFont{
    _hFont = hightLightFont;
    if (self.scaled) {
        [self.currentTabBtn.titleLabel setFont:self.hFont];
    }
}

#pragma mark - tab切换相关方法
- (void)tabDidTaped:(UIButton *)sender{
    NSInteger index = sender.tag - WM_BASE_TAG;
    if (index == self.currentTabIndex) {
        return;
    }
    [self selectTab:index];
}

- (void)selectTab:(NSInteger)index{
    if (self.tabArr.count > 0 && index < self.tabArr.count) {
        [self didScrollWithOffset:index - self.currentTabIndex isTaped:YES];
    }
}

/**
 *  根据偏移量或者点击标签，切换标签
 *
 *  @param offset  偏移量
 *  @param isTaped 是否是点击
 */
- (void)didScrollWithOffset:(CGFloat)offset isTaped:(BOOL)isTaped{
    //根据偏移量找到下一个被选中或将要被选中的标签
    UIButton *nextTab = [self.containerV viewWithTag:self.currentTabIndex + WM_BASE_TAG + (isTaped ? offset : (offset > 0 ? 1 : -1))];
    
    if (nextTab == nil) {
        nextTab = self.currentTabBtn;
    } else {
        if (nextTab.tag < WM_BASE_TAG) {
            nextTab = self.currentTabBtn;
        }
    }
    
    //如果是点击，直接切换到选中的标签
    if (isTaped) {
        [UIView animateWithDuration:0.35f animations:^{
            CGRect nFrame = nextTab.frame;
            CGFloat width = [self tabTextWidth:nextTab.titleLabel.text];
            CGFloat x = nFrame.origin.x + (nFrame.size.width - width) / 2;
            [self.lineV setFrame:CGRectMake(x, self.frame.size.height - self.lineHeight, width, self.lineHeight)];
            
            [self.currentTabBtn.titleLabel setFont:self.nFont];
            [nextTab.titleLabel setFont:self.scaled ? self.hFont : self.nFont];
        }];
    } else {//若不是点击选中则根据偏移量动态计算标签的大小、颜色值
        CGRect cFrame = self.currentTabBtn.frame;
        CGRect nFrame = nextTab.frame;
        CGFloat cWidth = [self tabTextWidth:self.currentTabBtn.titleLabel.text];
        CGFloat nWidth = [self tabTextWidth:nextTab.titleLabel.text];
        CGFloat width = cWidth + (nWidth - cWidth) * fabs(offset);
        
        CGFloat cX = cFrame.origin.x + (cFrame.size.width - cWidth) / 2;
        CGFloat nX = nFrame.origin.x + (nFrame.size.width - nWidth) / 2;
        CGFloat x = cX + (nX - cX) * fabs(offset);
        
        [self.lineV setFrame:CGRectMake(x, self.frame.size.height - self.lineHeight, width, self.lineHeight)];
        if (self.currentTabBtn == nextTab) {
            [self.currentTabBtn.titleLabel setFont:self.nFont];
        } else {
            //如果有放大效果
            if (self.scaled) {
                UIFontDescriptor *fontDescriptor = [self.nFont fontDescriptor];
                [self.currentTabBtn.titleLabel setFont:[UIFont fontWithDescriptor:fontDescriptor size:self.hFont.pointSize - self.sSize * fabs(offset)]];
                [nextTab.titleLabel setFont:[UIFont fontWithDescriptor:fontDescriptor size:self.nFont.pointSize + self.sSize * fabs(offset)]];
            }
            
            
            [self.currentTabBtn setTitleColor:[self getCurrentColor:fabs(offset)] forState:UIControlStateSelected];
            [nextTab setTitleColor:[self getNormalColor:fabs(offset)] forState:UIControlStateNormal];
            
        }
    }
    
    if (fabs(offset) == 1.f || isTaped) {
        [self.currentTabBtn setSelected:NO];
        [self.currentTabBtn setTitleColor:self.hColor forState:UIControlStateSelected];
        [nextTab setSelected:YES];
        [nextTab setTitleColor:self.nColor forState:UIControlStateNormal];
        
        self.currentTabBtn = nextTab;
        _currentTabIndex = nextTab.tag - WM_BASE_TAG;
        _currentTabTitle = self.currentTabBtn.currentTitle;
        //如果当前标签未显示完全则scrollV滚动到完全显示
        CGRect rect = [self.containerV convertRect:self.currentTabBtn.frame toView:self];
        if (rect.origin.x < 0) {
            [self.scrollV setContentOffset:CGPointMake(self.scrollV.contentOffset.x + rect.origin.x, 0) animated:YES];
        }else if(rect.origin.x + rect.size.width - self.frame.size.width > 0) {
            [self.scrollV setContentOffset:CGPointMake(self.currentTabBtn.frame.origin.x + self.currentTabBtn.frame.size.width - self.frame.size.width, 0) animated:YES];
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectedTab:title:)]) {
            [self.delegate didSelectedTab:self.currentTabIndex title:self.currentTabBtn.titleLabel.text];
        }
    }
}

/**
 *  获取当前标签颜色
 *
 *  @param offset 当前标签被选中的偏移量
 *
 *  @return 返回颜色值
 */
- (UIColor *)getCurrentColor:(CGFloat)offset{
    CGFloat hRed, hGreen, hBlue, hAlpha;
    [self.hColor getRed:&hRed green:&hGreen blue:&hBlue alpha:&hAlpha];
    CGFloat nRed, nGreen, nBlue, nAlpha;
    [self.nColor getRed:&nRed green:&nGreen blue:&nBlue alpha:&nAlpha];
    return [UIColor colorWithRed:hRed - (hRed - nRed) * offset green:hGreen - (hGreen - nGreen) * offset blue:hBlue - (hBlue - nBlue) * offset alpha:hAlpha];
}

/**
 *  获取正常标签颜色
 *
 *  @param offset 标签被选中的偏移量
 *
 *  @return 返回颜色值
 */
- (UIColor *)getNormalColor:(CGFloat)offset{
    CGFloat hRed, hGreen, hBlue, hAlpha;
    [self.hColor getRed:&hRed green:&hGreen blue:&hBlue alpha:&hAlpha];
    CGFloat nRed, nGreen, nBlue, nAlpha;
    [self.nColor getRed:&nRed green:&nGreen blue:&nBlue alpha:&nAlpha];
    return [UIColor colorWithRed:nRed + (hRed - nRed) * offset green:nGreen + (hGreen - nGreen) * offset blue:nBlue + (hBlue - nBlue) * offset alpha:hAlpha];
}


/**
 *  左右滑动一个Tab
 *
 *  @param pageWidth 分页的的宽度
 *  @param offsetX   X轴偏移量
 */
- (void)didScrollWithPageWidth:(CGFloat)pageWidth offsetX:(CGFloat)offsetX{
    
    CGFloat deltaOffsetX = fabs(offsetX - self.currentTabIndex * pageWidth) - pageWidth;
    
    if (deltaOffsetX > 0) {   //仅支持一页一页的滑动，超过一页减去超过的部分
        offsetX = offsetX - (offsetX - self.currentTabIndex * pageWidth > 0 ? deltaOffsetX : - deltaOffsetX);
    }
    
    CGFloat offset = (offsetX - self.currentTabIndex * pageWidth) / pageWidth;
    [self didScrollWithOffset:offset isTaped:NO];
}

@end
