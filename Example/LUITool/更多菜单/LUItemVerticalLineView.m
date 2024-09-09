//
//  LUItemVerticalLineView.m
//  LUITool_Example
//
//  Created by 六月 on 2024/9/9.
//  Copyright © 2024 Your Name. All rights reserved.
//

#import "LUItemVerticalLineView.h"

@interface LUItemVerticalLineView ()

@property (nonatomic, strong) UIView *bgView;

@end

@implementation LUItemVerticalLineView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.bgView = [[UIView alloc] init];
        self.bgView.clipsToBounds = YES;
        self.bgView.layer.cornerRadius = 5;
        self.bgView.backgroundColor = UIColor.redColor;
        [self addSubview:self.bgView];
        [self sendSubviewToBack:self.bgView];
        self.indicatorLine.hidden = YES;
        self.layer.zPosition = -999999;
    }
    return self;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    self.bgView.frame = bounds;
}

@end
