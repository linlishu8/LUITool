//
//  LUItemFlowCollectionView.m
//  LUITool
//
//  Created by 六月 on 2023/9/9.
//

#import "LUItemFlowCollectionView.h"
#import "LUICollectionViewModel.h"
#import "UIView+LUI.h"
#import "UICollectionViewFlowLayout+LUI.h"
#import "LUIMacro.h"
#import "UIScrollView+LUI.h"
#import "LUICollectionViewPageFlowLayout.h"
#import "UIColor+LUI.h"
@interface LUItemFlowCollectionView() <LUICollectionViewDelegatePageFlowLayout> {
    BOOL __needReloadData;
}
@property(nonatomic,strong) UICollectionView *collectionView;
@property(nonatomic,strong) LUICollectionViewPageFlowLayout *collectionViewFlowLayout;
@property(nonatomic,strong) LUICollectionViewModel *model;
@property(nonatomic,strong) __kindof UIView *itemIndicatorView;
@end

@implementation LUItemFlowCollectionView
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.collectionViewFlowLayout = [[LUICollectionViewPageFlowLayout alloc] init];
        self.collectionViewFlowLayout.interitemSpacing = 0;
        self.collectionViewFlowLayout.sectionInset = UIEdgeInsetsZero;
        self.collectionViewFlowLayout.scrollDirection = self.scrollDirection == LUItemFlowCollectionViewScrollDirectionHorizontal ? UICollectionViewScrollDirectionHorizontal : UICollectionViewScrollDirectionVertical;
        self.collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:self.collectionViewFlowLayout];
        self.collectionView.backgroundColor = UIColor.clearColor;
        self.collectionView.showsVerticalScrollIndicator = NO;
        self.collectionView.showsHorizontalScrollIndicator = NO;
        [self addSubview:self.collectionView];
        //
        self.model = [[LUICollectionViewModel alloc] initWithCollectionView:self.collectionView];
        self.model.forwardDelegate = self;
        self.separatorColor = UIColor.l_listViewSeparatorColor;
        
        __needReloadData = YES;
        _selectedIndex = NSNotFound;
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    BOOL sizeChange = !CGSizeEqualToSize(self.collectionView.bounds.size, bounds.size);
    self.collectionView.frame = bounds;
    if (__needReloadData || sizeChange) {
        [self __reloadData];
        [self __reloadIndicatorView:YES];
    }
}
- (CGSize)sizeThatFits:(CGSize)size {
    if (__needReloadData) {
        [self __reloadData];
    }
    LUICGAxis X = self.scrollAxis;
    LUICGAxis Y = LUICGAxisReverse(X);
    CGSize s = size;
    CGSize s1 = [self.collectionViewFlowLayout l_sizeThatFits:size];
    LUICGSizeSetLength(&s, Y, LUICGSizeGetLength(s1, Y));
    return s;
}
- (void)setScrollDirection:(LUItemFlowCollectionViewScrollDirection)scrollDirection {
    if (_scrollDirection == scrollDirection) return;
    _scrollDirection = scrollDirection;
    self.collectionViewFlowLayout.scrollDirection = self.scrollDirection == LUItemFlowCollectionViewScrollDirectionHorizontal ? UICollectionViewScrollDirectionHorizontal : UICollectionViewScrollDirectionVertical;
    [self setNeedReloadData];
}
- (LUICGAxis)scrollAxis {
    LUICGAxis X = self.scrollDirection == LUItemFlowCollectionViewScrollDirectionHorizontal ? LUICGAxisX : LUICGAxisY;
    return X;
}
- (void)setItems:(NSArray *)items {
    if (_items == items) return;
    _items = items;
    if (self.selectedIndex != NSNotFound) {
        self.selectedIndex = MIN(self.selectedIndex, self.items.count-1);
    }
    [self setNeedReloadData];
}
- (void)setItemCellClass:(Class)itemCellClass {
    if (_itemCellClass == itemCellClass) return;
    _itemCellClass = itemCellClass;
    [self setNeedReloadData];
}
- (void)setSelectedIndex:(NSInteger)selectedIndex {
    if (selectedIndex < 0 || selectedIndex >= self.items.count) return;
    if (_selectedIndex == selectedIndex) return;
    _selectedIndex = selectedIndex;
    [self setNeedReloadData];
}
- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated {
    if (selectedIndex < 0 || selectedIndex >= self.items.count) return;
    if (_selectedIndex == selectedIndex) return;
    _selectedIndex = selectedIndex;
    [self __reloadData];
    [self.collectionView layoutIfNeeded];
    if (animated) {
        [UIView animateWithDuration:0.25 animations:^{
            [self scrollItemIndicatorViewToIndex:selectedIndex animated:NO];
            [self collectionViewScrollToItemAtIndex:selectedIndex animated:NO];
        }];
    } else {
        [self scrollItemIndicatorViewToIndex:selectedIndex animated:NO];
        [self collectionViewScrollToItemAtIndex:selectedIndex animated:NO];
    }
}
- (CGSize)itemSizeAtIndex:(NSInteger)index collectionCellModel:(LUICollectionViewCellModel *)cellModel {
    CGRect bounds = self.collectionView.bounds;
    CGSize size = CGSizeZero;
    LUICGAxis X = self.scrollAxis;
    LUICGAxis Y = LUICGAxisReverse(X);
    LUICGSizeSetLength(&size, Y, LUICGRectGetLength(bounds, Y));
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(itemFlowCollectionView:itemSizeAtIndex:collectionCellModel:)]) {
        size = [self.delegate itemFlowCollectionView:self itemSizeAtIndex:index collectionCellModel:cellModel];
    }
    return size;
}
- (Class)itemCellClassAtIndex:(NSInteger)index {
    Class c = nil;
    if ([self.delegate respondsToSelector:@selector(itemFlowCollectionView:itemCellClassAtIndex:)]) {
        c = [self.delegate itemFlowCollectionView:self itemCellClassAtIndex:index];
    } else {
        c = self.itemCellClass;
    }
    if (!c) {
        c = LUItemFlowCellView.class;
    }
    return c;
}
- (void)setItemIndicatorViewClass:(Class)itemIndicatorViewClass {
    if (_itemIndicatorViewClass == itemIndicatorViewClass)return;
    [self.itemIndicatorView removeFromSuperview];
    _itemIndicatorViewClass = itemIndicatorViewClass;
    if (self.itemIndicatorViewClass) {
        self.itemIndicatorView = [[self.itemIndicatorViewClass alloc] init];
        self.itemIndicatorView.hidden = YES;
        [self.collectionView addSubview:self.itemIndicatorView];
        [self.collectionView sendSubviewToBack:self.itemIndicatorView];
        [self setNeedReloadData];
    }
}
- (void)scrollItemIndicatorViewFromIndex:(NSInteger)fromIndex to:(NSInteger)toIndex withProgress:(CGFloat)progress {
    if (self.itemIndicatorViewClass == nil)return;
    if (fromIndex < 0 || fromIndex >= self.items.count)return;
    if (toIndex < 0 || toIndex >= self.items.count)return;
    self.itemIndicatorView.frame = [self itemIndicatorRectWithScrollFromIndex:fromIndex to:toIndex withProgress:progress];
    [self.itemIndicatorView layoutIfNeeded];
}
- (void)collectionViewScrollItemFromIndex:(NSInteger)fromIndex to:(NSInteger)toIndex withProgress:(CGFloat)progress {
    if (fromIndex < 0 || fromIndex >= self.items.count)return;
    if (toIndex < 0 || toIndex >= self.items.count)return;
    //
    CGPoint offset0 = [self __contentOffsetWithItemAtIndex:fromIndex];
    CGPoint offset1 = [self __contentOffsetWithItemAtIndex:toIndex];
    CGPoint offset = LUICGPointInterpolate(offset0, offset1, progress);
    self.collectionView.contentOffset = offset;
    //
    UICollectionViewCell *cell0 = [self.collectionView cellForItemAtIndexPath:[self cellIndexPathForItemIndex:fromIndex]];
    if ([cell0 conformsToProtocol:@protocol(LUItemFlowCollectionCellViewDelegate)] && [cell0 respondsToSelector:@selector(itemFlowCollectionView:didScrollFromIndex:to:progress:)]) {
        [(UICollectionViewCell < LUItemFlowCollectionCellViewDelegate> *)cell0 itemFlowCollectionView:self didScrollFromIndex:fromIndex to:toIndex progress:progress];
    }
    UICollectionViewCell *cell1 = [self.collectionView cellForItemAtIndexPath:[self cellIndexPathForItemIndex:toIndex]];
    if ([cell1 conformsToProtocol:@protocol(LUItemFlowCollectionCellViewDelegate)] && [cell1 respondsToSelector:@selector(itemFlowCollectionView:didScrollFromIndex:to:progress:)]) {
        [(UICollectionViewCell < LUItemFlowCollectionCellViewDelegate> *)cell1 itemFlowCollectionView:self didScrollFromIndex:fromIndex to:toIndex progress:progress];
    }
    //处理中间的单元格状态
    NSInteger centerCount = ABS(toIndex-fromIndex);
    if (centerCount>1) for(int i=1;i < centerCount;i++) {
        NSInteger centerIndex = fromIndex+(toIndex>fromIndex?i:-i);
        UICollectionViewCell *cellCenter = [self.collectionView cellForItemAtIndexPath:[self cellIndexPathForItemIndex:centerIndex]];
        if ([cellCenter conformsToProtocol:@protocol(LUItemFlowCollectionCellViewDelegate)] && [cellCenter respondsToSelector:@selector(itemFlowCollectionView:didScrollFromIndex:to:progress:)]) {
            [(UICollectionViewCell < LUItemFlowCollectionCellViewDelegate> *)cellCenter itemFlowCollectionView:self didScrollFromIndex:fromIndex to:toIndex progress:progress];
        }
    }
}
- (nullable NSIndexPath *)cellIndexPathForItemIndex:(NSInteger)index {
    if (index < 0 || index >= self.items.count)return nil;
    BOOL needSeparatorView = [self needSeparatorView];
    NSIndexPath *indexpath = [NSIndexPath indexPathForItem:needSeparatorView?index*2:index inSection:0];
    return indexpath;
}
- (void)collectionViewScrollToItemAtIndex:(NSInteger)index animated:(BOOL)animated {
    [self __collectionViewScrollToItemAtIndex:index animated:animated];
}
- (CGPoint)__contentOffsetWithItemAtIndex:(NSInteger)index {
    if (index < 0 || index >= self.items.count)return CGPointZero;
    NSIndexPath *indexpath = [self cellIndexPathForItemIndex:index];
    UICollectionViewLayoutAttributes *attr = [self.collectionViewFlowLayout layoutAttributesForItemAtIndexPath:indexpath];
    CGRect cellFrame2 = attr.frame;
    LUIScrollViewScrollDirection direction = self.scrollDirection == LUItemFlowCollectionViewScrollDirectionVertical?LUIScrollViewScrollDirectionVertical:LUIScrollViewScrollDirectionHorizontal;
    CGPoint offset = [self.collectionView l_contentOffsetWithScrollTo:cellFrame2 direction:(direction) position:(LUIScrollViewScrollPositionMiddle)];
    return offset;
}
- (void)__collectionViewScrollToItemAtIndex:(NSInteger)index animated:(BOOL)animated {
    if (index < 0 || index >= self.items.count)return;
    CGPoint offset = [self __contentOffsetWithItemAtIndex:index];
    [self.collectionView setContentOffset:offset animated:animated];
}
- (void)setNeedReloadData {
    __needReloadData = YES;
    [self setNeedsLayout];
}
- (void)reloadDataWithAnimated:(BOOL)animated {
    __needReloadData = NO;
    [self layoutIfNeeded];
    [self __reloadData];
    if (animated) {
        [UIView animateWithDuration:0.25 animations:^{
            [self scrollItemIndicatorViewToIndex:self.selectedIndex animated:NO];
            [self collectionViewScrollToItemAtIndex:self.selectedIndex animated:NO];
        }];
    } else {
        [self scrollItemIndicatorViewToIndex:self.selectedIndex animated:NO];
        [self collectionViewScrollToItemAtIndex:self.selectedIndex animated:NO];
    }
}
- (void)__reloadData {
    __needReloadData = NO;
    [self.model removeAllSectionModels];
    BOOL needSeparatorView = [self needSeparatorView];
    @LUI_WEAKIFY(self);
    for(int i=0;i < self.items.count;i++) {
        id item = self.items[i];
        LUICollectionViewCellModel *cm = [LUICollectionViewCellModel modelWithValue:item cellClass:[self itemCellClassAtIndex:i] whenClick:^(__kindof LUICollectionViewCellModel * _Nonnull cellModel)  {
            @LUI_NORMALIZE(self);
            if (self.delegate && [self.delegate respondsToSelector:@selector(itemFlowCollectionView:didSelectIndex:)]) {
                [self.delegate itemFlowCollectionView:self didSelectIndex:i];
            }
        }];
        cm.selected = i == self.selectedIndex;
        [self.model addCellModel:cm];
        if (needSeparatorView && i != self.items.count-1) {
            LUICollectionViewCellModelItemFlowSeparator *separatorCM = [LUICollectionViewCellModelItemFlowSeparator modelWithValue:nil cellClass:self.separatorViewClass];
            separatorCM.separatorColor = self.separatorColor;
            separatorCM.separatorSize = self.separatorSize;
            separatorCM.scrollDirection = self.scrollDirection;
            [self.model addCellModel:separatorCM];
        }
    }
    [self.model reloadCollectionViewData];
    [self.collectionView layoutIfNeeded];
    CGPoint contentOffset = [self.collectionView l_adjustContentOffsetInRange:self.collectionView.contentOffset];
    if (!CGPointEqualToPoint(contentOffset, self.collectionView.contentOffset)) {
        self.collectionView.contentOffset = contentOffset;
        [self.collectionView layoutIfNeeded];//contentOffset变更时，马上进行一次重绘
    }
    
    if (self.items.count == 0) {
        self.itemIndicatorView.hidden = YES;
    } else if (self.itemIndicatorView != nil && self.itemIndicatorView.hidden) {
    }
    [self __reloadIndicatorView:NO];
}
- (void)__reloadIndicatorView:(BOOL)force {
    if (self.itemIndicatorView == nil)return;
    if (self.items.count == 0) {
        self.itemIndicatorView.hidden = YES;
        return;
    }
    if (self.itemIndicatorView.hidden) {
        self.itemIndicatorView.hidden = NO;
        [self scrollItemIndicatorViewToIndex:self.selectedIndex animated:NO];
    } else {
        CGRect f1 = self.itemIndicatorView.frame;
        if (force || CGSizeEqualToSize(f1.size, CGSizeZero)) {
            [self scrollItemIndicatorViewToIndex:self.selectedIndex animated:NO];
        }
    }
}
- (void)scrollItemIndicatorViewToIndex:(NSInteger)index animated:(BOOL)animated {
    if (index < 0 || index >= self.items.count)return;
    if (self.itemIndicatorViewClass == nil)return;
    CGRect f = [self itemIndicatorRectWithScrollFromIndex:index to:index withProgress:0];
    if (animated) {
        [UIView animateWithDuration:0.25 animations:^{
            self.itemIndicatorView.frame = f;
            [self.itemIndicatorView layoutIfNeeded];
        }];
    } else {
        self.itemIndicatorView.frame = f;
        [self.itemIndicatorView layoutIfNeeded];
    }
}
- (__kindof UICollectionViewCell *)itemCollectionViewCellForIndex:(NSInteger)index {
    if (!(index >= 0 && index < self.items.count)) {
        return nil;
    }
    NSIndexPath *p = [self cellIndexPathForItemIndex:index];
    if (p.item >= self.model.numberOfCells) {//还未reload
        return nil;
    }
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:p];
    if (!cell) {
        //cell还未显示出来
        CGPoint offset = self.collectionView.contentOffset;
        [self __collectionViewScrollToItemAtIndex:index animated:NO];
        [self.collectionView layoutIfNeeded];
        cell = [self.collectionView cellForItemAtIndexPath:p];
        self.collectionView.contentOffset = offset;
        [self.collectionView layoutIfNeeded];
    }
    return cell;
}
- (CGRect)itemIndicatorRectWithScrollFromIndex:(NSInteger)fromIndex to:(NSInteger)toIndex withProgress:(CGFloat)progress {
    LUICGAxis X = self.scrollAxis;
    LUICGAxis Y = LUICGAxisReverse(X);
    CGRect bounds = self.collectionView.bounds;
    CGRect f2 = bounds;
    LUICGRectSetLength(&f2, Y, LUICGRectGetLength(bounds, Y));
    
    CGRect r1 = [self itemContentRectForIndex:fromIndex];
    CGRect r2 = fromIndex == toIndex?r1:[self itemContentRectForIndex:toIndex];
    LUICGRectSetLength(&f2, X, LUICGFloatInterpolate(LUICGRectGetLength(r1, X), LUICGRectGetLength(r2, X), progress));
    LUICGRectSetMid(&f2, X, LUICGFloatInterpolate(LUICGRectGetMid(r1, X), LUICGRectGetMid(r2, X), progress));
    return f2;
}
- (CGRect)itemContentRectForIndex:(NSInteger)index {
    UICollectionViewCell *cell = [self itemCollectionViewCellForIndex:index];
    CGRect r;
    CGRect itemIndicatorRect = CGRectZero;
    if ([cell conformsToProtocol:@protocol(LUItemFlowCollectionCellViewDelegate)]) {
        id < LUItemFlowCollectionCellViewDelegate> flowCell = (id < LUItemFlowCollectionCellViewDelegate>)cell;
        if ([flowCell respondsToSelector:@selector(itemIndicatorRect)]) {
            itemIndicatorRect = flowCell.itemIndicatorRect;
        }
    }
    if (!CGRectEqualToRect(itemIndicatorRect, CGRectZero)) {
        r = [self.collectionView convertRect:itemIndicatorRect fromView:cell];
    } else {
        r = [self.collectionView convertRect:cell.l_frameSafety fromView:cell.superview];
    }
    return r;
}
- (void)setSeparatorViewClass:(Class)separatorViewClass {
    if (_separatorViewClass == separatorViewClass)return;
    _separatorViewClass = separatorViewClass;
    [self setNeedReloadData];
}
- (void)setSeparatorColor:(UIColor *)separatorColor {
    if (_separatorColor == separatorColor || [_separatorColor isEqual:separatorColor])return;
    _separatorColor = separatorColor;
    if (![self needSeparatorView]) return;
    [self setNeedReloadData];
}
- (void)setSeparatorSize:(CGSize)separatorSize {
    if (CGSizeEqualToSize(_separatorSize, separatorSize))return;
    _separatorSize = separatorSize;
    if (![self needSeparatorView]) return;
    [self setNeedReloadData];
}
- (BOOL)needSeparatorView {
    BOOL needSeparatorView = self.separatorViewClass != nil && [self.separatorViewClass isSubclassOfClass:LUICollectionViewCellBase.class];
    return needSeparatorView;
}
#pragma mark - delegate:UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView pageFlowLayout:(LUICollectionViewPageFlowLayout *)collectionViewLayout itemSizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGRect bounds = collectionView.bounds;
    CGSize size = CGSizeZero;
    LUICGAxis X = self.scrollAxis;
    LUICGAxis Y = LUICGAxisReverse(X);
    LUICGSizeSetLength(&size, Y, LUICGRectGetLength(bounds, Y));
    BOOL needSeparatorView = [self needSeparatorView];
    NSInteger index = indexPath.item;
    if (needSeparatorView && index%2 == 1) {//分隔线
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(separatorSizeOfItemFlowCollectionView:)]) {
            size = [self.delegate separatorSizeOfItemFlowCollectionView:self];
        } else {
            size = self.separatorSize;
        }
    } else {//item
        NSInteger itemIndex = index/2;
        size = [self itemSizeAtIndex:itemIndex collectionCellModel:[self.model cellModelAtIndexPath:indexPath]];
    }
    return size;
}
- (void)dealloc {
    //ios10时，会因为实现了scrollViewDidScroll：方法，导致闪退，需要手动清空delegate
    self.collectionView.delegate = nil;
}
- (void)doesNotRecognizeSelector:(SEL)aSelector {
    if (self.collectionView.dataSource == nil) {
        //ios内存释放机制，导致dataSource已经空了，但delegate还保持为自己。此时不应该响应任何方法了
        return;
    }
    [super doesNotRecognizeSelector:aSelector];
}
@end

