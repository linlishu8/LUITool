//
//  LUICustomTabBar.m
//  LUITool
//
//  Created by 六月 on 2024/9/10.
//

#import "LUICustomTabBar.h"
#import "CGGeometry+LUI.h"
#import "UIView+LUI.h"
#import "UIColor+LUI.h"
#import "NSArray+LUI.h"

@interface LUICustomTabBar()
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIVisualEffectView *backgroundEffectView;//半透明效果
@property (nonatomic, strong) UIView *topLineView;
@end

@implementation LUICustomTabBar
#ifdef DEBUG
- (void)dealloc {
    
}
#endif
- (id)initWithFrame:(CGRect)frame {
    if (self=[super initWithFrame:frame]) {
        _translucent = YES;
        _itemHeight = 48;
        _maxNumberOfItems = 5;
        self.scrollDirection = LUItemFlowCollectionViewScrollDirectionHorizontal;
        self.itemCellClass = LUICustomTabBarItemCellView.class;
        if (@available(iOS 11.0, *)) {
            self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        //
        self.backgroundImageView = [[UIImageView alloc] init];
        [self addSubview:self.backgroundImageView];
        //
        self.topLineView = [[UIView alloc] init];
        self.topLineView.backgroundColor = [UIColor l_colorWithLight:[UIColor l_colorWithString:@"#3C3C4349"] dark:[UIColor l_colorWithString:@"#54545899"]];
        [self addSubview:self.topLineView];
        //
        self.backgroundEffectView = [[UIVisualEffectView alloc] init];
        self.backgroundEffectView.hidden = !self.translucent;
        [self addSubview:self.backgroundEffectView];
        [self _LUICustomTabBar_doTraitCollection];
        
        [self sendSubviewToBack:self.topLineView];
        [self sendSubviewToBack:self.backgroundEffectView];
        [self sendSubviewToBack:self.backgroundImageView];
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    self.backgroundEffectView.frame = bounds;
    CGRect f1 = bounds;
    f1.size.height = 1.0/UIScreen.mainScreen.scale;
    f1.origin.y = -f1.size.height;
    self.topLineView.frame = f1;
    //
    CGRect f2 = bounds;
    self.backgroundImageView.frame = f2;
}
- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(size.width, self.itemHeight);
}
- (void)_notifyPropertyChange {
    if (self.whenPropertyChange) {
        self.whenPropertyChange(self);
    }
}
- (void)setItemHeight:(CGFloat)itemHeight {
    if (_itemHeight==itemHeight)return;
    _itemHeight = itemHeight;
    [self _notifyPropertyChange];
}
- (void)setMaxNumberOfItems:(NSUInteger)maxNumberOfItems {
    if (_maxNumberOfItems==maxNumberOfItems)return;
    _maxNumberOfItems = maxNumberOfItems;
    [self reloadDataWithAnimated:NO];
}
- (void)setTranslucent:(BOOL)translucent {
    if (_translucent==translucent)return;
    _translucent = translucent;
    self.backgroundEffectView.hidden = !self.translucent;
    [self.backgroundEffectView setNeedsDisplay];
    [self _notifyPropertyChange];
}
- (void)setBackgroundImage:(UIImage *)backgroundImage {
    _backgroundImage = backgroundImage;
    self.backgroundImageView.image = backgroundImage;
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self _LUICustomTabBar_doTraitCollection];
}
- (void)_LUICustomTabBar_doTraitCollection {
    if (@available(iOS 12.0, *)) {
        if (self.traitCollection.userInterfaceStyle==UIUserInterfaceStyleDark) {
            self.backgroundEffectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        }else {
            self.backgroundEffectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        }
    }else {
        self.backgroundEffectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    }
}
- (CGSize)itemSizeAtIndex:(NSInteger)index collectionCellModel:(LUICollectionViewCellModel *)cellModel {
    if ([self.delegate respondsToSelector:@selector(itemFlowCollectionView:itemSizeAtIndex:collectionCellModel:)]) {
        return [self.delegate itemFlowCollectionView:self itemSizeAtIndex:index collectionCellModel:cellModel];
    }
    NSInteger count = self.items.count;
    if (count==0)return CGSizeZero;
    
    NSInteger maxCountPerScreen = self.maxNumberOfItems;//item数量<=5时，平分容器宽度值；>5时，item宽度为容器宽度/5,并开启滚动
    CGRect bounds = self.bounds;
    CGSize s = bounds.size;
    if (count<=maxCountPerScreen) {
        s.width = bounds.size.width/count;
    }else {
        s.width = bounds.size.width/maxCountPerScreen;
    }
    return s;
}
- (Class)itemCellClassAtIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(itemFlowCollectionView:itemCellClassAtIndex:)]) {
        return [self.delegate itemFlowCollectionView:self itemCellClassAtIndex:index];
    }
    UIViewController *vc = self.items[index];
    LUICustomTabBarItem *tabBarItem = vc.mk_customTabBarItem;
    if (tabBarItem.itemCellClass) return tabBarItem.itemCellClass;
    return self.itemCellClass;
}
@end

