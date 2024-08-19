//
//  LUISectionMdel.m
//  LUITool
//
//  Created by 六月 on 2023/8/11.
//

#import "LUICollectionSectionModel.h"
#import "LUICollectionModel.h"
#import "LUICollectionCellModel.h"


@interface LUICollectionSectionModel() {
    NSMutableArray<LUICollectionCellModel *> *_cellModels;
    __weak LUICollectionModel *_collectionModel;
}
@end

@implementation LUICollectionSectionModel
- (id)init{
    if (self = [super init]) {
        _cellModels = [[NSMutableArray alloc] init];
    }
    return self;
}
- (id)copyWithZone:(NSZone *)zone{
    LUICollectionSectionModel *obj = [super copyWithZone:zone];
    obj.userInfo = self.userInfo;
    obj->_cellModels = [self.cellModels mutableCopy];
    for (LUICollectionCellModel *cm in self.cellModels) {
        [self configCellModelAfterAdding:cm];
    }
    return obj;
}
- (NSMutableArray<LUICollectionCellModel *> *)mutableCellModels{
    return _cellModels;
}
- (void)setCollectionModel:(LUICollectionModel *)collectionModel {
    _collectionModel = collectionModel;
}
- (LUICollectionModel *)collectionModel {
    return _collectionModel;
}
- (NSInteger)numberOfCells{
    NSInteger number = self.cellModels.count;
    return number;
}
- (NSInteger)indexInModel {
    NSInteger index = [self.collectionModel indexOfSectionModel:self];
    return index;
}
- (NSArray<LUICollectionCellModel *> *)cellModels{
    return self.mutableCellModels;
}
- (void)setCellModels:(NSArray<LUICollectionCellModel *> *)cellModels{
    [[self mutableCellModels] removeAllObjects];
    [[self mutableCellModels] addObjectsFromArray:cellModels];
    for (LUICollectionCellModel *cm in cellModels) {
        [self configCellModelAfterAdding:cm];
    }
}
- (void)addCellModel:(LUICollectionCellModel *)cellModel {
    if (!cellModel)return;
    [[self mutableCellModels] addObject:cellModel];
    [self configCellModelAfterAdding:cellModel];
}
- (void)addCellModels:(NSArray<LUICollectionCellModel *> *)cellModels{
    if (cellModels.count == 0)return;
    for (LUICollectionCellModel *cellModel in cellModels) {
        [self addCellModel:cellModel];
    }
}
- (void)insertCellModel:(LUICollectionCellModel *)cellModel atIndex:(NSInteger)index {
    if (!cellModel)return;
    [[self mutableCellModels] insertObject:cellModel atIndex:index];
    [self configCellModelAfterAdding:cellModel];
}
- (void)insertCellModels:(NSArray<LUICollectionCellModel *> *)cellModels afterIndex:(NSInteger)index {
    if (cellModels.count == 0)return;
    NSMutableIndexSet *indexset = [[NSMutableIndexSet alloc] init];
    for (int i=0;i<cellModels.count;i++) {
        [indexset addIndex:index+1+i];
    }
    [[self mutableCellModels] insertObjects:cellModels atIndexes:indexset];
    for (LUICollectionCellModel *cellModel in cellModels) {
        [self configCellModelAfterAdding:cellModel];
    }
}
- (void)insertCellModels:(NSArray<LUICollectionCellModel *> *)cellModels beforeIndex:(NSInteger)index {
    [self insertCellModels:cellModels afterIndex:index-1];
}
- (void)insertCellModelsToTop:(NSArray<LUICollectionCellModel *> *)cellModels{
    [self insertCellModels:cellModels beforeIndex:0];
}
- (void)insertCellModelsToBottom:(NSArray<LUICollectionCellModel *> *)cellModels{
    NSInteger count = self.numberOfCells;
    [self insertCellModels:cellModels afterIndex:count-1];
}
- (void)configCellModelAfterAdding:(LUICollectionCellModel *)cellModel {
    cellModel.sectionModel = self;
}
- (void)configCellModelAfterRemoving:(LUICollectionCellModel *)cellModel {
    cellModel.sectionModel = nil;
}
- (void)removeCellModel:(LUICollectionCellModel *)cellModel {
    [self configCellModelAfterRemoving:cellModel];
    [[self mutableCellModels] removeObject:cellModel];
}
- (void)removeCellModelAtIndex:(NSInteger)index {
    NSMutableArray<LUICollectionCellModel *> *cellModels = [self mutableCellModels];
    if (index>=0&&index<cellModels.count) {
        LUICollectionCellModel *cellModel = [cellModels objectAtIndex:index];
        [self configCellModelAfterRemoving:cellModel];
        [cellModels removeObjectAtIndex:index];
    }
}
- (void)removeCellModelsAtIndexes:(NSIndexSet *)indexes{
    if (indexes.count) {
        NSArray<LUICollectionCellModel *> *cellModels = [[self mutableCellModels] objectsAtIndexes:indexes];
        for (LUICollectionCellModel *cellModel in cellModels) {
            [self configCellModelAfterRemoving:cellModel];
        }
        [[self mutableCellModels] removeObjectsAtIndexes:indexes];
    }
}
- (void)removeAllCellModels{
    for (LUICollectionCellModel *cellModel in [self mutableCellModels]) {
        [self configCellModelAfterRemoving:cellModel];
    }
    [[self mutableCellModels] removeAllObjects];
}
- (LUICollectionCellModel *)cellModelAtIndex:(NSInteger)index {
    LUICollectionCellModel *cellModel;
    if (index>=0&&index<[self cellModels].count) {
        cellModel = [self cellModels][index];
    }
    return cellModel;
}
- (NSInteger)indexOfCellModel:(LUICollectionCellModel *)cellModel {
    NSInteger index = [[self cellModels] indexOfObject:cellModel];
    return index;
}

