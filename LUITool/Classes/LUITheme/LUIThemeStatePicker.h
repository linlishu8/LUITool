//
//  LUIThemeStatePicker.h
//  LUITool
//  应用主题元素，更新控件在指定UIControlState下的属性
//  Created by 六月 on 2023/9/2.
//

#import "LUIThemePickerBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface LUIThemeStatePicker : LUIThemePickerBase

@property (nonatomic, strong, nullable) id<LUIThemeElementProtocol> element;//主题元素
@property (nonatomic, assign) UIControlState state;

+ (NSString *)pickerKeyForObjSelector:(SEL)objSelector state:(UIControlState)state;
+ (instancetype)pickerForObjSelector:(SEL)objSelector  element:(id<LUIThemeElementProtocol>)element state:(UIControlState)state;

@end

@interface LUIThemeUIImageStatePicker : LUIThemeStatePicker
@end
@interface LUIThemeUIColorStatePicker : LUIThemeStatePicker
@end

NS_ASSUME_NONNULL_END
