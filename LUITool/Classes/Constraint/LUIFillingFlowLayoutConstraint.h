//
//  LUIFillingFlowLayoutConstraint.h
//  LUITool
//  在水平方向|垂直方向上,进行流布局,头尾元素顶边,剩余的元素,以等间隔排列.
//  Created by 六月 on 2024/8/14.
//

#import "LUILayoutConstraint.h"

NS_ASSUME_NONNULL_BEGIN

@interface LUIFillingFlowLayoutConstraint : LUILayoutConstraint

@property (nonatomic, assign) LUILayoutConstraintDirection layoutDirection;//元素的流布局方向.默认为LUILayoutConstraintDirectionVertical.水平布局时,元素从左到向右布局.垂直布局时,元素从上到下布局

@property (nonatomic, assign) LUILayoutConstraintVerticalAlignment layoutVerticalAlignment;//当水平布局时,每个元素在自己的单元格容器内,在垂直方向上的位置.默认为LUILayoutConstraintVerticalAlignmentCenter
@property (nonatomic, assign) LUILayoutConstraintHorizontalAlignment layoutHorizontalAlignment;//当垂直布局时,每个元素在自己的单元格容器内,在水平方向上的位置.默认为LUILayoutConstraintHorizontalAlignmentCenter

@property (nonatomic, assign) UIEdgeInsets contentInsets;//内边距,默认为(0,0,0,0)
- (CGSize)sizeThatFits:(CGSize)size resizeItems:(BOOL)resizeItems;
- (void)layoutItemsWithResizeItems:(BOOL)resizeItems;
@end

typedef enum : NSUInteger {
    LUIFillingFlowLayoutConstraint_H_C,
    LUIFillingFlowLayoutConstraint_H_T,
    LUIFillingFlowLayoutConstraint_H_B,
    LUIFillingFlowLayoutConstraint_V_C,
    LUIFillingFlowLayoutConstraint_V_L,
    LUIFillingFlowLayoutConstraint_V_R,
} LUIFillingFlowLayoutConstraintParam;
LUIAS_EnumTypeCategories(LUIFillingFlowLayoutConstraintParam)
@interface LUIFillingFlowLayoutConstraint (InitMethod)
- (id)initWithItems:(nullable NSArray<id<LUILayoutConstraintItemProtocol>> *)items constraintParam:(LUIFillingFlowLayoutConstraintParam)param contentInsets:(UIEdgeInsets)contentInsets;
@property (nonatomic, assign) LUIFillingFlowLayoutConstraintParam constraintParam;
+ (void)parseConstraintParam:(LUIFillingFlowLayoutConstraintParam)param layoutDirection:(LUILayoutConstraintDirection *)layoutDirection layoutVerticalAlignment:(LUILayoutConstraintVerticalAlignment *)layoutVerticalAlignment layoutHorizontalAlignment:(LUILayoutConstraintHorizontalAlignment *)layoutHorizontalAlignment;

+ (LUIFillingFlowLayoutConstraintParam)constraintParamWithLayoutDirection:(LUILayoutConstraintDirection)layoutDirection layoutVerticalAlignment:(LUILayoutConstraintVerticalAlignment)layoutVerticalAlignment layoutHorizontalAlignment:(LUILayoutConstraintHorizontalAlignment)layoutHorizontalAlignment;
@end

NS_ASSUME_NONNULL_END

/**
 *
 以下为layoutDirection,layoutVerticalAlignment,layoutHorizontalAlignment的6种组合:
 self.fillingItem = C
 LUIFillingFlowLayoutConstraint_H_C
 layoutDirection = LUILayoutConstraintDirectionHorizontal;
 layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentCenter;
 :
  __________
 |                    |
 |    B       D    |
 |A  B  C  D  E|
 |    B       D    |
 |__________|
 
 LUIFillingFlowLayoutConstraint_H_T
 layoutDirection = LUILayoutConstraintDirectionHorizontal;
 layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentTop;
 :
  __________
 |A  B  C  D  E|
 |    B       D    |
 |    B       D    |
 |                    |
 |__________|
 
 LUIFillingFlowLayoutConstraint_H_B
 layoutDirection = LUILayoutConstraintDirectionHorizontal;
 layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentBottom;
 :
  _____________
 |                            |
 |                            |
 |      B           D      |
 |      B           D      |
 |A__B__C__D__E|
 
 LUIFillingFlowLayoutConstraint_V_C
 layoutDirection = LUILayoutConstraintDirectionVertical;
 layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentCenter;
 :
  ____
 |    A   |
 |         |
 | BBB |
 |         |
 |   C    |
 |          |
 | DDD |
 |          |
 |__E__|
 
 LUIFillingFlowLayoutConstraint_V_L
 layoutDirection = LUILayoutConstraintDirectionVertical;
 layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentLeft;
 :
  ____
 |A       |
 |         |
 |BBB  |
 |         |
 |C      |
 |         |
 |DDD |
 |         |
 |E___|
 
 LUIFillingFlowLayoutConstraint_V_R
 layoutDirection = LUILayoutConstraintDirectionVertical;
 layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentRight;
 :
  ____
 |       A|
 |         |
 |  BBB|
 |         |
 |      C|
 |         |
 |  DDD|
 |         |
 |___E|
 */
