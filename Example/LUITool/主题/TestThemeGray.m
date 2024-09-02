//
//  TestThemeGray.m
//  LUITool_Example
//
//  Created by 六月 on 2024/9/2.
//  Copyright © 2024 Your Name. All rights reserved.
//

#import "TestThemeGray.h"

@implementation TestThemeGray

- (id)init{
    if (self = [super init]) {
        self.elements = @{
            @"label.text":@"label_vip",
            @"button.text":@"button_vip",
            @"button.text.local":NSLocalizedString(@"button.text", nil),
            @"button.text.highlight":@"button_highlight_vip",
        };
    }
    return self;
}

- (BOOL)dark {
    return NO;
}

- (NSString *)fontColorString {
    return @"#f00";
}

@end
