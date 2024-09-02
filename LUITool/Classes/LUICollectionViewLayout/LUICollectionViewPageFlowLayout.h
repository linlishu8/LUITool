//
//  LUICollectionViewPageFlowLayout.h
//  LUITool
//
//  Created by 六月 on 2023/8/19.
//

#import <UIKit/UIKit.h>
#import "CGGeometry+LUI.h"
#import "UICollectionViewFlowLayout+LUI.h"

NS_ASSUME_NONNULL_BEGIN

@class LUICollectionViewPageFlowLayout;

@protocol LUICollectionViewDelegatePageFlowLayout <UICollectionViewDelegate>
@optional
- (CGSize)collectionView:(UICollectionView *)collectionView pageFlowLayout:(LUICollectionViewPageFlowLayout *)collectionViewLayout itemSizeForItemAtIndexPath:(NSIndexPath *)indexPath;
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView pageFlowLayout:(LUICollectionViewPageFlowLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section;
- (CGFloat)collectionView:(UICollectionView *)collectionView pageFlowLayout:(LUICollectionViewPageFlowLayout *)collectionViewLayout interitemSpacingForSectionAtIndex:(NSInteger)section;
- (CGFloat)pagingBoundsPositionForCollectionView:(UICollectionView *)collectionView pageFlowLayout:(LUICollectionViewPageFlowLayout *)collectionViewLayout;
- (void)collectionView:(UICollectionView *)collectionView pageFlowLayout:(LUICollectionViewPageFlowLayout *)collectionViewLayout didScrollToPagingCell:(NSIndexPath *)indexPathAtPagingCell;//用户手势操作结束或者滚动动画结束时，才会触发
@end

@interface LUICollectionViewPageFlowLayout : UICollectionViewLayout
@property(nonatomic) CGFloat interitemSpacing;//默认为0
@property(nonatomic) CGSize itemSize;
@property(nonatomic) UICollectionViewScrollDirection scrollDirection; // default is UICollectionViewScrollDirectionHorizontal
@property(nonatomic) LUICGRectAlignment itemAlignment;//元素在与滚动方向垂直方向上的布局对齐参数，默认为居中LUICGRectAlignmentMid
@property(nonatomic,readonly) LUICGAxis scrollAxis;
@property(nonatomic) UIEdgeInsets sectionInset;//默认为zero

@property(nonatomic) BOOL enableCycleScroll;//是否允许循环滚动，默认为NO

/// 刷新数据，会全部重构cell和contentSize
- (void)reloadData;
#pragma mark - paging scroll
//停止滚动时，画面中的cell，是否与指定的位置对齐。pagingCellPosition指定cell的位置，pagingBoundsPosition指定bounds的位置，这两个位置要重合。
//{pagingBoundsPosition：0，pagingCellPosition：0}:cell左侧与bounds左侧对齐
//{pagingBoundsPosition：0.5，pagingCellPosition：0.5}:cell中线与bounds中线对齐
//{pagingBoundsPosition：1，pagingCellPosition：1}:cell右侧与bounds右侧对齐
//如果觉得scroll到paging位置速度太慢，可以设置：collectionView.decelerationRate = UIScrollViewDecelerationRateFast
@property(nonatomic) BOOL pagingEnabled;//是否滚动到paging位置，默认为NO
@property(nonatomic) CGFloat pagingBoundsPosition;//百分比取值[0,1]
@property(nonatomic) CGFloat pagingCellPosition;//百分比取值[0,1]
@property(nonatomic) BOOL playPagingSound;//当滚动到paging位置时，是否播放3DTouch效果，默认为NO
@property(nonatomic,readonly,nullable) NSIndexPath *indexPathAtPagingCell;//位于paging位置上的单元格，为nil时，代表没有单元格与paging位置相交。
- (void)setIndexPathAtPagingCell:(NSIndexPath *)indexPathAtPagingCell animated:(BOOL)animated;
- (nullable NSIndexPath *)indexPathForCellAtOffset:(CGFloat)position;

- (void)setIndexPathAtPagingCellWithDistance:(NSInteger)distance animated:(BOOL)animated;


//todo:指定contentOffset，返回其从currentPage滚动到toPage的百分比，可用于页码指示器的滚动进度展示
- (CGFloat)scrollProgressWithContentOffset:(CGPoint)offset toPagingCell:(NSIndexPath *_Nullable*_Nullable)toPadingCellIndexPathPoint;

#pragma mark - 定时滚动
@property(nonatomic,readonly) BOOL isAutoScrolling;

/// 设置定时滚动。注意，如果collectionView没有被展示（比如viewcontroller被推到navigation的底部堆栈），定时滚动只会修改contentOffset，prepareLayout、shouldInvalidateLayoutForBoundsChange方法不会被调用，会导致循环滚动失效。如果开启了定时滚动功能，那么调用collectionView的reloadData方法时，也要同步调用本对象的reloadData方法，用来清除循环滚动中的中间状态。否则如果reloadData会修改cell数量，那么会出现contentSize计算错误的问题。
/// - Parameters:
///   - distance: 滚动方向与步进距离，正值为向右，负值为向左
///   - duration: 间隔时长
- (void)startAutoScrollingWithDistance:(NSInteger)distance duration:(NSTimeInterval)duration;
- (void)stopAutoScrolling;

//由于highlightPagingCell，可能导致cell位置偏移，从而将bounds之外的元素，也移到了bounds内部，造成bounds里，实际显示元素大于bounds。该方法返回指定bounds时，其显示cell原本所占用的区域。目前用于循环滚动时，获取到当前视图内，真正的显示元素区域。默认直接返回bounds，子类可定制重载。
- (CGRect)visibleRectForOriginBounds:(CGRect)bounds;

@property(nonatomic,readonly) NSArray<UICollectionViewLayoutAttributes *> *cellAttributes;
//查找指定offset位置，距离它最近的单元格范围
- (NSRange)pagableCellIndexRangeNearToOffset:(CGFloat)position;

#pragma mark - highlight
@property(nonatomic) BOOL highlightPagingCell;//是否突出显示位于pagingBoundsPosition指定位置上的cell。默认为NO
//返回指定cell，距离bounds的paging对齐位置的距离。0代表就位于paging位置上,负值位于左侧，正值位于右侧
- (CGFloat)distanceToPagingPositionForCellLayoutAttributes:(UICollectionViewLayoutAttributes *)cellAttr;

//突出显示cell,子类可重写，定制各种显示
- (void)highlightPagingCellAttributes:(UICollectionViewLayoutAttributes *)cellAttr;
@end

@interface LUICollectionViewPageFlowLayout(SizeFits)<LUICollectionViewLayoutSizeFitsProtocol>
@end

@interface LUICollectionViewPageFlowLayout(LUICollectionViewDelegatePageFlowLayout)
@property(nonatomic,readonly,nullable) id<LUICollectionViewDelegatePageFlowLayout> pageFlowDelegate;
- (CGSize)itemSizeForSectionAtIndexPath:(NSIndexPath *)indexPath;
- (UIEdgeInsets)insetForSectionAtIndex:(NSInteger)section;
- (CGFloat)interitemSpacingForSectionAtIndex:(NSInteger)section;
- (CGFloat)pagingBoundsPositionForCollectionView;
@end

@interface UICollectionView(LUICollectionViewPageFlowLayout)
@property(nonatomic,readonly,nullable) LUICollectionViewPageFlowLayout *l_collectionViewPageFlowLayout;
@end
NS_ASSUME_NONNULL_END

#import "CGGeometry+LUI.h"
NS_ASSUME_NONNULL_BEGIN
//类似于UIPickerView的滚轮效果。pagingBoundsPosition和pagingCellPosition都为0.5
@interface LUICollectionViewPagePickerFlowLayout:LUICollectionViewPageFlowLayout
@property(nonatomic) LUICGRange  scaleRange;//滚轮元素的缩放倍数变化范围，默认为{1,0.75}
@property(nonatomic) LUICGRange alphaRange;//滚轮元素的alpha变化范围，默认为{1,0.75}
@property(nonatomic) CGFloat roundRadius;//滚轮半径，0代表使用bounds/2
@property(nonatomic) CGFloat m34;//透视效果，m34 = -1.0 / D，D越小，透视效果越明显，必须在有旋转效果的前提下，才会看到透视效果。默认为-1.0/800
@end

NS_ASSUME_NONNULL_END
