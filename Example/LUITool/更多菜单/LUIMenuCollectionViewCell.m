//
//  LUIMenuCollectionViewCell.m
//  LUITool_Example
//
//  Created by 六月 on 2024/9/10.
//  Copyright © 2024 Your Name. All rights reserved.
//

#import "LUIMenuCollectionViewCell.h"

@interface LUIMenuCollectionViewCell ()

@property (nonatomic,strong) UILabel *titleLabel;

@end

@implementation LUIMenuCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.l_listViewGroupBackgroundColor;
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.textColor = [UIColor l_colorWithLight:UIColor.blackColor];
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}
- (void)customLayoutSubviews {
    [super customLayoutSubviews];
    CGRect bounds = self.contentView.bounds;
    self.titleLabel.frame = bounds;
}
- (void)customReloadCellModel {
    [super customReloadCellModel];
    NSString *text = self.collectionCellModel.modelValue;
    self.titleLabel.text = text;
}

@end
