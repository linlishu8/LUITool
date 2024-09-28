//
//  LUITestTabBarController.m
//  LUITool_Example
//
//  Created by 六月 on 2024/9/10.
//  Copyright © 2024 Your Name. All rights reserved.
//

#import "LUITestTabBarController.h"

@interface LUITestTabBarController ()

@end

@implementation LUITestTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.customTabBar.collectionView.clipsToBounds = NO;
    NSMutableArray<UIViewController *> *viewControllers = [[NSMutableArray alloc] init];
    {
        UIViewController *vc = [[UIViewController alloc] init];
        [viewControllers addObject:vc];
    }
    {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[UINavigationController new]];
        nav.l_customTabBarItem.title = @"嵌套Nav";
        nav.l_customTabBarItem.badgeValue = @"1";
        nav.l_customTabBarItem.badgeStyle = LUICustomTabBarItemBadgeStyleDot;
        [viewControllers addObject:nav];
    }
    {
        UIViewController *vc = [[UIViewController alloc] init];
        [viewControllers addObject:vc];
    }
    {
        UIViewController *vc = [[UIViewController alloc] init];
        [viewControllers addObject:vc];
    }
    {
        UIViewController *vc = [[UIViewController alloc] init];
        vc.view.backgroundColor = UIColor.redColor;
        [viewControllers addObject:vc];
    }
    self.viewControllers = viewControllers;
    self.selectedIndex = 1;
    [self _configNavigationForViewController:self.selectedViewController];

}
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    if (@available(iOS 11.0, *)) {
//        NSLog(@"TestFunTabBarViewController safeAreaInsets:%@",NSStringFromUIEdgeInsets(self.view.safeAreaInsets));
    }
}

- (void)_configNavigationForViewController:(UIViewController *)viewController{
    self.title = viewController.title;
    self.navigationItem.rightBarButtonItems = viewController.navigationItem.rightBarButtonItems;
    self.navigationItem.leftBarButtonItems = viewController.navigationItem.leftBarButtonItems;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
