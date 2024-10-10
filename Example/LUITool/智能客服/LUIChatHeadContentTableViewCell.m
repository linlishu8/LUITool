//
//  LUIChatHeadContentTableViewCell.m
//  LUITool_Example
//
//  Created by 六月 on 2024/10/10.
//  Copyright © 2024 Your Name. All rights reserved.
//

#import "LUIChatHeadContentTableViewCell.h"

@interface LUIChatHeadContentTableViewCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) LUIFlowLayoutConstraint *flowlayout;

@end

@implementation LUIChatHeadContentTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.textColor = UIColor.blackColor;
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        self.titleLabel.numberOfLines = 0;
        [self.contentView addSubview:self.titleLabel];

        self.flowlayout = [[LUIFlowLayoutConstraint alloc] initWithItems:@[self.titleLabel] constraintParam:(LUIFlowLayoutConstraintParam_H_C_C) contentInsets:UIEdgeInsetsZero interitemSpacing:0];
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

    self.titleLabel.text = self.cellModel.modelValue;
}

- (CGSize)customSizeThatFits:(CGSize)size{
    return [self.flowlayout sizeThatFits:size resizeItems:YES];
}

@end
