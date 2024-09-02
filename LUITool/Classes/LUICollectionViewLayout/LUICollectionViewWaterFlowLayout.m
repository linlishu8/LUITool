//
//  LUICollectionViewWaterFlowLayout.m
//  LUITool
//
//  Created by 六月 on 2023/8/19.
//

#import "LUICollectionViewWaterFlowLayout.h"
#import "LUIWaterFlowLayoutConstraint.h"
#import "LUIFlowLayoutConstraint.h"
#import "NSArray+LUI_BinarySearch.h"
#import "CGGeometry+LUI.h"
#import "NSArray+LUI.h"
#import "UIScrollView+LUI.h"
NSString *const LUICollectionElementKindWaterFlowSectionLastLineItem=@"LUICollectionElementKindWaterFlowSectionLastLineItem";

@interface _LUICollectionViewWaterFlowLayoutLastLineItemLayoutAttributes : UICollectionViewLayoutAttributes
@property (nonatomic, strong) LUICollectionViewWaterFlowLayoutLastLineItemOption *lastLineItemOption;
+ (instancetype)layoutAttributesForLastLineItemReferenceOption:(LUICollectionViewWaterFlowLayoutLastLineItemOption *)lastLineItemOption withSectionIndex:(NSInteger)sectionIndex;
@end

@interface _LUICollectionViewWaterFlowLayoutCellAttributes : UICollectionViewLayoutAttributes
@property (nonatomic, weak) LUICollectionViewWaterFlowLayout *collectionLayout;//弱引用
@end

@implementation _LUICollectionViewWaterFlowLayoutCellAttributes
- (CGSize)sizeThatFits:(CGSize)size {
    CGSize s = [self.collectionLayout itemSizeForSectionAtIndexPath:self.indexPath fits:size];
    return s;
}
@end

@implementation _LUICollectionViewWaterFlowLayoutLastLineItemLayoutAttributes
+ (instancetype)layoutAttributesForLastLineItemReferenceOption:(LUICollectionViewWaterFlowLayoutLastLineItemOption *)lastLineItemOption withSectionIndex:(NSInteger)sectionIndex {
    _LUICollectionViewWaterFlowLayoutLastLineItemLayoutAttributes *attr = [self.class layoutAttributesForSupplementaryViewOfKind:LUICollectionElementKindWaterFlowSectionLastLineItem withIndexPath:[NSIndexPath indexPathWithIndex:sectionIndex]];
    attr.lastLineItemOption = lastLineItemOption;
    attr.size = lastLineItemOption.lastLineItemSize;
    return attr;
}
@end

@interface _LUICollectionViewWaterFlowLayoutSectionModel : NSObject<LUILayoutConstraintItemProtocol>
@property (nonatomic) UICollectionViewScrollDirection scrollDirection; // default is UICollectionViewScrollDirectionHorizontal
@property (nonatomic) LUICGRectAlignment itemAlignment;//元素在与滚动方向垂直方向上的布局对齐参数，默认为居中LUICGRectAlignmentMid
@property (nonatomic, strong) LUIWaterFlowLayoutConstraint *waterFlowLayout;
@property (nonatomic) UIEdgeInsets sectionInset;//默认为zero
@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes *> *cellAttributes;
@property (nonatomic, strong, nullable) UICollectionViewLayoutAttributes *headAttribute;
@property (nonatomic, strong, nullable) UICollectionViewLayoutAttributes *footAttribute;
@property (nonatomic, strong, nullable) _LUICollectionViewWaterFlowLayoutLastLineItemLayoutAttributes *lastLineItemAttribute;

@property (nonatomic, assign) CGRect frame;

