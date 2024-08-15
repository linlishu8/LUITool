//
//  LUITableViewCellSwipeAction.m
//  LUITool
//
//  Created by 六月 on 2022/5/14.
//

#import "LUITableViewCellSwipeAction.h"
#import "LUITableViewCellModel.h"
#import "LUIMacro.h"

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
    @LUI_WEAKIFY(self);
    @LUI_WEAKIFY(cellModel);
    UIContextualAction *rowAction = [UIContextualAction contextualActionWithStyle:self.style == LUITableViewCellSwipeActionStyleDestructive ? UIContextualActionStyleDestructive : UIContextualActionStyleNormal title:self.title handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        @LUI_NORMALIZE(self);
        @LUI_NORMALIZE(cellModel);
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
    @LUI_WEAKIFY(self);
    @LUI_WEAKIFY(cellModel);
    UITableViewRowAction *rowAction = [UITableViewRowAction rowActionWithStyle:self.style == LUITableViewCellSwipeActionStyleDestructive ? UITableViewRowActionStyleDestructive : UITableViewRowActionStyleNormal title:self.title handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        @LUI_NORMALIZE(self);
        @LUI_NORMALIZE(cellModel);
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