@interface LUICustomTabBarItem()
@property (nonatomic, strong) NSMutableDictionary *dynamicProperties;
//@property (nonatomic, weak) __kindof LUICollectionViewCellBase *itemCell;
@end

#import "NSObject+LUI.h"
@implementation LUICustomTabBarItem
#ifdef DEBUG
- (void)dealloc {
    
}
#endif
- (void)setTitle:(NSString *)title {
    if (self.title==title||[self.title isEqualToString:title])return;
    [super setTitle:title];
    [self _refreshTabBarItemCell];
}
- (void)setSelectedImage:(UIImage *)selectedImage {
    if (self.selectedImage==selectedImage||[self.selectedImage isEqual:selectedImage])return;
    [super setSelectedImage:selectedImage];
    [self _refreshTabBarItemCell];
}
- (void)setImage:(UIImage *)image {
    if (self.image==image||[self.image isEqual:image])return;
    [super setImage:image];
    [self _refreshTabBarItemCell];
}
- (void)setBadgeValue:(NSString *)badgeValue {
    if (self.badgeValue==badgeValue||[self.badgeValue isEqualToString:badgeValue])return;
    [super setBadgeValue:badgeValue];
    [self _refreshTabBarItemCell];
}
- (void)setBadgeStyle:(LUICustomTabBarItemBadgeStyle)badgeStyle {
    if (self.badgeStyle==badgeStyle)return;
    _badgeStyle = badgeStyle;
    [self _refreshTabBarItemCell];
}
- (void)refreshItemCell {
    if (!self.itemCell)return;
    LUICollectionViewCellModel *cellModel = self.itemCell.collectionCellModel;
    if ([cellModel.modelValue isKindOfClass:UIViewController.class]) {
        UIViewController *vc = cellModel.modelValue;
        if (vc.mk_customTabBarItem!=self) {//cell被复用了，此时它对应的item并非自己
            return;
        }
    }else if ([cellModel.modelValue isKindOfClass:self.class]) {
        if (cellModel.modelValue!=self) {
            return;
        }
    }
    //此处不能调用reload方法，否则如果后续调用tabBarController.selectedIndex=xx,选中会失效
    cellModel.needReloadCell = YES;
    [cellModel displayCell:self.itemCell];
}
- (void)_refreshTabBarItemCell {
    [self refreshItemCell];
}

- (void)setObject:(nullable id)obj forKeyedSubscript:(id<NSCopying>)key {
    if (obj==nil) {
        [self.dynamicProperties removeObjectForKey:key];
    }else {
        self.dynamicProperties[key] = obj;
    }
}
- (nullable id)objectForKeyedSubscript:(id<NSCopying>)key {
    id value = self.dynamicProperties[key];
    return value;
}
- (NSMutableDictionary *)dynamicProperties {
    if (_dynamicProperties)return _dynamicProperties;
    _dynamicProperties = [[NSMutableDictionary alloc] init];
    return _dynamicProperties;
}
- (nullable id)l_valueForKeyPath:(NSString *)path otherwise:(nullable id)other {
    return [self.dynamicProperties l_valueForKeyPath:path otherwise:other];
}
@end

