//
//  LUIExtendTabBarController.m
//  LUITool
//
//  Created by 六月 on 2024/9/10.
//

#import "LUIExtendTabBarController.h"
#import <objc/runtime.h>
#import "UIView+LUI.h"

@interface LUIExtendTabBarController_UITabBar : UITabBar
@end
@implementation LUIExtendTabBarController_UITabBar
- (CGSize)sizeThatFits:(CGSize)size{
    CGSize s = size;
    LUIExtendTabBarController *controller = (LUIExtendTabBarController *)self.l_viewControllerOfFirst;
    CGFloat itemHeight = controller.customTabBar.itemHeight;
    UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        safeAreaInsets = self.safeAreaInsets;
    }
    s.height = itemHeight+safeAreaInsets.bottom;
    return s;
}
@end

@interface LUIExtendTabBarController ()
@property (nonatomic, strong) LUICustomTabBar *customTabBar;
@end

@implementation LUIExtendTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.tabBar.class == UITabBar.class) {
        object_setClass(self.tabBar, LUIExtendTabBarController_UITabBar.class);//将tabBar高度参数化
    } else {
        NSLog(@"UITabBarController.tabBar.class为%@,不为UITabBar,需要更新LUIExtendTabBarController.m的代码实现",NSStringFromClass(self.tabBar.class));
    }
    [self.tabBar addSubview:self.customTabBar];
    self.tabBar.translucent = self.customTabBar.translucent;
}
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    CGRect bounds = self.tabBar.superview.bounds;
    CGRect f1 = bounds;
    f1.size = [self.tabBar sizeThatFits:bounds.size];
    LUICGRectAlignMaxYToRect(&f1, bounds);
    self.tabBar.frame = f1;
    //
    self.customTabBar.frame = self.tabBar.bounds;
    for (UIView *v in self.tabBar.subviews) {
        if (v == self.customTabBar) continue;
        v.hidden = YES;
    }
}
- (void)setViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers {
    [super setViewControllers:viewControllers];
    [self __reloadTabBarDataWithAnimated:YES];
}
- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    [super setSelectedIndex:selectedIndex];
    [self __reloadTabBarDataWithAnimated:YES];
}
- (void)setSelectedViewController:(__kindof UIViewController *)selectedViewController {
    [super setSelectedViewController:selectedViewController];
    [self __reloadTabBarDataWithAnimated:YES];
}

- (void)__reloadTabBarDataWithAnimated:(BOOL)animated {
    self.customTabBar.items = self.viewControllers;
    self.customTabBar.selectedIndex = self.selectedIndex;
    [self.customTabBar reloadDataWithAnimated:animated];
}

- (LUICustomTabBar *)customTabBar {
    if(_customTabBar)return _customTabBar;
    LUICustomTabBar *view = [[LUICustomTabBar alloc] init];
    view.delegate = self;
    _customTabBar = view;
    @LUI_WEAKIFY(self);
    view.whenPropertyChange = ^(LUICustomTabBar * _Nonnull customTabBar) {
        @LUI_NORMALIZE(self);
        self.tabBar.translucent = customTabBar.translucent;
        [self.view setNeedsLayout];
    };
    return _customTabBar;
}
#pragma mark - delegate:LUItemFlowCollectionViewDelegate
- (void)itemFlowCollectionView:(LUItemFlowCollectionView *)view didSelectIndex:(NSInteger)selectedIndex {
    UIViewController *viewController = self.viewControllers[selectedIndex];
    if (self.delegate && [self.delegate respondsToSelector:@selector(tabBarController:shouldSelectViewController:)]) {
        if (![self.delegate tabBarController:self shouldSelectViewController:viewController]) {
            return;
        }
    }
    self.selectedIndex = selectedIndex;
    if (self.delegate && [self.delegate respondsToSelector:@selector(tabBarController:didSelectViewController:)]) {
        [self.delegate tabBarController:self didSelectViewController:viewController];
    }
}

@end
