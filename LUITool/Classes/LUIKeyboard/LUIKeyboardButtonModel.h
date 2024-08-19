//
//  LUIKeyboardButtonModel.h
//  LUITool
//
//  Created by 六月 on 2024/8/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, LUIKeyboardButtonType) {
    LUIKeyboardButtonTypeCharacter,   // 字母、符号、数字输入
    LUIKeyboardButtonTypeShift,       // 切换大小写
    LUIKeyboardButtonTypeDelete,      // 删除
    LUIKeyboardButtonTypeChangeType   // 切换键盘类型
};

@interface LUIKeyboardButtonModel : NSObject

@property (nonatomic, copy) NSString *title;             // 按钮标题
@property (nonatomic, strong) UIImage *backgroundImage;  // 按钮背景图片
@property (nonatomic, assign) BOOL showTouchEffect;      // 是否显示点击效果
@property (nonatomic, assign) LUIKeyboardButtonType type;   // 按钮类型
@property (nonatomic, assign) CGSize size;               // 按钮大小
@property (nonatomic, assign) CGFloat verticalSpacing;   // 按钮上下间隔
@property (nonatomic, strong) NSString *switchToKeyboardType; // 切换的键盘类型

@end

NS_ASSUME_NONNULL_END
