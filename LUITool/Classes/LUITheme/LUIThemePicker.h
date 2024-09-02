//
//  LUIThemePicker.h
//  LUITool
//
//  Created by 六月 on 2023/9/2.
//

#import "LUIThemePickerBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface LUIThemePicker : LUIThemePickerBase

@property (nonatomic, strong, nullable) id<LUIThemeElementProtocol> element;//主题元素

+ (NSString *)pickerKeyForObjSelector:(SEL)objSelector;

+ (instancetype)pickerForObjSelector:(SEL)objSelector element:(id<LUIThemeElementProtocol>)element;

@end

@interface LUIThemeIdPicker : LUIThemePicker
@end

@interface LUIThemeUIImagePicker : LUIThemePicker
@end

//用于NSInteger类型，基于NSInteger的枚举
@interface LUIThemeNSIntegerPicker : LUIThemePicker
@end

@interface LUIThemeCGFloatPicker : LUIThemePicker
@end

@interface LUIThemeCGSizePicker : LUIThemePicker
@end

@interface LUIThemeCGColorRefPicker : LUIThemePicker
@end

@interface LUIThemeUIColorPicker : LUIThemePicker
@end

NS_ASSUME_NONNULL_END
