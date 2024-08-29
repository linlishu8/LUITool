//
//  UITraitCollection+LUI.m
//  LUITool
//
//  Created by 六月 on 2023/8/11.
//

#import "UITraitCollection+LUI.h"
#import <objc/runtime.h>

NSString *const kLUIUserInterfaceStyleChangeNotification=@"kLUIUserInterfaceStyleChangeNotification";

@implementation UITraitCollection (LUI)

+ (BOOL)l_isDarkStyle {
    BOOL isDark = NO;
    if (@available(iOS 12.0, *)) {
        isDark = ([UIScreen mainScreen].traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark);
    }
    return isDark;
}
@end

@implementation UIScreen(LUITheme)
+ (void)load {
    Method originMethod = class_getInstanceMethod([UIScreen class], @selector(traitCollectionDidChange:));
    Method swizzledMethod = class_getInstanceMethod([UIScreen class], @selector(luitheme_traitCollectionDidChange:));
    method_exchangeImplementations(originMethod, swizzledMethod);
}
- (void)luitheme_traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection API_AVAILABLE(ios(8.0)) {
    //调用原始的traitCollectionDidChange:方法
    [self luitheme_traitCollectionDidChange:previousTraitCollection];
    if (@available(iOS 12.0, *)) {
        if (self.traitCollection.userInterfaceStyle != previousTraitCollection.userInterfaceStyle) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kLUIUserInterfaceStyleChangeNotification object:nil];
        }
    } else {
    }
}

@end