@property (nonatomic, readonly) LUICGAxis scrollAxis;
@end
@implementation _LUICollectionViewWaterFlowLayoutSectionModel
- (id)init {
    if (self = [super init]) {
        self.cellAttributes = [[NSMutableArray alloc] init];
        self.waterFlowLayout = [[LUIWaterFlowLayoutConstraint alloc] init];
    }
    return self;
}
- (LUICGAxis)scrollAxis {
    LUICGAxis X = self.scrollDirection==UICollectionViewScrollDirectionVertical?LUICGAxisX:LUICGAxisY;
    return X;
}
- (void)setLastLineItemAttribute:(_LUICollectionViewWaterFlowLayoutLastLineItemLayoutAttributes *)lastLineItemAttribute {
    _lastLineItemAttribute = lastLineItemAttribute;
}
- (void)__configWaterFlowLayout {
    LUICollectionViewWaterFlowLayoutLastLineItemOption *option = self.lastLineItemAttribute.lastLineItemOption;
    self.waterFlowLayout.maxLines = option.maxLines;
    self.waterFlowLayout.lastLineItem = self.lastLineItemAttribute;
    self.waterFlowLayout.showLastLineItemWithinMaxLine = option.showLastLineItemWithinMaxLine;
    
    if (self.scrollDirection==UICollectionViewScrollDirectionVertical) {
        self.waterFlowLayout.layoutDirection = LUILayoutConstraintDirectionHorizontal;
        switch (self.itemAlignment)  {
            case LUICGRectAlignmentMin:
                self.waterFlowLayout.layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentTop;
                break;
            case LUICGRectAlignmentMid:
                self.waterFlowLayout.layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentCenter;
                break;
            case LUICGRectAlignmentMax:
                self.waterFlowLayout.layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentBottom;
                break;
            default:
                break;
        }
        self.waterFlowLayout.layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentLeft;
    }else {
        self.waterFlowLayout.layoutDirection = LUILayoutConstraintDirectionVertical;
        switch (self.itemAlignment)  {
            case LUICGRectAlignmentMin:
                self.waterFlowLayout.layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentLeft;
                break;
            case LUICGRectAlignmentMid:
                self.waterFlowLayout.layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentCenter;
                break;
            case LUICGRectAlignmentMax:
                self.waterFlowLayout.layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentRight;
                break;
            default:
                break;
        }
        self.waterFlowLayout.layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentCenter;
    }
}
- (void)addCellAttributes:(UICollectionViewLayoutAttributes *)cellAttr {
    if (!cellAttr) return;
    [self.cellAttributes addObject:cellAttr];
    [self.waterFlowLayout addItem:cellAttr];
}

- (nullable UICollectionViewLayoutAttributes *)cellAttributesForItemAtIndex:(NSInteger)index {
    if (index>=0&&index<self.cellAttributes.count) {
        return self.cellAttributes[index];
    }
    return nil;
}
- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind {
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        return self.headAttribute;
    }
    if ([elementKind isEqualToString:UICollectionElementKindSectionFooter]) {
        return self.footAttribute;
    }
    if ([elementKind isEqualToString:LUICollectionElementKindWaterFlowSectionLastLineItem]) {
        return self.lastLineItemAttribute;
    }
    return nil;
}
- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    LUICGAxis X = self.scrollAxis;
    LUICGAxis Y = LUICGAxisReverse(X);
    NSMutableArray<UICollectionViewLayoutAttributes *> *layoutAttributes = [[NSMutableArray alloc] init];
    if (self.headAttribute && LUICGRectCompareWithCGRect(self.headAttribute.frame, rect, Y)==NSOrderedSame) {
        [layoutAttributes addObject:self.headAttribute];
    }
    
    NSRange lineRange = [self.waterFlowLayout.itemAttributeSection.itemAttributs l_rangeOfSortedObjectsWithComparator:^NSComparisonResult(LUILayoutConstraintItemAttributeSection *_Nonnull arrayObj, NSInteger idx)  {
        return LUICGRectCompareWithCGRect(arrayObj.layoutFrame, rect, Y);
    }];
    if (lineRange.length>0)for (int i=0;i<lineRange.length;i++) {
        LUILayoutConstraintItemAttributeSection *line = self.waterFlowLayout.itemAttributeSection.itemAttributs[i+lineRange.location];
        for (LUILayoutConstraintItemAttribute *itemAttr in line.itemAttributs) {
            UICollectionViewLayoutAttributes *cellAttr = (UICollectionViewLayoutAttributes *)itemAttr.item;
            [layoutAttributes addObject:cellAttr];
        }
    }
    if (self.footAttribute && LUICGRectCompareWithCGRect(self.footAttribute.frame, rect, Y)==NSOrderedSame) {
        [layoutAttributes addObject:self.footAttribute];
    }
    //过滤掉空
    NSArray<UICollectionViewLayoutAttributes *> *result = [layoutAttributes l_map:^id _Nullable(UICollectionViewLayoutAttributes * _Nonnull obj)  {
        CGSize s = obj.size;
        if (s.width>0 && s.height>0) {
            return obj;
        }
        return nil;
    }];
    return result;
}
- (LUIFlowLayoutConstraint *)_createFlowlayout {
    LUIFlowLayoutConstraintParam param = self.scrollDirection==UICollectionViewScrollDirectionVertical?LUIFlowLayoutConstraintParam_V_T_L:LUIFlowLayoutConstraintParam_H_T_L;
    LUIFlowLayoutConstraint *flowlayout = [[LUIFlowLayoutConstraint alloc] initWithItems:nil constraintParam:(param) contentInsets:self.sectionInset interitemSpacing:0];
    [flowlayout addItem:self.headAttribute];
    [flowlayout addItem:self.waterFlowLayout];
    [flowlayout addItem:self.footAttribute];

    return flowlayout;
}
#pragma mark - protocol:LUILayoutConstraintItemProtocol
- (void)setLayoutFrame:(CGRect)frame {
    self.frame = frame;
}
- (CGRect)layoutFrame {
    return self.frame;
}
- (CGSize)sizeOfLayout {
    return self.frame.size;
}
- (BOOL)hidden {
    return NO;
}
- (void)setLayoutTransform:(CGAffineTransform)transform {
}
- (CGSize)sizeThatFits:(CGSize)size {
    return [self sizeThatFits:size resizeItems:YES];
}
- (CGSize)sizeThatFits:(CGSize)size resizeItems:(BOOL)resizeItems {
    LUIFlowLayoutConstraint *flowlayout = [self _createFlowlayout];
    CGSize s = [flowlayout sizeThatFits:size resizeItems:resizeItems];
    return s;
}
- (void)layoutItemsWithResizeItems:(BOOL)resizeItems {
    LUIFlowLayoutConstraint *flowlayout = [self _createFlowlayout];
    flowlayout.bounds = self.frame;
    [flowlayout layoutItemsWithResizeItems:resizeItems];
}
@end

