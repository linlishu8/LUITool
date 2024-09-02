//
//  LUIWaterFlowLayoutConstraint.h
//  LUITool
//
//  Created by 六月 on 2023/8/14.
//

#import "LUILayoutConstraint.h"

NS_ASSUME_NONNULL_BEGIN

@interface LUIWaterFlowLayoutConstraint : LUILayoutConstraint

@property (nonatomic, assign) LUILayoutConstraintDirection layoutDirection;//布局方向.默认为LUILayoutConstraintDirectionHorizontal
@property (nonatomic, assign) LUILayoutConstraintVerticalAlignment layoutVerticalAlignment;//所有元素作为一个整体,在垂直方向上的位置,以及每一个元素在整体内的垂直方向上的对齐方式.默认为LUILayoutConstraintVerticalAlignmentCenter

@property (nonatomic, assign) LUILayoutConstraintHorizontalAlignment layoutHorizontalAlignment;//所有元素作为一个整体,在水平方向上的位置,以及每一个元素在整体内的水平方向上的对方方式.默认为LUILayoutConstraintHorizontalAlignmentCenter
@property (nonatomic, assign) UIEdgeInsets contentInsets;//内边距,默认为(0,0,0,0)
@property (nonatomic, assign) CGFloat interitemSpacing;//平行layoutDirection方向上元素间的间隔,默认为0
@property (nonatomic, assign) CGFloat lineSpacing;//垂直layoutDirection方向上，元素间的间隔,默认为0

@property (nonatomic, readonly, nullable) LUILayoutConstraintItemAttributeSection *itemAttributeSection;

/// 计算最合适的尺寸
/// @param size 外层限制
/// @param resizeItems 是否计算子元素的最合适尺寸。YES：调用子元素的sizeThatFits方法。NO：直接使用子元素的bounds.size
- (CGSize)sizeThatFits:(CGSize)size resizeItems:(BOOL)resizeItems;

/// 对子元素进行布局
/// @param resizeItems 在布局前,是否让每个子元素自动调整到合适的尺寸
- (void)layoutItemsWithResizeItems:(BOOL)resizeItems;

/// 计算在限制的容器尺寸下，生成布局每行的元素情况（水平布局为行数，垂直布局为列数）。里面每个元素只是计算了size值，origin都为(0,0)
/// @param size 容器尺寸
/// @param resizeItems 在布局前,是否让每个子元素自动调整到合适的尺寸
- (nullable LUILayoutConstraintItemAttributeSection *)itemAttributeSectionThatFits:(CGSize)size resizeItems:(BOOL)resizeItems;


/// 在瀑布流布局的基础上，添加上行数限制。具体为超出上限的行，不展示。同时固定最后一行末尾元素为lastLineItem，且该元素优先布局。
/// 这种布局可以用在app的搜索历史列表，末尾添加上一个“展开/折叠"的按钮(=lastLineItem)，同时折叠起来时，只展示N行。
#pragma mark - limit max lines
@property (nonatomic, assign) NSInteger maxLines;//限制最大的行数（水平布局时为行数，垂直布局时为列数)，<=0代表不限。超过该行数，后续元素尺寸都设置为(0,0)
@property (nonatomic, strong, nullable) id<LUILayoutConstraintItemProtocol> lastLineItem;//最后一行固定在末尾的item。如果有值，最后一行布局时，每一个元素都将扣除该末尾元素的空间，保证末尾元素一定显示。
@property (nonatomic, assign) BOOL showLastLineItemWithinMaxLine;//当maxLines>0且行数在最大值之内时，是否显示lastLineItem
@property (nonatomic, readonly) BOOL overMaxLines;//当maxLines>0时，行数是否超出行上限
@end

NS_ASSUME_NONNULL_END


