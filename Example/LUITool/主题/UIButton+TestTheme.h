//
//  UIButton+TestTheme.h
//  LUITool_Example
//
//  Created by 六月 on 2023/9/2.
//  Copyright © 2024 Your Name. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (TestTheme)
- (void)test_setNormalImage:(UIImage *)normalImage highlightImage:(UIImage *)highlightImage;
- (void)ltheme_test_setNormalImage:(id<LUIThemeElementProtocol>)normalImage highlightImage:(id<LUIThemeElementProtocol>)highlightImage;
@end

NS_ASSUME_NONNULL_END
