//
//  LUIThemePickerBase.m
//  LUITool
//
//  Created by 六月 on 2023/9/2.
//

#import "LUIThemePickerBase.h"

@implementation LUIThemePickerBase
- (instancetype)initWithObjSelector:(SEL)objSelector {
    if (self = [self init]) {
        self.objSelector = objSelector;
    }
    return self;
}
- (NSString *)pickerKey {
    return NSStringFromSelector(self.objSelector);
}
- (void)applyThemeTo:(NSObject *)object {
}
#ifdef DEBUG
- (void)dealloc{
    
}
#endif
@end

#import "UIColor+LUITheme.h"
@implementation LUIThemePickerBase (Element)
+ (nullable UIColor *)themeUIColorWithElement:(id<LUIThemeElementProtocol>)element {
    UIColor *value = nil;
    id themeElement = element.themeElement;
    if ([themeElement isKindOfClass:[UIColor class]]) {
        value = (UIColor *)themeElement;
    } else if ([themeElement isKindOfClass:[NSString class]]) {
        value = [UIColor ltheme_colorWithString:(NSString *)themeElement];
    }
    return value;
}
+ (nullable UIImage *)themeUIImageWithElement:(id<LUIThemeElementProtocol>)element {
    id themeValue = element.themeElement;
    UIImage *value = nil;
    if ([themeValue isKindOfClass:[UIImage class]]) {
        value = (UIImage *)themeValue;
    } else if ([themeValue isKindOfClass:[NSString class]]) {
        value = [UIImage imageNamed:(NSString *)themeValue];
    }
    return value;
}
+ (CGColorRef)themeCGColorRefWithElement:(id<LUIThemeElementProtocol>)element {
    CGColorRef value = NULL;
    id themeElement = element.themeElement;
    if ([themeElement isKindOfClass:[UIColor class]]) {
        value = [(UIColor *)themeElement CGColor];
    } else if ([themeElement isKindOfClass:[NSString class]]) {
        value = [UIColor ltheme_colorWithString:(NSString *)themeElement].CGColor;
    } else {
        value = (__bridge CGColorRef)(themeElement);
    }
    return value;
}
+ (NSInteger)themeNSIntegerWithElement:(id<LUIThemeElementProtocol>)element {
    id themeValue = element.themeElement;
    NSInteger value = 0;
    if ([themeValue isKindOfClass:[NSNumber class]]) {
        value = [(NSNumber *)themeValue integerValue];
    } else if ([themeValue isKindOfClass:[NSString class]]) {
        value = [(NSString *)themeValue integerValue];
    }
    return value;
}
+ (CGFloat)themeCGFloatWithElement:(id<LUIThemeElementProtocol>)element {
    id themeValue = element.themeElement;
    CGFloat value = 0;
    if ([themeValue isKindOfClass:[NSNumber class]]) {
        value = [(NSNumber *)themeValue floatValue];
    } else if ([themeValue isKindOfClass:[NSString class]]) {
        value = [(NSString *)themeValue floatValue];
    }
    return value;
}
+ (CGSize)themeCGSizeWithElement:(id<LUIThemeElementProtocol>)element {
    id themeValue = element.themeElement;
    CGSize value = CGSizeZero;
    if ([themeValue isKindOfClass:[NSValue class]]) {
        value = [(NSValue *)themeValue CGSizeValue];
    }
    return value;
}
@end
