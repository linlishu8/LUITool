//
//  LUIThemePicker.m
//  LUITool
//
//  Created by 六月 on 2023/9/2.
//

#import "LUIThemePicker.h"

@implementation LUIThemePicker

+ (NSString *)pickerKeyForObjSelector:(SEL)objSelector{
    return NSStringFromSelector(objSelector);
}
- (NSString *)pickerKey{
    return [self.class pickerKeyForObjSelector:self.objSelector];
}
- (void)applyThemeTo:(NSObject *)object{
    id value = self.element.themeElement;
    void (*mp)(id, SEL,id) = (void (*)(id, SEL,id))[object methodForSelector:self.objSelector];
    mp(object,self.objSelector,value);
}
+ (instancetype)pickerForObjSelector:(SEL)objSelector element:(id<LUIThemeElementProtocol>)element {
    LUIThemePicker *picker = [[self alloc] initWithObjSelector:objSelector];
    picker.element = element;
    return picker;
}

@end

@implementation LUIThemeIdPicker
@end

@implementation LUIThemeUIImagePicker
- (void)applyThemeTo:(NSObject *)object{
    UIImage *value = [self.class themeUIImageWithElement:self.element];
    void (*mp)(id, SEL,UIImage *) = (void (*)(id, SEL,UIImage *))[object methodForSelector:self.objSelector];
    mp(object,self.objSelector,value);
}
@end

@implementation LUIThemeNSIntegerPicker
- (void)applyThemeTo:(NSObject *)object{
    NSInteger value = [self.class themeNSIntegerWithElement:self.element];
    void (*mp)(id, SEL,NSInteger) = (void (*)(id, SEL,NSInteger))[object methodForSelector:self.objSelector];
    mp(object,self.objSelector,value);
}
@end

@implementation LUIThemeCGFloatPicker
- (void)applyThemeTo:(NSObject *)object{
    CGFloat value = [self.class themeCGFloatWithElement:self.element];
    void (*mp)(id, SEL,CGFloat) = (void (*)(id, SEL,CGFloat))[object methodForSelector:self.objSelector];
    mp(object,self.objSelector,value);
}
@end

@implementation LUIThemeCGSizePicker
- (void)applyThemeTo:(NSObject *)object{
    CGSize value = [self.class themeCGSizeWithElement:self.element];
    void (*mp)(id, SEL,CGSize) = (void (*)(id, SEL,CGSize))[object methodForSelector:self.objSelector];
    mp(object,self.objSelector,value);
}
@end

#import "UIColor+LUITheme.h"
@implementation LUIThemeCGColorRefPicker
- (void)applyThemeTo:(NSObject *)object{
    CGColorRef value = [self.class themeCGColorRefWithElement:self.element];
    void (*mp)(id, SEL,CGColorRef) = (void (*)(id, SEL,CGColorRef))[object methodForSelector:self.objSelector];
    mp(object,self.objSelector,value);
}
@end

#import "UIColor+LUITheme.h"
@implementation LUIThemeUIColorPicker
- (void)applyThemeTo:(NSObject *)object{
    UIColor *value = [self.class themeUIColorWithElement:self.element];
    void (*mp)(id, SEL,UIColor *) = (void (*)(id, SEL,UIColor *))[object methodForSelector:self.objSelector];
    mp(object,self.objSelector,value);
}
@end
