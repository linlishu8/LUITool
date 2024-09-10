//
//  LUIViewController.m
//  LUITool
//
//  Created by Your Name on 08/10/2024.
//  Copyright (c) 2024 Your Name. All rights reserved.
//

#import "LUIViewController.h"
#import "LUIMainViewTableViewCell.h"
#import "LUIThemeViewController.h"
#import "LUISafeKeyboardViewController.h"
#import "LUIAlertViewController.h"
#import "LUIMenuViewController.h"

@interface LUIViewController ()

@property (nonatomic, strong) LUITableView *tableView;

@end

@implementation LUIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
    [self.view addSubview:self.tableView];
    
    [self __reloadData];
}

- (void)__reloadData {
    lui_weakify(self)
    LUITableViewCellModel *alertCellModel = [self addCellModelWithCellTitle:@"弹窗"];
    alertCellModel.whenClick = ^(__kindof LUITableViewCellModel * _Nonnull cellModel) {
        lui_strongify(self)
        LUIAlertViewController *alertViewController = [[LUIAlertViewController alloc] init];
        [self.navigationController pushViewController:alertViewController animated:YES];
    };
    
    LUITableViewCellModel *themeCellModel = [self addCellModelWithCellTitle:@"主题化"];
    themeCellModel.whenClick = ^(__kindof LUITableViewCellModel * _Nonnull cellModel) {
        lui_strongify(self)
        LUIThemeViewController *themeViewController = [[LUIThemeViewController alloc] init];
        [self.navigationController pushViewController:themeViewController animated:YES];
    };
    
    LUITableViewCellModel *keyBoardCellModel = [self addCellModelWithCellTitle:@"自定义键盘"];
    keyBoardCellModel.whenClick = ^(__kindof LUITableViewCellModel * _Nonnull cellModel) {
        lui_strongify(self)
        LUISafeKeyboardViewController *keyboardViewController = [[LUISafeKeyboardViewController alloc] init];
        [self.navigationController pushViewController:keyboardViewController animated:YES];
    };
    LUITableViewCellModel *chatCellModel = [self addCellModelWithCellTitle:@"聊天"];
    LUITableViewCellModel *ledVerticalCellModel = [self addCellModelWithCellTitle:@"垂直跑马灯"];
    LUITableViewCellModel *menuCellModel = [self addCellModelWithCellTitle:@"菜单"];
    menuCellModel.whenClick = ^(__kindof LUITableViewCellModel * _Nonnull cellModel) {
        lui_strongify(self)
        LUIMenuViewController *menuViewController = [[LUIMenuViewController alloc] init];
        [self.navigationController pushViewController:menuViewController animated:YES];
    };
    [self.tableView.model reloadTableViewData];
}

- (LUITableViewCellModel *)addCellModelWithCellTitle:(NSString *)cellTitle {
    LUITableViewCellModel *cellModel = [[LUITableViewCellModel alloc] init];
    cellModel.cellClass = [LUIMainViewTableViewCell class];
    cellModel.modelValue = cellTitle;
    [self.tableView.model addCellModel:cellModel];
    return cellModel;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGRect bounds = self.safeBounds;
    
    self.tableView.frame = bounds;
}

- (CGRect)safeBounds{
    CGRect fullBounds = self.view.bounds;
    CGRect bounds = fullBounds;
    if (@available(iOS 11.0, *)) {
        bounds = self.view.safeAreaLayoutGuide.layoutFrame;
    } else {
    }
    return bounds;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getters/setters

- (LUITableView *)tableView {
    if (!_tableView) {
        _tableView = [[LUITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.bounces = NO;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.scrollEnabled = NO;
        [_tableView l_hiddenFooterAreaSeparators];
    }
    return _tableView;
}

@end
