//
//  LUIKeyboardView.h
//  LUITool
//
//  Created by 六月 on 2024/8/18.
//

#import <UIKit/UIKit.h>
#import "LUIKeyboardButtonModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LUIKeyboardView : UIView

- (instancetype)initWithKeyboardButtons:(NSArray <NSArray <LUIKeyboardButtonModel *> *> *)keyboardButtons;

@end

NS_ASSUME_NONNULL_END
