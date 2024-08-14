//
//  LUITableViewCellSwipeAction.h
//  LUITool
//
//  Created by 六月 on 2022/5/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class LUITableViewCellModel;
@class LUITableViewCellSwipeAction;
typedef NS_ENUM(NSInteger, LUITableViewCellSwipeActionStyle) {
    LUITableViewCellSwipeActionStyleNormal = 0,
    LUITableViewCellSwipeActionStyleDestructive = 1,
};
typedef void (^LUITableViewCellSwipeActionHandler)(LUITableViewCellSwipeAction *action, __kindof LUITableViewCellModel *cellModel);

@interface LUITableViewCellSwipeAction : NSObject

+ (instancetype)actionWithStyle:(LUITableViewCellSwipeActionStyle)style title:(nullable NSString *)title handler:(LUITableViewCellSwipeActionHandler)handler;

@property(nonatomic,readonly) LUITableViewCellSwipeActionStyle style;
@property(nonatomic,copy,nullable) NSString *title;
@property(nonatomic,copy,readonly) LUITableViewCellSwipeActionHandler handler;
@property(nonatomic,copy,nullable) UIColor *backgroundColor; // a default background color is set from the action style
@property(nonatomic,copy,nullable) UIImage *image;
@property(nonatomic,assign) BOOL autoCompletion;//是否自动调用完成事件，默认为YES(即UIContextualAction中，将不会调用completionHandler）

- (UIContextualAction *)contextualActionWithCellModel:(LUITableViewCellModel *)cellModel API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(tvos);
- (UITableViewRowAction *)tableViewRowActionWithCellModel:(LUITableViewCellModel *)cellModel;
@end

NS_ASSUME_NONNULL_END
