//
//  LUITableViewCellBase.m
//  LUITool
//
//  Created by 六月 on 2021/8/13.
//

#import "LUITableViewCellBase.h"
#import "UITableViewCell+LUI.h"
#import "NSObject+LUI.h"
@interface LUITableViewCellBase()
@property(nonatomic) BOOL isCellModelChanged;//cellmodel是否有变化
@property(nonatomic) BOOL isNeedLayoutCellSubviews;//是否要重新布局视图
@end

@implementation LUITableViewCellBase
+ (NSString *)estimatedHeightKey{
    return [NSString stringWithFormat:@"%@_estimatedHeight",NSStringFromClass(self)];
}
+ (NSString *)cachedFitedSizeKey{
    return [NSString stringWithFormat:@"%@_cachedFitedSize",NSStringFromClass(self)];
}
+ (CGFloat)estimatedHeightWithTableView:(UITableView *)tableView cellModel:(LUITableViewCellModel *)cellModel{
    CGFloat height = [cellModel l_CGFloatForKeyPath:self.estimatedHeightKey otherwise:44];
    return height;
}
/// ios<11以下时，没有实现estimatedHeightWithTableView方法时，tableview会调用每一行的heightWithTableView方法，来计算高度；实现了estimatedHeightWithTableView，tableview只会调用显示行相关的heightWithTableView方法来计算高度，其余使用估算值。在使用单例cell计算动态高度时，如果有异步加载行为，需要在setCellModel方法中，根据是否单例来执行（单例代表该cell不会被用于显示，只是用于计算高度值）。
/// ios>=11时，tableview只会调用当前显示及附近区域行的heightWithTableView方法，计算高度，其余行的高度使用估算值。因为被计算的行，即为将要显示的行，所以在setCellModel方法中，可以执行异步加载操作。
+ (CGFloat)heightWithTableView:(UITableView *)tableView cellModel:(LUITableViewCellModel *)cellModel{
    if(self.class.useCachedFitedSize){
        CGRect bounds = tableView.bounds;
        NSValue *cacheSizeValue = cellModel[self.cachedFitedSizeKey];
        if(cacheSizeValue){
            CGSize cacheSize = [cacheSizeValue CGSizeValue];
            if(cacheSize.width==bounds.size.width){
                return cacheSize.height;
            }
        }
    }
    return UITableViewAutomaticDimension;
}
+ (BOOL)useCachedFitedSize{
    return YES;
}
- (void)setCellModel:(__kindof LUITableViewCellModel *)cellModel{//tableview尺寸变化时，并不会reload数据，cell也不会重新获取。只是会调用estimatedHeight、height方式，获取cell的估算尺寸和实际尺寸，然后更新cell.frame
    self.isCellModelChanged =
       cellModel.needReloadCell
    || _cellModel!=cellModel
    || cellModel.tableViewCell!=self
    ;
    _cellModel = cellModel;
    if(self.class.useCachedFitedSize && cellModel.needReloadCell){
        cellModel[self.class.cachedFitedSizeKey] = nil;
    }
    cellModel.needReloadCell = NO;
    
    if(!self.isCellModelChanged){
        return;
    }
    self.isNeedLayoutCellSubviews = YES;
    [self customReloadCellModel];
}
- (void)layoutSubviews{
    [super layoutSubviews];
    if(!self.isCellModelChanged&&!self.isNeedLayoutCellSubviews){
        return;
    }
    [self customLayoutSubviews];
    self.isNeedLayoutCellSubviews = NO;
}
- (CGSize)sizeThatFits:(CGSize)size{
    if(self.class.useCachedFitedSize){
        NSValue *cacheSizeValue = self.cellModel[self.class.cachedFitedSizeKey];
        if(cacheSizeValue){
            CGSize cacheSize = [cacheSizeValue CGSizeValue];
            if(cacheSize.width==size.width){
                return cacheSize;
            }
        }
    }
    CGSize sizeFits = [self l_sizeThatFits:size sizeFitsBlock:^CGSize(CGSize size) {
        return [self customSizeThatFits:size];
    }];
    sizeFits.width = size.width;
    if(self.class.useCachedFitedSize){
        self.cellModel[self.class.cachedFitedSizeKey] = [NSValue valueWithCGSize:sizeFits];
    }
    self.cellModel[self.class.estimatedHeightKey] = @(sizeFits.height);
    return sizeFits;
}
#pragma mark - override
- (void)customReloadCellModel{
    
}
- (void)customLayoutSubviews{
    
}
- (CGSize)customSizeThatFits:(CGSize)size{
    return size;
}
@end
