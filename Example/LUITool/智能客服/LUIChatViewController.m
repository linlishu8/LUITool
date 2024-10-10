//
//  LUIChatViewController.m
//  LUITool_Example
//
//  Created by 六月 on 2024/10/10.
//  Copyright © 2024 Your Name. All rights reserved.
//

#import "LUIChatViewController.h"
#import "LUIChatHeadTableViewCell.h"

@interface LUIChatViewController ()

@property (nonatomic, strong) LUITableView *tableView;

@end

@implementation LUIChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    
    LUITableViewCellModel *tableViewModel = [[LUITableViewCellModel alloc] init];
    tableViewModel.cellClass = [LUIChatHeadTableViewCell class];
    [self.tableView.model addCellModel:tableViewModel];
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

- (LUITableView *)tableView {
    if (!_tableView) {
        _tableView = [[LUITableView alloc] initWithFrame:CGRectZero style:(UITableViewStylePlain)];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = UIColor.whiteColor;
        [_tableView l_hiddenFooterAreaSeparators];
    }
    return _tableView;
}

@end
