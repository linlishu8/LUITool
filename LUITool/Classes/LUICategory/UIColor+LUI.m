//
//  UIColor+LUI.m
//  LUITool
//
//  Created by 六月 on 2023/8/11.
//

#import "UIColor+LUI.h"

@implementation UIColor (LUI)

- (NSString *)l_description {
    CGFloat r,g,b,a;
    if ([self getRed:&r green:&g blue:&b alpha:&a]) {
        int r1 = r*255;
        int g1 = g*255;
        int b1 = b*255;
        int a1 = a*255;
        return [NSString stringWithFormat:@"<#%02X%02X%02X%02X:%@>",r1,g1,b1,a1,[self description]];
    } else {
        return [super description];
    }
}
- (UIColor *)l_invertColorToDark:(BOOL)dark {
    if ([self isEqual:[UIColor whiteColor]]) {
        if (@available(iOS 13.0, *)) {
            return [UIColor systemGray5Color];
        } else {
            return [UIColor colorWithRed:0.173 green:0.173 blue:0.18 alpha:1];
        }
    }
    UIColor *c = self;
    CGFloat r,g,b,a,H,S,B;
    if ([self getRed:&r green:&g blue:&b alpha:&a]) {//灰度图片，直接反转灰度值
        if (r==g && g==b) {
            CGFloat gray = 1-r;
            c = [UIColor colorWithWhite:gray alpha:a];
            return c;
        }
    }
    if ([self getHue:&H saturation:&S brightness:&B alpha:&a]) {
        if (dark) {
            S -= 0.04;
            S = MAX(0,S);
        } else {
            S += 0.04;
            S = MIN(1,S);
        }
        if (dark) {
            B += 0.04;
            B = MIN(1,B);
        } else {
            B -= 0.04;
            B = MAX(0,B);
        }
        c = [UIColor colorWithHue:H saturation:S brightness:B alpha:a];
    }
    return c;
}
- (UIColor *)l_autoDynamicDarkColor {
    return [UIColor l_colorWithLight:self];
}
+ (nullable UIColor *)l_colorWithLight:(nullable UIColor *)lightColor {
    return [self l_colorWithLight:lightColor dark:[lightColor l_invertColorToDark:YES]];
}
- (UIColor *)l_resolvedColorWithTraitCollection:(UITraitCollection *)traitCollection {
    if (@available(iOS 13.0, *)) {
        return [self resolvedColorWithTraitCollection:traitCollection];
    } else {
        return self;
    }
}
+ (nullable UIColor *)l_colorWithLight:(nullable UIColor *)lightColor dark:(nullable UIColor *)darkColor {
    UIColor *c = lightColor;
    if (@available(iOS 13.0, *)) {
        c = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            UIColor *c = nil;
            if (traitCollection.userInterfaceStyle==UIUserInterfaceStyleDark) {
                if (darkColor) {
                    c = darkColor;
                } else {
                    c = lightColor;
                }
            } else {
                if (lightColor) {
                    c = lightColor;
                } else {
                    c = darkColor;
                }
            }
            return c;
        }];
    }
    return c;
}
- (UIColor *)l_grayColor {
    //参见https://blog.csdn.net/u012308586/article/details/94619769/
    //对于彩色转灰度，有一个很著名的心理学公式：Gray = R*0.299 + G*0.587 + B*0.114
    CGFloat r,g,b,a;
    [self getRed:&r green:&g blue:&b alpha:&a];
    CGFloat gray = r*0.299+g*0.587+b*0.114;
    UIColor *result = [UIColor colorWithWhite:gray alpha:a];
    return result;
}
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
 
 //红-绿-蓝（red-green-blue (RGB)）
 //        规定颜色值为 rgb 代码的颜色，函数格式为 rgb(R,G,B)，取值可以是 0-255 的整数或百分比。
 //        rgb(255,0,51)
 //        rgb(255, 0, 51)
 //        rgb(100%,0%,20%)
 //        rgb(100%, 0%, 20%)
 
 //红-绿-蓝-阿尔法（RGBa）
 //        RGBa 扩展了 RGB 颜色模式，它包含了阿尔法通道，允许设定一个颜色的透明度。a 表示透明度：0=透明；1=不透明。
 //        rgba(255,0,0,0.1)    /* 10% 不透明 */
 //        rgba(255,0,0,0.4)    /* 40% 不透明 */
 //        rgba(255,0,0,0.7)    /* 70% 不透明 */
 //        rgba(255,0,0,  1)    /* 不透明，即红色 */
