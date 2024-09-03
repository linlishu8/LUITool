//
//  UIKit+LUIThemeElement.m
//  LUITool
//
//  Created by 六月 on 2023/9/2.
//

#import "UIKit+LUIThemeElement.h"
#import "LUIThemeCenterElement.h"


@implementation UIColor (LUIThemeElement)
+ (id<LUIThemeElementProtocol>)ltheme_colorNamed:(NSString *)name{
    return [LUIThemeCenterElement themeElementForKey:name];
}
@end

@implementation UIImage (LUIThemeElement)
+ (id<LUIThemeElementProtocol>)ltheme_imageNamed:(NSString *)name{
    return [LUIThemeCenterElement themeElementForKey:name];
}
@end

@implementation NSString (LUIThemeElement)
+ (id<LUIThemeElementProtocol>)ltheme_stringNamed:(NSString *)name{
    return [LUIThemeCenterElement themeElementForKey:name];
}
@end

@implementation UIFont (LUIThemeElement)
+ (id<LUIThemeElementProtocol>)ltheme_fontNamed:(NSString *)name{
    return [LUIThemeCenterElement themeElementForKey:name];
}
@end

#import "LUIThemeCenterElement.h"
id<LUIThemeElementProtocol> ltheme_NSIntegerWithName(NSString * _Nonnull name){
    return [LUIThemeCenterElement themeElementForKey:name];
}
id<LUIThemeElementProtocol> ltheme_CGFloatWithName(NSString * _Nonnull name){
    return [LUIThemeCenterElement themeElementForKey:name];
}
id<LUIThemeElementProtocol> ltheme_UIEdgeInsetsWithName(NSString * _Nonnull name){
    return [LUIThemeCenterElement themeElementForKey:name];
}
id<LUIThemeElementProtocol> ltheme_CGSizeWithName(NSString * _Nonnull name){
    return [LUIThemeCenterElement themeElementForKey:name];
}
