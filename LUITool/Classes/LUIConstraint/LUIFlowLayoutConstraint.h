//
//  LUIFlowLayoutConstraint.h
//  LUITool
//  进行水平/垂直方向上的流布局,只会改变元素的位置,不会改变尺寸
//  Created by 六月 on 2023/8/14.
//

#import "LUILayoutConstraint.h"
#import "LUILayoutConstraintItemAttributeBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface LUIFlowLayoutConstraint : LUILayoutConstraint

@property (nonatomic, assign) LUILayoutConstraintDirection layoutDirection;//布局方向.默认为LUILayoutConstraintDirectionVertical
@property (nonatomic, assign) LUILayoutConstraintVerticalAlignment layoutVerticalAlignment;//所有元素作为一个整体,在垂直方向上的位置,以及每一个元素在整体内的垂直方向上的对齐方式.默认为LUILayoutConstraintVerticalAlignmentCenter

@property (nonatomic, assign) LUILayoutConstraintHorizontalAlignment layoutHorizontalAlignment;//所有元素作为一个整体,在水平方向上的位置,以及每一个元素在整体内的水平方向上的对方方式.默认为LUILayoutConstraintHorizontalAlignmentCenter
@property (nonatomic, assign) UIEdgeInsets contentInsets;//内边距,默认为(0,0,0,0)
@property (nonatomic, assign) CGFloat interitemSpacing;//元素间的间隔,默认为0
@property (nonatomic, assign) BOOL unLimitItemSizeInBounds;//在[self layoutItemsWithResizeItems:YES]时,计算每个元素的尺寸时,YES=不受self.bounds容器限制,item.size=item.sizeThatFits;NO=受self.bounds容器限制,item.size=MIN(item.sizeThatFits,bounds.size).默认为NO

@property (nonatomic, readonly, nullable) LUILayoutConstraintItemAttributeSection *itemAttributeSection;//流布局时，记录每个元素的frame信息

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

/**
 *  计算子元素是否不占用空间
 *
 *  @param bounds 在外层容器中的尺寸
 *  @param resizeItems 计算时,是否要计算子元素的最合适尺寸.
 *
 *  @return 是否不占用空间
 */
- (BOOL)isEmptyBounds:(CGRect)bounds withResizeItems:(BOOL)resizeItems;
@end

typedef enum : NSUInteger {
    LUIFlowLayoutConstraintParam_H_C_C,
    LUIFlowLayoutConstraintParam_H_C_L,
    LUIFlowLayoutConstraintParam_H_C_R,
    LUIFlowLayoutConstraintParam_H_T_C,
    LUIFlowLayoutConstraintParam_H_T_L,
    LUIFlowLayoutConstraintParam_H_T_R,
    LUIFlowLayoutConstraintParam_H_B_L,
    LUIFlowLayoutConstraintParam_H_B_C,
    LUIFlowLayoutConstraintParam_H_B_R,
    LUIFlowLayoutConstraintParam_V_C_C,
    LUIFlowLayoutConstraintParam_V_C_L,
    LUIFlowLayoutConstraintParam_V_C_R,
    LUIFlowLayoutConstraintParam_V_T_C,
    LUIFlowLayoutConstraintParam_V_T_L,
    LUIFlowLayoutConstraintParam_V_T_R,
    LUIFlowLayoutConstraintParam_V_B_C,
    LUIFlowLayoutConstraintParam_V_B_L,
    LUIFlowLayoutConstraintParam_V_B_R,
} LUIFlowLayoutConstraintParam;
LUIAS_EnumTypeCategories(LUIFlowLayoutConstraintParam)
@interface LUIFlowLayoutConstraint(InitMethod)
- (id)initWithItems:(nullable NSArray<id<LUILayoutConstraintItemProtocol>> *)items constraintParam:(LUIFlowLayoutConstraintParam)param contentInsets:(UIEdgeInsets)contentInsets interitemSpacing:(CGFloat)interitemSpacing;
- (void)configWithConstraintParam:(LUIFlowLayoutConstraintParam)param;
@property (nonatomic, assign) LUIFlowLayoutConstraintParam constraintParam;