NS_ASSUME_NONNULL_BEGIN
typedef enum : NSUInteger {
    LUIWaterFlowLayoutConstraintParam_H_C_C,
    LUIWaterFlowLayoutConstraintParam_H_C_L,
    LUIWaterFlowLayoutConstraintParam_H_C_R,
    LUIWaterFlowLayoutConstraintParam_H_T_C,
    LUIWaterFlowLayoutConstraintParam_H_T_L,
    LUIWaterFlowLayoutConstraintParam_H_T_R,
    LUIWaterFlowLayoutConstraintParam_H_B_L,
    LUIWaterFlowLayoutConstraintParam_H_B_C,
    LUIWaterFlowLayoutConstraintParam_H_B_R,
    LUIWaterFlowLayoutConstraintParam_V_C_C,
    LUIWaterFlowLayoutConstraintParam_V_C_L,
    LUIWaterFlowLayoutConstraintParam_V_C_R,
    LUIWaterFlowLayoutConstraintParam_V_T_C,
    LUIWaterFlowLayoutConstraintParam_V_T_L,
    LUIWaterFlowLayoutConstraintParam_V_T_R,
    LUIWaterFlowLayoutConstraintParam_V_B_C,
    LUIWaterFlowLayoutConstraintParam_V_B_L,
    LUIWaterFlowLayoutConstraintParam_V_B_R,
} LUIWaterFlowLayoutConstraintParam;

LUIAS_EnumTypeCategories(LUIWaterFlowLayoutConstraintParam)
@interface LUIWaterFlowLayoutConstraint(InitMethod)
- (id)initWithItems:(nullable NSArray<id<LUILayoutConstraintItemProtocol>> *)items constraintParam:(LUIWaterFlowLayoutConstraintParam)param contentInsets:(UIEdgeInsets)contentInsets interitemSpacing:(CGFloat)interitemSpacing lineSpacing:(CGFloat)lineSpacing;
- (void)configWithConstraintParam:(LUIWaterFlowLayoutConstraintParam)param;
@property (nonatomic, assign) LUIWaterFlowLayoutConstraintParam constraintParam;

+ (void)parseConstraintParam:(LUIWaterFlowLayoutConstraintParam)param layoutDirection:(LUILayoutConstraintDirection *)layoutDirection layoutVerticalAlignment:(LUILayoutConstraintVerticalAlignment *)layoutVerticalAlignment layoutHorizontalAlignment:(LUILayoutConstraintHorizontalAlignment *)layoutHorizontalAlignment;
+ (LUIWaterFlowLayoutConstraintParam)constraintParamWithLayoutDirection:(LUILayoutConstraintDirection)layoutDirection layoutVerticalAlignment:(LUILayoutConstraintVerticalAlignment)layoutVerticalAlignment layoutHorizontalAlignment:(LUILayoutConstraintHorizontalAlignment)layoutHorizontalAlignment;
@end
NS_ASSUME_NONNULL_END

