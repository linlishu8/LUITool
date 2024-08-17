//
//  LUILayoutConstraintItemAttributeBase.h
//  LUITool
//
//  Created by 六月 on 2023/8/14.
//

#import <Foundation/Foundation.h>
#import "LUICGRect.h"
#import "CGGeometry+LUI.h"

NS_ASSUME_NONNULL_BEGIN

/// 可被布局的元素应该实现的协议。使用该协议的 实现类，来临时存放布局中的尺寸信息。
@protocol LUILayoutConstraintItemAttributeProtocol <NSObject>
- (void)setLayoutFrame:(CGRect)frame;//元素的尺寸
- (CGRect)layoutFrame;
@end

@interface LUILayoutConstraintItemAttributeBase : NSObject <LUILayoutConstraintItemAttributeProtocol>

@property (nonatomic, assign) CGRect layoutFrame;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGPoint origin;

@end

/// 临时保存单个可布局元素以及它的尺寸信息。
@interface LUILayoutConstraintItemAttribute : LUILayoutConstraintItemAttributeBase
@property (nonatomic, strong) id<LUILayoutConstraintItemAttributeProtocol> item;
- (id)initWithItem:(id<LUILayoutConstraintItemAttributeProtocol>)item;

/// 设置item的frame信息
- (void)applyAttribute;

/// 设置item的frame信息，如果item是容器，则会调用容器的layoutItemsWithResizeItems方法
/// - Parameter resizeItems: 容器时，是否重新布局子元素
- (void)applyAttributeWithResizeItems:(BOOL)resizeItems;
@end


/// 临时保存多个可布局元素，同时把它们作为一个整体，保存整体尺寸信息
@interface LUILayoutConstraintItemAttributeSection : LUILayoutConstraintItemAttributeBase
@property (nonatomic, strong) NSArray<id<LUILayoutConstraintItemAttributeProtocol>> *itemAttributs;
- (void)addItemAttribute:(id<LUILayoutConstraintItemAttributeProtocol>)itemAttribute;
- (void)insertItemAttribute:(id<LUILayoutConstraintItemAttributeProtocol>)itemAttribute atIndex:(NSInteger)index;
- (void)removeItemAttributeAtIndex:(NSInteger)index;

/// 计算元素流布局，整体占用的尺寸大小
/// - Parameters:
///   - itemSpacing: 元素间隔
///   - X: 流布局的方向，LUICGAxisX时，水平流布局。LUICGAxisY时，垂直流布局
- (CGSize)sizeThatFlowLayoutItemsWithSpacing:(CGFloat)itemSpacing axis:(LUICGAxis)X;


/// 对元素进行流布局，并设置元素的frame信息。如果元素的size无效时（有一边<=0），该元素将不被设置为（0，0），则不会占用间隔空间
/// - Parameters:
///   - itemSpacing: 元素间隔
///   - X: 流布局方向，LUICGAxisX时，水平流布局。LUICGAxisY时，垂直流布局
///   - alignY: 流布局垂直方向中，元素的对齐。如水平流布局时，alignY为Min，则居上；alignY为Mid，则居中；alignY为Max，则居下
///   - needRevert: 是否反转items的顺序，YES时，最后一个元素将排在第一位
- (void)flowLayoutItemsWithSpacing:(CGFloat)itemSpacing axis:(LUICGAxis)X alignment:(LUICGRectAlignment)alignY needRevert:(BOOL)needRevert;
@end

NS_ASSUME_NONNULL_END
