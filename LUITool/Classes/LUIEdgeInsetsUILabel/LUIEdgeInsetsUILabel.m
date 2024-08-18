//
//  LUIEdgeInsetsUILabel.m
//  LUITool
//
//  Created by 六月 on 2024/8/18.
//

#import "LUIEdgeInsetsUILabel.h"

@implementation LUIEdgeInsetsUILabel

- (void)setContentInset:(UIEdgeInsets)contentInset {
    if (!UIEdgeInsetsEqualToEdgeInsets(contentInset, _contentInset)) {
        _contentInset = contentInset;
        [self setNeedsDisplay];
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize boundsize = size;
    UIEdgeInsets insets = self.contentInset;
    boundsize.width = MAX(0,size.width-insets.left-insets.right);
    boundsize.height = MAX(0,size.height-insets.top-insets.bottom);
    CGSize s = [super sizeThatFits:boundsize];
    if (s.width > 0) {
        s.width += insets.left + insets.right;
    }
    if (s.height > 0) {
        s.height += insets.top + insets.bottom;
    }
    if (self.fillContainerWidth) {
        s.width = size.width;
    }
    return s;
}

- (CGSize)intrinsicContentSize {
    return [self sizeThatFits:CGSizeMake(9999999, 9999999)];
}

- (void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.contentInset)];
}

@end
