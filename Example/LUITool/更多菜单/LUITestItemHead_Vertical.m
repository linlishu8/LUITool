//
//  LUITestItemHead_Vertical.m
//  LUITool_Example
//
//  Created by 六月 on 2024/9/10.
//  Copyright © 2024 Your Name. All rights reserved.
//

#import "LUITestItemHead_Vertical.h"
#import "LUIItemFlowView.h"

@implementation LUITestItemHead_Vertical

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.redColor;
    }
    return self;
}
+ (UIEdgeInsets)contentInsets {
    return UIEdgeInsetsMake(5, [LUIItemFlowView sizeWithDirectionVertical:YES] + 5, 5, 5);
}

@end
