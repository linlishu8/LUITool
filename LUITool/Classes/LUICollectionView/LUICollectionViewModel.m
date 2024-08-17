//
//  LUICollectionViewModel.m
//  LUITool
//
//  Created by 六月 on 2024/8/15.
//

#import "LUICollectionViewModel.h"
#import <objc/runtime.h>

@implementation LUICollectionViewModel
- (void)dealloc{
    
}
- (id)init{
    if (self = [super init]) {
        self.reuseCell = YES;
    }
    return self;
}
- (id)copyWithZone:(NSZone *)zone{
    LUICollectionViewModel *obj = [self.class allocWithZone:zone];
    obj.forwardDataSource = self.forwardDataSource;
    obj.forwardDelegate = self.forwardDelegate;
    obj.editting = self.isEditting;
    obj.collectionView = self.collectionView;
    obj.emptyBackgroundViewClass = self.emptyBackgroundViewClass;
    obj.emptyBackgroundView = self.emptyBackgroundView;
    obj.whenReloadBackgroundView = [self.whenReloadBackgroundView copy];
    obj.reuseCell = self.reuseCell;
    return obj;
}
- (id)initWithCollectionView:(UICollectionView *)collectionView {
    if (self=[self init]) {
        [self setCollectionViewDataSourceAndDelegate:collectionView];
    }
    return self;
}
- (LUICollectionSectionModel *)createEmptySectionModel {
    LUICollectionViewSectionModel *section = [[LUICollectionViewSectionModel alloc] init];
    return section;
}
- (void)addCellModel:(LUICollectionCellModel *)cellModel {
    if (!cellModel)return;
    LUICollectionViewSectionModel *section = (LUICollectionViewSectionModel *)[self.sectionModels lastObject];
    if (!section) {
        section = (LUICollectionViewSectionModel *)[self createEmptySectionModel];
        [self addSectionModel:section];
    }
    [section addCellModel:cellModel];
}
- (__kindof LUICollectionViewCellModel *)cellModelAtIndexPath:(NSIndexPath *)indexpath {
    return (LUICollectionViewCellModel *)[super cellModelAtIndexPath:indexpath];
}
- (__kindof LUICollectionViewSectionModel *)sectionModelAtIndex:(NSInteger)index {
    return (LUICollectionViewSectionModel *)[super sectionModelAtIndex:index];
}
- (__kindof LUICollectionViewCellModel *)cellModelForSelectedCellModel {
    return (LUICollectionViewCellModel *)[super cellModelForSelectedCellModel];
}
- (void)setCollectionViewDataSourceAndDelegate:(UICollectionView *)collectionView {
    self.collectionView = collectionView;
    collectionView.dataSource = self;
    collectionView.delegate = self;
}
- (void)setForwardDelegate:(id<UICollectionViewDelegate>)forwardDelegate{
    _forwardDelegate = forwardDelegate;
    if (self.collectionView.delegate == self) {
        self.collectionView.delegate = nil;
        self.collectionView.delegate = self;//重新赋值一次,使得scrollview重新判断scrollViewDidScroll:方法的有无
    }
}
- (void)reloadCollectionViewData{
    [self.collectionView reloadData];//reloadData时,collectionView会清掉旧的单元格选中状态
    for (LUICollectionViewSectionModel *sm in self.sectionModels) {
        for (LUICollectionViewCellModel *cm in sm.cellModels) {
            cm.needReloadCell = YES;
        }
    }
    if (self.allowsSelection) {
        if (self.allowsMultipleSelection) {
            NSArray *indexpaths = [self indexPathsForSelectedCellModels];
            for (NSIndexPath *indexpath in indexpaths) {
                [self.collectionView selectItemAtIndexPath:indexpath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
            }
        } else {
            NSIndexPath *indexpath = [self indexPathForSelectedCellModel];
            [self.collectionView selectItemAtIndexPath:indexpath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        }
    }
    [self reloadCollectionViewBackgroundView];
}
- (void)addCellModel:(LUICollectionViewCellModel *)cellModel animated:(BOOL)animated completion:(void (^)(BOOL finished))completion{
    if (!cellModel)return;
    cellModel.needReloadCell = YES;
    UICollectionView *collectionView = self.collectionView;
    [self addCellModel:cellModel];
    if (animated&&collectionView) {
        LUICollectionSectionModel *sm = (LUICollectionSectionModel *)[self.sectionModels lastObject];
        NSIndexPath *indexpath = [NSIndexPath indexPathForItem:[sm numberOfCells]-1 inSection:self.sectionModels.count-1];
        [collectionView performBatchUpdates:^{
            if ([collectionView numberOfSections] == 0) {//添加section
                [collectionView insertSections:[NSIndexSet indexSetWithIndex:0]];
            }
            [collectionView insertItemsAtIndexPaths:@[indexpath]];
        } completion:^(BOOL finished) {
            [self reloadCollectionViewBackgroundView];
            if (completion) {
                completion(finished);
            }
        }];
    } else {
        [self reloadCollectionViewData];
        if (completion) {
            completion(YES);
        }
    }
}
- (void)insertCellModel:(LUICollectionViewCellModel *)cellModel atIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated completion:(void (^)(BOOL finished))completion{
    if (!cellModel)return;
    cellModel.needReloadCell = YES;
    UICollectionView *collectionView = self.collectionView;
    [self insertCellModel:cellModel atIndexPath:indexPath];
    if (animated&&collectionView) {
//        LUICollectionSectionModel *sm = (LUICollectionSectionModel *)[self.sectionModels lastObject];
//        NSIndexPath *indexpath = [NSIndexPath indexPathForItem:[sm numberOfCells]-1 inSection:self.sectionModels.count-1];
        [collectionView performBatchUpdates:^{
            if ([collectionView numberOfSections] == 0) {//添加section
                [collectionView insertSections:[NSIndexSet indexSetWithIndex:0]];
            }
            [collectionView insertItemsAtIndexPaths:@[indexPath]];
        } completion:^(BOOL finished) {
            [self reloadCollectionViewBackgroundView];
            if (completion) {
                completion(finished);
            }
        }];
    } else {
        [self reloadCollectionViewData];
        if (completion) {
            completion(YES);
        }
    }
}
- (void)insertCellModels:(NSArray<LUICollectionViewCellModel *> *)cellModels afterIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated completion:(void (^)(BOOL finished))completion{
    if (!cellModels.count)return;
    for (LUICollectionViewCellModel *cm in cellModels) {
        cm.needReloadCell = YES;
    }
    UICollectionView *collectionView = self.collectionView;
    [self insertCellModels:cellModels afterIndexPath:indexPath];
    if (animated&&collectionView) {
//        LUICollectionSectionModel *sm = (LUICollectionSectionModel *)[self.sectionModels lastObject];
//        NSIndexPath *indexpath = [NSIndexPath indexPathForItem:[sm numberOfCells]-1 inSection:self.sectionModels.count-1];
        [collectionView performBatchUpdates:^{
            if ([collectionView numberOfSections] == 0) {//添加section
                [collectionView insertSections:[NSIndexSet indexSetWithIndex:0]];
            }
            NSMutableArray<NSIndexPath *> *indexPathes = [[NSMutableArray alloc] init];
            for (int i=0; i<cellModels.count; i++) {
                NSIndexPath *ip = [NSIndexPath indexPathForItem:indexPath.item+i+1 inSection:indexPath.section];
                [indexPathes addObject:ip];
            }
            [collectionView insertItemsAtIndexPaths:indexPathes];
        } completion:^(BOOL finished) {
            [self reloadCollectionViewBackgroundView];
            if (completion) {
                completion(finished);
            }
        }];
    } else {
        [self reloadCollectionViewData];
        if (completion) {
            completion(YES);
        }
    }
}
- (void)insertCellModels:(NSArray<LUICollectionViewCellModel *> *)cellModels beforeIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated completion:(void (^)(BOOL finished))completion{
    if (!cellModels.count)return;
    for (LUICollectionViewCellModel *cm in cellModels) {
        cm.needReloadCell = YES;
    }
    UICollectionView *collectionView = self.collectionView;
    [self insertCellModels:cellModels beforeIndexPath:indexPath];
    if (animated&&collectionView) {
//        LUICollectionSectionModel *sm = (LUICollectionSectionModel *)[self.sectionModels lastObject];
//        NSIndexPath *indexpath = [NSIndexPath indexPathForItem:[sm numberOfCells]-1 inSection:self.sectionModels.count-1];
        [collectionView performBatchUpdates:^{
            if ([collectionView numberOfSections] == 0) {//添加section
                [collectionView insertSections:[NSIndexSet indexSetWithIndex:0]];
            }
            NSMutableArray<NSIndexPath *> *indexPathes = [[NSMutableArray alloc] init];
            for (int i=0; i<cellModels.count; i++) {
                NSIndexPath *ip = [NSIndexPath indexPathForItem:indexPath.item+i inSection:indexPath.section];
                [indexPathes addObject:ip];
            }
            [collectionView insertItemsAtIndexPaths:indexPathes];
        } completion:^(BOOL finished) {
            [self reloadCollectionViewBackgroundView];
            if (completion) {
                completion(finished);
            }
        }];
    } else {
        [self reloadCollectionViewData];
        if (completion) {
            completion(YES);
        }
    }
}
- (void)removeCellModel:(LUICollectionViewCellModel *)cellModel animated:(BOOL)animated completion:(void (^)(BOOL finished))completion{
    if (!cellModel)return;
    NSIndexPath *indexpath = [self indexPathOfCellModel:cellModel];
    if (indexpath) {
        LUICollectionViewSectionModel *sm = (LUICollectionViewSectionModel *)[self sectionModelAtIndex:indexpath.section];
        [self removeCellModelAtIndexPath:indexpath];
        if (sm.numberOfCells == 0) {
            [self removeSectionModelAtIndex:indexpath.section];
        }
        UICollectionView *collectionView = self.collectionView;
        if (animated&&collectionView) {
            UICollectionView *collectionView = self.collectionView;
            [collectionView performBatchUpdates:^{
                if (sm.numberOfCells == 0) {
                    [collectionView deleteSections:[NSIndexSet indexSetWithIndex:indexpath.section]];
                }
                [collectionView deleteItemsAtIndexPaths:@[indexpath]];
            } completion:^(BOOL finished) {
                [self reloadCollectionViewBackgroundView];
                if (completion) {
                    completion(finished);
                }
            }];
        } else {
            [self reloadCollectionViewData];
            if (completion) {
                completion(YES);
            }
        }
    }
}
- (void)removeCellModels:(NSArray<LUICollectionViewCellModel *> *)cellModels animated:(BOOL)animated completion:(void (^)(BOOL finished))completion{
    if (cellModels.count == 0)return;
    NSArray<NSIndexPath *> *indexpaths = [self indexPathsOfCellModels:cellModels];
    if (indexpaths.count) {
        NSMutableIndexSet *deletedSectionIndexs = [[NSMutableIndexSet alloc] init];
        for (LUICollectionCellModel *cm in cellModels) {
            LUICollectionViewSectionModel *sm = (LUICollectionViewSectionModel *)cm.sectionModel;
            [sm removeCellModel:cm];
            if (sm.numberOfCells == 0) {
                [deletedSectionIndexs addIndex:sm.indexInModel];
                [self removeSectionModel:sm];
            }
        }
        UICollectionView *collectionView = self.collectionView;
        if (animated&&collectionView) {
            UICollectionView *collectionView = self.collectionView;
            [collectionView performBatchUpdates:^{
                if (deletedSectionIndexs.count!=0) {
                    [collectionView deleteSections:deletedSectionIndexs];
                }
                [collectionView deleteItemsAtIndexPaths:indexpaths];
            } completion:^(BOOL finished) {
                [self reloadCollectionViewBackgroundView];
                if (completion) {
                    completion(finished);
                }
            }];
        } else {
            [self reloadCollectionViewData];
            if (completion) {
                completion(YES);
            }
        }
    }
}
- (void)moveCellModelAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath inCollectionViewBatchUpdatesBlock:(BOOL)isBatchUpdates{
    if ([sourceIndexPath isEqual:destinationIndexPath])return;
    NSMutableArray<NSIndexPath *> *addedIndexPathes = [[NSMutableArray alloc] init];
    NSMutableArray<NSIndexPath *> *removeIndexPathes = [[NSMutableArray alloc] init];
    LUICollectionCellModel *sourceCellModel = [self cellModelAtIndexPath:sourceIndexPath];
    [self removeCellModelAtIndexPath:sourceIndexPath];
    [self insertCellModel:sourceCellModel atIndexPath:destinationIndexPath];
    [addedIndexPathes addObject:destinationIndexPath];
    [removeIndexPathes addObject:sourceIndexPath];
    if (isBatchUpdates) {
        UICollectionView *collectionView = self.collectionView;
        [collectionView deleteItemsAtIndexPaths:removeIndexPathes];
        [collectionView insertItemsAtIndexPaths:addedIndexPathes];
    }
}
- (void)insertSectionModel:(LUICollectionViewSectionModel *)sectionModel atIndex:(NSInteger)index animated:(BOOL)animated completion:(void (^)(BOOL finished))completion{
    if (!sectionModel)return;
    [self insertSectionModel:sectionModel atIndex:index];
    
    for (LUICollectionViewCellModel *cm in sectionModel.cellModels) {
        cm.needReloadCell = YES;
    }
    UICollectionView *collectionView = self.collectionView;
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:index];
    NSInteger count = sectionModel.numberOfCells;
    NSMutableArray<NSIndexPath *> *indexpaths = [[NSMutableArray alloc] initWithCapacity:count];
    for (int i=0; i<count; i++) {
        NSIndexPath *indexpath = [NSIndexPath indexPathForItem:i inSection:index];
        [indexpaths addObject:indexpath];
    }
    if (animated&&collectionView) {
        [collectionView performBatchUpdates:^{
            [collectionView insertSections:set];
            [collectionView insertItemsAtIndexPaths:indexpaths];
        } completion:^(BOOL finished) {
            [self reloadCollectionViewBackgroundView];
            if (completion) {
                completion(finished);
            }
        }];
    } else {
        [self reloadCollectionViewData];
        if (completion) {
            completion(YES);
        }
    }
}
- (void)removeSectionModel:(LUICollectionViewSectionModel *)sectionModel animated:(BOOL)animated completion:(void (^)(BOOL finished))completion{
    if (!sectionModel)return;
    NSInteger index = sectionModel.indexInModel;
    UICollectionView *collectionView = self.collectionView;
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:index];
    [self removeSectionModel:sectionModel];
    if (animated&&collectionView) {
        [collectionView performBatchUpdates:^{
            [collectionView deleteSections:set];
        } completion:^(BOOL finished) {
            [self reloadCollectionViewBackgroundView];
            if (completion) {
                completion(finished);
            }
        }];
    } else {
        [self reloadCollectionViewData];
        if (completion) {
            completion(YES);
        }
    }
}
#pragma mark - empty background
- (UIView *)createEmptyBackgroundView {
    Class c = self.emptyBackgroundViewClass;
    UIView *view;
    if (c) {
        view = [[c alloc] init];
    }
    return view;
}
- (void)reloadCollectionViewBackgroundView {
    if (!self.emptyBackgroundViewClass&&!self.emptyBackgroundView)return;
    if (self.numberOfCells == 0) {
        if (!self.emptyBackgroundView) {
            self.emptyBackgroundView = [self createEmptyBackgroundView];
        }
        self.collectionView.backgroundView = self.emptyBackgroundView;
    } else {
        self.collectionView.backgroundView = nil;
    }
    if (self.whenReloadBackgroundView) {
        self.whenReloadBackgroundView(self);
    }
}
#pragma mark - delegate:UICollectionViewDataSource,UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    self.collectionView = collectionView;
    LUICollectionViewSectionModel *sm = [self sectionModelAtIndex:section];
    NSInteger number = [sm numberOfCells];
    return number;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LUICollectionViewCellModel *cm = (LUICollectionViewCellModel *)[self cellModelAtIndexPath:indexPath];
    
    Class cellClass = cm.cellClass;
    NSString *reuseIdentity = self.reuseCell?cm.reuseIdentity:[NSString stringWithFormat:@"%@_%p",cm.reuseIdentity,cm];
    [collectionView registerClass:cellClass forCellWithReuseIdentifier:reuseIdentity];
    UICollectionViewCell<LUICollectionViewCellProtocol> *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentity forIndexPath:indexPath];
    [cm displayCell:cell];
    return cell;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSInteger number = [self numberOfSections];
    return number;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    LUICollectionViewSectionModel *sm = (LUICollectionViewSectionModel *)[self sectionModelAtIndex:indexPath.section];
    Class aClass = [sm supplementaryElementViewClassForKind:kind];
    if (!aClass) {
        return [UICollectionReusableView new];
    }
    [collectionView registerClass:aClass forSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass(aClass)];
    UICollectionReusableView<LUICollectionViewSupplementaryElementProtocol> *view = (UICollectionReusableView<LUICollectionViewSupplementaryElementProtocol> *)[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass(aClass) forIndexPath:indexPath];
    [sm displaySupplementaryElementView:view forKind:kind];
    return view;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(9_0) {
    BOOL move = NO;
    LUICollectionViewCellModel *cellModel = (LUICollectionViewCellModel *)[self cellModelAtIndexPath:indexPath];
    move = cellModel.canMove;
    return move;
}
- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath*)destinationIndexPath NS_AVAILABLE_IOS(9_0) {
    LUICollectionViewCellModel *srcTablecellModel = (LUICollectionViewCellModel *)[self cellModelAtIndexPath:sourceIndexPath];
    LUICollectionViewCellModel *dstTablecellModel = (LUICollectionViewCellModel *)[self cellModelAtIndexPath:destinationIndexPath];
    BOOL handed = NO;
    LUICollectionViewCellModelBlockM handler = srcTablecellModel.whenMove?:dstTablecellModel.whenMove;
    if (handler) {
        handler(srcTablecellModel,dstTablecellModel);
        handed = YES;
    }
    if ([self.forwardDataSource respondsToSelector:_cmd]) {
        [self.forwardDataSource collectionView:collectionView moveItemAtIndexPath:destinationIndexPath toIndexPath:destinationIndexPath];
        handed = YES;
    }
    if (!handed) {
        [self moveCellModelAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
    }
}
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    if ([self.forwardDelegate respondsToSelector:_cmd]) {
//        return [self.forwardDelegate collectionView:collectionView shouldSelectItemAtIndexPath:indexPath];
//    }
//    LUICollectionViewCellModel *cm = [self cellModelAtIndexPath:indexPath];
//    if (cm.selected) {
//        return NO;
//    } else {
//        return YES;
//    }
//}
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
//    if ([self.forwardDelegate respondsToSelector:_cmd]) {
//        return [self.forwardDelegate collectionView:collectionView shouldDeselectItemAtIndexPath:indexPath];
//    }
//    LUICollectionViewCellModel *cm = [self cellModelAtIndexPath:indexPath];
//    if (cm.selected) {
//        return YES;
//    } else {
//        return NO;
//    }
//}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if (cell
       &&[cell conformsToProtocol:@protocol(LUICollectionViewCellProtocol)]
       &&[cell respondsToSelector:@selector(collectionView:didSelectCell:)]
       ) {
        [(UICollectionViewCell<LUICollectionViewCellProtocol> *)cell collectionView:collectionView didSelectCell:YES];
    }
    LUICollectionViewCellModel *cm = [self cellModelAtIndexPath:indexPath];
    [self selectCellModel:cm];
    if (cm.whenSelected) {
        cm.whenSelected(cm,YES);
    }
    if (cm.whenClick) {
        cm.whenClick(cm);
    }
    if ([self.forwardDelegate respondsToSelector:_cmd]) {
        [self.forwardDelegate collectionView:collectionView didSelectItemAtIndexPath:indexPath];
    }
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if (cell
       &&[cell conformsToProtocol:@protocol(LUICollectionViewCellProtocol)]
       &&[cell respondsToSelector:@selector(collectionView:didSelectCell:)]
       ) {
        [(UICollectionViewCell<LUICollectionViewCellProtocol> *)cell collectionView:collectionView didSelectCell:NO];
    }
    LUICollectionViewCellModel *cm = [self cellModelAtIndexPath:indexPath];
    [self deselectCellModel:cm];
    if (cm.whenSelected) {
        cm.whenSelected(cm,NO);
    }
    if (collectionView.allowsMultipleSelection) {//多选时,deselect代表选中行被点击了
        if (cm.whenClick) {
            cm.whenClick(cm);
        }
    }
    if ([self.forwardDelegate respondsToSelector:_cmd]) {
        [self.forwardDelegate collectionView:collectionView didDeselectItemAtIndexPath:indexPath];
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(8.0)) {
    if ([cell conformsToProtocol:@protocol(LUICollectionViewCellProtocol)] && [cell respondsToSelector:@selector(collectionView:willDisplayCellModel:)]) {
        LUICollectionViewCellModel *cm = [self cellModelAtIndexPath:indexPath];
        [(UICollectionViewCell<LUICollectionViewCellProtocol> *)cell collectionView:collectionView willDisplayCellModel:cm];
    }
    if ([self.forwardDelegate respondsToSelector:_cmd]) {
        [self.forwardDelegate collectionView:collectionView willDisplayCell:cell forItemAtIndexPath:indexPath];
    }
}
- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(8.0)) {
    if ([view conformsToProtocol:@protocol(LUICollectionViewSupplementaryElementProtocol)] && [view respondsToSelector:@selector(collectionView:willDisplaySectionModel:kind:)]) {
        LUICollectionViewSectionModel *sm = [self sectionModelAtIndex:indexPath.section];
        [(UICollectionReusableView<LUICollectionViewSupplementaryElementProtocol> *)view collectionView:collectionView willDisplaySectionModel:sm kind:elementKind];
    }
    if ([self.forwardDelegate respondsToSelector:_cmd]) {
        [self.forwardDelegate collectionView:collectionView willDisplaySupplementaryView:view forElementKind:elementKind atIndexPath:indexPath];
    }
}
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell conformsToProtocol:@protocol(LUICollectionViewCellProtocol)] && [cell respondsToSelector:@selector(collectionView:didEndDisplayingCellModel:)]) {
        LUICollectionViewCellModel *cm = [self cellModelAtIndexPath:indexPath];
        [(UICollectionViewCell<LUICollectionViewCellProtocol> *)cell collectionView:collectionView didEndDisplayingCellModel:cm];
    }
    if ([self.forwardDelegate respondsToSelector:_cmd]) {
        [self.forwardDelegate collectionView:collectionView didEndDisplayingCell:cell forItemAtIndexPath:indexPath];
    }
}
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    if ([view conformsToProtocol:@protocol(LUICollectionViewSupplementaryElementProtocol)] && [view respondsToSelector:@selector(collectionView:didEndDisplayingSectionModel:kind:)]) {
        LUICollectionViewSectionModel *sm = [self sectionModelAtIndex:indexPath.section];
        [(UICollectionReusableView<LUICollectionViewSupplementaryElementProtocol> *)view collectionView:collectionView didEndDisplayingSectionModel:sm kind:elementKind];
    }
    if ([self.forwardDelegate respondsToSelector:_cmd]) {
        [self.forwardDelegate collectionView:collectionView didEndDisplayingSupplementaryView:view forElementOfKind:elementKind atIndexPath:indexPath];
    }
}

