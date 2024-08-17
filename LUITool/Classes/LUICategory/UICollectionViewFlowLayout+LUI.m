//
//  UICollectionViewFlowLayout+LUI.m
//  LUITool
//
//  Created by 六月 on 2023/8/11.
//

#import "UICollectionViewFlowLayout+LUI.h"
#import "UIScrollView+LUI.h"
#import "CGGeometry+LUI.h"
#import "UICollectionViewFlowLayout+LUI.h"

@implementation UICollectionViewFlowLayout (LUI)

- (id<UICollectionViewDelegateFlowLayout>)l_flowLayoutDelegate {
    id<UICollectionViewDelegateFlowLayout> delegate;
    if ([self.collectionView.delegate conformsToProtocol:@protocol(UICollectionViewDelegateFlowLayout)]) {
        delegate = (id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate;
    }
    return delegate;
}
- (CGSize)l_sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    id<UICollectionViewDelegateFlowLayout> delegate = self.l_flowLayoutDelegate;
    return [delegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)]?[delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath]:self.itemSize;
}
- (UIEdgeInsets)l_insetForSectionAtIndex:(NSInteger)index {
    UICollectionView *collectionView = self.collectionView;
    id<UICollectionViewDelegateFlowLayout> delegate = self.l_flowLayoutDelegate;
    return [delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]?[delegate collectionView:collectionView layout:self insetForSectionAtIndex:index]:self.sectionInset;
}
- (CGFloat)l_minimumLineSpacingForSectionAtIndex:(NSInteger)index {
    UICollectionView *collectionView = self.collectionView;
    id<UICollectionViewDelegateFlowLayout> delegate = self.l_flowLayoutDelegate;
    return [delegate respondsToSelector:@selector(collectionView:layout:minimumLineSpacingForSectionAtIndex:)]?[delegate collectionView:collectionView layout:self minimumLineSpacingForSectionAtIndex:index]:self.minimumLineSpacing;
}
- (CGFloat)l_minimumInteritemSpacingForSectionAtIndex:(NSInteger)index {
    UICollectionView *collectionView = self.collectionView;
    id<UICollectionViewDelegateFlowLayout> delegate = self.l_flowLayoutDelegate;
    return [delegate respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)]?[delegate collectionView:collectionView layout:self minimumInteritemSpacingForSectionAtIndex:index]:self.minimumInteritemSpacing;
}
- (CGSize)l_referenceSizeForFooterInSection:(NSInteger)index {
    UICollectionView *collectionView = self.collectionView;
    id<UICollectionViewDelegateFlowLayout> delegate = self.l_flowLayoutDelegate;
    return [delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForFooterInSection:)]?[delegate collectionView:collectionView layout:self referenceSizeForFooterInSection:index]:self.footerReferenceSize;
}
- (CGSize)l_referenceSizeForHeaderInSection:(NSInteger)index {
    UICollectionView *collectionView = self.collectionView;
    id<UICollectionViewDelegateFlowLayout> delegate = self.l_flowLayoutDelegate;
    return [delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForHeaderInSection:)]?[delegate collectionView:collectionView layout:self referenceSizeForHeaderInSection:index]:self.headerReferenceSize;
}

