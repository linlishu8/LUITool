//
//  UIKit+LUIThemeElement.h
//  LUITool
//
//  Created by 六月 on 2023/9/2.
//

#import <UIKit/UIKit.h>
#import "LUIThemeElementProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface UIColor (LUIThemeElement)
/// 返回主题中心中的元素
/// @param name 主题中元素对应的key值
+ (id<LUIThemeElementProtocol>)ltheme_colorNamed:(NSString *)name;
@end

@interface UIImage (LUIThemeElement)
/// 返回主题中心中的元素
/// @param name 主题中元素对应的key值
+ (id<LUIThemeElementProtocol>)ltheme_imageNamed:(NSString *)name;
@end

@interface NSString (LUIThemeElement)
/// 返回主题中心中的元素
/// @param name 主题中元素对应的key值
+ (id<LUIThemeElementProtocol>)ltheme_stringNamed:(NSString *)name;
@end

@interface UIFont (LUIThemeElement)
/// 返回主题中心中的元素
/// @param name 主题中元素对应的key值
+ (id<LUIThemeElementProtocol>)ltheme_fontNamed:(NSString *)name;
@end

id<LUIThemeElementProtocol> ltheme_NSIntegerWithName(NSString * _Nonnull name);
id<LUIThemeElementProtocol> ltheme_CGFloatWithName(NSString * _Nonnull name);
id<LUIThemeElementProtocol> ltheme_UIEdgeInsetsWithName(NSString * _Nonnull name);
id<LUIThemeElementProtocol> ltheme_CGSizeWithName(NSString * _Nonnull name);
NS_ASSUME_NONNULL_END
