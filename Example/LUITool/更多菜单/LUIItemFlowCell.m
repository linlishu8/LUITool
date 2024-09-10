//
//  LUIItemFlowCell.m
//  LUITool_Example
//
//  Created by 六月 on 2023/9/10.
//  Copyright © 2024 Your Name. All rights reserved.
//

#import "LUIItemFlowCell.h"
#import "LUIMenuGroup.h"

@implementation LUIItemFlowCell

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.titleLabel.textColor = [UIColor l_colorWithLight:UIColor.blackColor];
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        self.flowlayout = [[LUIFlowLayoutConstraint alloc] initWithItems:@[self.titleLabel] constraintParam:(LUIFlowLayoutConstraintParam_H_C_C) contentInsets:LUIEdgeInsetsMakeSameEdge(10) interitemSpacing:10];
    }
    return self;
}

- (void)customLayoutSubviews {
    [super customLayoutSubviews];
    CGRect bounds = self.contentView.bounds;
    self.flowlayout.bounds = bounds;
    [self.flowlayout layoutItemsWithResizeItems:YES];
}

- (CGSize)customSizeThatFits:(CGSize)size {
    return [self.flowlayout sizeThatFits:size resizeItems:YES];
}

- (void)customReloadCellModel{
    [super customReloadCellModel];
    LUIMenuGroup *modelValue = self.collectionCellModel.modelValue;
    self.titleLabel.text = modelValue.title;
    BOOL selected = self.collectionCellModel.selected;
    self.titleLabel.font = [UIFont systemFontOfSize:[self.class fontSizeForSelected:selected] weight:[self.class fontWeightForSelected:selected]];
}

+ (CGFloat)fontSizeForSelected:(BOOL)selected{
    return selected ? 20 : 14;
}
+ (CGFloat)fontWeightForSelected:(BOOL)selected{
    return selected?UIFontWeightBold:UIFontWeightRegular;
}
+ (UIColor *)titleColorWithSelected:(BOOL)selected{
    return selected?[UIColor l_colorWithLight:UIColor.systemBlueColor]:[UIColor l_colorWithLight:UIColor.blackColor];
}
- (void)itemFlowCollectionView:(LUItemFlowCollectionView *)view didScrollFromIndex:(NSInteger)fromIndex to:(NSInteger)toIndex progress:(CGFloat)progress{
    [super changeColorForItemFlowCollectionView:view didScrollFromIndex:fromIndex to:toIndex progress:progress];
    [self changeFontFotItemFlowCollectionView:view didScrollFromIndex:fromIndex to:toIndex progress:progress];
}
- (void)changeFontFotItemFlowCollectionView:(LUItemFlowCollectionView *)view didScrollFromIndex:(NSInteger)fromIndex to:(NSInteger)toIndex progress:(CGFloat)progress{
    NSIndexPath *fromIndexPath = [view cellIndexPathForItemIndex:fromIndex];
    NSIndexPath *myIndexPath = self.collectionCellModel.indexPathInModel;
    //字体大小和粗细渐变
    CGFloat fontSize1,fontSize2;
    CGFloat fontWeight1,fontWeight2;
    if([myIndexPath isEqual:fromIndexPath]){//选中->未选中
        fontSize1 = [self.class fontSizeForSelected:YES];
        fontWeight1 = [self.class fontWeightForSelected:YES];
        fontSize2 = [self.class fontSizeForSelected:NO];
        fontWeight2 = [self.class fontWeightForSelected:NO];
    }else{//未选中->选中
        fontSize1 = [self.class fontSizeForSelected:NO];
        fontWeight1 = [self.class fontWeightForSelected:NO];
        fontSize2 = [self.class fontSizeForSelected:YES];
        fontWeight2 = [self.class fontWeightForSelected:YES];
    }
    CGFloat fontSize = LUICGFloatInterpolate(fontSize1, fontSize2, progress);
    CGFloat fontWeight = LUICGFloatInterpolate(fontWeight1, fontWeight2, progress);
    self.titleLabel.font = [UIFont systemFontOfSize:fontSize weight:fontWeight];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}
LUIDEF_SINGLETON(LUIItemFlowCell)
+ (CGSize)sizeWithCollectionView:(UICollectionView *)collectionView collectionCellModel:(__kindof LUICollectionViewCellModel *)collectionCellModel{
    CGRect bounds = collectionView.bounds;
    return [self dynamicSizeWithCollectionView:collectionView collectionCellModel:collectionCellModel cellShareInstance:[self sharedInstance] calBlock:^CGSize(UICollectionView * _Nonnull collectionView, LUICollectionViewCellModel * _Nonnull cellModel, LUIItemFlowCell * cell) {
        BOOL selected = YES;
        cell.titleLabel.font = [UIFont systemFontOfSize:[self.class fontSizeForSelected:selected] weight:[self.class fontWeightForSelected:selected]];//尺寸固定为选中的值
        return [cell sizeThatFits:bounds.size];
    }];
}

@end
