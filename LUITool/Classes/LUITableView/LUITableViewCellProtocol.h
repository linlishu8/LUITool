//
//  LUITableViewCellProtocol.h
//  LUITool
//  LUITableViewCellModel对应的UITableViewCell视图要实现的delegate
//  Created by 六月 on 2024/8/12.
//

#import <Foundation/Foundation.h>
#import "LUITableViewCellModel.h"

#ifndef LDEF_LUITableViewCellModel
#define LDEF_LUITableViewCellModel(clazz,property) \
- (LUITableViewCellModel *)cellModel{\
    return self.property;\
}\
- (void)setCellModel:(LUITableViewCellModel *)cellModel{\
    self.property = (clazz *)cellModel;\
}
#endif
NS_ASSUME_NONNULL_BEGIN

@protocol LUITableViewCellProtocol <NSObject>
/**
 *  根据cellmodel,计算出cell视图的高度
 /// ios<11以下时，没有实现estimatedHeightWithTableView方法时，tableview会调用每一行的heightWithTableView方法，来计算高度；实现了estimatedHeightWithTableView，tableview只会调用显示行相关的heightWithTableView方法来计算高度，其余使用估算值。在使用单例cell计算动态高度时，如果有异步加载行为，需要在setCellModel方法中，根据是否单例来执行（单例代表该cell不会被用于显示，只是用于计算高度值）。
 /// ios>=11时，tableview只会调用当前显示及附近区域行的heightWithTableView方法，计算高度，其余行的高度使用估算值。因为被计算的行，即为将要显示的行，所以在setCellModel方法中，可以执行异步加载操作。
 
 *  @param tableView 外層tableview
 *  @param cellModel 单元格数据
 *
 *  @return 高度值,默认返回UITableViewAutomaticDimension
 */
+ (CGFloat)heightWithTableView:(UITableView *)tableView cellModel:(__kindof LUITableViewCellModel *)cellModel;

/// 返回cell的估算值
/// @param tableView 外层tableview
/// @param cellModel 单元格数据
/// @return 估算高度值,默认返回44
+ (CGFloat)estimatedHeightWithTableView:(UITableView *)tableView cellModel:(__kindof LUITableViewCellModel *)cellModel;

/// 单元格数据模型。在根据数据更新cell视图时，如果有异步加载资源的情况，在ios11以下时，需要判断当前cell是否单例，如果是单例，不进行异步加载资源操作。
@property(nonatomic,strong,nullable) __kindof LUITableViewCellModel *cellModel;
@optional
//选中/取消选中单元格
- (void)tableView:(UITableView *)tableView didSelectCell:(BOOL)selected;

/// cell要被显示前的回调。可在此处进行异步加载图片等资源。
/// @param tableView 列表
/// @param cellModel 单元格模型数据
- (void)tableView:(UITableView *)tableView willDisplayCellModel:(__kindof LUITableViewCellModel *)cellModel;

/// cell要被移出显示范围的回调。该方法的回调时机不确定。
/// @param tableView 列表
/// @param cellModel 单元格模型数据
- (void)tableView:(UITableView *)tableView didEndDisplayingCellModel:(__kindof LUITableViewCellModel *)cellModel;
@end

NS_ASSUME_NONNULL_END
