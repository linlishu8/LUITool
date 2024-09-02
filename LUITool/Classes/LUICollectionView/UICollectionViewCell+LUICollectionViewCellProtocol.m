//
//  UICollectionViewCell+LUICollectionViewCellProtocol.m
//  LUITool
//
//  Created by 六月 on 2023/8/16.
//

#import "UICollectionViewCell+LUICollectionViewCellProtocol.h"
#import "UIScrollView+LUI.h"
#import "LUICollectionViewCellModel.h"
#import "UICollectionViewFlowLayout+LUI.h"
#import <objc/runtime.h>

@implementation UICollectionViewCell (LUICollectionViewCellProtocol)
#pragma mark - deleagte:LUICollectionViewCellProtocol
- (LUICollectionViewCellModel *)collectionCellModel {
    LUICollectionViewCellModel *cellModel = objc_getAssociatedObject( self, "UICollectionViewCell.LUICollectionViewCellModel.collectionCellModel");
    return cellModel;
}
- (void)setCollectionCellModel:(LUICollectionViewCellModel *)collectionCellModel {
    objc_setAssociatedObject( self, "UICollectionViewCell.LUICollectionViewCellModel.collectionCellModel", collectionCellModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC );
}
+ (CGSize)dynamicSizeWithCollectionView:(UICollectionView *)collectionView collectionCellModel:(LUICollectionViewCellModel *)collectionCellModel cellShareInstance:(UICollectionViewCell<LUICollectionViewCellProtocol> *)cell calBlock:(CGSize(^)(UICollectionView *collectionView,LUICollectionViewCellModel *cellModel,id cell))block{
    
    CGSize size = CGSizeZero;
    CGRect bounds = collectionView.l_contentBounds;
    
    CGRect originBounds = cell.bounds;
    
    UICollectionViewFlowLayout *flowlayout = collectionView.l_collectionViewFlowLayout;
    UIEdgeInsets sectionInsets = UIEdgeInsetsZero;
    if (flowlayout) {
        NSInteger sectionIndex = collectionCellModel.indexPathInModel.section;
        sectionInsets = [flowlayout l_insetForSectionAtIndex:sectionIndex];
        bounds = UIEdgeInsetsInsetRect(bounds, sectionInsets);
    }

    bounds.origin = CGPointZero;
    cell.bounds = bounds;
    cell.collectionCellModel = collectionCellModel;
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    if (block) {
        size = block(collectionView,collectionCellModel,cell);
    }
    cell.collectionCellModel = nil;
    cell.bounds = originBounds;

    //限制itemSize不能超过cell可布局区域的范围
    if (flowlayout) {
        if (flowlayout.scrollDirection == UICollectionViewScrollDirectionVertical) {
            size.width = MIN(size.width,bounds.size.width);
        } else {
            size.height = MIN(size.height,bounds.size.height);
        }
    }
    
    //消除浮点误差
    size.width = ceil(size.width);
    size.height = ceil(size.height);
    return size;
}
@end
