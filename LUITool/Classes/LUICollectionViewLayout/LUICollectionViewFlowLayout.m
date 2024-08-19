//
//  LUICollectionViewFlowLayout.m
//  LUITool
//
//  Created by 六月 on 2024/8/19.
//

#import "LUICollectionViewFlowLayout.h"
#import "CGGeometry+LUI.h"

const NSInteger kLUICollectionViewFlowLayoutNoMaximumInteritemSpacing = -1;

@implementation LUICollectionViewFlowLayout
- (id)init {
    if (self = [super init]) {
        self.maximumInteritemSpacing = kLUICollectionViewFlowLayoutNoMaximumInteritemSpacing;
    }
    return self;
}
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray<UICollectionViewLayoutAttributes *> *originAttrs = [super layoutAttributesForElementsInRect:rect];//attributes已经按indexpath，从小到大排好序了
    NSMutableArray<UICollectionViewLayoutAttributes *> *attributes = [[NSMutableArray alloc] initWithCapacity:originAttrs.count];
    
    NSMutableDictionary<NSNumber *,NSMutableArray<UICollectionViewLayoutAttributes *> *> *sectionCellMaps = [[NSMutableDictionary alloc] init];//每个分组下的cell集合
    for (UICollectionViewLayoutAttributes *attr in originAttrs) {
        if (attr.representedElementCategory == UICollectionElementCategoryCell) {
            /*
             对attr进行copy，是为了解决以下警告：
             2021-03-11 10:11:24.271720+0800 LUITestApp[15747:1656480] UICollectionViewFlowLayout has cached frame mismatch for index path <NSIndexPath: 0x87d16792343e4297> {length = 2, path = 1 - 1} - cached value: { {66, 91}, {64, 65}}; expected value: { {71, 91}, {64, 65}}
             2021-03-11 10:11:24.271841+0800 LUITestApp[15747:1656480] This is likely occurring because the flow layout subclass LUICollectionViewFixInteritemSpacingFlowLayout is modifying attributes returned by UICollectionViewFlowLayout without copying them
             */
            UICollectionViewLayoutAttributes *cellAttr = [attr copy];
            NSIndexPath *p = attr.indexPath;
            NSMutableArray<UICollectionViewLayoutAttributes *> *cells = sectionCellMaps[@(p.section)];
            if (!cells) {
                cells = [[NSMutableArray alloc] init];
                sectionCellMaps[@(p.section)] = cells;
            }
            [cells addObject:cellAttr];
            [attributes addObject:cellAttr];
        } else {
            [attributes addObject:attr];
        }
    }
    
    LUICGAxis X = self.scrollDirection==UICollectionViewScrollDirectionVertical?LUICGAxisX:LUICGAxisY;
    LUICGAxis Y = LUICGAxisReverse(X);
    for (NSNumber *sn in sectionCellMaps) {
        NSInteger section = [sn integerValue];
        NSArray<UICollectionViewLayoutAttributes *> *cells = sectionCellMaps[sn];
        CGFloat maxSpace = [self l_maximumInteritemSpacingForSectionAtIndex:section];
        if (maxSpace == kLUICollectionViewFlowLayoutNoMaximumInteritemSpacing) {
            //不限制最大间隔
            continue;
        }
        //筛选出每一行
        for (int i=1; i<cells.count; i++) {//第0个不需要调整位置
            UICollectionViewLayoutAttributes *preCell = cells[i-1];
            UICollectionViewLayoutAttributes *curCell = cells[i];
            CGRect preFrame = preCell.frame;
            CGRect curFrame = curCell.frame;
            //判断是否在同一行
            if (LUICGRectGetMin(curFrame, Y)>LUICGRectGetMax(preFrame, Y)) {
                continue;//非同一行,不调整
            }
            CGFloat maxX = LUICGRectGetMax(preFrame, X)+maxSpace;
            if (LUICGRectGetMin(curFrame, X)>maxX) {
                LUICGRectSetMin(&curFrame, X, maxX);
                curCell.frame = curFrame;
            }
        }
    }
    return attributes;
}
@end

@implementation LUICollectionViewFlowLayout (LUICollectionViewDelegateFlowLayout)
- (id<LUICollectionViewDelegateFlowLayout>)l_LUIFlowLayoutDelegate {
    id<LUICollectionViewDelegateFlowLayout> delegate;
    if ([self.collectionView.delegate conformsToProtocol:@protocol(LUICollectionViewDelegateFlowLayout)]) {
        delegate = (id<LUICollectionViewDelegateFlowLayout>)self.collectionView.delegate;
    }
    return delegate;
}
- (CGFloat)l_maximumInteritemSpacingForSectionAtIndex:(NSInteger)index {
    UICollectionView *collectionView = self.collectionView;
    id<LUICollectionViewDelegateFlowLayout> delegate = self.l_LUIFlowLayoutDelegate;
    return [delegate respondsToSelector:@selector(collectionView:layout:maximumInteritemSpacingForSectionAtIndex:)]?[delegate collectionView:collectionView layout:self maximumInteritemSpacingForSectionAtIndex:index]:self.maximumInteritemSpacing;
}
@end

@implementation LUICollectionViewFixInteritemSpacingFlowLayout
- (CGFloat)l_maximumInteritemSpacingForSectionAtIndex:(NSInteger)index {
    id<UICollectionViewDelegateFlowLayout> delegate;
    if ([self.collectionView.delegate conformsToProtocol:@protocol(UICollectionViewDelegateFlowLayout)]) {
        delegate = (id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate;
    }
    UICollectionView *collectionView = self.collectionView;
    return [delegate respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)]?[delegate collectionView:collectionView layout:self minimumInteritemSpacingForSectionAtIndex:index]:self.minimumInteritemSpacing;
}
@end
