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
    buttonModel.title = @"1";
    buttonModel.type = LUIKeyboardButtonTypeCharacter;
    [line1Buttons addObject:buttonModel];
    
    LUIKeyboardButtonModel *buttonModel1 = [[LUIKeyboardButtonModel alloc] init];
    buttonModel1.title = @"2";
    buttonModel1.type = LUIKeyboardButtonTypeCharacter;
    [line1Buttons addObject:buttonModel1];
    
    LUIKeyboardButtonModel *buttonModel2 = [[LUIKeyboardButtonModel alloc] init];
    buttonModel2.title = @"3";
    buttonModel2.type = LUIKeyboardButtonTypeCharacter;
    [line1Buttons addObject:buttonModel2];
    
    LUIKeyboardButtonModel *buttonModel4 = [[LUIKeyboardButtonModel alloc] init];
    buttonModel4.title = @"4";
    buttonModel4.type = LUIKeyboardButtonTypeCharacter;
    [line1Buttons addObject:buttonModel4];
    
    LUIKeyboardButtonModel *buttonModel5 = [[LUIKeyboardButtonModel alloc] init];
    buttonModel5.title = @"5";
    buttonModel5.type = LUIKeyboardButtonTypeCharacter;
    [line1Buttons addObject:buttonModel5];
    
    LUIKeyboardButtonModel *buttonModel6 = [[LUIKeyboardButtonModel alloc] init];
    buttonModel6.title = @"6";
    buttonModel6.type = LUIKeyboardButtonTypeCharacter;
    [line1Buttons addObject:buttonModel6];
    
    LUIKeyboardButtonModel *buttonModel7 = [[LUIKeyboardButtonModel alloc] init];
    buttonModel7.title = @"7";
    buttonModel7.type = LUIKeyboardButtonTypeCharacter;
    [line1Buttons addObject:buttonModel7];
    
    LUIKeyboardButtonModel *buttonModel8 = [[LUIKeyboardButtonModel alloc] init];
    buttonModel8.title = @"8";
    buttonModel8.type = LUIKeyboardButtonTypeCharacter;
    [line1Buttons addObject:buttonModel8];
    
    LUIKeyboardButtonModel *buttonModel9 = [[LUIKeyboardButtonModel alloc] init];
    buttonModel9.title = @"9";
    buttonModel9.type = LUIKeyboardButtonTypeCharacter;
    [line1Buttons addObject:buttonModel9];
    
    LUIKeyboardButtonModel *buttonModel10 = [[LUIKeyboardButtonModel alloc] init];
    buttonModel10.title = @"0";
    buttonModel10.type = LUIKeyboardButtonTypeCharacter;
    [line1Buttons addObject:buttonModel10];
    
    [buttons addObject:line1Buttons];
    
    NSMutableArray *line2Buttons = [NSMutableArray array];
    LUIKeyboardButtonModel *button2Model = [[LUIKeyboardButtonModel alloc] init];
    button2Model.title = @"A";
    button2Model.size = CGSizeMake(42, 50);
    button2Model.type = LUIKeyboardButtonTypeCharacter;
    button2Model.paddingSpacing = UIEdgeInsetsMake(0, 10, 0, 0);
    [line2Buttons addObject:button2Model];
    
    LUIKeyboardButtonModel *button2Model1 = [[LUIKeyboardButtonModel alloc] init];
    button2Model1.title = @"S";
    button2Model1.type = LUIKeyboardButtonTypeCharacter;
    [line2Buttons addObject:button2Model1];
    
    LUIKeyboardButtonModel *button2Model2 = [[LUIKeyboardButtonModel alloc] init];
    button2Model2.title = @"D";
    button2Model2.size = CGSizeMake(42, 30);
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
