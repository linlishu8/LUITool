//
//  LUIExtendTabBarController.h
//  LUITool
//  扩展系统的UITabBarController，定义一个可高度自定义的标签控制器。底部tarBar的背景颜色、背景图片、半透明度、高度值以及每个tarBarItem的显示视图，均可以进行自定义。
//  Created by 六月 on 2024/9/10.
//

#import <UIKit/UIKit.h>
#import "LUItemFlowCollectionView.h"
#import "LUICustomTabBar.h"

NS_ASSUME_NONNULL_BEGIN

@interface LUIExtendTabBarController : UITabBarController <LUItemFlowCollectionViewDelegate>
/// 底部的tabBar视图，如果需要设置默认的tarBarItem显示视图，可以设置tabBar.itemCellClass属性
@property (nonatomic, readonly) LUICustomTabBar *customTabBar;
@end

NS_ASSUME_NONNULL_END
