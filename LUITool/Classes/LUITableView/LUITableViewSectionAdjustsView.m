//
//  LUITableViewSectionAdjustsView.m
//  LUITool
//
//  Created by 六月 on 2024/8/13.
//

#import "LUITableViewSectionAdjustsView.h"

@implementation LUITableViewSectionAdjustsView

+ (UIEdgeInsets)contentMargin {
    return UIEdgeInsetsMake(8, 16, 8, 16);
}
+ (LUITableViewSectionModel *)sectionModelWithHeadTitle:(NSString *)title {
    LUITableViewSectionModel *sm = [[LUITableViewSectionModel alloc] init];
    sm.showHeadView = YES;
    sm.headTitle = title;
    sm.showDefaultHeadView = NO;
    sm.headViewClass = self;
    return sm;
}
+ (LUITableViewSectionModel *)sectionModelWithFootTitle:(NSString *)title {
    LUITableViewSectionModel *sm = [[LUITableViewSectionModel alloc] init];
    sm.showFootView = YES;
    sm.footTitle = title;
    sm.showDefaultFootView = NO;
    sm.footViewClass = self;
    return sm;
}
+ (LUITableViewSectionModel *)sectionModelWithHeadTitle:(NSString *)headTitle footTitle:(NSString *)footTitle {
    LUITableViewSectionModel *sm = [[LUITableViewSectionModel alloc] init];
    sm.showHeadView = YES;
    sm.headTitle = headTitle;
    sm.showDefaultHeadView = NO;
    sm.headViewClass = self;
    
    sm.showFootView = YES;
    sm.footTitle = footTitle;
    sm.showDefaultFootView = NO;
    sm.footViewClass = self;
    return sm;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.contentView.bounds;
    UIEdgeInsets insets = [self.class contentMargin];
    //title
    CGRect f1 = bounds;
    f1 = UIEdgeInsetsInsetRect(f1, insets);
    self.textLabel.frame = f1;
}
- (CGSize)sizeThatFits:(CGSize)size {
    UIEdgeInsets insets = [self.class contentMargin];
    size.width -= insets.left + insets.right;
    size.height -= insets.top + insets.bottom;
    CGSize s = [self.textLabel sizeThatFits:size];
    if (!CGSizeEqualToSize(CGSizeZero, s)) {
        s.width += insets.left + insets.right;
        s.height += insets.top + insets.bottom;
    }
    return s;
}

@end