#import "UIImageView+LUI.h"
@interface LUICustomTabBarItemBadgeView()
@property (nonatomic, strong) UILabel *badgeTextLabel;//图片右上角的角标视图，圆角显示未读文本
@property (nonatomic, strong) UIView *badgeDotView;//图片右上角的角标视图，显示为一个圆点
@end
@implementation LUICustomTabBarItemBadgeView
- (id)initWithFrame:(CGRect)frame {
    if (self=[super initWithFrame:frame]) {
        _badgeColor = UIColor.redColor;
        _badgeTextColor = UIColor.whiteColor;
        _badgeDotSize = CGSizeMake(10, 10);
        //
        self.badgeDotView = [[UIView alloc] init];
        self.badgeDotView.clipsToBounds = YES;
        [self addSubview:self.badgeDotView];
        //
        self.badgeTextLabel = [[UILabel alloc] init];
        self.badgeTextLabel.textAlignment = NSTextAlignmentCenter;
        self.badgeTextLabel.font = [UIFont systemFontOfSize:13];
        self.badgeTextLabel.clipsToBounds = YES;
        [self addSubview:self.badgeTextLabel];
        [self _refreshBadgeStyle];
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    CGFloat cornerRadius = bounds.size.height/2;
    if (self.badgeStyle==LUICustomTabBarItemBadgeStyleText) {
        self.badgeTextLabel.frame = bounds;
        self.badgeTextLabel.layer.cornerRadius = cornerRadius;
    }else {
        self.badgeDotView.frame = bounds;
        self.badgeDotView.layer.cornerRadius = cornerRadius;
    }
}
- (CGSize)sizeThatFits:(CGSize)size {
    if (self.badgeValue.length==0) return CGSizeZero;
    CGSize s;
    if (self.badgeStyle==LUICustomTabBarItemBadgeStyleText) {
        s = [self.badgeTextLabel sizeThatFits:size];
        s.height += 2;
        CGFloat cornerRadius = s.height/2;
        s.width += cornerRadius;
        s.width = MAX(s.width,s.height);
    }else {
        s = self.badgeDotSize;
    }
    return s;
}
- (void)setBadgeColor:(UIColor *)badgeColor {
    if (!badgeColor)return;
    if (_badgeColor==badgeColor||[_badgeColor isEqual:badgeColor])return;
    _badgeColor = badgeColor;
    self.badgeTextLabel.backgroundColor = self.badgeColor;
    self.badgeDotView.backgroundColor = self.badgeColor;
}
- (void)setBadgeValue:(NSString *)badgeValue {
    if (_badgeValue==badgeValue||[_badgeValue isEqualToString:badgeValue])return;
    _badgeValue = badgeValue;
    [self _refreshBadgeStyle];
}
- (void)setBadgeTextColor:(UIColor *)badgeTextColor {
    if (_badgeTextColor==badgeTextColor||[_badgeTextColor isEqual:badgeTextColor])return;
    _badgeTextColor = badgeTextColor;
    self.badgeTextLabel.textColor = self.badgeTextColor;
}
- (void)setBadgeStyle:(LUICustomTabBarItemBadgeStyle)badgeStyle {
    if (_badgeStyle==badgeStyle)return;
    _badgeStyle = badgeStyle;
    [self _refreshBadgeStyle];
}
- (void)_refreshBadgeStyle {
    if (self.badgeStyle==LUICustomTabBarItemBadgeStyleText) {
        self.badgeTextLabel.hidden = NO;
        self.badgeDotView.hidden= YES;
    }else {
        self.badgeTextLabel.hidden = YES;
        self.badgeDotView.hidden= NO;
    }
    self.badgeTextLabel.text = self.badgeValue;
    self.badgeTextLabel.backgroundColor = self.badgeColor;
    self.badgeDotView.backgroundColor = self.badgeColor;
    self.badgeTextLabel.textColor = self.badgeTextColor;
    [self setNeedsLayout];
}
@end

@interface LUICustomTabBarItemCellView ()
@property (nonatomic, strong) LUILayoutButton *itemButton;
@property (nonatomic, strong) LUICustomTabBarItemBadgeView *badgeView;//图片右上角的角标视图
@end
@implementation LUICustomTabBarItemCellView
#ifdef DEBUG
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}
#endif
#ifdef DEBUG
- (void)dealloc {
    
}
#endif
- (id)initWithFrame:(CGRect)frame {
    if (self=[super initWithFrame:frame]) {
        self.titleLabel.hidden = YES;
        self.itemButton = [[LUILayoutButton alloc] initWithContentStyle:(LUILayoutButtonContentStyleVertical)];
        self.itemButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.itemButton.titleLabel.font = [UIFont systemFontOfSize:10];
        self.itemButton.imageSize = CGSizeMake(35, 23);
        self.itemButton.interitemSpacing = 5;
        self.itemButton.contentInsets = UIEdgeInsetsMake(0, 0, 2, 0);
        self.itemButton.layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentBottom;
        
        [self.itemButton setTitleColor:UIColor.systemBlueColor forState:(UIControlStateSelected)];
        [self.itemButton setTitleColor:[UIColor l_colorWithLight:[UIColor colorWithWhite:0.57 alpha:1]] forState:(UIControlStateNormal)];
        [self.itemButton addTarget:self action:@selector(_onItemButtonTap:) forControlEvents:(UIControlEventTouchUpInside)];
        [self.contentView addSubview:self.itemButton];
        //
        self.badgeView = [[LUICustomTabBarItemBadgeView alloc] init];
        [self.contentView addSubview:self.badgeView];
    }
    return self;
}
- (void)_onItemButtonTap:(id)sender {
    [self.collectionCellModel didClickSelf];
}
- (void)customLayoutSubviews {
    [super customLayoutSubviews];
    CGRect bounds = self.contentView.bounds;
    UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        safeAreaInsets = self.safeAreaInsets;
    }
    CGRect f1 = bounds;
    f1.size.height -= safeAreaInsets.bottom;
    self.itemButton.frame = f1;
    //由于badge的布局会依赖itemButton，当itemButton的frame没有变更，但数据变更时，会导致itemButton的imageView尺寸变更，因此要强制重新布局一次button的内部视图
    [self.itemButton setNeedsLayout];
    [self.itemButton layoutIfNeeded];
    
    if (!self.badgeView.hidden) {
        CGRect f1 = bounds;
        f1.size = [self.badgeView sizeThatFits:bounds.size];

        CGRect imageFrame = [self.itemButton.imageView convertRect:self.itemButton.imageView.l_frameOfImageContent toView:self.contentView];
        
        LUICGRectSetMidX(&f1, CGRectGetMaxX(imageFrame));
        LUICGRectSetMidY(&f1, CGRectGetMinY(imageFrame));
        f1.origin.y = MAX(1,f1.origin.y);
        f1.origin.x = MIN(f1.origin.x,CGRectGetMaxX(bounds)-f1.size.width-1);
        self.badgeView.frame = f1;
    }
}
- (void)customReloadCellModel {
    [super customReloadCellModel];
    LUICustomTabBarItem *item = self.customTabBarItem;
    item.itemCell = self;
    BOOL selected = self.collectionCellModel.selected;
    [self.itemButton setTitle:item.title forState:(UIControlStateNormal)];
    [self.itemButton setTitle:item.title forState:(UIControlStateSelected)];
    
    [self.itemButton setImage:item.image forState:(UIControlStateNormal)];
    [self.itemButton setImage:item.selectedImage forState:(UIControlStateSelected)];
    self.itemButton.selected = selected;
    
    self.badgeView.badgeValue = item.badgeValue;
    self.badgeView.badgeStyle = item.badgeStyle;
    self.badgeView.hidden = self.badgeView.badgeValue.length==0;
}
- (UIView *)itemIndicatorRectView {
    return self.itemButton;
}
- (LUICustomTabBarItem *)customTabBarItem {
    if ([self.collectionCellModel.modelValue isKindOfClass:LUICustomTabBarItem.class]) return self.collectionCellModel.modelValue;
    UIViewController *vc = self.customItemViewController;
    LUICustomTabBarItem *item = vc.mk_customTabBarItem;
    return item;
}
- (UIViewController *)customItemViewController {
    if (![self.collectionCellModel.modelValue isKindOfClass:UIViewController.class]) return nil;
    return self.collectionCellModel.modelValue;
}
- (CGSize)customSizeThatFits:(CGSize)size {
    return [self.itemButton sizeThatFits:size];
}
@end

#import <objc/runtime.h>
@implementation UIViewController (LUICustomTabBar)
- (LUICustomTabBarItem *)mk_customTabBarItem {
    const void * key = "mk_customTabBarItem";
    LUICustomTabBarItem *obj = objc_getAssociatedObject(self, key);
    if (!obj) {
        obj = [[LUICustomTabBarItem alloc] init];
        UITabBarItem *item = self.tabBarItem;
        obj.title = item.title;
        obj.selectedImage = item.selectedImage;
        obj.image = item.image;
        obj.badgeValue = item.badgeValue;
        if (@available(iOS 10.0, *)) {
            obj.badgeColor = item.badgeColor;
        }
        self.mk_customTabBarItem = obj;
    }
    return obj;
}
- (void)setMk_customTabBarItem:(LUICustomTabBarItem *)mk_customTabBarItem {
    const void * key = "mk_customTabBarItem";
    objc_setAssociatedObject(self, key, mk_customTabBarItem, OBJC_ASSOCIATION_RETAIN);
}
@end
