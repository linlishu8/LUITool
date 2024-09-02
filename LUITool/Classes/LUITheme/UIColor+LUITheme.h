//
//  UIColor+LUITheme.h
//  LUITool
//
//  Created by 六月 on 2023/9/2.
//

#import <UIKit/UIKit.h>
#import "LUIThemeElementProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface UIColor (LUITheme)

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
+ (nullable UIColor *)ltheme_colorWithString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
