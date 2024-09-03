//
//  LUIThemeViewController.m
//  LUITool_Example
//
//  Created by 六月 on 2023/8/18.
//  Copyright © 2024 Your Name. All rights reserved.
//

#import "LUIThemeViewController.h"
#import "UIButton+TestTheme.h"

@interface LUIThemeViewController ()

@property (nonatomic, strong) LUILedBannerVerticalView *bannerView;

@end

@implementation LUIThemeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"主题";
    
    self.view.ltheme_backgroundColor = [UIColor ltheme_colorNamed:@"bgColor"];
    
    LUILayoutButton *chgButton = [[LUILayoutButton alloc] init];
    [chgButton ltheme_setTitleColor:[UIColor ltheme_colorNamed:@"fontColor"] forState:UIControlStateNormal];
    [chgButton setTitle:@"Theme" forState:UIControlStateNormal];
    [chgButton addTarget:self action:@selector(changeTheme) forControlEvents:UIControlEventTouchUpInside];
    [chgButton sizeToFit];
    UIBarButtonItem *chgItem = [[UIBarButtonItem alloc] initWithCustomView:chgButton];
    self.navigationItem.rightBarButtonItem = chgItem;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(100, 100, 100, 30)];
    label.ltheme_text = [NSString ltheme_stringNamed:@"label.text"];
    label.ltheme_textColor = [UIColor ltheme_colorNamed:@"labelColor"];
    label.ltheme_font = [UIFont ltheme_fontNamed:@"labelFont"];
    [self.view addSubview:label];
    
    LUILayoutButton *button = [[LUILayoutButton alloc] initWithFrame:CGRectMake(100, 150, 100, 40)];
    button.imageSize = CGSizeMake(30, 30);
    [button ltheme_test_setNormalImage:[UIImage ltheme_imageNamed:@"buttonIcon"] highlightImage:[UIImage ltheme_imageNamed:@"buttonHighlightIconName"]];
    [button ltheme_setImage:[UIImage ltheme_imageNamed:@"buttonSelectedIconName"] forState:UIControlStateSelected];
    [button ltheme_setTitleColor:[UIColor ltheme_colorNamed:@"labelColor"] forState:UIControlStateNormal];
    [button ltheme_setTitle:[NSString ltheme_stringNamed:@"button.text"] forState:UIControlStateNormal];
    [button ltheme_setTitle:[NSString ltheme_stringNamed:@"button.text.local"] forState:UIControlStateSelected];
    [button ltheme_setTitle:[NSString ltheme_stringNamed:@"button.text.highlight"] forState:UIControlStateHighlighted];
    
    button.titleLabel.ltheme_font = [UIFont ltheme_fontNamed:@"labelFont"];
    [button addTarget:self action:@selector(_buttonDidTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)viewWillLayoutSubviews {
    
}

- (void)_buttonDidTap:(id)sender {
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
}

- (void)changeTheme{
    NSUInteger index = [LUIThemeCenter sharedInstance].currentThemeIndex;
    index = (index+1)%([LUIThemeCenter sharedInstance].themes.count);
    [LUIThemeCenter sharedInstance].currentThemeIndex = index;
}

@end
