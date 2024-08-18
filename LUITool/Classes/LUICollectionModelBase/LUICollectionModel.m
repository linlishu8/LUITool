//
//  LUIModel.m
//  LUITool
//
//  Created by 六月 on 2023/8/11.
//

#import "LUICollectionModel.h"
#import "LUICollectionSectionModel.h"
#import "LUICollectionCellModel.h"

@interface LUICollectionModel() {
    NSMutableArray<LUICollectionSectionModel *> *_sectionModels;
}
@end

@implementation LUICollectionModel
- (id)init{
    if (self = [super init]) {
        _sectionModels = [[NSMutableArray alloc] init];
        self.allowsSelection = YES;
    }
    return self;
}
- (id)copyWithZone:(NSZone *)zone{
    LUICollectionModel *obj = [super copyWithZone:zone];
    obj->_sectionModels = [_sectionModels mutableCopy];
    for(LUICollectionSectionModel *sm in self.sectionModels) {
        sm.collectionModel = self;
    }
    obj.userInfo = self.userInfo;
    obj.allowsSelection = self.allowsSelection;
    obj.allowsMultipleSelection = self.allowsMultipleSelection;
    obj.allowsFocus = self.allowsFocus;
    return obj;
}
- (NSMutableArray<__kindof LUICollectionSectionModel *> *)mutableSectionModels{
    return _sectionModels;
}
- (NSIndexPath *)indexPathOfLastCellModel {
    NSIndexPath *indexpath;
    NSInteger sections = self.numberOfSections;
    for (NSInteger i=sections-1;i>=0;i--) {
        LUICollectionSectionModel *sm = [self sectionModelAtIndex:i];
        NSInteger cells = sm.numberOfCells;
        if (cells>0) {
            indexpath = [NSIndexPath indexPathForItem:cells-1 inSection:i];
            break;
        }
    }
    return indexpath;
}
- (NSArray<__kindof LUICollectionSectionModel *> *)sectionModels{
    return [self mutableSectionModels];
}
- (void)setSectionModels:(NSArray<LUICollectionSectionModel *> *)sectionModels{
    [[self mutableSectionModels] removeAllObjects];
    [[self mutableSectionModels] addObjectsFromArray:sectionModels];
    for(LUICollectionSectionModel *sm in sectionModels) {
        sm.collectionModel = self;
    }
}
- (NSInteger)numberOfSections{
    NSInteger number = [self sectionModels].count;
    return number;
}
- (NSInteger)numberOfCells{
    NSInteger numberOfCells = 0;
    for (LUICollectionSectionModel *section in [self sectionModels]) {
        numberOfCells += [section numberOfCells];
    }
    return numberOfCells;
}
- (NSArray<__kindof LUICollectionCellModel *> *)allCellModels{
    NSMutableArray<LUICollectionCellModel *> *cells = [[NSMutableArray alloc] init];
    for (LUICollectionSectionModel *section in [self sectionModels]) {
        [cells addObjectsFromArray:[section cellModels]];
    }
    return cells;
}
- (__kindof LUICollectionSectionModel *)createEmptySectionModel {
    LUICollectionSectionModel *section = [[LUICollectionSectionModel alloc] init];
    return section;
}
- (void)addCellModel:(LUICollectionCellModel *)cellModel {
    if (!cellModel)return;
    LUICollectionSectionModel *section = [[self sectionModels] lastObject];
    if (!section) {
        section = [self createEmptySectionModel];
        [self addSectionModel:section];
    }
    [section addCellModel:cellModel];
}
- (void)addCellModelToFirst:(LUICollectionCellModel *)cellModel {
    if (!cellModel)return;
    LUICollectionSectionModel *section = [[self sectionModels] firstObject];
    if (!section) {
        section = [self createEmptySectionModel];
        [self addSectionModel:section];
    }
    [section insertCellModel:cellModel atIndex:0];
}
- (void)addCellModels:(NSArray<LUICollectionCellModel *> *)cellModels{
    for (LUICollectionCellModel *cellModel in cellModels) {
        [self addCellModel:cellModel];
    }
}
- (void)insertCellModel:(LUICollectionCellModel *)cellModel atIndexPath:(NSIndexPath *)indexPath {
    if (!cellModel)return;
    LUICollectionSectionModel *sectionModel = [self sectionModelAtIndex:indexPath.section];
    if (sectionModel) {
        [sectionModel insertCellModel:cellModel atIndex:indexPath.row];
    }
}
- (void)insertCellModels:(NSArray<LUICollectionCellModel *> *)cellModels afterIndexPath:(NSIndexPath *)indexPath {
    if (cellModels.count == 0||!indexPath)return;
    LUICollectionSectionModel *sectionModel = [self sectionModelAtIndex:indexPath.section];
    if (sectionModel) {
        [sectionModel insertCellModels:cellModels afterIndex:indexPath.row];
    }
}
- (void)insertCellModels:(NSArray<LUICollectionCellModel *> *)cellModels beforeIndexPath:(NSIndexPath *)indexPath {
    if (cellModels.count == 0||!indexPath)return;
    LUICollectionSectionModel *sectionModel = [self sectionModelAtIndex:indexPath.section];
    if (sectionModel) {
        [sectionModel insertCellModels:cellModels beforeIndex:indexPath.row];
    }
}
- (void)insertCellModelsToBottom:(NSArray<LUICollectionCellModel *> *)cellModels{
    if (cellModels.count == 0)return;
    LUICollectionSectionModel *sectionModel = [[self sectionModels] lastObject];
    if (sectionModel) {
        [sectionModel insertCellModelsToBottom:cellModels];
    }
}
- (void)insertCellModelsToTop:(NSArray<LUICollectionCellModel *> *)cellModels{
    if (cellModels.count == 0)return;
    LUICollectionSectionModel *sectionModel = [[self sectionModels] firstObject];
    if (sectionModel) {
        [sectionModel insertCellModelsToTop:cellModels];
    }
}
- (void)removeCellModel:(LUICollectionCellModel *)cellModel {
    for (LUICollectionSectionModel *section in [self sectionModels]) {
        [section removeCellModel:cellModel];
    }
}
- (void)removeCellModels:(NSArray<LUICollectionCellModel *> *)cellModels{
    for (LUICollectionCellModel *cellModel in cellModels) {
        [self removeCellModel:cellModel];
    }
}
- (void)removeCellModelAtIndexPath:(NSIndexPath *)indexPath {
    LUICollectionSectionModel *sectionModel = [self sectionModelAtIndex:indexPath.section];
    [sectionModel removeCellModelAtIndex:indexPath.row];
}
- (void)removeCellModelsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths{
    if (indexPaths.count == 0)return;
    NSMutableDictionary *sectionMap = [[NSMutableDictionary alloc] init];
    for (NSIndexPath *p in indexPaths) {
        NSInteger section = p.section;
        NSMutableArray<NSIndexPath *> *paths = sectionMap[@(section)];
        if (!paths) {
            paths = [[NSMutableArray alloc] initWithObjects:p, nil];
            sectionMap[@(section)] = paths;
        }
        [paths addObject:p];
    }
    for (NSNumber *sectionNum in sectionMap) {
        NSArray<NSIndexPath *> *subIndexPaths = sectionMap[sectionNum];
        NSMutableIndexSet *indexset = [[NSMutableIndexSet alloc] init];
        for (NSIndexPath *indexpath in subIndexPaths) {
            [indexset addIndex:indexpath.row];
        }
        LUICollectionSectionModel *sectionModel = [self sectionModelAtIndex:[sectionNum integerValue]];
        [sectionModel removeCellModelsAtIndexes:indexset];
    }
}
- (void)addSectionModel:(LUICollectionSectionModel *)sectionModel {
    if (!sectionModel)return;
    sectionModel.collectionModel = self;
    [[self mutableSectionModels] addObject:sectionModel];
}
- (void)insertSectionModel:(LUICollectionSectionModel *)sectionModel atIndex:(NSInteger)index {
    if (!sectionModel)return;
    sectionModel.collectionModel = self;
    [[self mutableSectionModels] insertObject:sectionModel atIndex:index];
}
- (void)addSectionModels:(NSArray<LUICollectionSectionModel *> *)sectionModels{
    for (LUICollectionSectionModel *sectionModel in sectionModels) {
        [self addSectionModel:sectionModel];
    }
}
- (void)removeSectionModel:(LUICollectionSectionModel *)sectionModel {
    sectionModel.collectionModel = nil;
    [[self mutableSectionModels] removeObject:sectionModel];
}
- (void)removeSectionModelAtIndex:(NSInteger)index {
    if (index>=0&&index<[self mutableSectionModels].count) {
        [[self mutableSectionModels] removeObjectAtIndex:index];
    }
}
- (void)removeSectionModelsInRange:(NSRange)range{
    [[self mutableSectionModels] removeObjectsInRange:range];
}
- (void)removeAllSectionModels{
    [[self mutableSectionModels] removeAllObjects];
}
- (NSIndexPath *)indexPathOfCellModel:(LUICollectionCellModel *)cellModel {
    __block NSIndexPath *indexpath = nil;
    [[self sectionModels] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        LUICollectionSectionModel *section = obj;
        NSInteger row = [section indexOfCellModel:cellModel];
        if (row != NSNotFound) {
            indexpath = [NSIndexPath indexPathForRow:row inSection:idx];
            *stop = YES;
        }
    }];
    return indexpath;
}
- (void)enumerateCellModelsUsingBlock:(void(^)(id cellModel,NSIndexPath *indexpath,BOOL *stop))block{
    if (!block)return;
    NSInteger sectionIndex = 0;
    BOOL stop = NO;
    for (LUICollectionSectionModel *sm in self.sectionModels) {
        NSInteger itemIndex = 0;
        for (LUICollectionCellModel *cellModel in sm.cellModels) {
            NSIndexPath *indexpath = [NSIndexPath indexPathForItem:itemIndex inSection:sectionIndex];
            block(cellModel,indexpath,&stop);
            if (stop) {
                return;
            }
            itemIndex++;
        }
        sectionIndex++;
    }
}
- (NSIndexPath *)indexPathOfCellModelPassingTest:(BOOL(^)(id cellModel,NSIndexPath *indexpath,BOOL *stop))block{
    if (!block)return nil;
    __block NSIndexPath *result;
    [self enumerateCellModelsUsingBlock:^(id cellModel, NSIndexPath *indexpath, BOOL *stop) {
        BOOL s = block(cellModel,indexpath,stop);
        if (s) {
            result = indexpath;
            *stop = YES;
        }
    }];
    return result;
}
- (NSArray<NSIndexPath *> *)indexPathsOfCellModelPassingTest:(BOOL(^)(id cellModel,NSIndexPath *indexpath,BOOL *stop))block{
    NSMutableArray<NSIndexPath *> *indexpaths = [[NSMutableArray alloc] init];
    [self enumerateCellModelsUsingBlock:^(id cellModel, NSIndexPath *indexpath, BOOL *stop) {
        BOOL s = block(cellModel,indexpath,stop);
        if (s) {
            [indexpaths addObject:indexpath];
        }
    }];
    return indexpaths;
}
- (NSArray<NSIndexPath *> *)indexPathsOfCellModels:(NSArray<LUICollectionCellModel *> *)cellModels{
    NSMutableArray<NSIndexPath *> *indexPaths = [[NSMutableArray alloc] initWithCapacity:cellModels.count];
    for (LUICollectionCellModel *cellModel in cellModels) {
        NSIndexPath *indexPath = [self indexPathOfCellModel:cellModel];
        if (indexPath) {
            [indexPaths addObject:indexPath];
        }
    }
    return indexPaths;
}
- (NSInteger)indexOfSectionModel:(LUICollectionSectionModel *)sectionModel {
    NSInteger index = [[self sectionModels] indexOfObject:sectionModel];
    return index;
}
- (NSIndexSet *)indexSetOfSectionModel:(LUICollectionSectionModel *)sectionModel {
    NSInteger index = [[self sectionModels] indexOfObject:sectionModel];
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:index];
    return indexSet;
}
- (LUICollectionCellModel *)cellModelAtIndexPath:(NSIndexPath *)indexpath {
    if (!indexpath)return nil;
    LUICollectionSectionModel *section = [self sectionModelAtIndex:indexpath.section];
    LUICollectionCellModel *cell = [section cellModelAtIndex:indexpath.row];
    return cell;
}
- (NSArray<__kindof LUICollectionCellModel *> *)cellModelsAtIndexPaths:(NSArray<NSIndexPath *> *)indexpaths{
    NSMutableArray<LUICollectionCellModel *> *cellModels = [[NSMutableArray alloc] init];
    for (NSIndexPath *indexpath in indexpaths) {
        id cm = [self cellModelAtIndexPath:indexpath];
        if (cm) {
            [cellModels addObject:cm];
        }
    }
    return cellModels;
}
- (LUICollectionSectionModel *)sectionModelAtIndex:(NSInteger)index {
    LUICollectionSectionModel *sectionModel;
    if (index>=0&&index<[self sectionModels].count) {
        sectionModel = [[self sectionModels] objectAtIndex:index];
    }
    return sectionModel;
}
- (void)removeEmptySectionModels{
    NSArray<LUICollectionSectionModel *> *sectionModels = [self emptySectionModels];
    [[self mutableSectionModels] removeObjectsInArray:sectionModels];
}
- (NSArray<__kindof LUICollectionSectionModel *> *)emptySectionModels{
    NSMutableArray<LUICollectionSectionModel *> *sectionModels = [[NSMutableArray alloc] init];
    for (LUICollectionSectionModel *sm in [self sectionModels]) {
        if (sm.numberOfCells == 0) {
            [sectionModels addObject:sm];
        }
    }
    return sectionModels;
}
- (void)moveCellModelAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (sourceIndexPath == nil||destinationIndexPath == nil)return;
    LUICollectionCellModel *sourceCellModel = [self cellModelAtIndexPath:sourceIndexPath];
    [self removeCellModelAtIndexPath:sourceIndexPath];
    [self insertCellModel:sourceCellModel atIndexPath:destinationIndexPath];
}

