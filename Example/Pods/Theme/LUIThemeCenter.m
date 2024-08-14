//
//  LUIThemeCenter.m
//  LUITool
//
//  Created by 六月 on 2021/8/8.
//

#import "LUIThemeCenter.h"
#import "NSObject+LUITheme.h"

@implementation LUITheme
- (nullable id)getElementValueWithKey:(NSString *)key{
    id value = self.elements[key];
    if(!value){
        SEL selector = NSSelectorFromString(key);
        if([self respondsToSelector:selector]){
            value = [self ltheme_performSelector:selector];
        }
    }
    return value;
}
@end

@implementation LUIThemeCenter
+ (id)sharedInstance {
    static LUIThemeCenter *__share__;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __share__ = [[LUIThemeCenter alloc] init];
    });
    return __share__;
}
- (void)notifyThemeChange {
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kLUIThemeUpdateNotification object:nil]];
}
- (void)setCurrentTheme:(id<LUIThemeProtocol>)currentTheme {
    if(_currentTheme!=currentTheme){
        _currentTheme = currentTheme;
        [self notifyThemeChange];
    }
}
- (void)setCurrentThemeIndex:(NSUInteger)currentIndex{
    if(currentIndex>=0 && currentIndex<self.themes.count){
        self.currentTheme = self.themes[currentIndex];
    }
}
- (NSUInteger)currentThemeIndex{
    return [self.themes indexOfObject:self.currentTheme];
}
- (void)setDefaultThemeIndex:(NSUInteger)defaultThemeIndex{
    if(defaultThemeIndex>=0 && defaultThemeIndex<self.themes.count){
        self.defaultTheme = self.themes[defaultThemeIndex];
    }
}
- (NSUInteger)defaultThemeIndex{
    return [self.themes indexOfObject:self.defaultTheme];
}
@end
