//
//  LUISafeKeyboardViewController.m
//  LUITool_Example
//
//  Created by 六月 on 2024/8/19.
//  Copyright © 2024 Your Name. All rights reserved.
//

#import "LUISafeKeyboardViewController.h"

@interface LUISafeKeyboardViewController ()

@end

@implementation LUISafeKeyboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
    NSMutableArray *buttons = [NSMutableArray array];
    
    NSMutableArray *line1Buttons = [NSMutableArray array];
    LUIKeyboardButtonModel *buttonModel = [[LUIKeyboardButtonModel alloc] init];
    buttonModel.title = @"Q";
    buttonModel.type = LUIKeyboardButtonTypeCharacter;
    [line1Buttons addObject:buttonModel];
    
    LUIKeyboardButtonModel *buttonModel1 = [[LUIKeyboardButtonModel alloc] init];
    buttonModel1.title = @"W";
    buttonModel.type = LUIKeyboardButtonTypeCharacter;
    [line1Buttons addObject:buttonModel1];
    
    [buttons addObject:line1Buttons];
    
    NSMutableArray *line2Buttons = [NSMutableArray array];
    LUIKeyboardButtonModel *button2Model = [[LUIKeyboardButtonModel alloc] init];
    button2Model.title = @"A";
    button2Model.type = LUIKeyboardButtonTypeCharacter;
    [line2Buttons addObject:button2Model];
    
    LUIKeyboardButtonModel *button2Model1 = [[LUIKeyboardButtonModel alloc] init];
    button2Model1.title = @"S";
    button2Model1.type = LUIKeyboardButtonTypeCharacter;
    [line2Buttons addObject:button2Model1];
    
    LUIKeyboardButtonModel *button2Model2 = [[LUIKeyboardButtonModel alloc] init];
    button2Model2.title = @"D";
    button2Model2.type = LUIKeyboardButtonTypeCharacter;
    [line2Buttons addObject:button2Model2];
    
    [buttons addObject:line2Buttons];
    
    LUIKeyboardView *safetKeyboard = [[LUIKeyboardView alloc] initWithKeyboardButtons:buttons];
    safetKeyboard.backgroundColor = UIColor.redColor;
    safetKeyboard.frame = CGRectMake(0, 0, 300, 300);
    
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