- (void)selectCellModelAtIndexPath:(NSIndexPath *)indexPath {
    LUICollectionCellModel *cellModel = [self cellModelAtIndexPath:indexPath];
    [self selectCellModel:cellModel];
}
- (void)selectCellModelsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths{
    NSArray<LUICollectionCellModel *> *cellModels = [self cellModelsAtIndexPaths:indexPaths];
    [self selectCellModels:cellModels];
}
- (void)selectCellModel:(LUICollectionCellModel *)cellModel {
    if (self.allowsSelection) {
        if (!self.allowsMultipleSelection) {
            NSArray<LUICollectionCellModel *> *allCells = [self allCellModels];
            for (LUICollectionCellModel *cm in allCells) {
                if (![cm isEqual:cellModel]) {
                    cm.selected = NO;
                }
            }
        }
        cellModel.selected = YES;
    }
}
- (void)selectCellModels:(NSArray<LUICollectionCellModel *> *)cellModels{
    if (self.allowsSelection) {
        if (self.allowsMultipleSelection) {
            for (LUICollectionCellModel *cellModel in cellModels) {
                cellModel.selected = YES;
            }
        }
    }
}
- (void)selectAllCellModels{
    [self selectCellModels:[self allCellModels]];
}
- (void)deselectCellModelAtIndexPath:(NSIndexPath *)indexPath {
    LUICollectionCellModel *cellModel = [self cellModelAtIndexPath:indexPath];
    [self deselectCellModel:cellModel];
}
- (void)deselectCellModel:(LUICollectionCellModel *)cellModel {
    cellModel.selected = NO;
}
- (void)deselectCellModels:(NSArray<LUICollectionCellModel *> *)cellModels{
    for (LUICollectionCellModel *cellModel in cellModels) {
        [self deselectCellModel:cellModel];
    }
}
- (void)deselectAllCellModels{
    [self deselectCellModels:[self allCellModels]];
}
- (NSIndexPath *)indexPathForSelectedCellModel {
    for (int i=0;i<[self sectionModels].count;i++) {
        LUICollectionSectionModel *sm = [self sectionModels][i];
        NSArray<LUICollectionCellModel *> *cellModels = sm.cellModels;
        for (int j=0; j<cellModels.count; j++) {
            LUICollectionCellModel *cm = cellModels[j];
            if (cm.selected) {
                NSIndexPath *indexpath = [NSIndexPath indexPathForItem:j inSection:i];
                return indexpath;
            }
        }
    }
    return nil;
}
- (__kindof LUICollectionCellModel *)cellModelForSelectedCellModel {
    for (LUICollectionSectionModel *sm in [self sectionModels]) {
        NSArray<LUICollectionCellModel *> *cellModels = sm.cellModels;
        for (LUICollectionCellModel *cm in cellModels) {
            if (cm.selected) {
                return cm;
            }
        }
    }
    return nil;
}
- (NSArray<NSIndexPath *> *)indexPathsForSelectedCellModels{
    NSMutableArray<NSIndexPath *> *indexpaths = [[NSMutableArray alloc] init];
    for (int i=0;i<[self sectionModels].count;i++) {
        LUICollectionSectionModel *sm = [self sectionModels][i];
        NSArray<LUICollectionCellModel *> *cellModels = sm.cellModels;
        for (int j=0; j<cellModels.count; j++) {
            LUICollectionCellModel *cm = cellModels[j];
            if (cm.selected) {
                NSIndexPath *indexpath = [NSIndexPath indexPathForItem:j inSection:i];
                [indexpaths addObject:indexpath];
            }
        }
    }
    return indexpaths;
}
- (NSArray<__kindof LUICollectionCellModel *> *)cellModelsForSelectedCellModels{
    NSMutableArray<LUICollectionCellModel *> *cellModels = [[NSMutableArray alloc] init];
    for (LUICollectionSectionModel *sm in [self sectionModels]) {
        NSArray<LUICollectionCellModel *> *cms = sm.cellModels;
        for (LUICollectionCellModel *cm in cms) {
            if (cm.selected) {
                [cellModels addObject:cm];
            }
        }
    }
    return cellModels;
}
@end
@implementation LUICollectionModel(Focused)
- (NSIndexPath *)indexPathForFocusedCellModel {
    for (int i=0;i<[self sectionModels].count;i++) {
        LUICollectionSectionModel *sm = [self sectionModels][i];
        NSArray<LUICollectionCellModel *> *cellModels = sm.cellModels;
        for (int j=0; j<cellModels.count; j++) {
            LUICollectionCellModel *cm = cellModels[j];
            if (cm.focused) {
                NSIndexPath *indexpath = [NSIndexPath indexPathForItem:j inSection:i];
                return indexpath;
            }
        }
    }
    return nil;
}
- (__kindof LUICollectionCellModel *)cellModelForFocusedCellModel {
    for (LUICollectionSectionModel *sm in [self sectionModels]) {
        NSArray<LUICollectionCellModel *> *cellModels = sm.cellModels;
        for (LUICollectionCellModel *cm in cellModels) {
            if (cm.focused) {
                return cm;
            }
        }
    }
    return nil;
}
- (void)focusCellModelAtIndexPath:(NSIndexPath *)indexpath focused:(BOOL)focused {
    if (!self.allowsFocus) {
        return;
    }
    LUICollectionCellModel *cellModel = [self cellModelAtIndexPath:indexpath];
    [self focusCellModel:cellModel focused:focused];
}
- (void)focusCellModel:(LUICollectionCellModel *)cellModel focused:(BOOL)focused {
    if (!self.allowsFocus) {
        return;
    }
    if (focused) {
        LUICollectionCellModel *oldCellModel = self.cellModelForFocusedCellModel;
        oldCellModel.focused = NO;
    }
    cellModel.focused = focused;
}
- (void)focusNone{
    if (!self.allowsFocus) {
        return;
    }
    LUICollectionCellModel *oldCellModel = self.cellModelForFocusedCellModel;
    oldCellModel.focused = NO;
}
@end