- (CGRect)l_contentBoundsForSectionAtIndex:(NSInteger)index {
    UICollectionView *collectionView = self.collectionView;
    UIEdgeInsets insets = [self l_insetForSectionAtIndex:index];
    CGRect bounds = collectionView.l_contentBounds;
    bounds.origin = CGPointZero;
    CGRect b = UIEdgeInsetsInsetRect(bounds, insets);
    b.origin = CGPointZero;
    return b;
}
@end
@implementation UICollectionViewFlowLayout (LUI_SizeFits)
- (CGSize)l_sizeThatFits:(CGSize)originBoundsSize {
    CGSize size = originBoundsSize;
    UICollectionViewFlowLayout *flowlayout = self;
    UICollectionViewScrollDirection direction = flowlayout.scrollDirection;
    
    LUICGAxis axis = direction == UICollectionViewScrollDirectionVertical?LUICGAxisX:LUICGAxisY;
    LUICGAxis axisR = LUICGAxisReverse(axis);
    LUICGSizeSetLength(&size, axisR, 99999999);
    
    CGRect originBounds = self.collectionView.bounds;
    CGRect bounds = originBounds;
    bounds.size = originBoundsSize;
    self.collectionView.bounds = bounds;
    
    CGSize sizeFits = CGSizeZero;
    UIEdgeInsets insets = self.collectionView.l_adjustedContentInset;
    size.width -= insets.left+insets.right;
    size.height -= insets.top+insets.bottom;
    
    //由于headerReferenceSize和footerReferenceSize会受bounds尺寸影响，因此要先算出bounds的最合适值，然后再计算head、foot的最合适尺寸
    //由于cell在originBoundsSize限制下，计算出适合的尺寸。这个尺寸会受originBoundsSize影响，在后续真实布局中，originBoundsSize的值可能会改变。因此要二次计算cell的最合适尺寸
    //第一次计算所有cell的最合适尺寸
    CGSize allCellsSize = [self __l_allCellsSizeThatFitsCellBoundsSize:size];//所有cell占用的总区域尺寸
    //如果allCellsSize限制值 != size限制值，代表cell动态计算时，限定的size变更了，需要二次计算
    if (LUICGSizeGetLength(allCellsSize, axis) != LUICGSizeGetLength(size,axis)) {
        CGSize boundsSize = size;
        LUICGSizeSetLength(&boundsSize, axis, LUICGSizeGetLength(allCellsSize, axis));
        
        //更新collectionView的尺寸
        CGRect newBounds = originBounds;
        newBounds.size = originBoundsSize;
        LUICGRectSetLength(&newBounds, axis, LUICGSizeGetLength(allCellsSize, axis)+LUIEdgeInsetsGetEdge(insets, axis, LUIEdgeInsetsMin)+LUIEdgeInsetsGetEdge(insets, axis, LUIEdgeInsetsMax));
        self.collectionView.bounds = newBounds;
        
        allCellsSize = [self __l_allCellsSizeThatFitsCellBoundsSize:boundsSize];
    }
    sizeFits = allCellsSize;
    
    sizeFits.width += insets.left+insets.right;
    sizeFits.height += insets.top+insets.bottom;

    //在计算出cell的占用区域后，在此基础上，计算head和foot的最合适尺寸
    LUICGSizeSetLength(&sizeFits, axis, ceil(LUICGSizeGetLength(sizeFits, axis)));//先消除浮点误差
    LUICGRectSetLength(&bounds, axis, LUICGSizeGetLength(sizeFits, axis));
    self.collectionView.bounds = bounds;
    
    for (int i=0; i<self.collectionView.numberOfSections; i++) {
        CGSize headerReferenceSize = [flowlayout l_referenceSizeForHeaderInSection:i];
        CGSize footerReferenceSize = [flowlayout l_referenceSizeForFooterInSection:i];
        
        LUICGSizeSetLength(&sizeFits, axisR,LUICGSizeGetLength(sizeFits, axisR)+LUICGSizeGetLength(headerReferenceSize, axisR)+LUICGSizeGetLength(footerReferenceSize, axisR));
    }
    
    //消除浮点误差
    sizeFits.width = ceil(sizeFits.width);
    sizeFits.height = ceil(sizeFits.height);
//    NSLog(@"sizeFit:%@",NSStringFromCGSize(sizeFits));
    self.collectionView.bounds = originBounds;
    return sizeFits;
}