/**
 *
 以下为layoutDirection,layoutVerticalAlignment,layoutHorizontalAlignment的18种组合:
 
 LUIWaterFlowLayoutConstraintParam_H_C_C
 layoutDirection = LUILayoutConstraintDirectionHorizontal;
 layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentCenter;
 layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentCenter;
 :
 __________
|                        |
|           B           |
|    A  A B C C    |
|           B           |
|                        |
|              E        |
|       D D E        |
|              E        |
|____________|
 
 LUIWaterFlowLayoutConstraintParam_H_C_L
 layoutDirection = LUILayoutConstraintDirectionHorizontal;
 layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentCenter;
 layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentLeft;
:
 _______
|                 |
|   B            |
|A B C C C |
|   B            |
|                 |
|    E           |
|D E           |
|    E           |
|________ |
 
 LUIWaterFlowLayoutConstraintParam_H_C_R
 layoutDirection = LUILayoutConstraintDirectionHorizontal;
 layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentCenter;
 layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentRight;
 :
 _________
|                     |
|               B    |
| C C C C B A|
|               B    |
|                     |
|               E    |
|               E D|
|               E    |
|__________ |
 
 LUIWaterFlowLayoutConstraintParam_H_T_C
 layoutDirection = LUILayoutConstraintDirectionHorizontal;
 layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentTop;
 layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentCenter;
 :
 _________
|   A A B C C  |
|         B C C  |
|         B          |
|                     |
|    D D D E    |
|               E    |
|               E    |
|                     |
|__________ |
 
 LUIWaterFlowLayoutConstraintParam_H_T_L
 layoutDirection = LUILayoutConstraintDirectionHorizontal;
 layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentTop;
 layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentLeft;
 :
 _________
|A B C C C C  |
|   B C C C C  |
|   B                |
|                     |
|D E               |
|    E               |
|    E               |
|                     |
|__________ |
 
 LUIWaterFlowLayoutConstraintParam_H_T_R
 layoutDirection = LUILayoutConstraintDirectionHorizontal;
 layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentTop;
 layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentRight;
 :
 _________
|    C C C B A|
|    C C C B A|
|               B   |
|                    |
|              E D|
|              E D|
|              E    |
|                    |
|__________|

 LUIWaterFlowLayoutConstraintParam_H_B_L
 layoutDirection = LUILayoutConstraintDirectionHorizontal;
 layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentBottom;
 layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentLeft;
 :
  _______
 |                 |
 |                 |
 |    B          |
 |    B C C   |
 |A  B C C   |
 |                 |
 |     E          |
 |     E          |
 |D_E_____|
 
 LUIWaterFlowLayoutConstraintParam_H_B_C
 layoutDirection = LUILayoutConstraintDirectionHorizontal;
 layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentBottom;
 layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentCenter;
 :
  _______________
 |                                   |
 |                                   |
 |                B                 |
 |                B C C C C  |
 | A A A A A B C C C C  |
 |                                   |
 |                       E          |
 |                       E          |
 |____D_D_D_E_____|
 
 LUIWaterFlowLayoutConstraintParam_H_B_R
 layoutDirection = LUILayoutConstraintDirectionHorizontal;
 layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentBottom;
 layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentRight;
 :
  _______________
 |                                   |
 |                                   |
 |                           B     |
 |                           B  A |
 | C C C C C C C  B  A |
 |                                   |
 |                          E      |
 |                          E       |
 |_____________E_D_|
 
 LUIWaterFlowLayoutConstraintParam_V_C_C
 layoutDirection = LUILayoutConstraintDirectionVertical;
 layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentCenter;
 layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentCenter;
 :
 _________
|    A               |
|    A          D   |
| BBB     EEE |
|    C         F    |
|__C_______|
 
 LUIWaterFlowLayoutConstraintParam_V_C_L
 layoutDirection = LUILayoutConstraintDirectionVertical;
 layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentCenter;
 layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentLeft;
 :
 ___________
| AA                    |
| AA        DD       |
| BBBB   EEE     |
| C          F          |
| C___________|
 
 LUIWaterFlowLayoutConstraintParam_V_C_R
 layoutDirection = LUILayoutConstraintDirectionVertical;
 layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentCenter;
 layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentRight;
 :
 ____________
|          AA             |
|          AA       DD |
|     BBBB     EEE |
|           C         F  |
|_____C_______|

 
 LUIWaterFlowLayoutConstraintParam_V_T_C
 layoutDirection = LUILayoutConstraintDirectionVertical;
 layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentTop;
 layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentCenter;
 :
 _________
|    A          D   |
|    A          D   |
| BBB     EEE |
|    C              |
|__________|
 
 
 LUIWaterFlowLayoutConstraintParam_V_T_L
 layoutDirection = LUILayoutConstraintDirectionVertical;
 layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentTop;
 layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentLeft;
 :
 __________
| AA        D         |
| AA        D         |
| BBBB  EEE     |
| C                     |
|____________|

 
 LUIWaterFlowLayoutConstraintParam_V_T_R
 layoutDirection = LUILayoutConstraintDirectionVertical;
 layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentTop;
 layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentRight;
 :
 __________
|         AA        D|
|         AA        D|
|     BBBB   EEE|
|           C           |
|____________|
 
 
 LUIWaterFlowLayoutConstraintParam_V_B_C
 layoutDirection = LUILayoutConstraintDirectionVertical;
 layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentBottom;
 layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentCenter;
 :
 
 _________
|                      |
|    C               |
|    C          E   |
|  BBB       E   |
|__A___DDD |
 
 
 LUIWaterFlowLayoutConstraintParam_V_B_L
 layoutDirection = LUILayoutConstraintDirectionVertical;
 layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentBottom;
 layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentLeft;
 :
 ___________
|                          |
|C                        |
|C           E          |
|BBB      E          |
|A_____DDD __|
 
 LUIWaterFlowLayoutConstraintParam_V_B_R
 layoutDirection = LUILayoutConstraintDirectionVertical;
 layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentBottom;
 layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentRight;
 :
 ___________
|                           |
|         C               |
|         C             E|
|     BBB            E|
| ____A___DDD |
 */
