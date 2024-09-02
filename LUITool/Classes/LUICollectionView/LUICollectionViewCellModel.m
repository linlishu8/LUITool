//
//  LUICollectionViewCellModel.m
//  LUITool
//
//  Created by 六月 on 2023/8/15.
//

#import "LUICollectionViewCellModel.h"
#import "LUICollectionViewModel.h"
#import "LUICollectionViewSectionModel.h"

@implementation LUICollectionViewCellModel
+ (instancetype)modelWithValue:(id)modelValue cellClass:(Class)cellClass{
    return [self modelWithValue:modelValue cellClass:cellClass whenClick:nil];
}
+ (instancetype)modelWithValue:(nullable id)modelValue cellClass:(Class)cellClass whenClick:(nullable LUICollectionViewCellModelBlockC)whenClick{
    LUICollectionViewCellModel *cm = [self modelWithValue:modelValue];
    cm.cellClass = cellClass;
    cm.whenClick = whenClick;
    return cm;
}
- (id)copyWithZone:(NSZone *)zone{
    LUICollectionViewCellModel *obj = [super copyWithZone:zone];
    obj.cellClass = self.cellClass;
    obj.reuseIdentity = self.reuseIdentity;
    obj.canDelete = self.canDelete;
    obj.canMove = self.canMove;
    obj.whenMove = self.whenMove;
    obj.whenDelete = self.whenDelete;
    obj.collectionViewCell = self.collectionViewCell;
    obj.whenClick = [self.whenClick copy];
    obj.whenSelected = [self.whenSelected copy];
    obj.needReloadCell = self.needReloadCell;
    return obj;
}
- (__kindof LUICollectionViewSectionModel *)sectionModel {
    return (LUICollectionViewSectionModel *)[super sectionModel];
}
- (__kindof LUICollectionViewModel *)collectionModel {
    return (LUICollectionViewModel *)[super collectionModel];
}
- (UICollectionView *)collectionView {
    return ((LUICollectionViewModel *)[self collectionModel]).collectionView;
}
- (NSString *)reuseIdentity{
    if (!_reuseIdentity) {
        _reuseIdentity = NSStringFromClass(self.cellClass);
    }
    return _reuseIdentity;
}
- (void)displayCell:(UICollectionViewCell<LUICollectionViewCellProtocol> *)cell{
    cell.collectionCellModel = self;
    self.collectionViewCell = cell;
    [cell setNeedsLayout];
}
- (void)refresh {
    NSIndexPath *indexPath = [[self collectionModel] indexPathOfCellModel:self];
    if (indexPath) {
        self.needReloadCell = YES;
        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        if (self.selected) {
            [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:(UICollectionViewScrollPositionNone)];
        }
    }
}
- (void)removeCellModelWithAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion{
    [[self collectionModel] removeCellModel:self animated:animated completion:completion];
}
- (void)didClickSelf{
    if (self.whenClick) {
        self.whenClick(self);
    }
}
- (void)didSelectedSelf:(BOOL)selected {
    if (self.whenSelected) {
        self.whenSelected(self,selected);
    }
}
- (BOOL)didDeleteSelf{
    if (self.whenDelete) {
        return self.whenDelete(self);
    }
    return NO;
}
@end
