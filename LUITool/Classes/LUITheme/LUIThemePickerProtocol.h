//
//  LUIThemePickerProtocol.h
//  LUITool
//  将控件属性、与主题元素绑定在一起，提供使用主题元素更新控件属性的方法
//  Created by 六月 on 2021/8/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LUIThemePickerProtocol <NSObject>

@property (nonatomic, assign) SEL objSelector;//要控件对象的属性选择器
@property (nonatomic, readonly) NSString *pickerKey;//唯一的key值，用于保存在控件对象的动态属性中

/// 应用主题中的元素到指定控件中
/// @param object 控件对象
- (void)applyThemeTo:(NSObject *)object;

@end

NS_ASSUME_NONNULL_END
