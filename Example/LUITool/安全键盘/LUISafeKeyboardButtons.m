//
//  LUISafeKeyboardButtons.m
//  LUITool_Example
//
//  Created by 六月 on 2024/8/21.
//  Copyright © 2024 Your Name. All rights reserved.
//

#import "LUISafeKeyboardButtons.h"

@implementation LUISafeKeyboardButtons

+ (NSArray <NSArray <LUIKeyboardButtonModel *> *> *)LetterKeyboard {
    NSMutableArray *buttons = [NSMutableArray array];
    NSArray *line1Char = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0"];
    NSArray *line2Char = @[@"q",@"w",@"e",@"r",@"t",@"y",@"u",@"i",@"o",@"p"];
    NSArray *line3Char = @[@"s",@"d",@"f",@"g",@"h",@"j",@"k"];
    NSArray *line4Char = @[@"z",@"x",@"c",@"v",@"b",@"n",@"m"];
    
    //第一行
    NSMutableArray *line1Buttons = [NSMutableArray array];
    [line1Char enumerateObjectsUsingBlock:^(NSString *num, NSUInteger idx, BOOL * _Nonnull stop) {
        LUIKeyboardButtonModel *buttonModel = [[LUIKeyboardButtonModel alloc] init];
        buttonModel.buttonHeight = 44;
        buttonModel.title = num;
        buttonModel.type = LUIKeyboardButtonTypeCharacter;
        buttonModel.backgroundColor = UIColor.whiteColor;
//        buttonModel.cornerRadii = [[LUICornerRadiiConfiguration alloc] initWithAllCornerRadii:4.0];
        [line1Buttons addObject:buttonModel];
    }];
    
    [buttons addObject:line1Buttons];
    
    //第二行
    NSMutableArray *line2Buttons = [NSMutableArray array];
    [line2Char enumerateObjectsUsingBlock:^(NSString *num, NSUInteger idx, BOOL * _Nonnull stop) {
        LUIKeyboardButtonModel *buttonModel = [[LUIKeyboardButtonModel alloc] init];
        buttonModel.buttonHeight = 44;
        buttonModel.title = num;
        buttonModel.type = LUIKeyboardButtonTypeCharacter;
        [line2Buttons addObject:buttonModel];
    }];
    [buttons addObject:line2Buttons];
    
    //第三行
    NSMutableArray *line3Buttons = [NSMutableArray array];
    LUIKeyboardButtonModel *abuttonModel = [[LUIKeyboardButtonModel alloc] init];
    abuttonModel.buttonHeight = 44;
    abuttonModel.title = @"a";
    abuttonModel.buttonWidth = 50;
    abuttonModel.marginInsets = UIEdgeInsetsMake(0, 20, 0, 0);
    abuttonModel.type = LUIKeyboardButtonTypeCharacter;
    [line3Buttons addObject:abuttonModel];
    
    [line3Char enumerateObjectsUsingBlock:^(NSString *num, NSUInteger idx, BOOL * _Nonnull stop) {
        LUIKeyboardButtonModel *buttonModel = [[LUIKeyboardButtonModel alloc] init];
        buttonModel.buttonHeight = 44;
        buttonModel.title = num;
        buttonModel.type = LUIKeyboardButtonTypeCharacter;
        [line3Buttons addObject:buttonModel];
    }];
    
    LUIKeyboardButtonModel *lbuttonModel = [[LUIKeyboardButtonModel alloc] init];
    lbuttonModel.buttonHeight = 44;
    lbuttonModel.title = @"l";
    lbuttonModel.buttonWidth = 50;
    lbuttonModel.marginInsets = UIEdgeInsetsMake(0, 0, 0, 20);
    lbuttonModel.type = LUIKeyboardButtonTypeCharacter;
    [line3Buttons addObject:lbuttonModel];
    
    [buttons addObject:line3Buttons];
    
    //第四行
    NSMutableArray *line4Buttons = [NSMutableArray array];
    LUIKeyboardButtonModel *shiftButtonModel = [[LUIKeyboardButtonModel alloc] init];
    shiftButtonModel.buttonHeight = 44;
    shiftButtonModel.buttonWidth = 60;
    shiftButtonModel.backgroundImage = [UIImage imageNamed:@"lui_keyboard_shift"];
    shiftButtonModel.marginInsets = UIEdgeInsetsMake(0, 20, 0, 0);
    shiftButtonModel.type = LUIKeyboardButtonTypeShift;
    [line4Buttons addObject:shiftButtonModel];
    
    [line4Char enumerateObjectsUsingBlock:^(NSString *num, NSUInteger idx, BOOL * _Nonnull stop) {
        LUIKeyboardButtonModel *buttonModel = [[LUIKeyboardButtonModel alloc] init];
        buttonModel.buttonHeight = 44;
        buttonModel.title = num;
        buttonModel.type = LUIKeyboardButtonTypeCharacter;
        [line4Buttons addObject:buttonModel];
    }];
    
    LUIKeyboardButtonModel *deleteButtonModel = [[LUIKeyboardButtonModel alloc] init];
    deleteButtonModel.buttonHeight = 44;
    deleteButtonModel.buttonWidth = 60;
    deleteButtonModel.backgroundImage = [UIImage imageNamed:@"lui_keyboard_delete"];
    deleteButtonModel.marginInsets = UIEdgeInsetsMake(0, 0, 0, 20);
    deleteButtonModel.type = LUIKeyboardButtonTypeDelete;
    [line4Buttons addObject:deleteButtonModel];
    
    [buttons addObject:line4Buttons];
    
    
    return buttons;
    
    
}

@end