- (NSIndexPath *)indexPathForSelectedCellModel {
    NSIndexPath *indexpath;
    for (int i=0; i<[self cellModels].count; i++) {
        LUICollectionCellModel *cm = [self cellModels][i];
        if (cm.selected) {
            indexpath = [NSIndexPath indexPathForRow:i inSection:[self.collectionModel indexOfSectionModel:self]];
            break;
        }
    }
    return indexpath;
}
- (LUICollectionCellModel *)cellModelForSelectedCellModel {
    LUICollectionCellModel *cellModel;
    for (int i=0; i<[self cellModels].count; i++) {
        LUICollectionCellModel *cm = [self cellModels][i];
        if (cm.selected) {
            cellModel = cm;
            break;
        }
    }
    return cellModel;
}
- (NSArray<NSIndexPath *> *)indexPathsForSelectedCellModels{
    NSMutableArray<NSIndexPath *> *indexPaths = [[NSMutableArray alloc] init];
    NSInteger index = [self.collectionModel indexOfSectionModel:self];
    for (int i=0; i<[self cellModels].count; i++) {
        LUICollectionCellModel *cm = [self cellModels][i];
        if (cm.selected) {
            NSIndexPath *indexpath = [NSIndexPath indexPathForRow:i inSection:index];
            [indexPaths addObject:indexpath];
        }
    }
    return indexPaths;
}
- (NSArray<LUICollectionCellModel *> *)cellModelsForSelectedCellModels{
    NSMutableArray<LUICollectionCellModel *> *cellModels = [[NSMutableArray alloc] init];
    for (LUICollectionCellModel *cm in [self cellModels]) {
        if (cm.selected) {
            [cellModels addObject:cm];
        }
    }
    return cellModels;
}

- (NSComparisonResult)compare:(LUICollectionSectionModel *)otherObject{
    NSInteger section1 = [self.collectionModel indexOfSectionModel:self];
    NSInteger section2 = [otherObject.collectionModel indexOfSectionModel:otherObject];
    NSComparisonResult r = NSOrderedSame;
    if (section1<section2) {
        r = NSOrderedAscending;
    }else if (section1>section2) {
        r = NSOrderedDescending;
    }
    return r;
}
@end
@implementation LUICollectionSectionModel(Focused)
- (NSInteger)indexForFocusedCellModel {
    NSInteger index = NSNotFound;
    for (int i=0;i<self.numberOfCells;i++) {
        LUICollectionCellModel *cm = self.cellModels[i];
        if (cm.focused) {
            index = i;
            break;
        }
    }
    return index;
}
- (__kindof LUICollectionCellModel *)cellModelForFocusedCellModel {
    NSInteger index = self.indexForFocusedCellModel;
    LUICollectionCellModel *cm = nil;
    if (index != NSNotFound) {
        cm = [self cellModelAtIndex:index];
    }
    return cm;
}
@end
