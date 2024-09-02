//
//  LUIAlertView.m
//  LUITool
//
//  Created by 六月 on 2023/8/18.
//

#import "LUIAlertView.h"

@interface LUIAlertView ()

@property (nonatomic, copy, nullable) NSString *title;//标题
@property (nonatomic, copy, nullable) NSString *message;//消息

@end

@implementation LUIAlertView

+ (instancetype)alertViewWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(LUIAlertViewStyle)preferredStyle {
    LUIAlertView *alertView = [[self alloc] init];
    alertView.title = title;
    alertView.message = message;
    alertView.preferredStyle = preferredStyle;
    return alertView;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _showMaskView = YES;
        _alertActionsCountForHorizontal = 2;
        
        [self addSubview:self.alertContenView];
    }
    return self;
}


- (LUITableView *)alertContenView {
    if (!_alertContenView) {
        //消息列表
        _alertContenView = [[LUITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _alertContenView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _alertContenView;
}

@end
