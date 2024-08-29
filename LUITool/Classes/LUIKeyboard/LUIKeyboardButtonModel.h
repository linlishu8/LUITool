//
//  LUIKeyboardButtonModel.h
//  LUITool
//
//  Created by 六月 on 2024/8/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LUIBorderConfiguration : NSObject

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, strong) UIColor *color;

- (instancetype)initWithWidth:(CGFloat)width color:(UIColor *)color;

@end

@interface LUICornerRadiiConfiguration : NSObject

@property (nonatomic, assign) CGFloat topLeft;
@property (nonatomic, assign) CGFloat topRight;
@property (nonatomic, assign) CGFloat bottomLeft;
@property (nonatomic, assign) CGFloat bottomRight;

- (instancetype)initWithTopLeft:(CGFloat)topLeft topRight:(CGFloat)topRight bottomLeft:(CGFloat)bottomLeft bottomRight:(CGFloat)bottomRight;

@end

typedef NS_ENUM(NSInteger, LUIKeyboardButtonType) {
    LUIKeyboardButtonTypeCharacter,   // 字母、符号、数字输入
    LUIKeyboardButtonTypeShift,       // 切换大小写
    LUIKeyboardButtonTypeDelete,      // 删除
    LUIKeyboardButtonTypeChangeType,   // 切换键盘类型
    LUIKeyboardButtonTypeEmpty,        // 空白按钮
};

@interface LUIKeyboardButtonModel : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, assign) LUIKeyboardButtonType type;   // 按钮类型
@property (nonatomic, assign) CGFloat buttonWidth;          //按钮宽度
@property (nonatomic, assign) CGFloat buttonHeight;         //按钮高度
@property (nonatomic, assign) UIEdgeInsets marginInsets;  // 按钮上下左右间隔

@property (nonatomic, strong) LUIBorderConfiguration *topBorder;
@property (nonatomic, strong) LUIBorderConfiguration *leftBorder;
@property (nonatomic, strong) LUIBorderConfiguration *bottomBorder;
@property (nonatomic, strong) LUIBorderConfiguration *rightBorder;

@property (nonatomic, strong) LUICornerRadiiConfiguration *cornerRadii;

@property (nonatomic, copy) NSArray <NSArray <LUIKeyboardButtonModel *> *> *keyBoardButtons; // 切换的键盘按键

@end

NS_ASSUME_NONNULL_END
