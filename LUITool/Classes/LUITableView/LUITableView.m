//
//  LUITableView.m
//  LUITool
//
//  Created by 六月 on 2023/8/11.
//

#import "LUITableView.h"
#import "UITableView+LUI.h"

@implementation LUITableView
- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    if (self=[super initWithFrame:frame style:style]) {
        self.model = [[LUITableViewModel alloc] initWithTableView:self];
        if (@available(iOS 15.0, *)) {
            self.sectionHeaderTopPadding = 0;
        }
    }
    return self;
}
- (void)setModel:(LUITableViewModel *)Model {
    if (_model!=model) {
        _model = model;
        [_model setTableViewDataSourceAndDelegate:self];
    }
}
- (CGSize)sizeThatFits:(CGSize)size{
    CGSize s = size;
    s.height = [self l_heightThatFits:size.width];
    return s;
}
- (void)dealloc{
    //ios10时，会因为实现了scrollViewDidScroll：方法，导致闪退，需要手动清空delegate
    self.delegate = nil;
}
@end
