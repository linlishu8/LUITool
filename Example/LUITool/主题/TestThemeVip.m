//
//  TestThemeVip.m
//  LUITool_Example
//
//  Created by 六月 on 2024/9/2.
//  Copyright © 2024 Your Name. All rights reserved.
//

#import "TestThemeVip.h"

@implementation TestThemeVip

- (id)init{
    if (self=[super init]) {
        self.elements = @{
            @"label.text":@"label_vip",
            @"button.text":@"button_vip",
            @"button.text.local":NSLocalizedString(@"button.text", nil),
            @"button.text.highlight":@"button_highlight_vip",
        };
    }
    return self;
}
- (NSString *)fontColorString {
    return [UITraitCollection l_isDarkStyle] ? @"#fbe2c8" : @"#f9cb9c";
}
- (CGFloat)borderWidth {
    return 5;
}
- (UIFont *)labelFont {
    return [UIFont systemFontOfSize:24];
}
- (UITableViewCellSelectionStyle)selectionStyle {
    return UITableViewCellSelectionStyleGray;
}
- (NSString *)buttonIconName {
    return @"app-icon-5.png";
}
- (NSString *)buttonHighlightIconName {
    return @"app-icon-6.png";
}
- (NSString *)buttonSelectedIconName {
    return @"app-icon-7.png";
}

@end
