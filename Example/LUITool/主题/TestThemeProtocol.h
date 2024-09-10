//
//  TestThemeProtocol.h
//  LUITool_Example
//
//  Created by 六月 on 2023/9/2.
//  Copyright © 2024 Your Name. All rights reserved.
//
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TestThemeProtocol <NSObject>
- (UIColor *)bgBarColor;//全局Bar背景色
- (UIColor *)bgColor;//全局背景色
- (UIColor *)fontColor;//全局前景色
- (NSString *)fontColorString;//全局前景色字符串
- (CGColorRef)fontColorRef;//全局前景色

- (CGFloat)borderWidth;//边距宽度
- (CGColorRef)borderColorRef;//边距颜色

- (UIColor *)labelColor;//label颜色
- (UIFont *)labelFont;//label字体

- (UITableViewCellSelectionStyle)selectionStyle;//cell选择效果

- (UIImage *)buttonIcon;//按钮图片
- (NSString *)buttonIconName;//按钮图片名称
- (NSString *)buttonHighlightIconName;//按钮高亮图片名称
- (NSString *)buttonSelectedIconName;//按钮选中图片名称

- (UIEdgeInsets)margin;
- (CGFloat)interitemSpacing;
@end

NS_ASSUME_NONNULL_END