//色相-饱和度-明度（Hue-saturation-lightness）
//        色相（Hue）表示色环（即代表彩虹的一个圆环）的一个角度。
//        饱和度和明度由百分数来表示。
//        100% 是满饱和度，而 0% 是一种灰度。
//        100% 明度是白色， 0% 明度是黑色，而 50% 明度是"一般的"。

//        hsl(120,100%,25%)    /* 深绿色 */
//        hsl(120,100%,50%)    /* 绿色 */
//        hsl(120,100%,75%)    /* 浅绿色 */

//色相-饱和度-明度-阿尔法（HSLa）
//        HSLa 扩展自 HSL 颜色模式，包含了阿尔法通道，可以规定一个颜色的透明度。 a 表示透明度：0=透明；1=不透明。
//        hsla(240,100%,50%,0.05)   /* 5% 不透明 */
//        hsla(240,100%,50%, 0.4)   /* 40% 不透明 */
//        hsla(240,100%,50%, 0.7)   /* 70% 不透明 */
//        hsla(240,100%,50%,   1)   /* 完全不透明 */

+ (UIColor *)l_colorWithString:(NSString *)string {
    UIColor *color = nil;
    NSString *lowstring = string.lowercaseString;
    if ([lowstring isEqual:@"red"]) {
        color = [UIColor redColor];
    } else if ([lowstring isEqual:@"green"]) {
        color = [UIColor greenColor];
    } else if ([lowstring isEqual:@"blue"]) {
        color = [UIColor blueColor];
    } else if ([lowstring isEqual:@"black"]) {
        color = [UIColor blackColor];
    } else if ([lowstring isEqual:@"gray"]) {
        color = [UIColor grayColor];
    } else if ([lowstring isEqual:@"white"]) {
        color = [UIColor whiteColor];
    } else if ([lowstring isEqual:@"purple"]) {
        color = [UIColor purpleColor];
    } else if ([string hasPrefix:@"#"]) {
        NSScanner *scanner = [[NSScanner alloc] initWithString:string];
        [scanner scanString:@"#" intoString:nil];
        unsigned hex;
        if ([scanner scanHexInt:&hex]) {
            switch (string.length) {
                case 4://#RGB，如#f03
                {
                    CGFloat divisor = 15.0;
                    CGFloat redValue = ((hex & 0xF00) >> 8 )/divisor;
                    CGFloat greenValue = ((hex & 0x0F0) >> 4 )/divisor;
                    CGFloat blueValue = ((hex & 0x00F) >> 0 )/divisor;
                    CGFloat alpha = 1.0;
                    color = [UIColor colorWithRed:redValue green:greenValue blue:blueValue alpha:alpha];
                }
                    break;
                case 5://#RGBA,如#f033
                {
                    CGFloat divisor = 15.0;
                    CGFloat redValue = ((hex & 0xF000) >> 12 )/divisor;
                    CGFloat greenValue = ((hex & 0x0F00) >> 8 )/divisor;
                    CGFloat blueValue = ((hex & 0x00F0) >> 4 )/divisor;
                    CGFloat alpha = ((hex & 0x000F) >> 0 )/divisor;
                    color = [UIColor colorWithRed:redValue green:greenValue blue:blueValue alpha:alpha];
                }
                    break;
                case 7://#RRGGBB，如#ff0033
                {
                    CGFloat divisor = 255.0;
                    CGFloat redValue = ((hex & 0xFF0000) >> 16 )/divisor;
                    CGFloat greenValue = ((hex & 0x00FF00) >> 8 )/divisor;
                    CGFloat blueValue = ((hex & 0x0000FF) >> 0 )/divisor;
                    CGFloat alpha = 1.0;
                    color = [UIColor colorWithRed:redValue green:greenValue blue:blueValue alpha:alpha];
                }
                    break;
                case 9://#RRGGBBAA，如#ff003322
                {
                    CGFloat divisor = 255.0;
                    CGFloat redValue = ((hex & 0xFF000000) >> 24 )/divisor;
                    CGFloat greenValue = ((hex & 0x00FF0000) >> 16 )/divisor;
                    CGFloat blueValue = ((hex & 0x0000FF00) >> 8 )/divisor;
                    CGFloat alpha = ((hex & 0x000000FF) >> 0 )/divisor;
                    color = [UIColor colorWithRed:redValue green:greenValue blue:blueValue alpha:alpha];
                }
                    break;
                default:
                    NSLog(@"Scan color string %@ fail,it should be like #RRGGBB or #RGB . eg #ff0033 or #f03",string);
                    break;
            }
        }
    }
    return color;
}
- (UIColor *)l_halfColor {
    UIColor *color = self;
    UIColor *halfColor = nil;
    if (!halfColor) {
        CGFloat r,g,b,a;
        if ([color getRed:&r green:&g blue:&b alpha:&a]) {
            halfColor = [UIColor colorWithRed:r*0.5 green:g*0.5 blue:b*0.5 alpha:a];
        }
    }
    if (!halfColor) {
        CGFloat w,a;
        if ([color getWhite:&w alpha:&a]) {
            halfColor = [UIColor colorWithWhite:w*0.5 alpha:a];
        }
    }
    if (!halfColor) {
        CGFloat h,s,b,a;
        if ([color getHue:&h saturation:&s brightness:&b alpha:&a]) {
            halfColor = [UIColor colorWithHue:h*0.5 saturation:s*0.5 brightness:b*0.5 alpha:a];
        }
    }
    return halfColor;
}
@end

