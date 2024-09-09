//
//  LUIGridPageCollectionViewLayout.h
//  LUITool
//  一个页面，容纳MxN的单元格，页面中每个单元格尺寸一致。每页左右滚动，以页进行paging，当前页面容纳不下元素时，将开启新的页面进行布局。开启新的section分组，将启用新的分页。每个section分组中，单元格大小、内边距、间隔都是一致了。不同section分组可以以不同的单元格大小、内边距、间隔。一个section分组，可能包含多个page页。
//  每页的元素布局，从左到右流布局，每行从上到下布局。每个元素大小为分组的itemSize，每个元素左右间隔为分组的interitemSpacing，上下两行间隔为分组的lineSpacing
//  Created by 六月 on 2023/8/18.
//

#import <UIKit/UIKit.h>
#import "UICollectionViewFlowLayout+LUI.h"
NS_ASSUME_NONNULL_BEGIN

@class LUIGridPageCollectionViewLayout;

@protocol LUICollectionViewDelegateGridPageLayout <UICollectionViewDelegate>
@optional
- (CGSize)collectionView:(UICollectionView *)collectionView gridPageLayout:(LUIGridPageCollectionViewLayout *)collectionViewLayout itemSizeForSectionAtIndex:(NSInteger)section;
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView gridPageLayout:(LUIGridPageCollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section;
- (CGFloat)collectionView:(UICollectionView *)collectionView gridPageLayout:(LUIGridPageCollectionViewLayout *)collectionViewLayout lineSpacingForSectionAtIndex:(NSInteger)section;
- (CGFloat)collectionView:(UICollectionView *)collectionView gridPageLayout:(LUIGridPageCollectionViewLayout *)collectionViewLayout interitemSpacingForSectionAtIndex:(NSInteger)section;
- (void)collectionView:(UICollectionView *)collectionView gridPageLayout:(LUIGridPageCollectionViewLayout *)collectionViewLayout didScrollToPage:(NSInteger)page;//用户手势操作结束或者滚动动画结束时，才会触发
@end

@interface LUIGridPageCollectionViewLayout : UICollectionViewLayout

@property(nonatomic) CGFloat interitemSpacing;//元素之间默认的左右的间隔
@property(nonatomic) CGFloat lineSpacing;//元素之间默认的上下的间隔
@property(nonatomic) CGSize itemSize;//默认每个元素的大小
@property(nonatomic) UIEdgeInsets sectionInset;//每页的内边距
@property (nonatomic, readonly) NSInteger numberOfPages;//总页数
@property(nonatomic) NSInteger currentPage;//当前显示的页索引
@property(nonatomic) NSInteger currentSection;//当前显示的分组索引
- (NSInteger)numberOfPagesInSection:(NSInteger)section;//指定分组包含的页数
- (NSInteger)sectionOfPageIndex:(NSInteger)page;//返回指定页，它所属的分组索引
@property (nonatomic, readonly) NSArray<NSNumber *> *visiblePages;//返回可见的页的索引范围

@property (nonatomic, readonly) NSInteger visiblePage;//返回可见面积最大的页
//自动滚动到页边缘。如果想要滚动速度快，可以设置self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast
//滚动到指定的页
- (void)scrollToPage:(NSInteger)page animated:(BOOL)animated;
//返回指定页面包含的元素indexpath
- (NSArray<NSIndexPath *> *)itemIndexPathsForPage:(NSInteger)page;
//返回指定分组包含的页范围
- (NSRange)pagesRangeForSection:(NSInteger)section;
//返回指定区域，包含的页索引数组
- (NSArray<NSNumber *> *)pagesWithRect:(CGRect)rect;

//指定contetnOffset，返回其从fromPage滚动到toPage的百分比
- (CGFloat)scrollProgressWithContentOffset:(CGPoint)offset fromPage:(NSInteger *)fromPage toPage:(NSInteger *)toPage;
//指定contentOffset，返回其从currentPage滚动到toPage的百分比，可用于页码指示器的滚动进度展示
- (CGFloat)scrollProgressWithContentOffset:(CGPoint)offset toPage:(NSInteger *)toPagePoint;

/// 刷新数据，会全部重构cell
- (void)reloadData;
#pragma mark - 定时滚动
@property (nonatomic, readonly) BOOL isAutoScrolling;

/// 设置定时滚动。注意，如果collectionView没有被展示（比如viewcontroller被推到navigation的底部堆栈），定时滚动只会修改contentOffset，prepareLayout、shouldInvalidateLayoutForBoundsChange方法不会被调用，会导致循环滚动失效。如果开启了定时滚动功能，那么调用collectionView的reloadData方法时，也要同步调用本对象的reloadData方法，用来清除循环滚动中的中间状态。否则如果reloadData会修改cell数量，那么会出现contentSize计算错误的问题。
/// - Parameters:
///   - distance: 滚动方向与步进距离，正值为向右，负值为向左
///   - duration: 间隔时长
- (void)startAutoScrollingWithDistance:(NSInteger)distance duration:(NSTimeInterval)duration;
- (void)stopAutoScrolling;
- (void)scrollToPageWithDistance:(NSInteger)distance animated:(BOOL)animated;

@property(nonatomic) BOOL enableCycleScroll;//是否允许循环滚动，默认为NO
@end

@interface LUIGridPageCollectionViewLayout(LUICollectionViewDelegateGridPageLayout)
@property (nonatomic, readonly,nullable) id<LUICollectionViewDelegateGridPageLayout> gridPageDelegate;
- (CGSize)itemSizeForSectionAtIndex:(NSInteger)section;
- (UIEdgeInsets)insetForSectionAtIndex:(NSInteger)section;
- (CGFloat)lineSpacingForSectionAtIndex:(NSInteger)section;
- (CGFloat)interitemSpacingForSectionAtIndex:(NSInteger)section;
@end

@interface LUIGridPageCollectionViewLayout(SizeFits)<LUICollectionViewLayoutSizeFitsProtocol>
/// 计算在指定行、列数、间隔时，itemSize值，使得所有的元素刚好填充整个区域
/// @param itemsPerRow 一行容纳的元素个数
/// @param lines 行数
/// @param interitemSpacing 元素左右间隔
/// @param lineSpacing 元素上下间隔
/// @param sectionInsets 内边距
- (CGSize)itemSizeThatFitsItemsPerRow:(NSInteger)itemsPerRow lines:(NSInteger)lines interitemSpacing:(CGFloat)interitemSpacing lineSpacing:(CGFloat)lineSpacing sectionInsets:(UIEdgeInsets)sectionInsets;
/// 在指定itemSize、最小元素间隔等条件下，计算元素间隔值，使得行内元素，刚好填充满一行
/// @param itemSize 元素尺寸
/// @param minimumInteritemSpacing 最小元素间隔
/// @param sectionInsets 内边距
- (CGFloat)interitemSpacingThatFitsItemSize:(CGSize)itemSize minimumInteritemSpacing:(CGFloat)minimumInteritemSpacing sectionInsets:(UIEdgeInsets)sectionInsets;

/// 在指定itemSize、最小元素行间隔等条件下，计算元素行间隔值，使得行，刚好填充满整个高度
/// @param itemSize 元素尺寸
/// @param minimumLineSpacing 最小的行间隔
/// @param sectionInsets 内边距
- (CGFloat)lineSpacingThatFitsItemSize:(CGSize)itemSize minimumLineSpacing:(CGFloat)minimumLineSpacing sectionInsets:(UIEdgeInsets)sectionInsets;

/// 在指定itemSize，一行容纳的元素个数下，计算元素左右间隔值
/// @param itemSize 元素尺寸
/// @param itemsPerRow 一行元素个数
/// @param sectionInsets 内边距
- (CGFloat)interitemSpacingThatFitsItemSize:(CGSize)itemSize itemsPerRow:(NSInteger)itemsPerRow sectionInsets:(UIEdgeInsets)sectionInsets;
@end

@interface UICollectionView(LUIGridPageCollectionViewLayout)
@property (nonatomic, readonly,nullable) LUIGridPageCollectionViewLayout *l_collectionViewGridPageLayout;
@end

NS_ASSUME_NONNULL_END
