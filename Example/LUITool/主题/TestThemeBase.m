//
//  TestThemeBase.m
//  LUITool_Example
//
//  Created by 六月 on 2023/9/2.
//  Copyright © 2024 Your Name. All rights reserved.
//

#import "TestThemeBase.h"

@implementation TestThemeBase

- (id)init {
    if (self = [super init]) {
    }
    return self;
}
- (UIColor *)bgBarColor {
    return self.dark ? [UIColor blackColor] : [UIColor whiteColor];
}
- (UIColor *)bgColor {
    return self.dark ? [UIColor blackColor] : [UIColor whiteColor];
}
- (NSString *)fontColorString {
    return self.dark ? @"#ffff" : @"#000";
}
- (UIColor *)fontColor {
    return [UIColor ltheme_colorWithString:self.fontColorString];
}
- (CGColorRef)fontColorRef {
    return self.fontColor.CGColor;
}
- (CGFloat)borderWidth {
    return 1.0;
}
- (nonnull CGColorRef)borderColorRef {
    return self.fontColor.CGColor;
}
- (UIColor *)labelColor {
    return self.fontColor;
}
- (UIFont *)labelFont {
    return [UIFont systemFontOfSize:12];
}
- (UITableViewCellSelectionStyle)selectionStyle {
    return self.dark ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleGray;
}
- (UIImage *)buttonIcon {
    return [UIImage imageNamed:self.buttonIconName];
}
- (NSString *)buttonIconName {
    return @"app-icon-2.png";
}
- (NSString *)buttonHighlightIconName {
    return @"app-icon-3.png";
}
- (NSString *)buttonSelectedIconName {
    return @"app-icon-4.png";
}
- (UIEdgeInsets)margin {
    return UIEdgeInsetsMake(10, 10, 10, 10);
}
- (CGFloat)interitemSpacing {
    return 10;
}

@end
