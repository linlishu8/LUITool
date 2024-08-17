//
//  NSObject+LUITheme.m
//  LUITool
//
//  Created by 六月 on 2021/8/8.
//

#import "NSObject+LUITheme.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

NSString *const kLUIThemeUpdateNotification=@"kLUIThemeUpdateNotification";
#define __lthemePickersProperty__ "__lthemePickersProperty__"
@implementation NSObject (LUITheme)

- (NSMutableDictionary<NSString *, id<LUIThemePickerProtocol>> *)__lthemePickers {
    NSMutableDictionary<NSString *, id<LUIThemePickerProtocol>> *allPickers = objc_getAssociatedObject(self, __lthemePickersProperty__);
    if (!allPickers) {
        allPickers = [[NSMutableDictionary alloc] init];
    }
    return allPickers;
}
- (NSDictionary<NSString *, id<LUIThemePickerProtocol>> *)lthemePickers {
    NSDictionary<NSString *, id<LUIThemePickerProtocol>> *allPickers = objc_getAssociatedObject(self, __lthemePickersProperty__);
    return allPickers;
}
- (void)setLthemePickers:(NSDictionary<NSString *, id<LUIThemePickerProtocol>> *)lthemePickers {
    objc_setAssociatedObject(self, __lthemePickersProperty__, lthemePickers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLUIThemeUpdateNotification object:nil];
    if (lthemePickers.count != 0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(__LUITheme_refreshTheme) name:kLUIThemeUpdateNotification object:nil];
    }
}
- (void)__LUITheme_refreshTheme {
    NSDictionary<NSString *,id<LUIThemePickerProtocol>> *allPickers = [[self lthemePickers] copy];
    [UIView animateWithDuration:0.25 animations:^{
        for (id<LUIThemePickerProtocol> picker in [allPickers allValues]) {
            [picker applyThemeTo:self];
        }
    }];
}
- (void)ltheme_setPicker:(nullable id<LUIThemePickerProtocol>)picker {
    NSMutableDictionary<NSString *,id<LUIThemePickerProtocol>> *allPickers = [self __lthemePickers];
    allPickers[picker.pickerKey] = picker;
    self.lthemePickers = allPickers;
    [picker applyThemeTo:self];
}
- (void)ltheme_removePickerForKey:(NSString *)key {
    NSMutableDictionary<NSString *,id<LUIThemePickerProtocol>> *allPickers = [self __lthemePickers];
    if (allPickers.count!=0) {
        [allPickers removeObjectForKey:key];
        self.lthemePickers = allPickers;
    }
}
- (nullable id<LUIThemePickerProtocol>)ltheme_getPickerForKey:(NSString *)key {
    NSMutableDictionary<NSString *, id<LUIThemePickerProtocol>> *allPickers = [self __lthemePickers];
    return allPickers[key];
}

- (id)ltheme_performSelector:(SEL)aSelector {
    id result = nil;
    NSMethodSignature *sig = [self methodSignatureForSelector:aSelector];
    const char *methodReturnType = sig.methodReturnType;
    NSInvocation *invo = [NSInvocation invocationWithMethodSignature:sig];
    invo.target = self;
    invo.selector = aSelector;
    /*
     c ： char
     i ： int
     s ： short
     l ： long 在64位程序中，l为32位。
     q ： long long
     C ： unsigned char
     I ： unsigned int
     S ： unsigned short
     L ： unsigned long
     Q ： unsigned long long
     f ： float
     d ： double
     B ： C++标准的bool或者C99标准的_Bool
     v ： void
     * ： 字符串（char *）
     @ ： 对象（无论是静态指定的还是通过id引用的）
     # ： 类（Class）
     : ： 方法选标（SEL）
     [array type] ： 数组
     {name=type...} ： 结构体
     (name=type...) ： 联合体
     bnum ： num个bit的位域
     ^type ： type类型的指针
     ? ： 未知类型（其它时候，一般用来指函数指针）
     */
    if (strcmp(methodReturnType, @encode(void)) == 0) {
        [invo invoke];
        result = nil;
    }else if (strcmp(methodReturnType, @encode(char)) == 0) {
        [invo invoke];
        char v;
        [invo getReturnValue:&v];
        result = @(v);
    }else if (strcmp(methodReturnType, @encode(int)) == 0) {
        [invo invoke];
        int v;
        [invo getReturnValue:&v];
        result = @(v);
    }else if (strcmp(methodReturnType, @encode(short)) == 0) {
        [invo invoke];
        short v;
        [invo getReturnValue:&v];
        result = @(v);
    }else if (strcmp(methodReturnType, @encode(long)) == 0) {
        [invo invoke];
        long v;
        [invo getReturnValue:&v];
        result = @(v);
    }else if (strcmp(methodReturnType, @encode(long long)) == 0) {
        [invo invoke];
        long long v;
        [invo getReturnValue:&v];
        result = @(v);
    }else if (strcmp(methodReturnType, @encode(unsigned char)) == 0) {
        [invo invoke];
        unsigned char v;
        [invo getReturnValue:&v];
        result = @(v);
    }else if (strcmp(methodReturnType, @encode(unsigned int)) == 0) {
        [invo invoke];
        unsigned int v;
        [invo getReturnValue:&v];
        result = @(v);
    }else if (strcmp(methodReturnType, @encode(unsigned short)) == 0) {
        [invo invoke];
        unsigned short v;
        [invo getReturnValue:&v];
        result = @(v);
    }else if (strcmp(methodReturnType, @encode(unsigned long)) == 0) {
        [invo invoke];
        unsigned long v;
        [invo getReturnValue:&v];
        result = @(v);
    }else if (strcmp(methodReturnType, @encode(unsigned long long)) == 0) {
        [invo invoke];
        unsigned long long v;
        [invo getReturnValue:&v];
        result = @(v);
    }else if (strcmp(methodReturnType, @encode(float)) == 0) {
        [invo invoke];
        float v;
        [invo getReturnValue:&v];
        result = @(v);
    }else if (strcmp(methodReturnType, @encode(double)) == 0) {
        [invo invoke];
        double v;
        [invo getReturnValue:&v];
        result = @(v);
    }else if (strcmp(methodReturnType, @encode(BOOL)) == 0) {
        [invo invoke];
        BOOL v;
        [invo getReturnValue:&v];
        result = @(v);
    }else if (strcmp(methodReturnType, @encode(char *)) == 0) {
        [invo invoke];
        char *v;
        [invo getReturnValue:&v];
        result = @(v);
    }else if (*methodReturnType  ==  '{') {
        //结构体
        [invo invoke];
        void * v;
        [invo getReturnValue:&v];
        result = [NSValue value:&v withObjCType:methodReturnType];
    } else {//调用原来的performSelector:，返回对象
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        result = [self performSelector:aSelector];
        #pragma clang diagnostic pop
    }
    return result;
}
@end