@interface LUICollectionViewWaterFlowLayout() {
    BOOL _isSizeFitting;
    CGSize _contentSize;
}
@property (nonatomic, strong) NSMutableArray<_LUICollectionViewWaterFlowLayoutSectionModel *> *sectionModels;

@end

@implementation LUICollectionViewWaterFlowLayout
- (id)init {
    if (self = [super init]) {
        self.sectionModels = [[NSMutableArray alloc] init];
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    return self;
}
- (NSArray<_LUICollectionViewWaterFlowLayoutSectionModel *> *)__prepareAllAttribuesWithBounds:(CGRect)bounds contentSize:(CGSize *)contentSize {
    LUICGAxis X = self.scrollAxis;
    LUICGAxis Y = LUICGAxisReverse(X);
    NSInteger numberOfSections = self.collectionView.numberOfSections;
    NSMutableArray<_LUICollectionViewWaterFlowLayoutSectionModel *> *sectionModels = [[NSMutableArray alloc] initWithCapacity:numberOfSections];
    
    LUIFlowLayoutConstraintParam param = self.scrollDirection==UICollectionViewScrollDirectionVertical?LUIFlowLayoutConstraintParam_V_T_L:LUIFlowLayoutConstraintParam_H_T_L;
    LUIFlowLayoutConstraint *flowlayout = [[LUIFlowLayoutConstraint alloc] initWithItems:nil constraintParam:(param) contentInsets:UIEdgeInsetsZero interitemSpacing:self.sectionSpacing];
    
    for (int i=0;i<numberOfSections;i++) {
        NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:i];
        _LUICollectionViewWaterFlowLayoutSectionModel *sm = [[_LUICollectionViewWaterFlowLayoutSectionModel alloc] init];
        sm.scrollDirection = self.scrollDirection;
        sm.itemAlignment = self.itemAlignment;
        sm.sectionInset = [self insetForSectionAtIndex:i];
        sm.waterFlowLayout.interitemSpacing = [self interitemSpacingForSectionAtIndex:i];
        sm.waterFlowLayout.lineSpacing = [self lineSpacingForSectionAtIndex:i];
        [sectionModels addObject:sm];
         {//分组头部
            NSString *kind = UICollectionElementKindSectionHeader;
            CGSize size = [self referenceSizeForHeaderInSection:i];
            CGFloat w = LUICGSizeGetLength(size, X);
            CGFloat h = LUICGSizeGetLength(size, Y);
            if (w>0 && h>0) {
                UICollectionViewLayoutAttributes *suppleAttr = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:[NSIndexPath indexPathWithIndex:i]];
                suppleAttr.size = size;
                sm.headAttribute = suppleAttr;
            }
        }
         {//分组尾部
            NSString *kind = UICollectionElementKindSectionFooter;
            CGSize size = [self referenceSizeForFooterInSection:i];
            CGFloat w = LUICGSizeGetLength(size, X);
            CGFloat h = LUICGSizeGetLength(size, Y);
            if (w>0 && h>0) {
                UICollectionViewLayoutAttributes *suppleAttr = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:[NSIndexPath indexPathWithIndex:i]];
                suppleAttr.size = size;
                sm.footAttribute = suppleAttr;
            }
        }
         {//分组最后一行最后一个元素视图
            LUICollectionViewWaterFlowLayoutLastLineItemOption *option = [self referenceOptionForLastLineItemInSection:i];
            if (option) {
                _LUICollectionViewWaterFlowLayoutLastLineItemLayoutAttributes *suppleAttr = [_LUICollectionViewWaterFlowLayoutLastLineItemLayoutAttributes layoutAttributesForLastLineItemReferenceOption:option withSectionIndex:i];
                sm.lastLineItemAttribute = suppleAttr;
            }
        }
        
        for (int j=0;j<numberOfItems;j++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:j inSection:i];
            _LUICollectionViewWaterFlowLayoutCellAttributes *cellAttr = [_LUICollectionViewWaterFlowLayoutCellAttributes layoutAttributesForCellWithIndexPath:indexPath];
            cellAttr.collectionLayout = self;
            [sm addCellAttributes:cellAttr];
        }
        [sm __configWaterFlowLayout];
        [flowlayout addItem:sm];
    }
    CGRect f1 = bounds;
    LUICGRectSetLength(&f1, Y, 99999999);
    flowlayout.bounds = f1;
    [flowlayout layoutItemsWithResizeItems:YES];
    if (contentSize!=NULL) {
        CGSize size = [flowlayout sizeThatFits:f1.size resizeItems:NO];
        *contentSize = size;
    }
    return sectionModels;
}
- (nullable _LUICollectionViewWaterFlowLayoutSectionModel *)_sectionModelWithIndex:(NSInteger)sectionIndex {
    _LUICollectionViewWaterFlowLayoutSectionModel *sm = nil;
    if (sectionIndex>=0 && sectionIndex<self.sectionModels.count) {
        sm = self.sectionModels[sectionIndex];
    }
    return sm;
}
#pragma mark - public
- (LUICGAxis)scrollAxis {
    LUICGAxis X = self.scrollDirection==UICollectionViewScrollDirectionVertical?LUICGAxisX:LUICGAxisY;
    return X;
}
#pragma mark - UISubclassingHooks
// The collection view calls -prepareLayout once at its first layout as the first message to the layout instance.
// The collection view calls -prepareLayout again after layout is invalidated and before requerying the layout information.
// Subclasses should always call super if they override.
- (void)prepareLayout {
    CGSize contentSize = CGSizeZero;
    CGRect contentBounds = self.collectionView.l_contentBounds;
    contentBounds.origin = CGPointZero;
    NSArray<_LUICollectionViewWaterFlowLayoutSectionModel *> *sectionModels = [self __prepareAllAttribuesWithBounds:contentBounds contentSize:&contentSize];
    [self.sectionModels removeAllObjects];
    [self.sectionModels addObjectsFromArray:sectionModels];
    _contentSize = contentSize;
}

