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
