//
//  UITableViewCell+LUITableViewCell.m
//  LUITool
//
//  Created by 六月 on 2022/5/14.
//

#import "UITableViewCell+LUITableViewCell.h"
#import "UITableViewCell+LUI.h"
#import "UITableView+LUI.h"
#import "UIScrollView+LUI.h"
#import <objc/runtime.h>

@implementation UITableViewCell (LUITableViewCell)
#pragma mark - deleagte:LUITableViewCellProtocol
- (LUITableViewCellModel *)cellModel{
    LUITableViewCellModel *cellModel = objc_getAssociatedObject( self, "UITableViewCell.LUITableViewCell.cellModel");
    return cellModel;
}
- (void)setCellModel:(LUITableViewCellModel *)cellModel{
    objc_setAssociatedObject( self, "UITableViewCell.LUITableViewCell.cellModel", cellModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC );
}
+ (CGFloat)estimatedHeightWithTableView:(UITableView *)tableView cellModel:(LUITableViewCellModel *)cellModel{
    return 44;
}
/// ios<11以下时，没有实现estimatedHeightWithTableView方法时，tableview会调用每一行的heightWithTableView方法，来计算高度；实现了estimatedHeightWithTableView，tableview只会调用显示行相关的heightWithTableView方法来计算高度，其余使用估算值。在使用单例cell计算动态高度时，如果有异步加载行为，需要在setCellModel方法中，根据是否单例来执行（单例代表该cell不会被用于显示，只是用于计算高度值）。
/// ios>=11时，tableview只会调用当前显示及附近区域行的heightWithTableView方法，计算高度，其余行的高度使用估算值。因为被计算的行，即为将要显示的行，所以在setCellModel方法中，可以执行异步加载操作。
+ (CGFloat)heightWithTableView:(UITableView *)tableView cellModel:(LUITableViewCellModel *)cellModel{
    return UITableViewAutomaticDimension;
}
@end
