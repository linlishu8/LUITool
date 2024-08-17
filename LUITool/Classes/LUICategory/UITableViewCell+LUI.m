//
//  UITableViewCell+LUI.m
//  LUITool
//
//  Created by 六月 on 2023/8/11.
//

#import "UITableViewCell+LUI.h"
#import "UIView+LUI.h"
#import "UITableView+LUI.h"

CGFloat const kLUIAccessoryTypeDefaultLeftMargin = 10;
CGFloat const kLUIAccessoryTypeDefaultRightMargin = 15;

@implementation UITableViewCell (LUI)

//系统操作区域视图宽度
- (CGFloat)l_accessorySystemTypeViewWidth {
    CGFloat width = 0;
    switch (self.accessoryType) {
        case UITableViewCellAccessoryNone:
            width = 0;
            break;
        case UITableViewCellAccessoryDisclosureIndicator:
            if (@available(iOS 13.0, *)) {
                width = 11.5;
            }else {
                width = 8;
            }
            break;
        case UITableViewCellAccessoryDetailDisclosureButton:
            if (@available(iOS 13.0, *)) {
                width = 44;
            }else {
                width = 42;
            }
            break;
        case UITableViewCellAccessoryCheckmark:
            if (@available(iOS 13.0, *)) {
                width = 19.5;
            }else {
                width = 14;
            }
            break;
        case UITableViewCellAccessoryDetailButton:
            if (@available(iOS 13.0, *)) {
                width = 25;
            }else {
                width = 22;
            }
            break;
        default:
            break;
    }
    return width;
}
//系统操作区域视图与contentView的左边距
- (CGFloat)l_accessorySystemTypeViewLeftMargin {
    CGFloat margin = kLUIAccessoryTypeDefaultLeftMargin;
    switch (self.accessoryType) {
        case UITableViewCellAccessoryNone:
            margin = 0;
            break;
        case UITableViewCellAccessoryDisclosureIndicator:
            if (@available(iOS 13.0, *)) {
                margin = 0;
            }
            break;
        case UITableViewCellAccessoryDetailDisclosureButton:
            if (@available(iOS 13.0, *)) {
                margin = -0.5;
            }
            break;
        case UITableViewCellAccessoryCheckmark:
            if (@available(iOS 13.0, *)) {
                margin = 2.25;
            }
            break;
        case UITableViewCellAccessoryDetailButton:
            if (@available(iOS 13.0, *)) {
                margin = -0.5;
            }
            break;
        default:
            break;
    }
    return margin;
}
//系统操作区域视图与UITableViewCell的右边距
- (CGFloat)l_accessorySystemTypeViewRightMargin {
    CGFloat margin = kLUIAccessoryTypeDefaultRightMargin;
    switch (self.accessoryType) {
        case UITableViewCellAccessoryNone:
            margin = 0;
            break;
        case UITableViewCellAccessoryDisclosureIndicator:
            if (@available(iOS 13.0, *)) {
                margin = 20;
            }
            break;
        case UITableViewCellAccessoryDetailDisclosureButton:
            if (@available(iOS 13.0, *)) {
                margin = 20;
            }
            break;
        case UITableViewCellAccessoryCheckmark:
            if (@available(iOS 13.0, *)) {
                margin = 22.25;
            }
            break;
        case UITableViewCellAccessoryDetailButton:
            if (@available(iOS 13.0, *)) {
                margin = 19.5;
            }
            break;
        default:
            break;
    }
    return margin;
}

- (CGFloat)l_accessoryCustomViewLeftMargin {
    CGFloat width = kLUIAccessoryTypeDefaultLeftMargin;
    if (@available(iOS 13.0, *)) {
        width = 0;
    }
    return width;
}
- (CGFloat)l_accessoryCustomViewRightMargin {
    CGFloat width = kLUIAccessoryTypeDefaultRightMargin;
    if (@available(iOS 13.0, *)) {
        width = 20;
    }
    return width;
}
- (CGFloat)l_accessoryViewLeftMargin {
    CGFloat margin = 0;
    if (self.accessoryView == nil) {
        margin = self.l_accessorySystemTypeViewLeftMargin;
    }else {
        margin = self.l_accessoryCustomViewLeftMargin;
    }
    return margin;
}
- (CGFloat)l_accessoryViewRightMargin {
    CGFloat margin = 0;
    if (self.accessoryView == nil) {
        margin = self.l_accessorySystemTypeViewRightMargin;
    }else {
        margin = self.l_accessoryCustomViewRightMargin;
    }
    return margin;
}
- (CGSize)l_sizeThatFits:(CGSize)size sizeFitsBlock:(CGSize(^)(CGSize size))block {
    size.height = 99999999;
    UITableView *tableView = (UITableView *)[self l_firstSuperViewWithClass:[UITableView class]];
    CGSize limitSize = self.contentView.bounds.size;
    limitSize.height = MAX(size.height,limitSize.height);
    CGSize s = CGSizeZero;
    if (block) {
        s = block(limitSize);
    }
    if (s.height > 0 && ![UITableView l_isAutoAddSeparatorHeightToCell]) {
        s.height += tableView.l_separatorHeight;
    }
    //消除浮点误差
    s.height = ceil(s.height);
    return s;
}

@end
