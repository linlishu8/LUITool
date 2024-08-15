//
//  LUICollectionViewSectionModel.m
//  LUITool
//
//  Created by 六月 on 2024/8/15.
//

#import "LUICollectionViewSectionModel.h"
#import "LUICollectionViewModel.h"
#import "LUICollectionViewSupplementaryElementProtocol.h"

@implementation LUICollectionViewSectionModel

- (id)init {
    if (self=[super init]) {
        _supplementaryElementCellClasses = [[NSMutableDictionary alloc] init];
    }
    return self;
}
- (id)copyWithZone:(NSZone *)zone {
    LUICollectionViewSectionModel *obj = [super copyWithZone:zone];
    obj->_supplementaryElementCellClasses = [self->_supplementaryElementCellClasses mutableCopy];
    return obj;
}
- (__kindof LUICollectionViewModel *)collectionModel {
    return (LUICollectionViewModel *)[super collectionModel];
}
- (__kindof LUICollectionViewCellModel *)cellModelAtIndex:(NSInteger)index {
     return (LUICollectionViewCellModel *)[super cellModelAtIndex:index];
}
- (UICollectionView *)collectionView {
    return ((LUICollectionViewModel *)[self collectionModel]).collectionView;
}
- (void)refresh {
    NSIndexSet *set = [[self collectionModel] indexSetOfSectionModel:self];
    if (set) {
        [self.collectionView reloadSections:set];
    }
}
- (void)setSupplementaryElementViewClass:(Class<LUICollectionViewSupplementaryElementProtocol>)aClass forKind:(NSString *)kind {
    if (aClass==nil) {
        [self removeSupplementaryElementViewClassForKind:kind];
        return;
    }
    if (![(Class)aClass isSubclassOfClass:[UICollectionReusableView class]]) return;
    [_supplementaryElementCellClasses setObject:aClass forKey:kind];
}
- (void)removeSupplementaryElementViewClassForKind:(NSString *)kind {
    [_supplementaryElementCellClasses removeObjectForKey:kind];
}
- (Class<LUICollectionViewSupplementaryElementProtocol>)supplementaryElementViewClassForKind:(NSString *)kind {
    Class<LUICollectionViewSupplementaryElementProtocol> aClass = _supplementaryElementCellClasses[kind];
    return aClass;
}
- (void)displaySupplementaryElementView:(UICollectionReusableView<LUICollectionViewSupplementaryElementProtocol> *)view forKind:(NSString *)kind {
    [view setCollectionSectionModel:self forKind:kind];
    [view setNeedsLayout];
}

@end
