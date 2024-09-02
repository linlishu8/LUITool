//
//  UIKit+LUITheme.m
//  LUITool
//
//  Created by 六月 on 2023/9/2.
//

#import "UIKit+LUITheme.h"
#import "NSObject+LUITheme.h"
#import "NSString+LUITheme.h"
#import "LUIThemePicker.h"
#import "LUIThemeStatePicker.h"

@implementation UIView (LUITheme)
ltheme_define_property(alpha, LUIThemeCGFloatPicker)
ltheme_define_property(backgroundColor, LUIThemeUIColorPicker)
ltheme_define_property(tintColor, LUIThemeUIColorPicker)
@end

@implementation UILabel (LUITheme)
ltheme_define_property(text, LUIThemeIdPicker)
ltheme_define_property(font, LUIThemeIdPicker)
ltheme_define_property(textColor, LUIThemeUIColorPicker)
ltheme_define_property(highlightedTextColor, LUIThemeUIColorPicker)
ltheme_define_property(shadowColor, LUIThemeUIColorPicker)
@end

@implementation UIImageView (LUITheme)
ltheme_define_property(image, LUIThemeUIImagePicker)
@end

@implementation CALayer (LUITheme)
ltheme_define_property(backgroundColor,LUIThemeCGColorRefPicker)
ltheme_define_property(borderWidth,LUIThemeCGFloatPicker)
ltheme_define_property(borderColor,LUIThemeCGColorRefPicker)
ltheme_define_property(shadowColor,LUIThemeCGColorRefPicker)
ltheme_define_property(strokeColor,LUIThemeCGColorRefPicker)
@end

@implementation UIBarButtonItem (LUITheme)
ltheme_define_property(tintColor, LUIThemeUIColorPicker)
@end

@implementation UINavigationBar (LUITheme_Color)
- (void)setL_titleTextColor:(UIColor *)titleTextColor {
    NSMutableDictionary *attr = [[NSMutableDictionary alloc] init];
    [attr addEntriesFromDictionary:self.titleTextAttributes];
    attr[NSForegroundColorAttributeName] = titleTextColor;
    self.titleTextAttributes = attr;
}
- (UIColor *)l_titleTextColor {
    NSDictionary *attr = self.titleTextAttributes;
    UIColor *color = attr[NSForegroundColorAttributeName];
    return color;
}
- (void)setL_titleTextFont:(UIFont *)titleTextFont {
    NSMutableDictionary *attr = [[NSMutableDictionary alloc] init];
    [attr addEntriesFromDictionary:self.titleTextAttributes];
    attr[NSFontAttributeName] = titleTextFont;
    self.titleTextAttributes = attr;
}
- (UIFont *)l_titleTextFont {
    NSDictionary *attr = self.titleTextAttributes;
    UIFont *font = attr[NSFontAttributeName];
    return font;
}
- (void)l_setBackgroundColorOfBar:(UIColor *)backgroundColor{
    CGRect rect = CGRectZero;
    UIColor *color = backgroundColor;
    rect.size = CGSizeMake(1, 1);
    CGFloat scale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(rect.size,NO,scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, color.CGColor);
    CGContextFillRect(ctx, rect);
    CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);
    UIGraphicsEndImageContext();
    [self setBackgroundImage:img forBarMetrics:UIBarMetricsDefault];
}
@end

@implementation UINavigationBar (LUITheme)
ltheme_define_property(barStyle, LUIThemeNSIntegerPicker)
ltheme_define_property(barTintColor, LUIThemeUIColorPicker)
ltheme_define_property(titleTextAttributes, LUIThemeIdPicker)
ltheme_define_property(largeTitleTextAttributes, LUIThemeIdPicker)

- (id<LUIThemeElementProtocol>)ltheme_titleTextColor{
    LUIThemeUIColorPicker *picker = [self ltheme_getPickerForKey:[LUIThemeUIColorPicker pickerKeyForObjSelector:@selector(setL_titleTextColor:)]];
    return picker.element;
}
- (void)setLtheme_titleTextColor:(id<LUIThemeElementProtocol>)value{
    [self ltheme_setPicker:[LUIThemeUIColorPicker pickerForObjSelector:@selector(setL_titleTextColor:) element:value]];
}

- (id<LUIThemeElementProtocol>)ltheme_titleTextFont{
    LUIThemeIdPicker *picker = [self ltheme_getPickerForKey:[LUIThemeIdPicker pickerKeyForObjSelector:@selector(setL_titleTextFont:)]];
    return picker.element;
}
- (void)setLtheme_titleTextFont:(id<LUIThemeElementProtocol>)value{
    [self ltheme_setPicker:[LUIThemeIdPicker pickerForObjSelector:@selector(setL_titleTextFont:) element:value]];
}

- (void)ltheme_setBackgroundColorOfBar:(id<LUIThemeElementProtocol>)value{
    [self ltheme_setPicker:[LUIThemeUIColorPicker pickerForObjSelector:@selector(l_setBackgroundColorOfBar:) element:value]];
}
@end

@implementation UITabBar (LUITheme)
ltheme_define_property(barStyle, LUIThemeNSIntegerPicker)
ltheme_define_property(barTintColor, LUIThemeUIColorPicker)
@end

@implementation UITableView (LUITheme)
ltheme_define_property(separatorColor, LUIThemeUIColorPicker)
@end

