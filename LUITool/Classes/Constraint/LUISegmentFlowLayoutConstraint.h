//
//  LUISegmentFlowLayoutConstraint.h
//  LUITool
//  将bounds切分成两块,然后两块靠边各自进行流布局
//  Created by 六月 on 2024/8/14.
//

#import "LUILayoutConstraint.h"

NS_ASSUME_NONNULL_BEGIN

@interface LUISegmentFlowLayoutConstraint : LUILayoutConstraint
@property (nonatomic, assign) LUILayoutConstraintDirection layoutDirection;//布局方向.默认为LUILayoutConstraintDirectionVertical
@property (nonatomic, assign) LUILayoutConstraintVerticalAlignment layoutVerticalAlignment;//所有元素作为一个整体,在垂直方向上的位置,以及每一个元素在整体内的垂直方向上的对齐方式.默认为LUILayoutConstraintVerticalAlignmentCenter

@property (nonatomic, assign) LUILayoutConstraintHorizontalAlignment layoutHorizontalAlignment;//所有元素作为一个整体,在水平方向上的位置,以及每一个元素在整体内的水平方向上的对方方式.默认为LUILayoutConstraintHorizontalAlignmentCenter
@property (nonatomic, assign) UIEdgeInsets contentInsets;//内边距,默认为(0,0,0,0)
@property (nonatomic, assign) CGFloat interitemSpacing;//元素间的间隔,默认为0

@property (nonatomic, assign) NSInteger boundaryItemIndex;//临界点,用于将self.items区分成两块,第一块为[0,boundaryItemIndex],第二块为(boundaryItemIndex,self.items.count)
- (void)setBoundaryItemIndexWithItem:(id<LUILayoutConstraintItemProtocol>)item;
@property (nonatomic, assign) BOOL isLayoutPriorityFirstItems;//是否优先布局前半部分.如果是,对前半部分sizeToFit,然后bounds扣掉前半部分区域,剩下区域给后半部分布局.默认为NO
@property (nonatomic, assign) CGFloat layoutPriorityItemsMaxBoundsPercent;//优先布局的一方,最多占掉bounds的宽/长的百分比,默认为0.75
@property (nonatomic, assign) BOOL fixSizeToFitsBounds;//在计算sizeThatFits时,根据布局方向,自动固定对应边的尺寸为传入的 size 的边,(如水平布局时,sizeThatFits.width=size.width),默认为 NO,即不固定

/**
 *  计算最合适的尺寸
 *
 *  @param size        外层限制
 *  @param resizeItems 是否计算子元素的最合适尺寸。YES：调用子元素的sizeThatFits方法。NO：直接使用子元素的bounds.size
 *
 *  @return 最合适的尺寸
 */
- (CGSize)sizeThatFits:(CGSize)size resizeItems:(BOOL)resizeItems;

/**
 *  对子元素进行布局
 *
 *  @param resizeItems 在布局前,是否让每个子元素自动调整到合适的尺寸
 */
- (void)layoutItemsWithResizeItems:(BOOL)resizeItems;

@end


typedef enum : NSUInteger {
    LUISegmentFlowLayoutConstraint_H_C,
    LUISegmentFlowLayoutConstraint_H_T,
    LUISegmentFlowLayoutConstraint_H_B,
    LUISegmentFlowLayoutConstraint_V_C,
    LUISegmentFlowLayoutConstraint_V_L,
    LUISegmentFlowLayoutConstraint_V_R,
} LUISegmentFlowLayoutConstraintParam;
LUIAS_EnumTypeCategories(LUISegmentFlowLayoutConstraintParam)

@interface LUISegmentFlowLayoutConstraint (InitMethod)
- (id)initWithItems:(nullable NSArray<id<LUILayoutConstraintItemProtocol>> *)items constraintParam:(LUISegmentFlowLayoutConstraintParam)param contentInsets:(UIEdgeInsets)contentInsets interitemSpacing:(CGFloat)interitemSpacing;
- (void)configWithConstraintParam:(LUISegmentFlowLayoutConstraintParam)param;

@property (nonatomic, assign) LUISegmentFlowLayoutConstraintParam constraintParam;

+ (void)parseConstraintParam:(LUISegmentFlowLayoutConstraintParam)param layoutDirection:(LUILayoutConstraintDirection *)layoutDirection layoutVerticalAlignment:(LUILayoutConstraintVerticalAlignment *)layoutVerticalAlignment layoutHorizontalAlignment:(LUILayoutConstraintHorizontalAlignment *)layoutHorizontalAlignment;
+ (LUISegmentFlowLayoutConstraintParam)constraintParamWithLayoutDirection:(LUILayoutConstraintDirection)layoutDirection layoutVerticalAlignment:(LUILayoutConstraintVerticalAlignment)layoutVerticalAlignment layoutHorizontalAlignment:(LUILayoutConstraintHorizontalAlignment)layoutHorizontalAlignment;
@end
NS_ASSUME_NONNULL_END
/**
 *
 以下为layoutDirection,layoutVerticalAlignment,layoutHorizontalAlignment的6种组合:
 
 LUISegmentFlowLayoutConstraint_H_C
 layoutDirection = LUILayoutConstraintDirectionHorizontal;
 layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentCenter;
 :
  ________________
 |                                  |
 |   B                             |
 |A B                          C|
 |   B                             |
 |_________________|
 
 LUISegmentFlowLayoutConstraint_H_T
 layoutDirection = LUILayoutConstraintDirectionHorizontal;
 layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentTop;
 :
  _________________
 |A B                           C|
 |   B                           C|
 |   B                             |
 |                                  |
 |_________________|
 
 LUISegmentFlowLayoutConstraint_H_B
 layoutDirection = LUILayoutConstraintDirectionHorizontal;
 layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentBottom;
 :
  _________________
 |                                   |
 |                                   |
 |    B                            |
 |    B                          C|
 |A_B_____________C|
 
 LUISegmentFlowLayoutConstraint_V_C
 layoutDirection = LUILayoutConstraintDirectionVertical;
 layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentCenter;
 :
  ____
 |    A   |
 | BBB |
 |         |
 |         |
 |__C_|
 
 LUISegmentFlowLayoutConstraint_V_L
 layoutDirection = LUILayoutConstraintDirectionVertical;
 layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentLeft;
 :
  _____
 |A        |
 |BBB   |
 |          |
 |          |
 |CC__|
 
 LUISegmentFlowLayoutConstraint_V_R
 layoutDirection = LUILayoutConstraintDirectionVertical;
 layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentRight;
 :
  _____
 |        A|
 |   BBB|
 |          |
 |          |
 |___CC|
  */
