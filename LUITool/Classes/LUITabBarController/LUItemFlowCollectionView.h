//
//  LUItemFlowCollectionView.h
//  LUITool
//  对一系列item进行流布局的collectionView容器，包含选中效果、当前选中item的指示器、item之间的分隔线。支持横向、竖向布局。可用在TabBar的标签容器
//  Created by 六月 on 2024/9/9.
//

#import <UIKit/UIKit.h>
#import "CGGeometry+LUI.h"
#import "LUICollectionViewCellModel.h"
#import "LUICollectionViewPageFlowLayout.h"

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, LUItemFlowCollectionViewScrollDirection) {
    LUItemFlowCollectionViewScrollDirectionHorizontal,
    LUItemFlowCollectionViewScrollDirectionVertical,
};
@class LUItemFlowCollectionView;

@protocol LUItemFlowCollectionCellViewDelegate <NSObject>
@optional
- (void)itemFlowCollectionView:(LUItemFlowCollectionView *)view didScrollFromIndex:(NSInteger)fromIndex to:(NSInteger)toIndex progress:(CGFloat)progress;
@property (nonatomic, readonly) CGRect itemIndicatorRect;//返回选中指示器对齐的rect值
@end

@protocol LUItemFlowCollectionViewDelegate <NSObject>
@optional
- (CGSize)itemFlowCollectionView:(LUItemFlowCollectionView *)view itemSizeAtIndex:(NSInteger)index collectionCellModel:(LUICollectionViewCellModel *)cellModel;//返回指定item的单元格尺寸值
- (Class)itemFlowCollectionView:(LUItemFlowCollectionView *)view itemCellClassAtIndex:(NSInteger)index;//返回指定item的单元格类型，需要为LUICollectionViewCellBase的子类
- (void)itemFlowCollectionView:(LUItemFlowCollectionView *)view didSelectIndex:(NSInteger)selectedIndex;//点击指定item的回调
- (CGSize)separatorSizeOfItemFlowCollectionView:(LUItemFlowCollectionView *)view;//返回分隔线单元格的尺寸值
@end

@interface LUItemFlowCollectionView : UIView
@property (nonatomic, weak, nullable) id<LUItemFlowCollectionViewDelegate> delegate;
@property (nonatomic, readonly) UICollectionView *collectionView;
@property (nonatomic, readonly) LUICollectionViewPageFlowLayout *collectionViewFlowLayout;
@property (nonatomic, strong, nullable) NSArray *items;//数据源，itemCellClass单元格可以通过self.collectionCellModel.modelValue获取到对应的值
@property (nonatomic, assign) Class itemCellClass;//展示items中内容的单元格视图类，需要为LUICollectionViewCellBase子类
@property (nonatomic, assign) NSInteger selectedIndex;//单独设置selectIndex,并不会刷新UI。如果要刷新UI，请调用- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated;方法

- (CGSize)itemSizeAtIndex:(NSInteger)index collectionCellModel:(LUICollectionViewCellModel *)cellModel;
- (Class)itemCellClassAtIndex:(NSInteger)index;

//选中指示器
@property (nonatomic, assign, nullable) Class itemIndicatorViewClass;//选中指示器视图类,nil代表不需要指示器。可选值为LUItemFlowIndicatorView。默认为nil
@property (nonatomic, readonly, nullable) __kindof UIView *itemIndicatorView;

//分隔线
@property (nonatomic, assign, nullable) Class separatorViewClass;//分隔线的显示类，nil代表不要显示分隔线。可选值为LUItemFlowSeparatorView，默认为nil，代表不显示
@property (nonatomic, strong, nullable) UIColor *separatorColor;//当separatorViewClass为LUItemFlowSeparatorView时，指定分隔线颜色,默认为UIColor.mk_listViewSeparatorColor
@property (nonatomic, assign) CGSize separatorSize;//当separatorViewClass为LUItemFlowSeparatorView时，指定分隔线尺寸值,默认为(0,0)，代表不显示

@property (nonatomic, assign) LUItemFlowCollectionViewScrollDirection scrollDirection;//滚动方向，默认为水平滚动：LUItemFlowCollectionViewScrollDirectionHorizontal
@property (nonatomic, readonly) LUICGAxis scrollAxis;

