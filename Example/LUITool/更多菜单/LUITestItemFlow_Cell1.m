//
//  LUITestItemFlow_Cell1.m
//  LUITool_Example
//
//  Created by 六月 on 2023/9/10.
//  Copyright © 2024 Your Name. All rights reserved.
//

#import "LUITestItemFlow_Cell1.h"

@interface LUITestItemFlow_Cell1 ()

@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) LUIFlowLayoutConstraint *flowlayout;

@end

@implementation LUITestItemFlow_Cell1

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.l_listViewGroupBackgroundColor;
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.textColor = [UIColor l_colorWithLight:UIColor.blackColor];
        [self.contentView addSubview:self.titleLabel];
        //
        self.flowlayout = [[LUIFlowLayoutConstraint alloc] initWithItems:@[self.titleLabel] constraintParam:(LUIFlowLayoutConstraintParam_H_C_L) contentInsets:LUIEdgeInsetsMakeSameEdge(10) interitemSpacing:10];
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
    NSString *text = self.collectionCellModel.modelValue;
    self.titleLabel.text = text;
}
+ (CGSize)sizeWithCollectionView:(UICollectionView *)collectionView collectionCellModel:(__kindof LUICollectionViewCellModel *)collectionCellModel {
    CGRect bounds = collectionView.bounds;
    return CGSizeMake(bounds.size.width, 50);
}

@end
