//
//  LUICollectionViewModel+UICollectionViewDelegateFlowLayout.m
//  LUITool
//
//  Created by 六月 on 2024/8/16.
//

#import "LUICollectionViewModel+UICollectionViewDelegateFlowLayout.h"

@implementation LUICollectionViewModel (UICollectionViewDelegateFlowLayout)

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    id<UICollectionViewDelegateFlowLayout> forwardDelegate = nil;
    if ([self.forwardDelegate conformsToProtocol:@protocol(UICollectionViewDelegateFlowLayout)]) {
        forwardDelegate = (id<UICollectionViewDelegateFlowLayout>)self.forwardDelegate;
    }
    CGRect bounds = collectionView.bounds;
    CGSize size = CGSizeZero;
    if ([collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]]) {
        UICollectionViewFlowLayout *flowlayout = (UICollectionViewFlowLayout *)collectionViewLayout;
        if (CGSizeEqualToSize(bounds.size,CGSizeZero)) {//flowlayout布局时,0尺寸会出现"the item height must be less that the height of the UICollectionView minus the section insets top and bottom values."的警告,因此直接设置0的itemsize
            size = CGSizeZero;
        } else {
            size = flowlayout.itemSize;
        }
    }
    if ([forwardDelegate respondsToSelector:_cmd]) {
        size = [forwardDelegate collectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:indexPath];
    } else {
        LUICollectionViewCellModel *cm = [self cellModelAtIndexPath:indexPath];
        Class cellClass = cm.cellClass;
        if ([cellClass respondsToSelector:@selector(sizeWithCollectionView:collectionCellModel:)]) {
            size = [cellClass sizeWithCollectionView:collectionView collectionCellModel:cm];
        }
    }
    return size;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    id<UICollectionViewDelegateFlowLayout> forwardDelegate = nil;
    if ([self.forwardDelegate conformsToProtocol:@protocol(UICollectionViewDelegateFlowLayout)]) {
        forwardDelegate = (id<UICollectionViewDelegateFlowLayout>)self.forwardDelegate;
    }
    NSString *kind = UICollectionElementKindSectionHeader;
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionViewLayout;
    CGSize size = flowLayout.headerReferenceSize;
    
    if ([forwardDelegate respondsToSelector:_cmd]) {
        size = [forwardDelegate collectionView:collectionView layout:collectionViewLayout referenceSizeForHeaderInSection:section];
    } else {
        LUICollectionViewSectionModel *sm = (LUICollectionViewSectionModel *)[self sectionModelAtIndex:section];
        Class aClass = [sm supplementaryElementViewClassForKind:kind];
        if (aClass&&[aClass conformsToProtocol:@protocol(LUICollectionViewSupplementaryElementProtocol)]) {
            if ([aClass respondsToSelector:@selector(referenceSizeWithCollectionView:collectionSectionModel:forKind:)]) {
                size = [aClass referenceSizeWithCollectionView:collectionView collectionSectionModel:sm forKind:kind];
            }
        }
    }
    return size;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    id<UICollectionViewDelegateFlowLayout> forwardDelegate = nil;
    if ([self.forwardDelegate conformsToProtocol:@protocol(UICollectionViewDelegateFlowLayout)]) {
        forwardDelegate = (id<UICollectionViewDelegateFlowLayout>)self.forwardDelegate;
    }
    NSString *kind = UICollectionElementKindSectionFooter;
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionViewLayout;
    CGSize size = flowLayout.footerReferenceSize;
    
    if ([forwardDelegate respondsToSelector:_cmd]) {
        size = [forwardDelegate collectionView:collectionView layout:collectionViewLayout referenceSizeForFooterInSection:section];
    } else {
        LUICollectionViewSectionModel *sm = (LUICollectionViewSectionModel *)[self sectionModelAtIndex:section];
        Class aClass = [sm supplementaryElementViewClassForKind:kind];
        if (aClass&&[aClass conformsToProtocol:@protocol(LUICollectionViewSupplementaryElementProtocol)]) {
            if ([aClass respondsToSelector:@selector(referenceSizeWithCollectionView:collectionSectionModel:forKind:)]) {
                size = [aClass referenceSizeWithCollectionView:collectionView collectionSectionModel:sm forKind:kind];
            }
        }
    }
    return size;
}

@end