// UICollectionView calls these four methods to determine the layout information.
// Implement -layoutAttributesForElementsInRect: to return layout attributes for for supplementary or decoration views, or to perform layout in an as-needed-on-screen fashion.
// Additionally, all layout subclasses should implement -layoutAttributesForItemAtIndexPath: to return layout attributes instances on demand for specific index paths.
// If the layout supports any supplementary or decoration view types, it should also implement the respective atIndexPath: methods for those types.
- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray<UICollectionViewLayoutAttributes *> *layoutAttributes = [[NSMutableArray alloc] init];
    
    LUICGAxis X = self.scrollAxis;
    LUICGAxis Y = LUICGAxisReverse(X);
    NSRange sectionModelRange = [self.sectionModels l_rangeOfSortedObjectsWithComparator:^NSComparisonResult(_LUICollectionViewWaterFlowLayoutSectionModel * _Nonnull arrayObj, NSInteger idx)  {
        CGRect f1 = arrayObj.frame;
        return LUICGRectCompareWithCGRect(f1, rect, Y);
    }];
    if (sectionModelRange.length==0) return nil;
    for (int i=0;i<sectionModelRange.length;i++) {
        _LUICollectionViewWaterFlowLayoutSectionModel *sm = self.sectionModels[sectionModelRange.location+i];
        [layoutAttributes addObjectsFromArray:[sm layoutAttributesForElementsInRect:rect]];
    }
    return layoutAttributes;
}
- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    _LUICollectionViewWaterFlowLayoutSectionModel *sm = [self _sectionModelWithIndex:indexPath.section];
    UICollectionViewLayoutAttributes *cellAttr = [sm cellAttributesForItemAtIndex:indexPath.item];
    return cellAttr;
}
- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    _LUICollectionViewWaterFlowLayoutSectionModel *sm = [self _sectionModelWithIndex:indexPath.section];
    UICollectionViewLayoutAttributes *attr = [sm layoutAttributesForSupplementaryViewOfKind:elementKind];
    return attr;
}
- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString*)elementKind atIndexPath:(NSIndexPath *)indexPath {
    return nil;
}
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    if (_isSizeFitting)return NO;
    CGRect bounds = self.collectionView.bounds;
    if (!CGSizeEqualToSize(newBounds.size, bounds.size)) {
        return YES;
    }
    return NO;
}
- (CGSize)collectionViewContentSize {
    return _contentSize;
}
@end


