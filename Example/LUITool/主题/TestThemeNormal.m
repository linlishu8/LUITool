//
//  TestThemeNormal.m
//  LUITool_Example
//
//  Created by 六月 on 2023/9/2.
//  Copyright © 2024 Your Name. All rights reserved.
//

#import "TestThemeNormal.h"

@implementation TestThemeNormal

- (id)init{
    if (self = [super init]) {
        self.elements = @{
            @"label.text" : @"label_normal",
            @"button.text" : @"button_normal",
            @"button.text.local" : NSLocalizedString(@"button.text", nil),
            @"button.text.highlight" : @"button_highlight_normal",
        };
    }
    return self;
}

@end
