//
//  UIButton+TestTheme.m
//  LUITool_Example
//
//  Created by 六月 on 2024/9/2.
//  Copyright © 2024 Your Name. All rights reserved.
//

#import "UIButton+TestTheme.h"

@interface TestUIButtonPicker : LUIThemePickerBase
@property (nonatomic, strong) id<LUIThemeElementProtocol> normalImageElement;
@property (nonatomic, strong) id<LUIThemeElementProtocol> highlightImageElement;
@end
@implementation TestUIButtonPicker
- (void)applyThemeTo:(NSObject *)object {
    UIImage *normalImage = [self.class themeUIImageWithElement:self.normalImageElement];
    UIImage *highlightImage = [self.class themeUIImageWithElement:self.highlightImageElement];
    void (*mp)(id, SEL,UIImage *,UIImage *) = (void (*)(id, SEL,UIImage *,UIImage *))[object methodForSelector:self.objSelector];
    mp(object,self.objSelector,normalImage,highlightImage);
}
@end

@implementation UIButton (TestTheme)
- (void)test_setNormalImage:(UIImage *)normalImage highlightImage:(UIImage *)highlightImage {
    [self setImage:normalImage forState:UIControlStateNormal];
    [self setImage:highlightImage forState:UIControlStateHighlighted];
}
- (void)ltheme_test_setNormalImage:(id<LUIThemeElementProtocol>)normalImage highlightImage:(id<LUIThemeElementProtocol>)highlightImage{
    TestUIButtonPicker *picker = [[TestUIButtonPicker alloc] initWithObjSelector:@selector(test_setNormalImage:highlightImage:)];
    picker.normalImageElement = normalImage;
    picker.highlightImageElement = highlightImage;
    [self ltheme_setPicker:picker];
}
@end
