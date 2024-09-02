//
//  LUIFillingLayoutConstraint.h
//  LUITool
//  布局时,有一个填充元素,它在其他元素布局结束之后,填充剩下的空间
//  Created by 六月 on 2023/8/14.
//

#import "LUILayoutConstraint.h"

NS_ASSUME_NONNULL_BEGIN

@interface LUIFillingLayoutConstraint : LUILayoutConstraint

@property (nonatomic, assign) LUILayoutConstraintDirection layoutDirection;//布局方向.默认为LUILayoutConstraintDirectionVertical
@property (nonatomic, assign) LUILayoutConstraintVerticalAlignment layoutVerticalAlignment;//所有元素作为一个整体,在垂直方向上的位置,以及每一个元素在整体内的垂直方向上的对齐方式.默认为LUILayoutConstraintVerticalAlignmentCenter

@property (nonatomic, assign) LUILayoutConstraintHorizontalAlignment layoutHorizontalAlignment;//所有元素作为一个整体,在水平方向上的位置,以及每一个元素在整体内的水平方向上的对方方式.默认为LUILayoutConstraintHorizontalAlignmentCenter

@property (nonatomic, assign) UIEdgeInsets contentInsets;//内边距,默认为(0,0,0,0)
@property (nonatomic, assign) CGFloat interitemSpacing;//元素间的间隔,默认为0
@property (nonatomic, strong, nullable) id<LUILayoutConstraintItemProtocol> fillingItem;//被填充的元素,它会在最后才进行布局,尺寸等于剩下的空白区域
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
    LUIFillingLayoutConstraint_H_C,
    LUIFillingLayoutConstraint_H_T,
    LUIFillingLayoutConstraint_H_B,
    LUIFillingLayoutConstraint_V_C,
    LUIFillingLayoutConstraint_V_L,
    LUIFillingLayoutConstraint_V_R,
} LUIFillingLayoutConstraintParam;
LUIAS_EnumTypeCategories(LUIFillingLayoutConstraintParam)
@interface LUIFillingLayoutConstraint (InitMethod)
- (id)initWithItems:(nullable NSArray<id<LUILayoutConstraintItemProtocol>> *)items fillingItem:(nullable id<LUILayoutConstraintItemProtocol>)fillingItem constraintParam:(LUIFillingLayoutConstraintParam)param contentInsets:(UIEdgeInsets)contentInsets interitemSpacing:(CGFloat)interitemSpacing;
@property (nonatomic, assign) LUIFillingLayoutConstraintParam constraintParam;
+ (void)parseConstraintParam:(LUIFillingLayoutConstraintParam)param layoutDirection:(LUILayoutConstraintDirection *)layoutDirection layoutVerticalAlignment:(LUILayoutConstraintVerticalAlignment *)layoutVerticalAlignment layoutHorizontalAlignment:(LUILayoutConstraintHorizontalAlignment *)layoutHorizontalAlignment;
+ (LUIFillingLayoutConstraintParam)constraintParamWithLayoutDirection:(LUILayoutConstraintDirection)layoutDirection layoutVerticalAlignment:(LUILayoutConstraintVerticalAlignment)layoutVerticalAlignment layoutHorizontalAlignment:(LUILayoutConstraintHorizontalAlignment)layoutHorizontalAlignment;
@end
NS_ASSUME_NONNULL_END
/**
 *
 以下为layoutDirection,layoutVerticalAlignment,layoutHorizontalAlignment的6种组合:
 self.fillingItem = C
 LUIFillingLayoutConstraint_H_C
 layoutDirection = LUILayoutConstraintDirectionHorizontal;
 layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentCenter;
 :
  ______________
 |                              |
 |   B                         |
 |A B CC<------->CC|
 |   B                         |
 |_______________|
 
 LUIFillingLayoutConstraint_H_T
 layoutDirection = LUILayoutConstraintDirectionHorizontal;
 layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentTop;
 :
  ______________
 |A B CC<------->CC|
 |   B                        |
 |   B                        |
 |                              |
 |_______________|
 
 LUIFillingLayoutConstraint_H_B
 layoutDirection = LUILayoutConstraintDirectionHorizontal;
 layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentBottom;
 :
  _______________
 |                               |
 |                               |
 |    B                         |
 |    B                         |
 |A_B_CC<------->CC|
 
 LUIFillingLayoutConstraint_V_C
 layoutDirection = LUILayoutConstraintDirectionVertical;
 layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentCenter;
 :
  ____
 |    A   |
 | BBB |
 |    C  |
 |    C  |
 |__C_|
 
 LUIFillingLayoutConstraint_V_L
 layoutDirection = LUILayoutConstraintDirectionVertical;
 layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentLeft;
 :
  ____
 |  A     |
 |BBB  |
 |  C    |
 |  C    |
 |_C__|
 
 LUIFillingLayoutConstraint_V_R
 layoutDirection = LUILayoutConstraintDirectionVertical;
 layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentRight;
 :
  ____
 |     A  |
 |  BBB|
 |     C |
 |     C |
 |__ C|
 */
