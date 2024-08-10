//
//  LUIThemeCenter.h
//  LUITool
//
//  Created by 六月 on 2024/8/8.
//
//  主题化的思路： 1.定义一个主题对象(LUITheme)，里面含有所有与主题相关图片、文本、字体、颜色、尺寸等主题元素，可以根据key值获取到指定的主题元素。
//  2.提供一个全局的主题中心（LUIThemeCenter），持有所有可用的主题对象列表，并可以设置当前主题、默认主题，并在主题发生变化时，发出主题变更通知。
//  3.定义获取主题元素的对象（LUIThemeElementProtocol协议），由它负责返回主题元素。这里不直接使用主题元素，是为了能够在主题变更时，该对象能够返回对应主题下的主题元素。提供一个从全局主题中心中，获取当前主题下，指定key的主题元素的类（LUIThemeCenterElement)。
//  4.定义一个将获取主题元素对象与控件属性绑定在一起的绑定器对象（LUIThemePickerProtocol协议），并提供获取主题元素内容，应用到指定控件属性的功能。
//  5.针对各种控件，提供设置指定属性对应的绑定器对象的方式。将直接设置属性，替换为设置属性绑定器。然后由该绑定器负责获取属性值，设置到属性上，并且提供在主题变更时，更新属性的支持。

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LUIThemeProtocol <NSObject>

/// 根据指定的key值，获取到主题元素对象。主题元素可以为UIImage，NSNumber，NSValue，UIColor，NSString等
/// @param key key
- (nullable id)getElementValueWithKey:(NSString *)key;

@end

@interface LUITheme : NSObject<LUIThemeProtocol>
/// 当key不存在elements时，会尝试调用key对应的方法，来获取元素对象
@property (nonatomic, strong, nullable) NSDictionary *elements;//key=>主题元素

@end

NS_ASSUME_NONNULL_END

NS_ASSUME_NONNULL_BEGIN

@interface LUIThemeCenter : NSObject

+ (nonnull instancetype)sharedInstance;

@property (nonatomic, strong) NSArray<id<LUIThemeProtocol>> *themes;
@property (nonatomic, strong) id<LUIThemeProtocol> currentTheme;
@property (nonatomic, strong) id<LUIThemeProtocol> defaultTheme;
@property (nonatomic, assign) NSUInteger currentThemeIndex;
@property (nonatomic, assign) NSUInteger defaultThemeIndex;

- (void)notifyThemeChange;

@end

NS_ASSUME_NONNULL_END
