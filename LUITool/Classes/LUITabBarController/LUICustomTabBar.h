//
//  LUICustomTabBar.h
//  LUITool
//
//  Created by 六月 on 2024/9/10.
//

#import "LUItemFlowCollectionView.h"
#import "LUILayoutButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface LUICustomTabBar : LUItemFlowCollectionView
@property (nonatomic, assign) CGFloat itemHeight;//tabBar区域item的高度值，默认为48；self.tabBar的高度为tabBarItemHeight+底部安全区域的bottom值

/// tabBar区域是否半透明，默认为YES:半透明
//YES:半透明，此时viewController的height=self.view.bounds.size.height,同时safeAreaInsets.bottom=self.tabBar.bounds.size.height。会在tabBar底部添加半透明的UIVisualEffectView
//NO:不透明，此时viewController的height=self.view.bounds.size.height-self.tabBar.bounds.size.height,同时safeAreaInsets.bottom=0。隐藏tabBar底部的半透明的UIVisualEffectView
@property (nonatomic, assign) BOOL translucent;

@property (nonatomic, assign) NSUInteger maxNumberOfItems;//一屏最多显示的tabBarItem数量，超过该值时，tabBar将开启左右滚动。该值默认为5
@property (nonatomic, copy, nullable) void(^whenPropertyChange)(LUICustomTabBar *customTabBar);

@property (nonatomic, readonly) UIView *topLineView;//顶部的分隔线视图
@property (nonatomic, strong, nullable) UIImage *backgroundImage;//背景图片
@property (nonatomic, readonly) UIImageView *backgroundImageView;//背景图片视图
@property (nonatomic, readonly) UIVisualEffectView *backgroundEffectView;//半透明效果
@end

/// 自定义的tabBar数据
typedef enum : NSUInteger {
    LUICustomTabBarItemBadgeStyleText,//展示文本
    LUICustomTabBarItemBadgeStyleDot,//展示圆点
} LUICustomTabBarItemBadgeStyle;//角标展示样式
@interface LUICustomTabBarItem : UITabBarItem
@property (nonatomic, strong, nullable) Class itemCellClass;//该tabBar自定义使用的CollectionViewCell视图
@property (nonatomic, weak) __kindof LUICollectionViewCellBase *itemCell;
@property (nonatomic, assign) LUICustomTabBarItemBadgeStyle badgeStyle;//角标展示样式,默认为LUICustomTabBarItemBadgeStyleText
@property (nonatomic, strong,nullable) id userInfo;//扩展数据
- (void)refreshItemCell;//刷新tarBar对应的视图itemCell

//添加动态属性
//id value = self[@"key"];
//self[@"key"] = nil;
//self[@"key"] = @(YES);
- (void)setObject:(nullable id)obj forKeyedSubscript:(id<NSCopying>)key;
- (nullable id)objectForKeyedSubscript:(id<NSCopying>)key;
- (nullable id)l_valueForKeyPath:(NSString *)path otherwise:(nullable id)other;
@end

///未读角标展示
@interface LUICustomTabBarItemBadgeView : UIView
@property (nonatomic, assign) LUICustomTabBarItemBadgeStyle badgeStyle;//默认为展示文本
@property (nonatomic, strong, nullable) NSString *badgeValue;//未读数
@property (nonatomic, readonly) UILabel *badgeTextLabel;//图片右上角的角标视图，圆角显示未读文本
@property (nonatomic, strong) UIColor *badgeColor;//默认为红色
@property (nonatomic, strong) UIColor *badgeTextColor;//默认为白色

@property (nonatomic, readonly) UIView *badgeDotView;//图片右上角的角标视图，显示为一个圆点
@property (nonatomic, assign) CGSize badgeDotSize;//圆点尺寸，默认为10,10
@end

/// 默认的LUICustomTabBarItem显示视图，其collectionCellModel.modelValue为UIViewController
@interface LUICustomTabBarItemCellView : LUItemFlowCellView
@property (nonatomic, readonly, nullable) __kindof LUICustomTabBarItem *customTabBarItem;//返回tarBarItem值
@property (nonatomic, readonly, nullable) __kindof UIViewController *customItemViewController;//返回tarBarItem对应的UIViewController
@property (nonatomic, readonly) LUILayoutButton *itemButton;//上图片，下文本的按钮
@property (nonatomic, readonly) LUICustomTabBarItemBadgeView *badgeView;//图片右上角的角标视图
@end

@interface UIViewController (LUICustomTabBar)
@property (null_resettable, nonatomic, strong) __kindof LUICustomTabBarItem *l_customTabBarItem;
@end

NS_ASSUME_NONNULL_END
