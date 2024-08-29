//
//  LUISafeKeyboardViewController.m
//  LUITool_Example
//
//  Created by 六月 on 2024/8/19.
//  Copyright © 2024 Your Name. All rights reserved.
//

#import "LUISafeKeyboardViewController.h"
#import "LUISafeKeyboardButtons.h"

@interface LUISafeKeyboardViewController ()

@end

@implementation LUISafeKeyboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    titleView.backgroundColor = UIColor.blackColor;
    LUIKeyboardView *safetKeyboard = [[LUIKeyboardView alloc] initWithTitleView:titleView];
    safetKeyboard.sectionInset = UIEdgeInsetsMake(6, 0, 0, 0);
    safetKeyboard.minimumInteritemSpacing = 0;
    [safetKeyboard __reloadKeyboardButtons:[LUISafeKeyboardButtons LetterKeyboard]];
    safetKeyboard.backgroundColor = UIColor.grayColor;
    CGSize keyboardSize = [safetKeyboard sizeThatFits:self.view.frame.size];
    safetKeyboard.frame = CGRectMake(0, 50, self.view.bounds.size.width, keyboardSize.height);
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(100, 100, 200, 100)];
    textField.layer.borderWidth = 2;
    textField.layer.borderColor = UIColor.blackColor.CGColor;
    [self.view addSubview:textField];
    
    textField.inputView = safetKeyboard;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

@end
