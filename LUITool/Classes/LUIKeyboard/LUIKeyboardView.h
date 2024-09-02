//
//  LUIKeyboardView.h
//  LUITool
//
//  Created by 六月 on 2023/8/18.
//

#import <UIKit/UIKit.h>
#import "LUIKeyboardButtonModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LUIKeyboardView : UIView

@property (nonatomic, assign) UIEdgeInsets sectionInset;//键盘每个section的内边距
@property (nonatomic) CGFloat minimumInteritemSpacing;//元素中的间隔

- (instancetype)initWithTitleView:(UIView *)titleView;
- (void)__reloadKeyboardButtons:(NSArray <NSArray <LUIKeyboardButtonModel *> *> *)keyboardButtons;

@end

NS_ASSUME_NONNULL_END
