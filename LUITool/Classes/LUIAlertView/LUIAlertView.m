//
//  LUIAlertView.m
//  LUITool
//
//  Created by 六月 on 2024/8/18.
//

#import "LUIAlertView.h"

@implementation LUIAlertView

+ (instancetype)alertViewWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(LUIAlertViewStyle)preferredStyle {
    LUIAlertView *alertView = [[self alloc] init];
    alertView.title = title;
    alertView.message = message;
    alertView.preferredStyle = preferredStyle;
    return alertView;
}

@end
