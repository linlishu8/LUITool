//
//  LUIPageControl.h
//  LUITool
//
//  Created by 六月 on 2024/9/5.
//

#import <UIKit/UIKit.h>
#import "LUICollectionViewCellProtocol.h"
#import "CGGeometry+LUI.h"

typedef NS_ENUM(NSInteger, LUIPageControlDirection) {
    LUIPageControlDirectionHorizontal,//水平布局
    LUIPageControlDirectionVertical//垂直布局
};

NS_ASSUME_NONNULL_BEGIN

//页码视图需要实现的协议
@class LUIPageControl;
@protocol LUIPageIndicatorCollectionViewProtocol <LUICollectionViewCellProtocol>
/// 返回页码视图在PageControl中，指定位置时的尺寸值
/// - Parameters:
///   - pageControl: 页码视图
///   - pageIndex: 页码位置，取值在[0,pageControl.numberOfPages-1]
///   - selected: 是否选中该页码
+ (CGSize)sizeForPageControl:(LUIPageControl *)pageControl pageIndex:(NSInteger)pageIndex selected:(BOOL)selected;

@optional
/*
 未选中状态
 选中状态
 从未选中过渡到选中，进度百分比
 从选中过渡到未选中，进度百分比
 */
- (void)pageControl:(LUIPageControl *)pageControl didScrollToPage:(NSInteger)pageIndex progress:(CGFloat)progress;
@end

NS_ASSUME_NONNULL_END

NS_ASSUME_NONNULL_BEGIN

@class LUIPageIndicatorCollectionViewModel;

@interface LUIPageControl : UIView
@property (nonatomic, assign) NSInteger numberOfPages;//总页数，默认为0
@property (nonatomic, assign) NSInteger currentPage;//选中页的索引，取值在[0,self.numberOfPages-1]
@property (nonatomic, assign) BOOL hidesForSinglePage;//只有一页时，隐藏自己
@property (nonatomic, strong, nullable) UIColor *pageIndicatorTintColor;//未选中页的颜色值
@property (nonatomic, strong, nullable) UIColor *currentPageIndicatorTintColor;//选中页的颜色值

@property (nonatomic, assign) CGSize pageIndicatorSize;//统一的未选中页的尺寸值，默认为0x0，代表由cell自行决定
@property (nonatomic, assign) CGSize currentPageIndicatorSize;//统一的当前选中页的尺寸值，默认为0x0，代表由cell自行决定

@property (nonatomic, strong, nullable) UIImage *pageIndicatorImage;//未选中页的图片，图片优先级高于TintColor
@property (nonatomic, strong, nullable) UIImage *currentPageIndicatorImage;//选中页的图片，图片优先级高于TintColor
@property (nonatomic, assign) LUIPageControlDirection direction;//默认为LUIPageControlDirectionHorizontal
@property (nonatomic, readonly) LUICGAxis scrollAxis;

@property (nonatomic, assign) UIEdgeInsets contentInsets;//内边距，默认为(0,0,0,0)
@property (nonatomic, assign) CGFloat interitemSpacing;//页码视图之间的间隔，默认为9px
@property (nonatomic, assign) BOOL scaleEdgePageIndicator;//是否缩小边缘页，默认为YES

- (void)setCurrentPage:(NSInteger)currentPage animated:(BOOL)animated;

// 百分比进度滚动到指定的页
- (void)scrollToPageIndex:(NSInteger)pageIndex progress:(CGFloat)progress;

/// 显示出来的页码范围，值在[visiblePages.localtion,NSMakeRange(visiblePages)).如果没有显示时，返回NSMakeRange(NSNotFound, 0)
/// 每次调用时，都会实时计算
@property (nonatomic, readonly) NSRange visiblePages;

/// 计算指定选中页时，可视内的页码范围
/// - Parameter currentPage: 当前页码
- (NSRange)visiblePagesForCurrentPage:(NSInteger)currentPage;

- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount;

/// 返回指定页单元，选中/非选中时的cell尺寸
/// - Parameters:
///   - pageIndex: 页码值
///   - selected: 是否选中
- (CGSize)pageIndicatorCellSizeForPageIndex:(NSInteger)pageIndex selected:(BOOL)selected;

#pragma mark - SubClass Override
@property (nonatomic, assign) Class<LUIPageIndicatorCollectionViewProtocol> pageIndicatorCellClass;//未选中页码对应的collectionViewCell单元格类。默认为LUIDotPageIndicatorCollectionView
/// 返回未选中页码对应的collectionViewCell单元格类。默认为LUIDotPageIndicatorCollectionView
/// - Parameter page: 指定页
- (Class<LUIPageIndicatorCollectionViewProtocol>)pageIndicatorCellClassForPage:(NSInteger)page;

@property (nonatomic, assign) Class<LUIPageIndicatorCollectionViewProtocol> currentPageIndicatorCellClass;//选中页码对应的collectionViewCell单元格类。默认为LUIDotPageIndicatorCollectionView
/// 返回选中页码对应的collectionViewCell单元格类。默认为LUIDotPageIndicatorCollectionView
/// - Parameter page: 指定页
- (Class<LUIPageIndicatorCollectionViewProtocol>)currentPageIndicatorCellClassForPage:(NSInteger)page;

/// 返回指定页码对应的collection cell数据模组
/// - Parameter page: 指定页
- (LUIPageIndicatorCollectionViewModel *)createPageIndicatorCollectionViewModelForPage:(NSInteger)page;
@end
NS_ASSUME_NONNULL_END


#import "LUICollectionViewCellModel.h"
#import "LUICollectionViewCellBase.h"

NS_ASSUME_NONNULL_BEGIN
//单个页码视图对应的数据模型model
@interface LUIPageIndicatorCollectionViewModel : LUICollectionViewCellModel
@property (nonatomic, weak) LUIPageControl *pageControl;//弱引用
@property (nonatomic, assign) NSRange visiblePages;//当前显示的页码范围
@end

/// 单个页码视图基类
@interface LUIPageIndicatorCollectionViewBase : LUICollectionViewCellBase<LUIPageIndicatorCollectionViewProtocol>
@property (nonatomic, readonly, nullable) LUIPageIndicatorCollectionViewModel *pageControlCellModel;
- (CGAffineTransform)transformWithScaleEdgePageIndicatorWithCurrentPage:(NSInteger)currentPage visiblePages:(NSRange)range;
@end

/// 单个圆点或显示图片的页码视图。
@interface LUIDotPageIndicatorCollectionView : LUIPageIndicatorCollectionViewBase
@property (nonatomic, readonly) UIView *pageDotView;//页码圆点视图
@property (nonatomic, readonly) UIImageView *pageImageView;//页码图片视图
+ (UIEdgeInsets)pageContentInsets;//页码视图的外边距，默认为0
+ (CGSize)maxSize;//最大尺寸值，默认为(8,8)
@end

/// 纯色的单个圆点页码视图,实现了滚动时百分比翻页效果。实现了方法- (void)pageControl:(LUIPageControl *)pageControl didScrollToPage:(NSInteger)pageIndex progress:(CGFloat)progress;
@interface LUIColorDotPageIndicatorCollectionView : LUIPageIndicatorCollectionViewBase
@property (nonatomic, readonly) UIView *pageDotView;//页码圆点视图
+ (UIEdgeInsets)pageContentInsets;//页码视图的外边距，默认为0
@end
NS_ASSUME_NONNULL_END
