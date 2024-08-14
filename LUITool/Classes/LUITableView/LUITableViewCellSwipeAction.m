//
//  LUITableViewCellSwipeAction.m
//  LUITool
//
//  Created by 六月 on 2022/5/14.
//

#import "LUITableViewCellSwipeAction.h"
#import "LUITableViewCellModel.h"

@interface LUITableViewCellSwipeAction ()
@property (nonatomic, assign) LUITableViewCellSwipeActionStyle style;
@property (nonatomic, copy) LUITableViewCellSwipeActionHandler handler;
@end

@implementation LUITableViewCellSwipeAction

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.autoCompletion = YES;
    }
    return self;
}
+ (instancetype)actionWithStyle:(LUITableViewCellSwipeActionStyle)style title:(nullable NSString *)title handler:(LUITableViewCellSwipeActionHandler)handler {
    LUITableViewCellSwipeAction *action = [[LUITableViewCellSwipeAction alloc] init];
    action.title = title;
    action.handler = handler;
    action.style = style;
    return action;
}
- (UIContextualAction *)contextualActionWithCellModel:(LUITableViewCellModel *)cellModel {
    lui_weakify(self)
    UIContextualAction *rowAction = [UIContextualAction contextualActionWithStyle:self.style == LUITableViewCellSwipeActionStyleDestructive ? UIContextualActionStyleDestructive : UIContextualActionStyleNormal title:self.title handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        lui_strongify(self)
        if (self.handler) {
            self.handler(self, cellModel);
            if (self.autoCompletion) {
                completionHandler(YES);
            }
        }
    }];
    rowAction.image = self.image;
    rowAction.backgroundColor = self.backgroundColor;
    return rowAction;
}
- (UITableViewRowAction *)tableViewRowActionWithCellModel:(LUITableViewCellModel *)cellModel {
    lui_weakify(self)
    UITableViewRowAction *rowAction = [UITableViewRowAction rowActionWithStyle:self.style == LUITableViewCellSwipeActionStyleDestructive ? UITableViewRowActionStyleDestructive : UITableViewRowActionStyleNormal title:self.title handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        lui_strongify(self)
        if (self.handler) {
            self.handler(self, cellModel);
            if (self.autoCompletion) {
                [cellModel refreshWithAnimated:YES];
            }
        }
    }];
    if (self.backgroundColor) {
        rowAction.backgroundColor = self.backgroundColor;
    }
    return rowAction;
}
- (void)dealloc {
    
}

@end
