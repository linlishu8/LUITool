//
//  LUIThemeCenter+Test.m
//  LUITool_Example
//
//  Created by 六月 on 2021/8/10.
//  Copyright © 2024 Your Name. All rights reserved.
//

#import "LUIThemeCenter+Test.h"
#import "TestThemeNormal.h"
#import "TestThemeVip.h"
#import "TestThemeGray.h"

@implementation LUIThemeCenter (Test)

+ (void)test_setupThemes{
    [LUIThemeCenter sharedInstance].themes = @[
        [TestThemeNormal new],
        [TestThemeVip new],
        [TestThemeGray new],
    ];
    
    [LUIThemeCenter sharedInstance].defaultThemeIndex = 0;
    [LUIThemeCenter sharedInstance].currentThemeIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"test_current_theme_index"];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kLUIThemeUpdateNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [LUIThemeCenter test_saveTheme];
    }];
}
+ (void)test_saveTheme {
    [[NSUserDefaults standardUserDefaults] setInteger:[LUIThemeCenter sharedInstance].currentThemeIndex forKey:@"test_current_theme_index"];
}

@end