+ (void)parseConstraintParam:(LUIFlowLayoutConstraintParam)param layoutDirection:(LUILayoutConstraintDirection *)layoutDirection layoutVerticalAlignment:(LUILayoutConstraintVerticalAlignment *)layoutVerticalAlignment layoutHorizontalAlignment:(LUILayoutConstraintHorizontalAlignment *)layoutHorizontalAlignment;
+ (LUIFlowLayoutConstraintParam)constraintParamWithLayoutDirection:(LUILayoutConstraintDirection)layoutDirection layoutVerticalAlignment:(LUILayoutConstraintVerticalAlignment)layoutVerticalAlignment layoutHorizontalAlignment:(LUILayoutConstraintHorizontalAlignment)layoutHorizontalAlignment;
@end
NS_ASSUME_NONNULL_END
/**
 *
 以下为layoutDirection,layoutVerticalAlignment,layoutHorizontalAlignment的18种组合:
 
 LUIFlowLayoutConstraintParam_H_C_C
 layoutDirection = LUILayoutConstraintDirectionHorizontal;
 layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentCenter;
 layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentCenter;
 :
 _________
|                    |
|         B         |
|      A B C     |
|         B         |
|__________|
 
 LUIFlowLayoutConstraintParam_H_C_L
 layoutDirection = LUILayoutConstraintDirectionHorizontal;
 layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentCenter;
 layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentLeft;
:
 ________
|                 |
|   B            |
|A B C        |
|   B            |
|________ |
 
 LUIFlowLayoutConstraintParam_H_C_R
 layoutDirection = LUILayoutConstraintDirectionHorizontal;
 layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentCenter;
 layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentRight;
 :
 __________
|                     |
|               B    |
|            A B C|
|               B    |
|___________|
 
 LUIFlowLayoutConstraintParam_H_T_C
 layoutDirection = LUILayoutConstraintDirectionHorizontal;
 layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentTop;
 layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentCenter;
 :
 __________
|      A B C      |
|         B C      |
|         B          |
|                     |
|__________ |
 
 LUIFlowLayoutConstraintParam_H_T_L
 layoutDirection = LUILayoutConstraintDirectionHorizontal;
 layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentTop;
 layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentLeft;
 :
 __________
|A B C            |
|   B C            |
|   B                |
|                     |
|__________ |
 
 LUIFlowLayoutConstraintParam_H_T_R
 layoutDirection = LUILayoutConstraintDirectionHorizontal;
 layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentTop;
 layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentRight;
 :
 __________
|            A B C|
|               B C|
|               B    |
|                     |
|__________ |

 LUIFlowLayoutConstraintParam_H_B_L
 layoutDirection = LUILayoutConstraintDirectionHorizontal;
 layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentBottom;
 layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentLeft;
 :
  ________
 |                 |
 |                 |
 |     B          |
 |     B C      |
 |A_B_C___|
 
 LUIFlowLayoutConstraintParam_H_B_C
 layoutDirection = LUILayoutConstraintDirectionHorizontal;
 layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentBottom;
 layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentCenter;
 :
  _________________
 |                                   |
 |                                   |
 |                B                 |
 |                B   C           |
 |______A_B_C______|
 
 LUIFlowLayoutConstraintParam_H_B_R
 layoutDirection = LUILayoutConstraintDirectionHorizontal;
 layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentBottom;
 layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentRight;
 :
  _________________
 |                                   |
 |                                   |
 |                            B     |
 |                            B  C|
 |____________A_B_C|
 
 LUIFlowLayoutConstraintParam_V_C_C
 layoutDirection = LUILayoutConstraintDirectionVertical;
 layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentCenter;
 layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentCenter;
 :
 ____
|          |
|    A    |
| BBB  |
|    C    |
|_____|
 
 LUIFlowLayoutConstraintParam_V_C_L
 layoutDirection = LUILayoutConstraintDirectionVertical;
 layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentCenter;
 layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentLeft;
 :
 ____
|          |
|A        |
|BBB   |
|CC     |
|_____|
 
 LUIFlowLayoutConstraintParam_V_C_R
 layoutDirection = LUILayoutConstraintDirectionVertical;
 layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentCenter;
 layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentRight;
 :
 ____
|         |
|       A|
|  BBB|
|    CC|
|_____|
 
 LUIFlowLayoutConstraintParam_V_T_C
 layoutDirection = LUILayoutConstraintDirectionVertical;
 layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentTop;
 layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentCenter;
 :
 ____
|    A   |
| BBB |
|    C  |
|         |
|____ |
 
 LUIFlowLayoutConstraintParam_V_T_L
 layoutDirection = LUILayoutConstraintDirectionVertical;
 layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentTop;
 layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentLeft;
 :
 ____
|A       |
|BBB  |
|CC    |
|         |
|____ |
 
 LUIFlowLayoutConstraintParam_V_T_R
 layoutDirection = LUILayoutConstraintDirectionVertical;
 layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentTop;
 layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentRight;
 :
 ____
|     A  |
|  BBB|
|   CC |
|         |
|____ |
 
 LUIFlowLayoutConstraintParam_V_B_C
 layoutDirection = LUILayoutConstraintDirectionVertical;
 layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentBottom;
 layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentCenter;
 :
 ____
|         |
|         |
|    A   |
| BBB |
|__C_ |
 
 LUIFlowLayoutConstraintParam_V_B_L
 layoutDirection = LUILayoutConstraintDirectionVertical;
 layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentBottom;
 layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentLeft;
 :
 ____
|          |
|          |
|A        |
|BBB   |
|CC__ |
 
 LUIFlowLayoutConstraintParam_V_B_R
 layoutDirection = LUILayoutConstraintDirectionVertical;
 layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentBottom;
 layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentRight;
 :
 _____
|           |
|           |
|         A|
|    BBB|
|___CC|
 */