/// 将指示器滚动到指定位置，位置为fromIndex到toIndex的插值，插值比例为progress
/// - Parameters:
///   - fromIndex: 开始位置
///   - toIndex: 结束位置
///   - progress: 完成进度
- (void)scrollItemIndicatorViewFromIndex:(NSInteger)fromIndex to:(NSInteger)toIndex withProgress:(CGFloat)progress;
- (void)collectionViewScrollItemFromIndex:(NSInteger)fromIndex to:(NSInteger)toIndex withProgress:(CGFloat)progress;
- (nullable NSIndexPath *)cellIndexPathForItemIndex:(NSInteger)index;//计算指定item的位置，对应的cellIndexPath值（在有分隔线的时候，item的位置不等于cellIndexPath.item值）
/// 将指示器滚动到指定的位置
/// - Parameters:
///   - index: 指定的item位置索引
///   - animated: 是否动画
- (void)scrollItemIndicatorViewToIndex:(NSInteger)index animated:(BOOL)animated;

/// 将collectionView滚动到指定item，item视图居中显示
/// - Parameters:
///   - index: 指定item的索引
///   - animated: 是否动画
- (void)collectionViewScrollToItemAtIndex:(NSInteger)index animated:(BOOL)animated;

/// 选中指定的item，collectionView滚动到item位置，如果有ItemIndicatorView，ItemIndicatorView同步滚动到选中的item位置
/// - Parameters:
///   - selectedIndex: 选中的item索引
///   - animated: 是否动画
- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated;

/// 刷新CollectionView数据,itemIndicatorView位置
- (void)reloadDataWithAnimated:(BOOL)animated;
@end

NS_ASSUME_NONNULL_END

#import "LUICollectionViewCellBase.h"
NS_ASSUME_NONNULL_BEGIN
@interface LUItemFlowCellView : LUICollectionViewCellBase<LUItemFlowCollectionCellViewDelegate>
@property (nonatomic, readonly) UILabel *titleLabel;
@property (nonatomic, readonly) CGRect itemIndicatorRect;//返回选中指示器对齐的rect值
@property (nonatomic, readonly, nullable) UIView *itemIndicatorRectView;//返回选中指示器对齐的视图，用于计算itemIndicatorRect
LUIAS_SINGLETON(LUItemFlowCellView)
- (void)itemFlowCollectionView:(LUItemFlowCollectionView *)view didScrollFromIndex:(NSInteger)fromIndex to:(NSInteger)toIndex progress:(CGFloat)progress;
- (void)changeColorForItemFlowCollectionView:(LUItemFlowCollectionView *)view didScrollFromIndex:(NSInteger)fromIndex to:(NSInteger)toIndex progress:(CGFloat)progress;
+ (nullable UIColor *)titleColorWithSelected:(BOOL)selected;//返回指定状态下的颜色值，nil时代表select状态变更不改变颜色值。默认为nil
@end
NS_ASSUME_NONNULL_END

NS_ASSUME_NONNULL_BEGIN
typedef enum : NSUInteger {
    LUItemFlowIndicatorLinePositionMin,//水平滚动：居上；垂直滚动：居下
    LUItemFlowIndicatorLinePositionMax,//水平滚动：居左；垂直滚动：居右
} LUItemFlowIndicatorLinePosition;
//选中指示器视图
@interface LUItemFlowIndicatorLineView : UIView
@property (nonatomic, readonly) UIView *indicatorLine;//指示线条视图
@property (nonatomic, assign) CGFloat indicatorLineSize;//线宽，默认为2
@property (nonatomic, assign) LUItemFlowIndicatorLinePosition indicatorLinePosition;//指示线条的位置，水平滚动时，位置为上(min)或下(max)，垂直滚动时，位置为左(min)或右(max)。默认为LUItemFlowIndicatorLinePositionMax
@property (nonatomic, assign) CGFloat indicatorLineMarggin;//指示线条与indicatorLinePosition对应边的边距，默认为0
@end
@interface LUItemFlowCollectionView(LUItemFlowIndicatorLineView)
@property (nonatomic, readonly, nullable) __kindof LUItemFlowIndicatorLineView *itemIndicatorLineView;
@end
NS_ASSUME_NONNULL_END

NS_ASSUME_NONNULL_BEGIN
//分隔线单元格
@interface LUICollectionViewCellModelItemFlowSeparator : LUICollectionViewCellModel
@property (nonatomic, strong, nullable) UIColor *separatorColor;
@property (nonatomic, assign) CGSize separatorSize;
@property (nonatomic, assign) LUItemFlowCollectionViewScrollDirection scrollDirection;
@property (nonatomic, readonly) LUICGAxis scrollAxis;
@end
@interface LUItemFlowSeparatorView : LUICollectionViewCellBase
@property (nonatomic, readonly) UIView *separatorLine;//分隔线条视图
@property (nonatomic, assign) CGSize separatorSize;//分隔线条尺寸值
@property (nonatomic, readonly, nullable) LUICollectionViewCellModelItemFlowSeparator *separatorCellModel;
@end
NS_ASSUME_NONNULL_END