#pragma mark - Forward Invocations
/**
 *根據指定的Selector返回該類支持的方法簽名,一般用於prototol或者消息轉發forwardInvocation:中NSInvocation參數的methodSignature屬性
 注:系統調用- (void)forwardInvocation:(NSInvocation *)invocation方法前,會先調用此方法獲取NSMethodSignature,然後生成方法所需要的NSInvocation
 */
- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    NSMethodSignature *signature = [super methodSignatureForSelector:selector];
    if (signature  ==  nil) {
        id delegate = self.forwardDelegate;
        if ([delegate respondsToSelector:selector]) {
            signature = [delegate methodSignatureForSelector:selector];
        } else {
            delegate = self.forwardDataSource;
            if ([delegate respondsToSelector:selector]) {
                signature = [delegate methodSignatureForSelector:selector];
            }
        }
    }
    return signature;
}
- (BOOL)respondsToSelector:(SEL)selector {
    if ([super respondsToSelector:selector]) {
        return YES;
    } else {
        if ([self.forwardDelegate respondsToSelector:selector]) {
            return YES;
        }else if ([self.forwardDataSource respondsToSelector:selector]) {
            return YES;
        }
    }
    return NO;
}
- (BOOL)conformsToProtocol:(Protocol *)aProtocol{
    BOOL conforms = NO;
    if ([super conformsToProtocol:aProtocol]) {
        conforms = YES;
    } else {
        if ([self.forwardDelegate conformsToProtocol:aProtocol]) {
            conforms = YES;
        }else if ([self.forwardDataSource conformsToProtocol:aProtocol]) {
            conforms = YES;
        }
    }
    return conforms;
}
/**
 *對調用未定義的方法進行消息重定向
 */
- (void)forwardInvocation:(NSInvocation *)invocation {
    BOOL didForward = NO;
    id delegate = self.forwardDelegate;
    if ([delegate respondsToSelector:invocation.selector]) {
        [invocation invokeWithTarget:delegate];
        didForward = YES;
    }
    if (!didForward) {
        delegate = self.forwardDataSource;
        if ([delegate respondsToSelector:invocation.selector]) {
            [invocation invokeWithTarget:delegate];
            didForward = YES;
        }
    }
    if (!didForward) {
        [super forwardInvocation:invocation];
    }
}
- (void)doesNotRecognizeSelector:(SEL)aSelector{
    [super doesNotRecognizeSelector:aSelector];
}
@end
