//
//  LUIChatHeadTableViewCell.m
//  LUITool_Example
//
//  Created by 六月 on 2024/10/10.
//  Copyright © 2024 Your Name. All rights reserved.
//

#import "LUIChatHeadTableViewCell.h"
#import "LUIChatHeadContentTableViewCell.h"

@interface LUIChatHeadTableViewCell ()

@property (nonatomic, strong) LUITableView *tableView;
@property (nonatomic, strong) LUIFlowLayoutConstraint *flowlayout;

@end

@implementation LUIChatHeadTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self.contentView addSubview:self.tableView];
        
        LUILayoutConstraintItemWrapper *tableWrapper = [LUILayoutConstraintItemWrapper wrapItem:self.tableView sizeThatFitsBlock:^CGSize(LUILayoutConstraintItemWrapper * _Nonnull wrapper, CGSize size, BOOL resizeItems) {
            CGFloat height = [wrapper.originItem l_heightThatFits:size.width];
            return CGSizeMake(size.width, height);
        }];

        self.flowlayout = [[LUIFlowLayoutConstraint alloc] initWithItems:@[tableWrapper] constraintParam:(LUIFlowLayoutConstraintParam_H_C_C) contentInsets:UIEdgeInsetsZero interitemSpacing:0];
    }
    return self;
}
- (void)customLayoutSubviews {
    [super customLayoutSubviews];

    CGRect bounds = self.contentView.bounds;
    self.flowlayout.bounds = bounds;
    [self.flowlayout layoutItemsWithResizeItems:YES];
}
- (void)customReloadCellModel {
    [super customReloadCellModel];
    
    
    [self __reloadTableView];
}

- (void)__reloadTableView {
    NSArray *titleArray = @[@"阿斯蒂芬撒旦法阿斯蒂芬撒旦法阿斯蒂芬撒旦法阿斯蒂芬撒旦法阿旦法阿斯蒂芬撒旦法阿斯蒂芬撒旦法阿旦法阿斯蒂芬撒旦法阿斯蒂芬撒旦法阿撒旦法阿斯蒂芬撒旦法阿斯蒂芬撒旦法阿斯蒂芬撒旦法", @"阿斯蒂芬撒旦法", @"阿斯蒂芬撒旦法", @"阿斯蒂芬撒旦法"];
    for (NSString *title in titleArray) {
        LUITableViewCellModel *viewModel = [[LUITableViewCellModel alloc] init];
        viewModel.cellClass = [LUIChatHeadContentTableViewCell class];
        viewModel.modelValue = title;
        [self.tableView.model addCellModel:viewModel];
    }
    [self.tableView.model reloadTableViewData];
}

- (CGSize)customSizeThatFits:(CGSize)size{
    return [self.flowlayout sizeThatFits:size resizeItems:YES];
}

#pragma mark - getters/setters

- (LUITableView *)tableView {
    if (!_tableView) {
        _tableView = [[LUITableView alloc] initWithFrame:CGRectZero style:(UITableViewStylePlain)];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = UIColor.clearColor;
        [_tableView l_hiddenFooterAreaSeparators];
    }
    return _tableView;
}


@end