@implementation UIColor (LUIListSelectionCellView)
+ (UIColor *)l_listViewBackgroundColor {
    UIColor *color = [UIColor l_colorWithLight:[UIColor l_colorWithString:@"#F2F2F7"] dark:[UIColor blackColor]];
    return color;
}
+ (UIColor *)l_listViewGroupBackgroundColor {
    UIColor *color = [UIColor l_colorWithLight:[UIColor whiteColor] dark:[UIColor l_colorWithString:@"#1C1C1C"]];
    return color;
}
+ (UIColor *)l_listViewSeparatorColor {
    UIColor *color = [UIColor l_colorWithLight:[UIColor l_colorWithString:@"#D2D2D2"] dark:[UIColor l_colorWithString:@"#444444"]];
    return color;
}
+ (UIColor *)l_listViewCellSelectedColor {
    UIColor *color = [UIColor l_colorWithLight:[UIColor l_colorWithString:@"#DBDBDD"] dark:[UIColor l_colorWithString:@"#404040"]];
    return color;
}
@end
@implementation UIColor (LUIAlertView)
+ (UIColor *)l_alertBackgroundColor {
    UIColor *color = [UIColor l_colorWithLight:[UIColor l_colorWithString:@"#EFEFEF"] dark:[UIColor l_colorWithString:@"#212121"]];
    return color;
}
+ (UIColor *)l_defaultActionStyleColor {
    UIColor *color = UIColor.systemBlueColor;
    return color;
}
+ (UIColor *)l_destructiveActionStyleColor {
    UIColor *color = UIColor.systemRedColor;
    return color;
}
+ (UIColor *)l_cancelStyleActionColor {
    UIColor *color = UIColor.systemBlueColor;
    return color;
}
+ (UIColor *)l_disableActionColor {
    UIColor *color = UIColor.systemGrayColor;
    return color;
}
+ (UIColor *)l_actionCellSelectedColor {
    return [UIColor l_colorWithLight:[UIColor l_colorWithString:@"#DBDBDE"] dark:[UIColor l_colorWithString:@"#3E3E3E"]];
}

@end
