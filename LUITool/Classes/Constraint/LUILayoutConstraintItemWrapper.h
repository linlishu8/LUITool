//
//  LUILayoutConstraintItemWrapper.h
//  LUITool
//
//  Created by 六月 on 2024/8/14.
//

#import <Foundation/Foundation.h>
#import "LUILayoutConstraint.h"

NS_ASSUME_NONNULL_BEGIN

extern const CGFloat kLUILayoutConstraintItemFillContainerSize;//填充容器尺寸

@interface LUILayoutConstraintItemWrapper : NSObject <LUILayoutConstraintItemProtocol>

typedef CGSize(^LUILayoutConstraintItemWrapperBlock)(LUILayoutConstraintItemWrapper *wrapper,CGSize size,BOOL resizeItems);
@property(nonatomic,strong) __kindof id<LUILayoutConstraintItemProtocol> originItem;//被包装的原始布局元素对象
@property(nonatomic,assign) UIEdgeInsets margin;//外边距,默认为(0,0,0,0),self.layoutFrame=self.originItem.layoutFrame+self.margin
@property(nonatomic,assign) CGSize paddingSize;//内边距尺寸,用于计算sizeThatFits.具体为:sizeThatFits的值=self.margin+self.originItem的sizeThatFits值+self.paddingSize
@property(nonatomic,copy,nullable) LUILayoutConstraintItemWrapperBlock sizeThatFitsBlock;//用返回- (CGSize)sizeThatFits:(CGSize)size;和- (CGSize)sizeThatFits:(CGSize)size resizeItems:(BOOL)resizeItems;值的计算
@property(nonatomic,assign) CGSize fixedSize;//固定的尺寸,用于sizeThatFits:计算.如果某一边值<=0,代表这一边值不限定

+ (__kindof LUILayoutConstraintItemWrapper *)wrapItem:(id<LUILayoutConstraintItemProtocol>)originItem;
+ (__kindof LUILayoutConstraintItemWrapper *)wrapItem:(id<LUILayoutConstraintItemProtocol>)originItem fixedSize:(CGSize)fixedSize;
+ (__kindof LUILayoutConstraintItemWrapper *)wrapItem:(id<LUILayoutConstraintItemProtocol>)originItem sizeThatFitsBlock:(nullable LUILayoutConstraintItemWrapperBlock)sizeThatFitsBlock;
#pragma mark - delegate:LUILayoutConstraintItemProtocol
- (void)setLayoutFrame:(CGRect)frame;//设置布局尺寸
- (CGRect)layoutFrame;
- (CGSize)sizeOfLayout;//返回尺寸信息
- (BOOL)hidden;//是否隐藏,默认为NO

- (CGSize)sizeThatFits:(CGSize)size;
- (CGSize)sizeThatFits:(CGSize)size resizeItems:(BOOL)resizeItems;//适合于容器
- (void)layoutItemsWithResizeItems:(BOOL)resizeItems;//适合于容器

@end

NS_ASSUME_NONNULL_END
