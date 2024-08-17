//
//  LUIMainViewTableViewCell.m
//  LUITool_Example
//
//  Created by 六月 on 2024/8/17.
//  Copyright © 2024 Your Name. All rights reserved.
//

#import "LUIMainViewTableViewCell.h"

@interface LUIMainViewTableViewCell ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) LUIFlowLayoutConstraint *flowlayout;

@end

@implementation LUIMainViewTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:self.titleLabel];
        
        self.flowlayout = [[LUIFlowLayoutConstraint alloc] initWithItems:@[self.titleLabel] constraintParam:LUIFlowLayoutConstraintParam_H_C_C contentInsets:UIEdgeInsetsZero interitemSpacing:0];
    }
    return self;
}

- (void)customReloadCellModel {
    [super customReloadCellModel];
    
    self.titleLabel.text = self.cellModel.modelValue;
}

- (void)customLayoutSubviews {
    [super customLayoutSubviews];
    CGRect bounds = self.contentView.bounds;
    self.flowlayout.bounds = bounds;
    [self.flowlayout layoutItemsWithResizeItems:YES];
}

- (CGSize)customSizeThatFits:(CGSize)size {
    CGSize s = [self.flowlayout sizeThatFits:size resizeItems:YES];
    s.height = MAX(s.height, 30);
    return s;
}

#pragma mark - getters and setters

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = UIColor.blackColor;
        _titleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _titleLabel;
}

@end