@implementation LUICollectionViewWaterFlowLayout(SizeFits)
- (CGSize)l_sizeThatFits:(CGSize)size {
    LUICGAxis X = self.scrollAxis;
    LUICGAxis Y = LUICGAxisReverse(X);
    CGSize sizeFits = CGSizeZero;
    CGRect originBounds = self.collectionView.bounds;
    CGRect bounds = originBounds;
    UIEdgeInsets insets = self.collectionView.l_adjustedContentInset;
    _isSizeFitting = YES;
    BOOL sizeChange = LUICGRectGetLength(bounds, X)!=LUICGSizeGetLength(size, X);
    if (sizeChange) {
        bounds.size = size;
        self.collectionView.bounds = bounds;
    }
    
    CGSize contentSize = CGSizeZero;
    CGRect contentBounds = self.collectionView.l_contentBounds;
    contentBounds.origin = CGPointZero;
    [self __prepareAllAttribuesWithBounds:contentBounds contentSize:&contentSize];
    
    if (sizeChange) {
        self.collectionView.bounds = originBounds;
    }
    sizeFits = contentSize;
    
    CGFloat h = LUICGSizeGetLength(sizeFits, Y);
    CGFloat w = LUICGSizeGetLength(sizeFits, X);
    if (h>0) {
        h += LUIEdgeInsetsGetEdgeSum(insets, Y);
        LUICGSizeSetLength(&sizeFits, Y, h);
    }
    if (w>0) {
        w += LUIEdgeInsetsGetEdgeSum(insets, X);
        LUICGSizeSetLength(&sizeFits, X, w);
    }

    
    //消除浮点误差
    sizeFits.width = ceil(sizeFits.width);
    sizeFits.height = ceil(sizeFits.height);
    _isSizeFitting = NO;
    return sizeFits;
}
@end

