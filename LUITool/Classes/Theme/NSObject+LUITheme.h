//
//  NSObject+LUITheme.h
//  LUITool
//
//  Created by 六月 on 2024/8/8.
//

#import <Foundation/Foundation.h>
#import "LUIThemePickerProtocol.h"
extern NSString * _Nullable const kLUIThemeUpdateNotification;
NS_ASSUME_NONNULL_BEGIN

@interface NSObject (LUITheme)

- (void)ltheme_setPicker:(nullable id<LUIThemePickerProtocol>)picker;//设置picker时，会应用一次主题
- (void)ltheme_removePickerForKey:(NSString *)key;
- (nullable id<LUIThemePickerProtocol>)ltheme_getPickerForKey:(NSString *)key;

/// 原来的performSelector:方法，如果返回基本类型(比如 void，int，结构体，枚举)，可能会闪退。因此这里对基本类型进行处理，返回nil或者NSNumber、NSValue。非基本类型，返回原来的performSelector:值
/// @param aSelector 选择器
- (nullable id)ltheme_performSelector:(SEL)aSelector;

@end

NS_ASSUME_NONNULL_END
