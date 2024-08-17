//
//  LUIViewController.m
//  LUITool
//
//  Created by Your Name on 08/10/2024.
//  Copyright (c) 2024 Your Name. All rights reserved.
//

#import "LUIViewController.h"
#import "LUIMainViewTableViewCell.h"

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
    [self.tableView.model removeAllSectionModels];
    LUITableViewCellModel *alertViewCellModel = [[LUITableViewCellModel alloc] init];
    alertViewCellModel.cellClass = [LUIMainViewTableViewCell class];
    alertViewCellModel.modelValue = @"弹窗";
    [self.tableView.model addCellModel:alertViewCellModel];
    
    [self.tableView.model reloadTableViewData];
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