@implementation LUICollectionViewWaterFlowLayout(LUICollectionViewDelegateWaterFlowLayout)
- (id<LUICollectionViewDelegateWaterFlowLayout>)waterFlowDelegate {
    if ([self.collectionView.delegate conformsToProtocol:@protocol(LUICollectionViewDelegateWaterFlowLayout)]) {
        return (id<LUICollectionViewDelegateWaterFlowLayout>)self.collectionView.delegate;
    }
    return nil;
}
- (CGSize)itemSizeForSectionAtIndexPath:(NSIndexPath *)indexPath fits:(CGSize)fitsSize {
    id<LUICollectionViewDelegateWaterFlowLayout> delegate = self.waterFlowDelegate;
    CGSize value = self.itemSize;
    if ([delegate respondsToSelector:@selector(collectionView:waterFlowLayout:itemSizeForItemAtIndexPath:fits:)]) {
        value = [delegate collectionView:self.collectionView waterFlowLayout:self itemSizeForItemAtIndexPath:indexPath fits:fitsSize];
    }
    return value;
}
- (UIEdgeInsets)insetForSectionAtIndex:(NSInteger)section {
    id<LUICollectionViewDelegateWaterFlowLayout> delegate = self.waterFlowDelegate;
    UIEdgeInsets value = self.sectionInset;
    if ([delegate respondsToSelector:@selector(collectionView:waterFlowLayout:insetForSectionAtIndex:)]) {
        value = [delegate collectionView:self.collectionView waterFlowLayout:self insetForSectionAtIndex:section];
    }
    return value;
}
- (CGFloat)interitemSpacingForSectionAtIndex:(NSInteger)section {
    id<LUICollectionViewDelegateWaterFlowLayout> delegate = self.waterFlowDelegate;
    CGFloat value = self.interitemSpacing;
    if ([delegate respondsToSelector:@selector(collectionView:waterFlowLayout:interitemSpacingForSectionAtIndex:)]) {
        value = [delegate collectionView:self.collectionView waterFlowLayout:self interitemSpacingForSectionAtIndex:section];
    }
    return value;
}
- (CGFloat)lineSpacingForSectionAtIndex:(NSInteger)section {
    id<LUICollectionViewDelegateWaterFlowLayout> delegate = self.waterFlowDelegate;
    CGFloat value = self.lineSpacing;
    if ([delegate respondsToSelector:@selector(collectionView:waterFlowLayout:lineSpacingForSectionAtIndex:)]) {
        value = [delegate collectionView:self.collectionView waterFlowLayout:self lineSpacingForSectionAtIndex:section];
    }
    return value;
}
- (CGSize)referenceSizeForHeaderInSection:(NSInteger)section {
    id<LUICollectionViewDelegateWaterFlowLayout> delegate = self.waterFlowDelegate;
    CGSize value = self.headerReferenceSize;
    if ([delegate respondsToSelector:@selector(collectionView:waterFlowLayout:referenceSizeForHeaderInSection:)]) {
        value = [delegate collectionView:self.collectionView waterFlowLayout:self referenceSizeForHeaderInSection:section];
    }
    return value;
}
- (CGSize)referenceSizeForFooterInSection:(NSInteger)section {
    id<LUICollectionViewDelegateWaterFlowLayout> delegate = self.waterFlowDelegate;
    CGSize value = self.footerReferenceSize;
    if ([delegate respondsToSelector:@selector(collectionView:waterFlowLayout:referenceSizeForHeaderInSection:)]) {
        value = [delegate collectionView:self.collectionView waterFlowLayout:self referenceSizeForFooterInSection:section];
    }
    return value;
}

- (nullable LUICollectionViewWaterFlowLayoutLastLineItemOption *)referenceOptionForLastLineItemInSection:(NSInteger)section; {
    id<LUICollectionViewDelegateWaterFlowLayout> delegate = self.waterFlowDelegate;
    LUICollectionViewWaterFlowLayoutLastLineItemOption *value = self.lastLineItemReferenceOption;
    if ([delegate respondsToSelector:@selector(collectionView:waterFlowLayout:referenceOptionForLastLineItemInSection:)]) {
        value = [delegate collectionView:self.collectionView waterFlowLayout:self referenceOptionForLastLineItemInSection:section];
    }
    return value;
}
@end
@implementation UICollectionView(LUICollectionViewWaterFlowLayout)
- (nullable LUICollectionViewWaterFlowLayout *)l_collectionViewWaterFlowLayout {
    if ([self.collectionViewLayout isKindOfClass:[LUICollectionViewWaterFlowLayout class]]) {
        return (LUICollectionViewWaterFlowLayout *)self.collectionViewLayout;
    }
    return nil;
}
@end

@implementation LUICollectionViewWaterFlowLayoutLastLineItemOption
@end
