//
//  LUITableViewSectionViewProtocol.h
//  LUITool
//
//  Created by 六月 on 2024/8/12.
//

#import <Foundation/Foundation.h>
#import "LUITableViewSectionModel.h"

typedef enum{
    LUITableViewSectionViewKindOfHead = 0,    //头部
    LUITableViewSectionViewKindOfFoot = 1    //尾部
} LUITableViewSectionViewKind;

NS_ASSUME_NONNULL_BEGIN

@protocol LUITableViewSectionViewProtocol <NSObject>
/**
 *  返回视图的高度
 *
 *  @param tableView    外层的tableview
 *  @param sectionModel 分组数据模型
 *  @param kind         视图的类型
 *
 *  @return 高度值
 */
+ (CGFloat)heightWithTableView:(UITableView *)tableView sectionModel:(__kindof LUITableViewSectionModel *)sectionModel kind:(LUITableViewSectionViewKind)kind;
/**
 *  设置分组模型與显示類型
 *
 *  @param sectionModel 分组模型
 *  @param kind         类型
 */
- (void)setSectionModel:(nullable __kindof LUITableViewSectionModel *)sectionModel kind:(LUITableViewSectionViewKind)kind;

@optional

/// section视图将要被显示的回调
/// @param tableView 列表
/// @param sectionModel 分组数据模型
/// @param kind 表头/表尾
- (void)tableView:(UITableView *)tableView willDisplaySectionModel:(__kindof LUITableViewSectionModel *)sectionModel kind:(LUITableViewSectionViewKind)kind;

/// section视图完成显示的回调
/// @param tableView 列表
/// @param sectionModel 分组数据模型
/// @param kind 表头/表尾
- (void)tableView:(UITableView *)tableView didEndDisplayingSectionModel:(__kindof LUITableViewSectionModel *)sectionModel kind:(LUITableViewSectionViewKind)kind;
@end

NS_ASSUME_NONNULL_END
