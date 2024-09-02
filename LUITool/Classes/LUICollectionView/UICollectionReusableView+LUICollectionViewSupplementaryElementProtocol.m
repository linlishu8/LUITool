//
//  UICollectionReusableView+LUICollectionViewSupplementaryElementProtocol.m
//  LUITool
//
//  Created by 六月 on 2023/8/16.
//

#import "UICollectionReusableView+LUICollectionViewSupplementaryElementProtocol.h"
#import "UIScrollView+LUI.h"
#import "UICollectionViewFlowLayout+LUI.h"

@implementation UICollectionReusableView (LUICollectionViewSupplementaryElementProtocol)
+ (CGSize)dynamicReferenceSizeWithCollectionView:(UICollectionView *)collectionView collectionSectionModel:(LUICollectionViewSectionModel *)sectionModel forKind:(NSString *)kind viewShareInstance:(UICollectionReusableView<LUICollectionViewSupplementaryElementProtocol> *)view calBlock:(CGSize(^)(UICollectionView *collectionView,LUICollectionViewSectionModel *sectionModel,NSString *kind,id view))block{
    CGSize size = CGSizeZero;
    
    UICollectionViewFlowLayout *flowlayout = collectionView.l_collectionViewFlowLayout;
    CGRect bounds = collectionView.l_contentBounds;
    CGRect originBounds = view.bounds;
    
    if (flowlayout) {
        if (flowlayout.scrollDirection == UICollectionViewScrollDirectionVertical) {
            bounds.size.height = 99999999;
        } else {
            bounds.size.width = 99999999;
        }
    }
    
    bounds.origin = CGPointZero;
    view.bounds = bounds;
    [view setCollectionSectionModel:sectionModel forKind:kind];
    [view setNeedsLayout];
    [view layoutIfNeeded];
    if (block) {
        size = block(collectionView,sectionModel,kind,view);
    }
    [view setCollectionSectionModel:nil forKind:kind];
    view.bounds = originBounds;

    //限制view不能超过view可布局区域的范围
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