@implementation UITextField (LUITheme)
ltheme_define_property(font, LUIThemeIdPicker)
ltheme_define_property(keyboardAppearance, LUIThemeNSIntegerPicker)
ltheme_define_property(textColor, LUIThemeUIColorPicker)
@end

@implementation UITextView (LUITheme)
ltheme_define_property(font, LUIThemeIdPicker)
ltheme_define_property(keyboardAppearance, LUIThemeNSIntegerPicker)
ltheme_define_property(textColor, LUIThemeUIColorPicker)
@end

@implementation UISearchBar (LUITheme)
//#if os(iOS)
ltheme_define_property(barStyle, LUIThemeNSIntegerPicker)
//#endif
ltheme_define_property(keyboardAppearance, LUIThemeNSIntegerPicker)
ltheme_define_property(barTintColor, LUIThemeUIColorPicker)
@end

@implementation UIProgressView (LUITheme)
ltheme_define_property(progressTintColor, LUIThemeUIColorPicker)
ltheme_define_property(trackTintColor, LUIThemeUIColorPicker)
@end

@implementation UIPageControl (LUITheme)
ltheme_define_property(pageIndicatorTintColor, LUIThemeUIColorPicker)
ltheme_define_property(currentPageIndicatorTintColor, LUIThemeUIColorPicker)
@end

@implementation UIActivityIndicatorView (LUITheme)
ltheme_define_property(activityIndicatorViewStyle, LUIThemeNSIntegerPicker)
@end

@implementation UIToolbar (LUITheme)
ltheme_define_property(barStyle, LUIThemeNSIntegerPicker)
ltheme_define_property(barTintColor, LUIThemeUIColorPicker)
@end

@implementation UISwitch (LUITheme)
ltheme_define_property(onTintColor, LUIThemeUIColorPicker)
ltheme_define_property(thumbTintColor, LUIThemeUIColorPicker)
@end

@implementation UISlider (LUITheme)
ltheme_define_property(thumbTintColor, LUIThemeUIColorPicker)
ltheme_define_property(minimumTrackTintColor, LUIThemeUIColorPicker)
ltheme_define_property(maximumTrackTintColor, LUIThemeUIColorPicker)
@end

@implementation UIPopoverPresentationController (LUITheme)
ltheme_define_property(backgroundColor, LUIThemeUIColorPicker)
@end

@implementation UIButton (LUITheme)
- (id<LUIThemeElementProtocol>)ltheme_getImageForState:(UIControlState)state{
    LUIThemeUIImageStatePicker *picker = [self ltheme_getPickerForKey:[LUIThemeUIImageStatePicker pickerKeyForObjSelector:[NSString ltheme_setSelectorForStatedProperty:@"image"] state:state]];
    return picker.element;
}
- (void)ltheme_setImage:(id<LUIThemeElementProtocol>)value forState:(UIControlState)state{
    [self ltheme_setPicker:[LUIThemeUIImageStatePicker pickerForObjSelector:[NSString ltheme_setSelectorForStatedProperty:@"image"] element:value state:state]];
}
- (id<LUIThemeElementProtocol>)ltheme_backgroundImageForState:(UIControlState)state{
    LUIThemeUIImageStatePicker *picker = [self ltheme_getPickerForKey:[LUIThemeUIImageStatePicker pickerKeyForObjSelector:[NSString ltheme_setSelectorForStatedProperty:@"backgroundImage"] state:state]];
    return picker.element;
}
- (void)ltheme_setBackgroundImage:(id<LUIThemeElementProtocol>)value forState:(UIControlState)state{
    [self ltheme_setPicker:[LUIThemeUIImageStatePicker pickerForObjSelector:[NSString ltheme_setSelectorForStatedProperty:@"backgroundImage"] element:value state:state]];
}
- (id<LUIThemeElementProtocol>)ltheme_titleColorForState:(UIControlState)state{
    LUIThemeUIImageStatePicker *picker = [self ltheme_getPickerForKey:[LUIThemeUIImageStatePicker pickerKeyForObjSelector:[NSString ltheme_setSelectorForStatedProperty:@"titleColor"] state:state]];
    return picker.element;
}
- (void)ltheme_setTitleColor:(id<LUIThemeElementProtocol>)value forState:(UIControlState)state{
    [self ltheme_setPicker:[LUIThemeUIColorStatePicker pickerForObjSelector:[NSString ltheme_setSelectorForStatedProperty:@"titleColor"] element:value state:state]];
}

- (id<LUIThemeElementProtocol>)ltheme_titleForState:(UIControlState)state{
    LUIThemeUIImageStatePicker *picker = [self ltheme_getPickerForKey:[LUIThemeUIImageStatePicker pickerKeyForObjSelector:[NSString ltheme_setSelectorForStatedProperty:@"title"] state:state]];
    return picker.element;
}
- (void)ltheme_setTitle:(id<LUIThemeElementProtocol>)value forState:(UIControlState)state{
    [self ltheme_setPicker:[LUIThemeStatePicker pickerForObjSelector:[NSString ltheme_setSelectorForStatedProperty:@"title"] element:value state:state]];
}
@end

@implementation UITableViewCell (LUITheme)
ltheme_define_property(selectionStyle, LUIThemeNSIntegerPicker)
@end
