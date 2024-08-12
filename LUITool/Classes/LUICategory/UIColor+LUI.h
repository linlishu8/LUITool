//
//  UIColor+LUI.h
//  LUITool
//
//  Created by 六月 on 2023/8/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (LUI)
@property (nonatomic, readonly) NSString *l_description;//输出调试的字符串
/// 浅色模式时，返回lightColor，深色模式时，返回lightColor的取反色
/// @param lightColor 浅色模式的颜色
+ (nullable UIColor *)l_colorWithLight:(nullable UIColor *)lightColor;

/// 返回浅色、深色模式对应的颜色
/// @param lightColor 浅色颜色值，nil时，将使用darkColor的取反色
/// @param darkColor 深色颜色值，nil时，将使用lightColor的取反色
+ (nullable UIColor *)l_colorWithLight:(nullable UIColor *)lightColor dark:(nullable UIColor *)darkColor;

- (UIColor *)l_resolvedColorWithTraitCollection:(UITraitCollection *)traitCollection;

/// 返回灰度值
@property (nonatomic, readonly) UIColor *l_grayColor;

/// 生成支持黑暗模式的动态颜色
@property (nonatomic, readonly) UIColor *l_autoDynamicDarkColor;

@property (nonatomic, readonly, nullable) UIColor *l_halfColor;//返回一半分量的颜色值


//支持以下格式：
//颜色的名称，比如red, blue, brown, lightseagreen等，不区分大小写
///
///color:red;    /* 红色 */
///color:black;  /* 黑色 */
///color:gray;   /* 灰色 */
///color:white;  /* 白色 */
///color:purple; /* 紫色 */

//十六进制符号 #RRGGBB、#RRGGBBAA、#RGB、#RGBA（比如 #ff0000）。"#" 后跟 6 位或者 3 位十六进制字符（0-9, A-F）
//        #f03
//        #F03
//        #ff0033
//        #FF0033
//        #FF0033FF
+ (nullable UIColor *)l_colorWithString:(NSString *)string;
@end

@interface UIColor (LUIAlertView)

@property (nonatomic, readonly, class) UIColor *l_alertBackgroundColor;
@property (nonatomic, readonly, class) UIColor *l_defaultActionStyleColor;//确定等操作按钮的蓝色颜色
@property (nonatomic, readonly, class) UIColor *l_destructiveActionStyleColor;//删除操作按钮的红色颜色
@property (nonatomic, readonly, class) UIColor *l_cancelStyleActionColor;//取消操作按钮的红色颜色
@property (nonatomic, readonly, class) UIColor *l_disableActionColor;//不可用的灰色颜色
@property (nonatomic, readonly, class) UIColor *l_actionCellSelectedColor;//操作按钮选中的颜色

@end

NS_ASSUME_NONNULL_END
