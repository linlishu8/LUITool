//
//  LUIThemeCenterElement.m
//  LUITool
//  定位到全局主题中心的当前主题，根据指定的key，获取主题元素
//  Created by 六月 on 2023/9/2.
//

#import "LUIThemeCenterElement.h"
#import "LUIThemeCenter.h"

@implementation LUIThemeCenterElement

+ (instancetype)themeElementForKey:(NSString *)key {
    LUIThemeCenterElement *el = [[self alloc] init];
    el.key = key;
    return el;
}
- (id<NSObject>)themeElement {
    id value = [[LUIThemeCenter sharedInstance].currentTheme getElementValueWithKey:self.key];
    if(!value){
        value = [[LUIThemeCenter sharedInstance].defaultTheme getElementValueWithKey:self.key];
    }
    return value;
}

@end
