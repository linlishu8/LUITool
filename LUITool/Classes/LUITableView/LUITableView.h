//
//  LUITableView.h
//  LUITool
//
//  Created by 六月 on 2024/8/11.
//

#import <UIKit/UIKit.h>
#import "LUITableViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LUITableView : UITableView 

@property (nonatomic, strong, nullable) LUITableViewModel *model;

@end

NS_ASSUME_NONNULL_END
