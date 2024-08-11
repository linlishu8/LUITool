//
//  UIButton+LUI.h
//  LUITool
//
//  Created by 六月 on 2024/8/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (LUI)
/**
 *  给不同的状态设置背景颜色,原理是通过生成color对应的图片,然后设置到背景图片中去
 *
 *  @param color 颜色
 *  @param state 状态
 */
- (void)l_setBackgroundColor:(nullable UIColor *)color forState:(UIControlState)state;

/**
 *  设置按钮的背景颜色,其中normal状态下的颜色为color,highlighted状态下的颜色为color的各个分量颜色值的一半
 *
 *  @param color 颜色
 */
- (void)l_setBackgroundColorForNormalAndHighlightedState:(nullable UIColor *)color;

@end

@interface UIButton (LUI_ActionBlock)
typedef void(^LUIButtonActionBlock)(id __nullable conext);

/**
 *  添加 block 形式的UIControlEventTouchUpInside点击事件
 *
 *  @param block   要执行的 block
 *  @param context block 执行时,传入的上下文对象,不会被 UIButton 持有
 */
- (void)l_addClickActionBlock:(nullable LUIButtonActionBlock)block context:(nullable id)context;
@end

NS_ASSUME_NONNULL_END
