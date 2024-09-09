//
//  UIKit+LUITheme.h
//  LUITool
//
//  Created by 六月 on 2023/9/2.
//

#import <UIKit/UIKit.h>
#import "LUIThemeElementProtocol.h"

#define ltheme_define_property(name,pickerClass)\
- (id<LUIThemeElementProtocol>)ltheme_##name{\
    pickerClass *picker = (pickerClass *)[self ltheme_getPickerForKey:[pickerClass pickerKeyForObjSelector:[NSString ltheme_setSelectorForProperty:@#name]]];\
    return picker.element;\
}\
- (void)setLtheme_##name:(id<LUIThemeElementProtocol>)value{\
    [self ltheme_setPicker:[pickerClass pickerForObjSelector:[NSString ltheme_setSelectorForProperty:@#name] element:value]];\
}

NS_ASSUME_NONNULL_BEGIN
@interface UIView (LUITheme)
@property (nonatomic, strong,nullable) id<LUIThemeElementProtocol> ltheme_alpha;
@property (nonatomic, strong,nullable) id<LUIThemeElementProtocol> ltheme_backgroundColor;
@property (nonatomic, strong,nullable) id<LUIThemeElementProtocol> ltheme_tintColor;
@end

@interface UILabel (LUITheme)
@property (nonatomic, strong,nullable) id<LUIThemeElementProtocol> ltheme_text;
@property (nonatomic, strong,nullable) id<LUIThemeElementProtocol> ltheme_font;
@property (nonatomic, strong,nullable) id<LUIThemeElementProtocol> ltheme_textColor;
@property (nonatomic, strong,nullable) id<LUIThemeElementProtocol> ltheme_highlightedTextColor;
@property (nonatomic, strong,nullable) id<LUIThemeElementProtocol> ltheme_shadowColor;
@end

@interface UIImageView (LUITheme)
@property (nonatomic, strong,nullable) id<LUIThemeElementProtocol> ltheme_image;
@end

@interface CALayer (LUITheme)
@property (nonatomic, strong,nullable) id<LUIThemeElementProtocol> ltheme_backgroundColor;
@property (nonatomic, strong,nullable) id<LUIThemeElementProtocol> ltheme_borderWidth;
@property (nonatomic, strong,nullable) id<LUIThemeElementProtocol> ltheme_borderColor;
@property (nonatomic, strong,nullable) id<LUIThemeElementProtocol> ltheme_shadowColor;
@property (nonatomic, strong,nullable) id<LUIThemeElementProtocol> ltheme_strokeColor;
@end

@interface UIBarButtonItem (LUITheme)
@property (nonatomic, strong,nullable) id<LUIThemeElementProtocol> ltheme_tintColor;
@end

@interface UINavigationBar (LUITheme_Color)
@property (nonatomic, strong,nullable) UIColor *l_titleTextColor;//标题颜色
@property (nonatomic, strong,nullable) UIFont *l_titleTextFont;//标题字体
/**
 *  设置导航条背景颜色
 *
 *  @param backgroundColor 背景颜色
 */
- (void)l_setBackgroundColorOfBar:(nullable UIColor *)backgroundColor;
@end

@interface UINavigationBar (LUITheme)
@property (nonatomic, strong,nullable) id<LUIThemeElementProtocol> ltheme_barStyle;
@property (nonatomic, strong,nullable) id<LUIThemeElementProtocol> ltheme_barTintColor;
@property (nonatomic, strong,nullable) id<LUIThemeElementProtocol> ltheme_titleTextAttributes;
@property (nonatomic, strong,nullable) id<LUIThemeElementProtocol> ltheme_largeTitleTextAttributes;

@property (nonatomic, strong,nullable) id<LUIThemeElementProtocol> ltheme_titleTextColor;
@property (nonatomic, strong,nullable) id<LUIThemeElementProtocol> ltheme_titleTextFont;
- (void)ltheme_setBackgroundColorOfBar:(id<LUIThemeElementProtocol>)value;
@end

@interface UITableView (LUITheme)
@property (nonatomic, strong,nullable) id<LUIThemeElementProtocol> ltheme_separatorColor;
@end

@interface UITabBar (LUITheme)
@property (nonatomic, strong,nullable) id<LUIThemeElementProtocol> ltheme_barStyle;
@property (nonatomic, strong,nullable) id<LUIThemeElementProtocol> ltheme_barTintColor;
@end

@interface UITextField (LUITheme)
@property (nonatomic, strong,nullable) id<LUIThemeElementProtocol> ltheme_font;
@property (nonatomic, strong,nullable) id<LUIThemeElementProtocol> ltheme_keyboardAppearance;
@property (nonatomic, strong,nullable) id<LUIThemeElementProtocol> ltheme_textColor;
@end

@interface UITextView (LUITheme)
@property (nonatomic, strong,nullable) id<LUIThemeElementProtocol> ltheme_font;
@property (nonatomic, strong,nullable) id<LUIThemeElementProtocol> ltheme_keyboardAppearance;
@property (nonatomic, strong,nullable) id<LUIThemeElementProtocol> ltheme_textColor;
@end

@interface UISearchBar (LUITheme)
//#if os(iOS)
@property (nonatomic, strong,nullable) id<LUIThemeElementProtocol> ltheme_barStyle;
//#endif
@property (nonatomic, strong,nullable) id<LUIThemeElementProtocol> ltheme_keyboardAppearance;
@property (nonatomic, strong,nullable) id<LUIThemeElementProtocol> ltheme_barTintColor;
@end

@interface UIProgressView (LUITheme)
@property (nonatomic, strong,nullable) id<LUIThemeElementProtocol> ltheme_progressTintColor;
@property (nonatomic, strong,nullable) id<LUIThemeElementProtocol> ltheme_trackTintColor;
@end

@interface UIPageControl (LUITheme)
@property (nonatomic, strong,nullable) id<LUIThemeElementProtocol> ltheme_pageIndicatorTintColor;
@property (nonatomic, strong,nullable) id<LUIThemeElementProtocol> ltheme_currentPageIndicatorTintColor;
@end

@interface UIActivityIndicatorView (LUITheme)
@property (nonatomic, strong,nullable) id<LUIThemeElementProtocol> ltheme_activityIndicatorViewStyle;
@end

@interface UIToolbar (LUITheme)
@property (nonatomic, strong,nullable) id<LUIThemeElementProtocol> ltheme_barStyle;
@property (nonatomic, strong,nullable) id<LUIThemeElementProtocol> ltheme_barTintColor;
@end

@interface UISwitch (LUITheme)
@property (nonatomic, strong,nullable) id<LUIThemeElementProtocol> ltheme_onTintColor;
@property (nonatomic, strong,nullable) id<LUIThemeElementProtocol> ltheme_thumbTintColor;
@end

@interface UISlider (LUITheme)
@property (nonatomic, strong,nullable) id<LUIThemeElementProtocol> ltheme_thumbTintColor;
@property (nonatomic, strong,nullable) id<LUIThemeElementProtocol> ltheme_minimumTrackTintColor;
@property (nonatomic, strong,nullable) id<LUIThemeElementProtocol> ltheme_maximumTrackTintColor;
@end

@interface UIPopoverPresentationController (LUITheme)
@property (nonatomic, strong,nullable) id<LUIThemeElementProtocol> ltheme_backgroundColor;
@end

@interface UIButton (LUITheme)
- (id<LUIThemeElementProtocol>)ltheme_getImageForState:(UIControlState)state;
- (void)ltheme_setImage:(id<LUIThemeElementProtocol>)value forState:(UIControlState)state;

- (id<LUIThemeElementProtocol>)ltheme_backgroundImageForState:(UIControlState)state;
- (void)ltheme_setBackgroundImage:(id<LUIThemeElementProtocol>)value forState:(UIControlState)state;

- (id<LUIThemeElementProtocol>)ltheme_titleColorForState:(UIControlState)state;
- (void)ltheme_setTitleColor:(id<LUIThemeElementProtocol>)value forState:(UIControlState)state;

- (id<LUIThemeElementProtocol>)ltheme_titleForState:(UIControlState)state;
- (void)ltheme_setTitle:(id<LUIThemeElementProtocol>)value forState:(UIControlState)state;
@end

@interface UITableViewCell (LUITheme)
@property (nonatomic, strong,nullable) id<LUIThemeElementProtocol> ltheme_selectionStyle;
@end

NS_ASSUME_NONNULL_END
