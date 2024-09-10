//
//  LUIMenuCollectionViewCell.m
//  LUITool_Example
//
//  Created by 六月 on 2023/9/10.
//  Copyright © 2024 Your Name. All rights reserved.
//

#import "LUIMenuCollectionViewCell.h"
#import "LUIMenuGroup.h"

@interface LUIMenuCollectionViewCell ()

@property (nonatomic, strong) LUILayoutButton *menuButton;

@end

@implementation LUIMenuCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.menuButton = [[LUILayoutButton alloc] initWithContentStyle:(LUILayoutButtonContentStyleVertical)];
        self.menuButton.imageSize = CGSizeMake(30, 30);
        self.menuButton.interitemSpacing = 10;
        [self.menuButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
        [self.menuButton setTitleColor:[UIColor systemGrayColor] forState:UIControlStateHighlighted];
        self.menuButton.titleLabel.font = [UIFont systemFontOfSize:12];
        self.menuButton.titleLabel.numberOfLines = 2;
        self.menuButton.contentInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        [self.menuButton addTarget:self action:@selector(__buttonDidTap:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.menuButton];
        self.contentView.clipsToBounds = YES;
        self.layer.borderColor = [UIColor grayColor].CGColor;
        self.layer.borderWidth = 1;
    }
    return self;
}

- (void)__buttonDidTap:(id)sender{
    [self.collectionCellModel didClickSelf];
}

- (void)customLayoutSubviews {
    [super customLayoutSubviews];
    CGRect bounds = self.contentView.bounds;
    self.menuButton.frame = bounds;
}

- (CGSize)customSizeThatFits:(CGSize)size {
    [super customSizeThatFits:size];
    CGSize s = [self.menuButton sizeThatFits:size];
    CGSize sizeFits = [LUICGRect scaleSize:s aspectFitToMaxSize:CGSizeMake(100, 100)];
    return sizeFits;
}

- (void)customReloadCellModel {
    [super customReloadCellModel];
    LUIMenu *modelObject = self.collectionCellModel.modelValue;
    [self.menuButton setTitle:modelObject.title forState:UIControlStateNormal];
    [self.menuButton setImage:modelObject.icon forState:UIControlStateNormal];
}

@end
