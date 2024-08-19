//
//  LUICollectionViewWaterFlowLayout.h
//  LUITool
//
//  Created by 六月 on 2024/8/19.
//

#import <UIKit/UIKit.h>
#import "CGGeometry+LUI.h"
#import "UICollectionViewFlowLayout+LUI.h"

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN NSString *const LUICollectionElementKindWaterFlowSectionLastLineItem;//每一组最后一行末尾元素，使用分组的SupplementaryView来实现

@class LUICollectionViewWaterFlowLayout;
@class LUICollectionViewWaterFlowLayoutLastLineItemOption;
@protocol LUICollectionViewDelegateWaterFlowLayout <UICollectionViewDelegate>
@optional

/// 返回每一个cell的尺寸，如果尺寸值小于fitsSize时，将会另起一行显示
/// - Parameters:
///   - collectionView: 集合
///   - collectionViewLayout: 瀑布流布局
///   - indexPath: 索引
///   - fitsSize: 当前行剩余空间
- (CGSize)collectionView:(UICollectionView *)collectionView waterFlowLayout:(LUICollectionViewWaterFlowLayout *)collectionViewLayout itemSizeForItemAtIndexPath:(NSIndexPath *)indexPath fits:(CGSize)fitsSize;

/// 返回分组的内边距
/// - Parameters:
///   - collectionView: 集合
///   - collectionViewLayout: 瀑布流布局
///   - section: 索引
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView waterFlowLayout:(LUICollectionViewWaterFlowLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section;

/// 返回分组的元素间间隔（垂直滚动时，为左右间隔，水平滚动时为上下间隔）
/// - Parameters:
///   - collectionView: 集合
///   - collectionViewLayout: 瀑布流布局
///   - section: 索引
- (CGFloat)collectionView:(UICollectionView *)collectionView waterFlowLayout:(LUICollectionViewWaterFlowLayout *)collectionViewLayout interitemSpacingForSectionAtIndex:(NSInteger)section;

/// 返回分组的行间隔（垂直滚动时，为上下行间隔，水平滚动时为左右列间隔）
/// - Parameters:
///   - collectionView: 集合
///   - collectionViewLayout: 瀑布流布局
///   - section: 索引
- (CGFloat)collectionView:(UICollectionView *)collectionView waterFlowLayout:(LUICollectionViewWaterFlowLayout *)collectionViewLayout lineSpacingForSectionAtIndex:(NSInteger)section;

/// 返回分组的头部视图尺寸，如果返回（0，0）时，将不显示头部
/// - Parameters:
///   - collectionView: 集合
///   - collectionViewLayout: 瀑布流布局
///   - section: 索引
- (CGSize)collectionView:(UICollectionView *)collectionView waterFlowLayout:(LUICollectionViewWaterFlowLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;

/// 返回分组的尾部视图尺寸，如果返回（0，0）时，将不显示头部
/// - Parameters:
///   - collectionView: 集合
///   - collectionViewLayout: 瀑布流布局
///   - section: 索引
- (CGSize)collectionView:(UICollectionView *)collectionView waterFlowLayout:(LUICollectionViewWaterFlowLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section;

/// 返回分组的最后一行末尾视图配置（该视图优先布局），配置包含有行数上限等
/// - Parameters:
///   - collectionView: 集合
///   - collectionViewLayout: 瀑布流布局
///   - section: 索引
- (nullable LUICollectionViewWaterFlowLayoutLastLineItemOption *)collectionView:(UICollectionView *)collectionView waterFlowLayout:(LUICollectionViewWaterFlowLayout *)collectionViewLayout referenceOptionForLastLineItemInSection:(NSInteger)section;

@end

@interface LUICollectionViewWaterFlowLayout : UICollectionViewLayout
@property(nonatomic) CGFloat interitemSpacing;//平行scrollDirection方向上，元素间的间隔，默认为0。如果Vertical上下滑动时，代表元素间的左右间隔；如果Horizontal左右滑动时，代表元素间的上下间隔。
@property(nonatomic) CGFloat lineSpacing;//垂直scrollDirection方向上，元素间的间隔,默认为0。如果Vertical上下滑动时，代表行的上下间隔；如果Horizontal左右滑动时，代表列的左右间隔。
@property(nonatomic) CGSize itemSize;//默认的cell尺寸值
@property(nonatomic) UIEdgeInsets sectionInset;//分组内边距，默认为zero
@property(nonatomic) CGFloat sectionSpacing;//分组之间的间距，默认为0
@property(nonatomic) CGSize headerReferenceSize;//分组头部视图尺寸，默认为zero
@property(nonatomic) CGSize footerReferenceSize;//分组尾部视图尺寸，默认为zero
@property(nonatomic,strong,nullable) LUICollectionViewWaterFlowLayoutLastLineItemOption *lastLineItemReferenceOption;//分组最后一行末尾视图配置，默认为nil

@property(nonatomic) UICollectionViewScrollDirection scrollDirection; //scroll的滚动方向，默认为 UICollectionViewScrollDirectionVertical（上下滑动）
@property(nonatomic) LUICGRectAlignment itemAlignment;//元素在与滚动方向垂直方向上的布局对齐参数，默认为居中LUICGRectAlignmentMid。如果Vertical上下滑动时，代表居上、居中、居下；如果Horizontal左右滑动时，代表居左，居中，居右。
@property(nonatomic,readonly) LUICGAxis scrollAxis;

@end

@interface LUICollectionViewWaterFlowLayoutLastLineItemOption : NSObject
@property(nonatomic,assign) NSInteger maxLines;//限制最大的行数（水平布局时为行数，垂直布局时为列数)，<=0代表不限。超过该行数，后续元素尺寸都设置为(0,0)
@property(nonatomic) CGSize lastLineItemSize;//如果有值，最后一行布局时，每一个元素都将扣除该末尾元素的空间，保证末尾元素一定显示。
@property(nonatomic,assign) BOOL showLastLineItemWithinMaxLine;//当maxLines>0且行数在最大值之内时，是否显示lastLineItem
@end

@interface LUICollectionViewWaterFlowLayout(SizeFits)<LUICollectionViewLayoutSizeFitsProtocol>
@end

@interface LUICollectionViewWaterFlowLayout(LUICollectionViewDelegateWaterFlowLayout)
@property(nonatomic,readonly,nullable) id<LUICollectionViewDelegateWaterFlowLayout> waterFlowDelegate;
- (CGSize)itemSizeForSectionAtIndexPath:(NSIndexPath *)indexPath fits:(CGSize)fitsSize;
- (UIEdgeInsets)insetForSectionAtIndex:(NSInteger)section;
- (CGFloat)interitemSpacingForSectionAtIndex:(NSInteger)section;
- (CGFloat)lineSpacingForSectionAtIndex:(NSInteger)section;
- (CGSize)referenceSizeForHeaderInSection:(NSInteger)section;
- (CGSize)referenceSizeForFooterInSection:(NSInteger)section;
- (nullable LUICollectionViewWaterFlowLayoutLastLineItemOption *)referenceOptionForLastLineItemInSection:(NSInteger)section;
@end

@interface UICollectionView(LUICollectionViewWaterFlowLayout)
@property(nonatomic,readonly,nullable) LUICollectionViewWaterFlowLayout *l_collectionViewWaterFlowLayout;
@end

NS_ASSUME_NONNULL_END
