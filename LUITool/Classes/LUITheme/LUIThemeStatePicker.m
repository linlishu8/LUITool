//
//  LUIThemeStatePicker.m
//  LUITool
//
//  Created by 六月 on 2023/9/2.
//

#import "LUIThemeStatePicker.h"

@implementation LUIThemeStatePicker
+ (NSString *)pickerKeyForObjSelector:(SEL)objSelector state:(UIControlState)state {
    return [NSString stringWithFormat:@"%@%@",NSStringFromSelector(objSelector),@(state)];
}
- (NSString *)pickerKey {
    return [self.class pickerKeyForObjSelector:self.objSelector state:self.state];
}
- (void)applyThemeTo:(id)object {
    id themeValue = self.element.themeElement;
    id value = themeValue;
    void (*mp)(id, SEL,id,UIControlState) = (void (*)(id, SEL,id,UIControlState))[object methodForSelector:self.objSelector];
    mp(object, self.objSelector, value, self.state);
}
+ (instancetype)pickerForObjSelector:(SEL)objSelector element:(id<LUIThemeElementProtocol>)element state:(UIControlState)state {
    LUIThemeStatePicker *picker = [[self alloc] initWithObjSelector:objSelector];
    picker.element = element;
    picker.state = state;
    return picker;
}
@end

@implementation LUIThemeUIImageStatePicker
- (void)applyThemeTo:(id)object {
    UIImage *value = [self.class themeUIImageWithElement:self.element];
    void (*mp)(id, SEL,UIImage *,UIControlState) = (void (*)(id, SEL,UIImage *,UIControlState))[object methodForSelector:self.objSelector];
    mp(object, self.objSelector, value, self.state);
}
@end

#import "UIColor+LUITheme.h"
@implementation LUIThemeUIColorStatePicker
- (void)applyThemeTo:(id)object {
    UIColor *value = [self.class themeUIColorWithElement:self.element];
    void (*mp)(id, SEL, UIColor *, UIControlState) = (void (*)(id, SEL, UIColor *, UIControlState))[object methodForSelector:self.objSelector];
    mp(object, self.objSelector, value, self.state);
}
@end
