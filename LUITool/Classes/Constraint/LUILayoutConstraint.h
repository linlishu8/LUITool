//
//  LUILayoutConstraint.h
//  LUITool
//
//  Created by 六月 on 2023/8/14.
//

#import <Foundation/Foundation.h>
#import "LUILayoutConstraintItemAttributeBase.h"
#import "LUIDefine_EnumUtil.h"

NS_ASSUME_NONNULL_BEGIN

//被布局的元素要支持的方法
@protocol LUILayoutConstraintItemProtocol <LUILayoutConstraintItemAttributeProtocol>

- (CGSize)sizeOfLayout;//返回尺寸信息
- (BOOL)hidden;//是否隐藏,默认为NO
- (void)setLayoutTransform:(CGAffineTransform)transform;//以布局bounds为中心点,对布局作为一个整体,设置底下元素的仿射矩阵
@optional
- (CGSize)sizeThatFits:(CGSize)size;
- (CGSize)sizeThatFits:(CGSize)size resizeItems:(BOOL)resizeItems;//适合于容器
- (void)layoutItemsWithResizeItems:(BOOL)resizeItems;//适合于容器
@end

typedef NS_ENUM(NSInteger, LUILayoutConstraintVerticalAlignment) {
    LUILayoutConstraintVerticalAlignmentCenter  = 0,
    LUILayoutConstraintVerticalAlignmentTop     = 1,
    LUILayoutConstraintVerticalAlignmentBottom  = 2,
};
LUIAS_EnumTypeCategories(LUILayoutConstraintVerticalAlignment)
CG_INLINE LUICGRectAlignment LUICGRectAlignmentFromLUILayoutConstraintVerticalAlignment(LUILayoutConstraintVerticalAlignment align) {
    return align == LUILayoutConstraintVerticalAlignmentCenter ? LUICGRectAlignmentMid:(align == LUILayoutConstraintVerticalAlignmentTop ? LUICGRectAlignmentMin:LUICGRectAlignmentMax);
}

typedef NS_ENUM(NSInteger, LUILayoutConstraintHorizontalAlignment) {
    LUILayoutConstraintHorizontalAlignmentCenter = 0,
    LUILayoutConstraintHorizontalAlignmentLeft   = 1,
    LUILayoutConstraintHorizontalAlignmentRight  = 2,
};
LUIAS_EnumTypeCategories(LUILayoutConstraintHorizontalAlignment)
CG_INLINE LUICGRectAlignment LUICGRectAlignmentFromLUILayoutConstraintHorizontalAlignment(LUILayoutConstraintHorizontalAlignment align) {
    return align==LUILayoutConstraintHorizontalAlignmentCenter?LUICGRectAlignmentMid:(align==LUILayoutConstraintHorizontalAlignmentLeft?LUICGRectAlignmentMin:LUICGRectAlignmentMax);
}

typedef NS_ENUM(NSUInteger, LUILayoutConstraintDirection) {
    LUILayoutConstraintDirectionVertical,//垂直布局
    LUILayoutConstraintDirectionHorizontal,//水平布局
};
LUIAS_EnumTypeCategories(LUILayoutConstraintDirection)

@interface LUILayoutConstraint : NSObject <LUILayoutConstraintItemProtocol, NSCopying> {
    @protected
    NSMutableArray<id<LUILayoutConstraintItemProtocol>> *_items;
}

@property (nonatomic, assign) BOOL hidden;//是否隐藏,默认为NO
@property (nonatomic, strong, nullable) NSArray<id<LUILayoutConstraintItemProtocol>> *items;//@[id<LUILayoutConstraintItemProtocol>]
@property (nonatomic, assign) CGRect bounds;//在bounds的区域内布局
@property (nonatomic, assign) BOOL layoutHiddenItem;//是否布局隐藏元素,默认为NO
- (instancetype)initWithItems:(nullable NSArray<id<LUILayoutConstraintItemProtocol>> *)items bounds:(CGRect)bounds;
- (void)addItem:(id<LUILayoutConstraintItemProtocol>)item;
- (void)removeItem:(id<LUILayoutConstraintItemProtocol>)item;
- (void)replaceItem:(id<LUILayoutConstraintItemProtocol>)oldItem with:(nullable id<LUILayoutConstraintItemProtocol>)newItem;//进行item的替换,如果items中元素为LUILayoutConstraintItemWrapper话,会检查期origin是否==oldItem
- (void)layoutItems;//进行布局,子类实现
@property (nonatomic, readonly, nullable) NSArray<id<LUILayoutConstraintItemProtocol>> *layoutedItems;//显示的元素,@[id<LUILayoutConstraintItemProtocol>]
@property (nonatomic, readonly, nullable) NSArray<id<LUILayoutConstraintItemProtocol>> *visiableItems;//显示的元素,@[id<LUILayoutConstraintItemProtocol>]
/**
 *  计算适应的bounds的尺寸
 *    @override    子类重量写
 *  @param size 限定的尺寸
 *
 *  @return 合适的尺寸
 */
- (CGSize)sizeThatFits:(CGSize)size;

/**
 *    将布局中的元素,作为一个整体,以self.bounds中心点为坐标原点,应用上transform仿射变换矩阵
 *    例如:transform=CGAffineTransformMakeRotation(M_PI_2),则会以对每一个item,以bounds为中心点,旋转90度
 *    @param transform 变换矩阵
 */
- (void)setLayoutTransform:(CGAffineTransform)transform;

/**
 *  将布局中的元素,作为一个整体,以self.bounds中心点为坐标原点,应用上transform仿射变换矩阵.该方法计算出transform添加上中心点变换的矩阵运算
 *    @param transform 变换矩阵
 *  @return 以bounds为中心点的变换矩阵
 */
- (CGAffineTransform)convertTransfromWith:(CGAffineTransform)transform toItem:(id<LUILayoutConstraintItemProtocol>)item;
@end

@interface UIView(LUILayoutConstraintItemProtocol) <LUILayoutConstraintItemProtocol>
@end

@interface UICollectionViewLayoutAttributes(LUILayoutConstraintItemProtocol) <LUILayoutConstraintItemProtocol>
@end

NS_ASSUME_NONNULL_END
