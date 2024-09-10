//
//  LUIItemFlowCell_Vertical.m
//  LUITool_Example
//
//  Created by 六月 on 2023/9/10.
//  Copyright © 2024 Your Name. All rights reserved.
//

#import "LUIItemFlowCell_Vertical.h"

@implementation LUIItemFlowCell_Vertical

- (id)initWithFrame:(CGRect)frame{
    if(self=[super initWithFrame:frame]){
        self.titleLabel.numberOfLines = 2;
        self.flowlayout.constraintParam = LUIFlowLayoutConstraintParam_V_C_C;
    }
    return self;
}
- (CGRect)itemIndicatorRect{
    return self.bounds;
}

@end