//size为cell的限制区域，不包含contentInsets
- (CGSize)__l_allCellsSizeThatFitsCellBoundsSize:(CGSize)size {
    UICollectionViewFlowLayout *flowlayout = self;
    UICollectionViewScrollDirection direction = flowlayout.scrollDirection;
    LUICGAxis X = direction == UICollectionViewScrollDirectionVertical?LUICGAxisX:LUICGAxisY;
    LUICGAxis Y = LUICGAxisReverse(X);
    LUICGSizeSetLength(&size, Y, 99999999);
    
    CGSize allCellsSize = CGSizeZero;//所有cell占用的总区域尺寸,包含了sectionInsets
    for (int i=0; i<self.collectionView.numberOfSections; i++) {
        CGFloat minimumLineSpacing = [flowlayout l_minimumLineSpacingForSectionAtIndex:i];
        CGFloat minimumInteritemSpacing = [flowlayout l_minimumInteritemSpacingForSectionAtIndex:i];
        UIEdgeInsets sectionInset = [flowlayout l_insetForSectionAtIndex:i];
        CGSize boundSize = size;
        boundSize.width -= sectionInset.left+sectionInset.right;
        boundSize.height -= sectionInset.top+sectionInset.bottom;
        
        CGFloat interitemSpacing = X == LUICGAxisX?minimumInteritemSpacing:minimumLineSpacing;
        CGFloat lineSpacing = X == LUICGAxisX?minimumLineSpacing:minimumInteritemSpacing;
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:i];
        CGSize sectionFitSize = CGSizeZero;
        CGSize limitSize = boundSize;
        CGFloat maxHeight = 0;//元素的最大高度
        NSMutableArray<NSNumber *> *widths = [[NSMutableArray alloc] initWithCapacity:itemCount];
        CGFloat maxWidth = 0;//每行的最大宽度
        NSMutableArray<NSNumber *> *heights = [[NSMutableArray alloc] initWithCapacity:itemCount];
        for (int j=0; j<[self.collectionView numberOfItemsInSection:i]; j++) {
            NSIndexPath *p = [NSIndexPath indexPathForItem:j inSection:i];
            CGSize itemSize = [self l_sizeForItemAtIndexPath:p];
            
            //消除itemSize的浮点误差，否则有可能导致collectview在布局时，因为浮点误差，一行会少布局一个元素
            itemSize.width = ceil(itemSize.width);
            itemSize.height = ceil(itemSize.height);
            
            CGFloat w = LUICGSizeGetLength(itemSize, X);
            if (w>0) {
                LUICGSizeSetLength(&limitSize, X, LUICGSizeGetLength(limitSize, X)-w);
                if (LUICGSizeGetLength(limitSize, X)<0) {//当前行已经放不了，需要另起一行
                    CGFloat sumWidth = (widths.count-1)*interitemSpacing;//元素的总长度
                    for (NSNumber *l in widths) {
                        sumWidth += [l floatValue];
                    }
                    maxWidth = MAX(maxWidth,sumWidth);
                    [heights addObject:@(maxHeight)];
                    
                    LUICGSizeSetLength(&limitSize, X, LUICGSizeGetLength(boundSize, X)-w);
                    LUICGSizeSetLength(&limitSize, Y, LUICGSizeGetLength(limitSize, Y)-maxHeight-lineSpacing);
                    maxHeight = 0;
                    [widths removeAllObjects];
                }
                LUICGSizeSetLength(&limitSize, X, LUICGSizeGetLength(limitSize, X)-interitemSpacing);
                maxHeight = MAX(maxHeight,LUICGSizeGetLength(itemSize, Y));
                [widths addObject:@(w)];
            }
        }
        
        if (widths.count) {//处理最后一行
            CGFloat sumWidth = (widths.count-1)*interitemSpacing;//元素的总长度
            for (NSNumber *l in widths) {
                sumWidth += [l floatValue];
            }
            maxWidth = MAX(maxWidth,sumWidth);
            [heights addObject:@(maxHeight)];
        }
        if (heights.count>0) {
            CGFloat sumHeight = (heights.count-1)*lineSpacing;//元素的总长度
            for (NSNumber *l in heights) {
                sumHeight += [l floatValue];
            }
            LUICGSizeSetLength(&sectionFitSize, X, maxWidth);
            LUICGSizeSetLength(&sectionFitSize, Y, sumHeight);
        }
        
        sectionFitSize.width += sectionInset.left+sectionInset.right;
        sectionFitSize.height += sectionInset.top+sectionInset.bottom;
        //
        LUICGSizeSetLength(&allCellsSize, X, MAX(LUICGSizeGetLength(allCellsSize, X),LUICGSizeGetLength(sectionFitSize, X)));
        LUICGSizeSetLength(&allCellsSize,Y,LUICGSizeGetLength(allCellsSize, Y)+LUICGSizeGetLength(sectionFitSize, Y));
    }
    return allCellsSize;
}
@end

@implementation UICollectionView (LUI_UICollectionViewFlowLayout)
- (UICollectionViewFlowLayout *)l_collectionViewFlowLayout {
    if ([self.collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]]) {
        return (UICollectionViewFlowLayout *)self.collectionViewLayout;
    }
    return nil;
}
@end