#import "UIColor+LUI.h"
@interface LUItemFlowCellView()
@property(nonatomic,strong) UILabel *titleLabel;
@end
@implementation LUItemFlowCellView
- (id)initWithFrame:(CGRect)frame {
    if (self=[super initWithFrame:frame]) {
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.contentView.bounds;
    CGRect f1 = bounds;
    f1.size = [self.titleLabel sizeThatFits:bounds.size];
    LUICGRectAlignMidXToRect(&f1, bounds);
    LUICGRectAlignMidYToRect(&f1, bounds);
    self.titleLabel.frame = bounds;
}
- (UIView *)itemIndicatorRectView {
    return self.titleLabel;
}
- (CGRect)itemIndicatorRect {
    if (!self.itemIndicatorRectView)return CGRectZero;
    return [self.itemIndicatorRectView.superview convertRect:self.itemIndicatorRectView.l_frameSafety toView:self];
}
- (void)customReloadCellModel {
    [super customReloadCellModel];
    BOOL selected = self.collectionCellModel.selected;
    UIColor *color = [self.class titleColorWithSelected:selected];
    if (color) {
        self.titleLabel.textColor = color;
    }
}
+ (UIColor *)titleColorWithSelected:(BOOL)selected {
    return nil;
}
LUIDEF_SINGLETON(LUItemFlowCellView)
- (void)changeColorForItemFlowCollectionView:(LUItemFlowCollectionView *)view didScrollFromIndex:(NSInteger)fromIndex to:(NSInteger)toIndex progress:(CGFloat)progress {
    NSIndexPath *fromIndexPath = [view cellIndexPathForItemIndex:fromIndex];
    NSIndexPath *toIndexPath = [view cellIndexPathForItemIndex:toIndex];
    NSIndexPath *myIndexPath = self.collectionCellModel.indexPathInModel;
    if (![myIndexPath isEqual:fromIndexPath] && ![myIndexPath isEqual:toIndexPath]) {//中间单元格
        self.titleLabel.textColor = [self.class titleColorWithSelected:NO];
        return;
    }
    //颜色渐变
    UIColor *color1;
    UIColor *color2;
    if ([myIndexPath isEqual:fromIndexPath]) {//选中->未选中
        color1 = [self.class titleColorWithSelected:YES];
        color2 = [self.class titleColorWithSelected:NO];
    } else {//未选中->选中
        color1 = [self.class titleColorWithSelected:NO];
        color2 = [self.class titleColorWithSelected:YES];
    }
    if (color1 && color2) {
        self.titleLabel.textColor = LUIColorInterpolate(color1, color2, progress);
    }
}
- (void)itemFlowCollectionView:(LUItemFlowCollectionView *)view didScrollFromIndex:(NSInteger)fromIndex to:(NSInteger)toIndex progress:(CGFloat)progress {
    [self changeColorForItemFlowCollectionView:view didScrollFromIndex:fromIndex to:toIndex progress:progress];
}
@end

@interface LUItemFlowIndicatorLineView ()
@property(nonatomic,strong) UIView *indicatorLine;
@end
@implementation LUItemFlowIndicatorLineView
#ifdef DEBUG
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}
#endif
- (id)initWithFrame:(CGRect)frame {
    if (self=[super initWithFrame:frame]) {
        self.indicatorLine = [[UIView alloc] init];
        self.indicatorLine.backgroundColor = UIColor.systemBlueColor;
        self.indicatorLineSize = 2;
        self.indicatorLineMarggin = 0;
        self.indicatorLinePosition = LUItemFlowIndicatorLinePositionMax;
        [self addSubview:self.indicatorLine];
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    LUItemFlowCollectionView *view = [self l_firstSuperViewWithClass:LUItemFlowCollectionView.class];
    LUICGAxis X = view.scrollAxis;
    LUICGAxis Y = LUICGAxisReverse(X);
    CGRect f1 = bounds;
    LUICGRectSetLength(&f1, Y, self.indicatorLineSize);
    if (self.indicatorLinePosition == LUItemFlowIndicatorLinePositionMin) {
        LUICGRectSetMinEdgeToRect(&f1, Y, bounds, self.indicatorLineMarggin);
    } else {
        LUICGRectSetMaxEdgeToRect(&f1, Y, bounds, self.indicatorLineMarggin);
    }
    self.indicatorLine.frame = f1;
}
- (void)setIndicatorLineSize:(CGFloat)indicatorLineSize {
    if (_indicatorLineSize == indicatorLineSize)return;
    _indicatorLineSize = indicatorLineSize;
    [self setNeedsLayout];
}
- (void)setIndicatorLinePosition:(LUItemFlowIndicatorLinePosition)indicatorLinePosition {
    if (_indicatorLinePosition == indicatorLinePosition)return;
    _indicatorLinePosition = indicatorLinePosition;
    [self setNeedsLayout];
}
- (void)setIndicatorLineMarggin:(CGFloat)indicatorLineMarggin {
    if (_indicatorLineMarggin == indicatorLineMarggin)return;
    _indicatorLineMarggin = indicatorLineMarggin;
    [self setNeedsLayout];
}
@end
@implementation LUItemFlowCollectionView(LUItemFlowIndicatorLineView)
- (LUItemFlowIndicatorLineView *)itemIndicatorLineView {
    return [self.itemIndicatorView isKindOfClass:LUItemFlowIndicatorLineView.class] ? self.itemIndicatorView : nil;
}
@end


@implementation LUICollectionViewCellModelItemFlowSeparator
- (LUICGAxis)scrollAxis {
    LUICGAxis X = self.scrollDirection == LUItemFlowCollectionViewScrollDirectionHorizontal ? LUICGAxisX : LUICGAxisY;
    return X;
}
@end
#import "UIColor+LUI.h"
@interface LUItemFlowSeparatorView()
@property(nonatomic,strong) UIView *separatorLine;
@end
@implementation LUItemFlowSeparatorView
- (id)initWithFrame:(CGRect)frame {
    if (self=[super initWithFrame:frame]) {
        self.separatorLine = [[UIView alloc] init];
        self.separatorLine.backgroundColor = [UIColor l_colorWithLight:UIColor.blackColor];
        [self.contentView addSubview:self.separatorLine];
    }
    return self;
}
- (void)customLayoutSubviews {
    [super customLayoutSubviews];
    CGRect bounds = self.bounds;
    CGRect f1 = bounds;
    f1.size = self.separatorSize;
    LUICGRectAlignMidXToRect(&f1, bounds);
    LUICGRectAlignMidYToRect(&f1, bounds);
    self.separatorLine.frame = f1;
}
- (void)customReloadCellModel {
    [super customReloadCellModel];
    LUICollectionViewCellModelItemFlowSeparator *separatorCellModel = self.separatorCellModel;
    if (separatorCellModel) {
        self.separatorLine.backgroundColor = separatorCellModel.separatorColor;
        self.separatorSize = separatorCellModel.separatorSize;
    }
}
- (LUICollectionViewCellModelItemFlowSeparator *)separatorCellModel {
    return [self.collectionCellModel isKindOfClass:LUICollectionViewCellModelItemFlowSeparator.class] ? self.collectionCellModel : nil;
}
@end
