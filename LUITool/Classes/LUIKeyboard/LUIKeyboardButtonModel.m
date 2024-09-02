//
//  LUIKeyboardButtonModel.m
//  LUITool
//
//  Created by 六月 on 2023/8/29.
//

#import "LUIKeyboardButtonModel.h"

@implementation LUIBorderConfiguration

- (instancetype)initWithWidth:(CGFloat)width color:(UIColor *)color {
    self = [super init];
    if (self) {
        _width = width;
        _color = color;
    }
    return self;
}

@end

@implementation LUICornerRadiiConfiguration

- (instancetype)initWithTopLeft:(CGFloat)topLeft topRight:(CGFloat)topRight bottomLeft:(CGFloat)bottomLeft bottomRight:(CGFloat)bottomRight {
    self = [super init];
    if (self) {
        _topLeft = topLeft;
        _topRight = topRight;
        _bottomLeft = bottomLeft;
        _bottomRight = bottomRight;
    }
    return self;
}

- (instancetype)initWithAllCornerRadii:(CGFloat)cornerRadii {
    self = [super init];
    if (self) {
        _topLeft = cornerRadii;
        _topRight = cornerRadii;
        _bottomLeft = cornerRadii;
        _bottomRight = cornerRadii;
    }
    return self;
}

@end

@implementation LUIKeyboardButtonModel

@end
