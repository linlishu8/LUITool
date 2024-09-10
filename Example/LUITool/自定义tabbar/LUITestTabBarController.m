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
        UIViewController *vc = [[MKUICustomTabBarControllerParamListViewController alloc] init];
        [viewControllers addObject:vc];
    }
    {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[MKUICustomTabBarControllerParamListViewController new]];
        nav.l_customTabBarItem.title = @"嵌套Nav";
        nav.mk_customTabBarItem.badgeValue = @"1";
        nav.mk_customTabBarItem.image = Menu.randomImage;
        nav.mk_customTabBarItem.badgeStyle = MKUICustomTabBarItemBadgeStyleDot;
        [viewControllers addObject:nav];
    }
    {
        UIViewController *vc = [[UIViewController alloc] init];
        vc.mk_customTabBarItem.itemCellClass = MKUICustomTabBarItemCellViewTestBigIcon.class;
        vc.mk_customTabBarItem.image = Menu.randomImage;
        [viewControllers addObject:vc];
        self.blankViewController = vc;
    }
    {
        UIViewController *vc = [[FunTableViewController alloc] init];
        vc.mk_customTabBarItem.itemCellClass = MKUICustomTabBarItemCellViewTestBigIcon.class;
        vc.mk_customTabBarItem.image = Menu.randomImage;
        [viewControllers addObject:vc];
    }
    {
        UIViewController *vc = [[TestUITabBarController alloc] init];
        [viewControllers addObject:vc];
    }
    {
        UIViewController *vc = [[UIViewController alloc] init];
        vc.view.backgroundColor = UIColor.redColor;
        [viewControllers addObject:vc];
    }
    self.viewControllers = viewControllers;
    self.selectedIndex = 1;
    self.delegate = self;
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
#pragma mark -delegate:MKUICustomTabBarControllerDelegate
- (void)customTabBarController:(MKUICustomTabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    [self _configNavigationForViewController:viewController];
}
- (BOOL)customTabBarController:(MKUICustomTabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    if(viewController==self.blankViewController){//点击了特殊的空白名称，此时不进行选中，弹一个提示窗
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"点击空白视图" message:nil preferredStyle:(UIAlertControllerStyleAlert)];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        return NO;
    }
    if(tabBarController.selectedViewController==viewController){//再次点击选中的vc
        NSArray<UIScrollView *> *scrollViews = [viewController.view mk_subviewsWithClass:UIScrollView.class resursion:YES];
        for(UIScrollView *scrollView in scrollViews){
            [scrollView mk_scrollToTopWithAnimated:YES];
        }
    }
    return YES;
}
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
