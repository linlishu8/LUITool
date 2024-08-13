//
//  LUITableViewModel.m
//  LUITool
//
//  Created by 六月 on 2023/8/11.
//

#import "LUITableViewModel.h"
#import "UIScrollView+LUI.h"
#import <objc/runtime.h>
#import "LUITableViewCellProtocol.h"
#import "LUITableViewSectionViewProtocol.h"
#import "UITableViewCell+LUITableViewCell.h"

@implementation LUITableViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.defaultSectionIndexTitle = LUITableViewDefaultSectionIndexTitle;
        self.reuseCell = YES;
    }
    return self;
}


- (id)copyWithZone:(NSZone *)zone {
    LUITableViewModel *obj = [super copyWithZone:zone];
    obj->_defaultIndexTitleSectionModel = self->_defaultIndexTitleSectionModel;
    obj.forwardDataSource = self.forwardDataSource;
    obj.forwardDelegate = self.forwardDelegate;
    obj.tableView= self.tableView;
    obj.showSectionIndexTitle = self.showSectionIndexTitle;
    obj.defaultSectionIndexTitle = self.defaultSectionIndexTitle;
    obj.editing = self.isEditing;
    obj.reuseCell = self.reuseCell;
    obj.emptyBackgroundViewClass = self.emptyBackgroundViewClass;
    obj.emptyBackgroundView = self.emptyBackgroundView;
    obj.whenReloadBackgroundView = [self.whenReloadBackgroundView copy];
    obj.hiddenSectionHeadView = self.hiddenSectionHeadView;
    obj.hiddenSectionFootView = self.hiddenSectionFootView;
    return obj;
}
- (id)initWithTableView:(UITableView *)tableView {
    if (self = [self init]) {
        [self setTableViewDataSourceAndDelegate:tableView];
    }
    return self;
}
- (LUICollectionSectionModel *)createEmptySectionModel {
    LUITableViewSectionModel *section = [[LUITableViewSectionModel alloc] init];
    return section;
}
- (void)addCellModel:(LUICollectionCellModel *)cellModel {
    if (!cellModel) return;
    LUITableViewSectionModel *section = (LUITableViewSectionModel *)[self.sectionModels lastObject];
    if (!section) {
        section = (LUITableViewSectionModel *)[self createEmptySectionModel];
        [self addSectionModel:section];
    }
    [section addCellModel:cellModel];
}
- (__kindof LUITableViewCellModel *)cellModelAtIndexPath:(NSIndexPath *)indexpath {
    LUITableViewCellModel *cellModel = [super cellModelAtIndexPath:indexpath];
    if ([cellModel isKindOfClass:[LUITableViewCellModel class]]) {
        return (LUITableViewCellModel *)cellModel;
    }
    return nil;
}
- (__kindof LUITableViewCellModel *)cellModelForSelectedCellModel {
    LUICollectionCellModel *cellModel = [super cellModelForSelectedCellModel];
    if ([cellModel isKindOfClass:[LUITableViewCellModel class]]) {
        return (LUITableViewCellModel *)cellModel;
    }
    return nil;
}
- (__kindof LUITableViewSectionModel *)sectionModelAtIndex:(NSInteger)index {
    LUICollectionSectionModel *sectionModel = [super sectionModelAtIndex:index];
    if ([sectionModel isKindOfClass:[LUITableViewSectionModel class]]) {
        return (LUITableViewSectionModel *)sectionModel;
    }
    return nil;
}
- (LUITableViewSectionModel *)addAutoIndexedCellModel:(LUITableViewCellModel *)cellModel {
    if (!cellModel) {
        return nil;
    }
    BOOL useDefaultIndexTitle = cellModel.indexTitle.length == 0;
    NSString *indexTitle = useDefaultIndexTitle?self.defaultSectionIndexTitle:cellModel.indexTitle;
    LUITableViewSectionModel *sectionModel = useDefaultIndexTitle?_defaultIndexTitleSectionModel:[self sectionModelWithIndexTitle:indexTitle];
    if (!sectionModel) {
        sectionModel = (LUITableViewSectionModel *)[self createEmptySectionModel];
        sectionModel.indexTitle = indexTitle;
        sectionModel.headTitle = indexTitle;
        sectionModel.showHeadView = YES;
        sectionModel.showDefaultHeadView = YES;
        if(useDefaultIndexTitle) {
            _defaultIndexTitleSectionModel = sectionModel;
        }
        [self addSectionModel:sectionModel];
    }
    [sectionModel addCellModel:cellModel];
    return sectionModel;
}
/**
 *    根據单元格的索引值,獲取應該被歸類的分组数据
 */
- (LUITableViewSectionModel *)sectionModelWithIndexTitle:(NSString *)indexTitle {
    LUITableViewSectionModel *sectionModel;
    for (LUITableViewSectionModel *m in self.sectionModels) {
        NSString *sectionIndexTitle = m.indexTitle;
        if ([sectionIndexTitle isEqual:indexTitle]) {
            sectionModel = m;
            break;
        }
    }
    return sectionModel;
}
- (void)sort {
    lui_weakify(self);
    [self.mutableSectionModels sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        lui_strongify(self);
        NSString *t1 = [(LUITableViewSectionModel *)obj1 indexTitle];
        NSString *t2 = [(LUITableViewSectionModel *)obj2 indexTitle];
        NSComparisonResult r = [t1 compare:t2];
        if(r!=NSOrderedSame){    //保證使用默认的分组索引值位置排序的最底部
            if (obj1 == self->_defaultIndexTitleSectionModel) {
                r = NSOrderedDescending;
            } else if (obj2 == self->_defaultIndexTitleSectionModel) {
                r = NSOrderedAscending;
            }
        }
        return r;
    }];
}
- (void)reloadTableViewData{
    [self reloadTableViewDataWithAnimated:NO];
}
- (void)reloadTableViewDataWithAnimated:(BOOL)animated{
    for (LUICollectionSectionModel *section in [self sectionModels]) {
        for (LUITableViewCellModel *cm in [section cellModels]) {
            cm.needReloadCell = YES;
        }
    }
    [self.tableView reloadData];//reladData时,tableView会清掉旧的行选中状态
    if (self.allowsSelection) {
        lui_weakify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            lui_strongify(self);
            if (self.allowsMultipleSelection) {
                NSArray *indexpaths = [self indexPathsForSelectedCellModels];
                for (NSIndexPath *indexpath in indexpaths) {
                    [self.tableView selectRowAtIndexPath:indexpath animated:animated scrollPosition:UITableViewScrollPositionNone];
                }
            } else {
                NSIndexPath *indexpath = [self indexPathForSelectedCellModel];
                [self.tableView selectRowAtIndexPath:indexpath animated:animated scrollPosition:UITableViewScrollPositionNone];
            }
        });
    }
    [self reloadTableViewBackgroundView];
}
- (void)addCellModel:(LUITableViewCellModel *)cellModel animated:(BOOL)animated {
    if (!cellModel) return;
    cellModel.needReloadCell = YES;
    UITableView *tableView = self.tableView;
    [self addCellModel:cellModel];
    LUICollectionSectionModel *sm = [self.sectionModels lastObject];
    NSIndexPath *indexpath = [NSIndexPath indexPathForItem:[sm numberOfCells]-1 inSection:self.sectionModels.count-1];
    [tableView beginUpdates];
    if ([tableView numberOfSections] == 0) {//添加section
        [tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:animated ? UITableViewRowAnimationAutomatic : UITableViewRowAnimationNone];
    }
    [tableView insertRowsAtIndexPaths:@[indexpath] withRowAnimation:animated ? UITableViewRowAnimationAutomatic : UITableViewRowAnimationNone];
    [tableView endUpdates];
    [self reloadTableViewBackgroundView];
}
- (void)insertCellModel:(LUITableViewCellModel *)cellModel atIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
    if(!cellModel||!indexPath)return;
    cellModel.needReloadCell = YES;
    UITableView *tableView = self.tableView;
    LUICollectionSectionModel *sectionModel = [self sectionModelAtIndex:indexPath.section];
    if (sectionModel) {
        [sectionModel insertCellModel:cellModel atIndex:indexPath.row];
    } else {//section不存在时,不操作
        return;
    }
    [tableView beginUpdates];
    [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:animated ? UITableViewRowAnimationAutomatic : UITableViewRowAnimationNone];
    [tableView endUpdates];
    [self reloadTableViewBackgroundView];
}
- (void)insertCellModel:(LUITableViewCellModel *)cellModel afterIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
    if (!cellModel) return;
    [self insertCellModels:@[cellModel] afterIndexPath:indexPath animated:animated];
}
- (void)insertCellModels:(NSArray *)cellModels afterIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
    if (cellModels.count == 0 || indexPath == nil) return;
    UITableView *tableView = self.tableView;
    for (LUITableViewCellModel *cm in cellModels) {
        cm.needReloadCell = YES;
    }
    [self insertCellModels:cellModels afterIndexPath:indexPath];
    NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:cellModels.count];
    for (int i=0; i<cellModels.count; i++) {
        NSIndexPath *addIndexpath = [NSIndexPath indexPathForRow:indexPath.row+1+i inSection:indexPath.section];
        [indexPaths addObject:addIndexpath];
    }
    [tableView beginUpdates];
    [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:animated ? UITableViewRowAnimationAutomatic : UITableViewRowAnimationNone];
    [tableView endUpdates];
    [self reloadTableViewBackgroundView];
}
- (void)insertCellModel:(LUITableViewCellModel *)cellModel beforeIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
    if (!cellModel) return;
    [self insertCellModels:@[cellModel] beforeIndexPath:indexPath animated:animated];
}
- (void)insertCellModels:(NSArray *)cellModels beforeIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
    if (cellModels.count == 0 || indexPath == nil) return;
    for (LUITableViewCellModel *cm in cellModels) {
        cm.needReloadCell = YES;
    }
    UITableView *tableView = self.tableView;
    [self insertCellModels:cellModels beforeIndexPath:indexPath];
    NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:cellModels.count];
    for (int i=0; i<cellModels.count; i++) {
        NSIndexPath *addIndexpath = [NSIndexPath indexPathForRow:indexPath.row+i inSection:indexPath.section];
        [indexPaths addObject:addIndexpath];
    }
    [tableView beginUpdates];
    [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:animated ? UITableViewRowAnimationAutomatic : UITableViewRowAnimationNone];
    [tableView endUpdates];
    [self reloadTableViewBackgroundView];
}
- (void)insertCellModelsToBottom:(NSArray<LUITableViewCellModel *> *)cellModels scrollToBottom:(BOOL)scrollToBottom {
    if (cellModels.count == 0) return;
    LUITableViewSectionModel *sm = (LUITableViewSectionModel *)[[self sectionModels] lastObject];
    if (!sm) {
        sm = (LUITableViewSectionModel *)[self createEmptySectionModel];
        [self addSectionModel:sm];
    }
    [sm insertCellModelsToBottom:cellModels];
    [self reloadTableViewData];
    //移动到底部
    if (scrollToBottom) {
        [self.tableView l_scrollToBottomWithAnimated:YES];
    }
}
- (void)insertCellModelsToTop:(NSArray<LUITableViewCellModel *> *)cellModels keepContentOffset:(BOOL)keepContentOffset {
    if (cellModels.count==0) return;
    
    LUITableViewSectionModel *sm = (LUITableViewSectionModel *)[[self sectionModels] firstObject];
    if (!sm) {
        sm = (LUITableViewSectionModel *)[self createEmptySectionModel];
        [self addSectionModel:sm];
    }
    [sm insertCellModelsToTop:cellModels];
    UITableView *tableView = self.tableView;
    //    //保持contentOffset不变
    CGPoint contentOffset = tableView.contentOffset;
    CGSize contentSize1 = tableView.contentSize;
    [self reloadTableViewData];
    CGSize contentSize2 = tableView.contentSize;
    contentOffset.y += contentSize2.height-contentSize1.height;
    if (keepContentOffset) {
        [tableView setContentOffset:contentOffset animated:NO];
    }
}

- (void)removeCellModel:(LUITableViewCellModel *)cellModel animated:(BOOL)animated {
    if (!cellModel) return;
    NSIndexPath *indexpath = [self indexPathOfCellModel:cellModel];
    if (indexpath) {
        cellModel.needReloadCell = YES;
        [self removeCellModelAtIndexPath:indexpath];
        UITableView *tableView = self.tableView;
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexpath] withRowAnimation:animated ? UITableViewRowAnimationAutomatic : UITableViewRowAnimationNone];
        [tableView endUpdates];
        [self reloadTableViewBackgroundView];
    }
}
- (void)removeCellModels:(NSArray *)cellModels animated:(BOOL)animated {
    if (cellModels.count == 0) return;
    NSArray *indexpaths = [self indexPathsOfCellModels:cellModels];
    [self removeCellModelsAtIndexPaths:indexpaths animated:animated];
}
- (void)removeCellModelsAtIndexPaths:(NSArray *)indexpaths animated:(BOOL)animated {
    if (indexpaths.count == 0) return;
    [self removeCellModelsAtIndexPaths:indexpaths];
    UITableView *tableView = self.tableView;
    [tableView beginUpdates];
    [tableView deleteRowsAtIndexPaths:indexpaths withRowAnimation:animated ? UITableViewRowAnimationAutomatic : UITableViewRowAnimationNone];
    [tableView endUpdates];
    [self reloadTableViewBackgroundView];
}
- (void)insertSectionModel:(LUITableViewSectionModel *)sectionModel atIndex:(NSInteger)index animated:(BOOL)animated {
    if (!sectionModel) return;
    for (LUITableViewCellModel *cm in [sectionModel cellModels]) {
        cm.needReloadCell = YES;
    }
    UITableView *tableView = self.tableView;
    [self insertSectionModel:sectionModel atIndex:index];
    
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:index];
    NSInteger count = sectionModel.numberOfCells;
    NSMutableArray<NSIndexPath *> *indexpaths = [[NSMutableArray alloc] initWithCapacity:count];
    for (int i=0; i<count; i++) {
        NSIndexPath *indexpath = [NSIndexPath indexPathForRow:index inSection:index];
        [indexpaths addObject:indexpath];
    }
    
    [tableView beginUpdates];
    [tableView insertSections:set withRowAnimation:animated ? UITableViewRowAnimationAutomatic : UITableViewRowAnimationNone];
    [tableView insertRowsAtIndexPaths:indexpaths withRowAnimation:animated ? UITableViewRowAnimationAutomatic : UITableViewRowAnimationNone];
    [tableView endUpdates];
}
- (void)removeSectionModel:(LUITableViewSectionModel *)sectionModel animated:(BOOL)animated {
    UITableView *tableView = self.tableView;
    NSInteger index = sectionModel.indexInModel;
    [self removeSectionModel:sectionModel];
    
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:index];
    NSInteger count = sectionModel.numberOfCells;
    NSMutableArray<NSIndexPath *> *indexpaths = [[NSMutableArray alloc] initWithCapacity:count];
    for (int i=0; i<count; i++) {
        NSIndexPath *indexpath = [NSIndexPath indexPathForRow:index inSection:index];
        [indexpaths addObject:indexpath];
    }
    
    [tableView beginUpdates];
    [tableView deleteSections:set withRowAnimation:animated ? UITableViewRowAnimationAutomatic : UITableViewRowAnimationNone];
    [tableView deleteRowsAtIndexPaths:indexpaths withRowAnimation:animated ? UITableViewRowAnimationAutomatic : UITableViewRowAnimationNone];
    [tableView endUpdates];
}
- (void)deselectAllCellModelsWithAnimated:(BOOL)animated {
    [self deselectAllCellModels];
    for (NSIndexPath *p in self.tableView.indexPathsForSelectedRows) {
        [self.tableView deselectRowAtIndexPath:p animated:animated];
    }
}
- (void)deselectCellModels:(NSArray<LUICollectionCellModel *> *)cellModels animated:(BOOL)animated {
    [super deselectCellModels:cellModels];
    for (LUITableViewCellModel *cm in cellModels) {
        [self.tableView deselectRowAtIndexPath:cm.indexPathInModel animated:animated];
    }
}
- (void)selectAllCellModelsWithAnimated:(BOOL)animated {
    [self selectAllCellModels];
    for (int i=0; i<self.numberOfSections; i++) {
        LUICollectionSectionModel *sm = [self sectionModelAtIndex:i];
        for (int j=0; j<sm.numberOfCells; j++) {
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i] animated:animated scrollPosition:(UITableViewScrollPositionNone)];
        }
    }
    [self selectCellModels:self.allCellModels animated:animated];
}
- (void)selectCellModels:(NSArray<LUITableViewCellModel *> *)cellModels animated:(BOOL)animated {
    [super selectCellModels:cellModels];
    for (LUITableViewCellModel *cm in cellModels) {
        [self.tableView selectRowAtIndexPath:cm.indexPathInModel animated:animated scrollPosition:(UITableViewScrollPositionNone)];
    }
}
- (void)setCellModel:(LUITableViewCellModel *)cellModel selected:(BOOL)selected animated:(BOOL)animated {
    CGPoint offset = self.tableView.contentOffset;
    if (selected) {
        [self selectCellModel:cellModel];
        [self.tableView selectRowAtIndexPath:cellModel.indexPathInModel animated:animated scrollPosition:(UITableViewScrollPositionTop)];
    } else {
        [self deselectCellModel:cellModel];
        [self.tableView deselectRowAtIndexPath:cellModel.indexPathInModel animated:animated];
    }
    if (!animated) {//防止因为设置了选中indexpath，导致的画面滚动
        self.tableView.contentOffset = offset;
    }
}
#pragma mark - forward
- (LUITableViewModel *)forwardDataSourceTo:(NSObject<UITableViewDataSource> *)dataSource {
    self.forwardDataSource = dataSource;
    return self;
}
- (LUITableViewModel *)forwardDelegateTo:(NSObject<UITableViewDelegate> *)delegate {
    self.forwardDelegate = delegate;
    return self;
}
- (void)setTableViewDataSourceAndDelegate:(UITableView *)tableView {
    self.tableView = tableView;
    tableView.dataSource = self;
    tableView.delegate = self;
}
- (void)setForwardDelegate:(id<UITableViewDelegate>)forwardDelegate {
    _forwardDelegate = forwardDelegate;
    if (self.tableView.delegate == self) {
        self.tableView.delegate = nil;
        self.tableView.delegate = self;//重新赋值一次,使得scrollview重新判断scrollViewDidScroll:方法的有无
    }
}
- (void)setHiddenSectionHeadView:(BOOL)hiddenSectionHeadView {
    if (_hiddenSectionHeadView != hiddenSectionHeadView) {
        _hiddenSectionHeadView = hiddenSectionHeadView;
        [self __resetTableViewDelegateDataSource];
    }
}
- (void)setHiddenSectionFootView:(BOOL)hiddenSectionFootView {
    if (_hiddenSectionFootView != hiddenSectionFootView) {
        _hiddenSectionFootView = hiddenSectionFootView;
        [self __resetTableViewDelegateDataSource];
    }
}
- (void)hideSectionHeadFootView {
    BOOL change = !_hiddenSectionHeadView || !_hiddenSectionHeadView;
    _hiddenSectionHeadView = YES;
    _hiddenSectionFootView = YES;
    if (change) {
        [self __resetTableViewDelegateDataSource];
    }
}
- (void)__resetTableViewDelegateDataSource {
    if (self.tableView.delegate == self) {
        self.tableView.delegate = nil;
        self.tableView.delegate = self;//重新赋值一次,使得scrollview重新判断scrollViewDidScroll:方法的有无
    }
    if (self.tableView.dataSource==self) {
        self.tableView.dataSource = nil;
        self.tableView.dataSource = self;
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
- (void)reloadTableViewBackgroundView {
    if (!self.emptyBackgroundViewClass && !self.emptyBackgroundView) return;
    if (self.numberOfCells == 0) {
        if (!self.emptyBackgroundView) {
            self.emptyBackgroundView = [self createEmptyBackgroundView];
        }
        self.tableView.backgroundView = self.emptyBackgroundView;
    } else {
        self.tableView.backgroundView = nil;
    }
    if (self.whenReloadBackgroundView) {
        self.whenReloadBackgroundView(self);
    }
}
#pragma mark - Forward Invocations
/**
 *根据指定的Selector返回该类支持的方法签名,一般用于prototol或者消息转发forwardInvocation:中NSInvocation参数的methodSignature属性
 注:系统调用- (void)forwardInvocation:(NSInvocation *)invocation方法前,会先调用此方法获取NSMethodSignature,然后生成方法所需要的NSInvocation
 */
- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    NSMethodSignature *signature = [super methodSignatureForSelector:selector];
    if (signature == nil) {
        id delegate = self.forwardDelegate;
        if ([delegate respondsToSelector:selector]) {
            signature = [delegate methodSignatureForSelector:selector];
        }else{
            delegate = self.forwardDataSource;
            if ([delegate respondsToSelector:selector]) {
                signature = [delegate methodSignatureForSelector:selector];
            }
        }
    }
    return signature;
}
- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    BOOL conforms = NO;
    if ([super conformsToProtocol:aProtocol]) {
        conforms = YES;
    } else {
        if ([self.forwardDelegate conformsToProtocol:aProtocol]) {
            conforms = YES;
        } else if([self.forwardDataSource conformsToProtocol:aProtocol]) {
            conforms = YES;
        }
    }
    return conforms;
}
- (BOOL)respondsToSelector:(SEL)selector {
    BOOL responds = NO;
    if ([super respondsToSelector:selector]) {
        responds = YES;
    } else {
        if ([self.forwardDelegate respondsToSelector:selector]) {
            responds = YES;
        } else if ([self.forwardDataSource respondsToSelector:selector]) {
            responds = YES;
        }
    }
    if (!responds && !self.hiddenSectionHeadView) {
        if (selector == @selector(tableView:heightForHeaderInSection:)) {
            responds = YES;
        } else if (selector==@selector(tableView:titleForHeaderInSection:)) {
            responds = YES;
        } else if (selector==@selector(tableView:viewForHeaderInSection:)) {
            responds = YES;
        }
    }
    if (!responds && !self.hiddenSectionFootView) {
        if (selector == @selector(tableView:heightForFooterInSection:)) {
            responds = YES;
        } else if (selector == @selector(tableView:titleForFooterInSection:)) {
            responds = YES;
        } else if (selector == @selector(tableView:viewForFooterInSection:)) {
            responds = YES;
        }
    }
    return responds;
}
/**
 *对调用未定义的方法进行消息重定向
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
        BOOL responds = NO;
        if (!self.hiddenSectionHeadView) {
            //当要显示section的head、foot时，使用重定向到__tableView:xx:相应方法
            SEL selector = invocation.selector;
            if (selector == @selector(tableView:heightForHeaderInSection:)) {
                invocation.selector = @selector(__tableView:heightForHeaderInSection:);
                responds = YES;
            } else if (selector == @selector(tableView:titleForHeaderInSection:)) {
                invocation.selector = @selector(__tableView:titleForHeaderInSection:);
                responds = YES;
            } else if (selector == @selector(tableView:viewForHeaderInSection:)) {
                invocation.selector = @selector(__tableView:viewForHeaderInSection:);
                responds = YES;
            }
        }
        
        if (!self.hiddenSectionFootView) {
            //当要显示section的head、foot时，使用重定向到__tableView:xx:相应方法
            SEL selector = invocation.selector;
            if (selector == @selector(tableView:heightForFooterInSection:)) {
                invocation.selector = @selector(__tableView:heightForFooterInSection:);
                responds = YES;
            } else if(selector == @selector(tableView:titleForFooterInSection:)) {
                invocation.selector = @selector(__tableView:titleForFooterInSection:);
                responds = YES;
            } else if(selector == @selector(tableView:viewForFooterInSection:)) {
                invocation.selector = @selector(__tableView:viewForFooterInSection:);
                responds = YES;
            }
        }
        if (responds) {
            [invocation invokeWithTarget:self];
        } else {
            [super forwardInvocation:invocation];
        }
    }
}
- (void)doesNotRecognizeSelector:(SEL)aSelector {
    [super doesNotRecognizeSelector:aSelector];
}
#pragma mark - delegate:UITableViewDataSource,UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    self.tableView = tableView;
    LUITableViewSectionModel *sectionModel = [self sectionModelAtIndex:section];
    NSInteger number = [sectionModel numberOfCells];
    return number;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LUITableViewCellModel *cellModel = [self cellModelAtIndexPath:indexPath];
    UITableViewCell<LUITableViewCellProtocol> *cell = nil;
    Class cellClass = cellModel.cellClass;
    if (cellClass && cell && ![cell isKindOfClass:cellClass]) {
        cell = nil;
    }
    if (!cell) {
        NSString *identity = self.reuseCell ? cellModel.reuseIdentity:[NSString stringWithFormat:@"%@_%p", cellModel.reuseIdentity, cellModel];
        //当取消重用时，identity将添加上cellModel的内存地址
        cell = [tableView dequeueReusableCellWithIdentifier:identity];
        if (!cell) {
            if (!cellClass) {
                cellClass = [UITableViewCell class];
            }
            cell = [[cellClass alloc] initWithStyle:cellModel.cellStyle reuseIdentifier:identity];
        }
    }
    [cellModel displayCell:cell];
    return cell;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sections = [self numberOfSections];
    return sections;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL edit = NO;
    LUITableViewCellModel *cellModel = [self cellModelAtIndexPath:indexPath];
    edit = cellModel.canEdit;
    return edit;
}
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.forwardDelegate respondsToSelector:_cmd]) {
        return [self.forwardDelegate tableView:tableView editActionsForRowAtIndexPath:indexPath];
    }
    LUITableViewCellModel *cellModel = [self cellModelAtIndexPath:indexPath];
    return cellModel.editActions;
}
- (nullable UISwipeActionsConfiguration *)tableView:(UITableView *)tableView leadingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(tvos) {
    if ([self.forwardDelegate respondsToSelector:_cmd]) {
        return [self.forwardDelegate tableView:tableView leadingSwipeActionsConfigurationForRowAtIndexPath:indexPath];
    }
    LUITableViewCellModel *cellModel = [self cellModelAtIndexPath:indexPath];
    return [cellModel swipeActionsConfigurationWithIndexPath:indexPath leading:YES];
}
- (nullable UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(tvos) {
    //注：实现了trailingSwipeActionsConfigurationForRowAtIndexPath/leadingSwipeActionsConfigurationForRowAtIndexPath方法，要ios11上，就不会再去调用editActionsForRowAtIndexPath方法了
    if ([self.forwardDelegate respondsToSelector:_cmd]) {
        return [self.forwardDelegate tableView:tableView trailingSwipeActionsConfigurationForRowAtIndexPath:indexPath];
    }
    LUITableViewCellModel *cellModel = [self cellModelAtIndexPath:indexPath];
    return [cellModel swipeActionsConfigurationWithIndexPath:indexPath leading:NO];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL move = NO;
    LUITableViewCellModel *cellModel = [self cellModelAtIndexPath:indexPath];
    move = cellModel.canMove;
    return move;
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    LUITableViewCellModel *cellModel = [self cellModelAtIndexPath:indexPath];
    if (cellModel.whenClickAccessory) {
        cellModel.whenClickAccessory(cellModel);
    }
}
- (NSArray*)_sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSMutableArray *sectionIndexTitles = nil;
    if (self.showSectionIndexTitle) {
        sectionIndexTitles = [[NSMutableArray alloc] init];
        for (LUITableViewSectionModel *sectionModel in self.sectionModels) {
            NSString *title = sectionModel.indexTitle ? : self.defaultSectionIndexTitle;
            if (title) {
                [sectionIndexTitles addObject:@{@"title" : title, @"model" : sectionModel}];
            }
        }
    }
    return sectionIndexTitles;
}
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView { // return list of section titles to display in section index view (e.g. "ABCD...Z#")
    NSMutableArray *sectionIndexTitles = nil;
    if (self.showSectionIndexTitle) {
        sectionIndexTitles = [[NSMutableArray alloc] init];
        NSArray *map = [self _sectionIndexTitlesForTableView:tableView];
        for (NSDictionary* info in map) {
            NSString *title = info[@"title"];
            [sectionIndexTitles addObject:title];
        }
    }
    return sectionIndexTitles;
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {// tell table which section corresponds to section title/index (e.g. "B",1))
    NSInteger sectionIndex = NSNotFound;
    if (self.showSectionIndexTitle) {
        NSArray *map = [self _sectionIndexTitlesForTableView:tableView];
        NSDictionary *info = [map objectAtIndex:index];
        LUITableViewSectionModel *sectionModel = info[@"model"];
        sectionIndex = [self indexOfSectionModel:sectionModel];
    }
    return sectionIndex;
}
// Data manipulation - insert and delete support
// After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {//使用默认的左侧按钮时，才会被触发
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        LUITableViewCellModel *cellModel = nil;
        LUITableViewSectionModel *sectionModel = [self sectionModelAtIndex:indexPath.section];
        cellModel = [sectionModel cellModelAtIndex:indexPath.row];
        if (cellModel.whenDelete) {
            cellModel.whenDelete(cellModel);
        }
    }
    if ([self.forwardDataSource respondsToSelector:_cmd]) {
        [self.forwardDataSource tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
    }
}
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    LUITableViewCellModel *srcTablecellModel = [self cellModelAtIndexPath:sourceIndexPath];
    LUITableViewCellModel *dstTablecellModel = [self cellModelAtIndexPath:destinationIndexPath];
    BOOL handed = NO;
    LUITableViewCellModelBlockM handler = srcTablecellModel.whenMove?:dstTablecellModel.whenMove;
    if (handler) {
        handler(srcTablecellModel,dstTablecellModel);
        handed = YES;
    }
    if ([self.forwardDataSource respondsToSelector:_cmd]) {
        [self.forwardDataSource tableView:tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
        handed = YES;
    }
    if (!handed) {
        [self moveCellModelAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    LUITableViewCellModel *cellModel = [self cellModelAtIndexPath:indexPath];
    Class cellClass = cellModel.cellClass;
    
    CGFloat height = [cellClass heightWithTableView:tableView cellModel:cellModel];
    return height;
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    LUITableViewCellModel *cellModel = [self cellModelAtIndexPath:indexPath];
    Class cellClass = cellModel.cellClass;
    CGFloat height = [cellClass estimatedHeightWithTableView:tableView cellModel:cellModel];
    return height;
}
- (CGFloat)__tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat height = 0;
    LUITableViewSectionModel *sectionModel = [self sectionModelAtIndex:section];
    if (sectionModel.showHeadView) {
        if(sectionModel.showDefaultHeadView) {
            height = sectionModel.headViewHeight;
            if (height == 0) {
                height = UITableViewAutomaticDimension;
            }
        }else{
            height = [sectionModel.headViewClass heightWithTableView:tableView sectionModel:sectionModel kind:LUITableViewSectionViewKindOfHead];
        }
    }
    return height;
}
- (CGFloat)__tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    CGFloat height = 0;
    LUITableViewSectionModel *sectionModel = [self sectionModelAtIndex:section];
    if (sectionModel.showFootView) {
        if (sectionModel.showDefaultFootView) {
            height = sectionModel.footViewHeight;
            if (height==0) {
                height = UITableViewAutomaticDimension;
            }
        } else {
            height = [sectionModel.footViewClass heightWithTableView:tableView sectionModel:sectionModel kind:LUITableViewSectionViewKindOfFoot];
        }
    }
    return height;
}
- (NSString *)__tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    LUITableViewSectionModel *sectionModel = [self sectionModelAtIndex:section];
    NSString *title = sectionModel.headTitle;
    if (title.length == 0 && sectionModel.showHeadView) {
        title = @" ";
        //当显示自定义视图时，如果没有title且height为UITableViewAutomaticDimension，会不显示视图。因此这里手动赋值上空格字符串
    }
    return title;
}
- (NSString *)__tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    LUITableViewSectionModel *sectionModel = [self sectionModelAtIndex:section];
    NSString *title = sectionModel.footTitle;
    if (title.length == 0 && sectionModel.showFootView) {
        title = @" ";
        //当显示自定义视图时，如果没有title且height为UITableViewAutomaticDimension，会不显示视图。因此这里手动赋值上空格字符串
    }
    return title;
}
- (UIView *)__tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView<LUITableViewSectionViewProtocol> *view = nil;
    LUITableViewSectionModel *sectionModel = [self sectionModelAtIndex:section];
    if (!sectionModel.showDefaultHeadView) {
        Class c = sectionModel.headViewClass;
        if (c) {
            CGRect f = CGRectMake(0, 0, tableView.bounds.size.width, 40);
            CGFloat h = [self tableView:tableView heightForHeaderInSection:section];
            if (h >= 0) {
                f.size.height = h;
            }
            view = [[c alloc] initWithFrame:f];
            [sectionModel displayHeadView:view];
        }
    }
    return view;
}
- (UIView *)__tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView<LUITableViewSectionViewProtocol> *view = nil;
    LUITableViewSectionModel *sectionModel = [self sectionModelAtIndex:section];
    if (!sectionModel.showDefaultFootView) {
        Class c = sectionModel.footViewClass;
        if (c) {
            CGRect f = CGRectMake(0, 0, tableView.bounds.size.width, 40);
            CGFloat h = [self tableView:tableView heightForFooterInSection:section];
            if (h >= 0) {
                f.size.height = h;
            }
            view = [[c alloc] initWithFrame:f];
            [sectionModel displayFootView:view];
        }
    }
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell
       && [cell conformsToProtocol:@protocol(LUITableViewCellProtocol)]
       && [cell respondsToSelector:@selector(tableView:didSelectCell:)]
       ) {
        [cell tableView:tableView didSelectCell:YES];
    }
    LUITableViewCellModel *cellModel = [self cellModelAtIndexPath:indexPath];
    [self selectCellModel:cellModel];
    if (cellModel.whenSelected) {
        cellModel.whenSelected(cellModel, YES);
    }
    if (cellModel.whenClick) {
        cellModel.whenClick(cellModel);
    }
    if ([self.forwardDelegate respondsToSelector:_cmd]) {
        [self.forwardDelegate tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell
       && [cell conformsToProtocol:@protocol(LUITableViewCellProtocol)]
       && [cell respondsToSelector:@selector(tableView:didSelectCell:)]
       ) {
        [cell tableView:tableView didSelectCell:NO];
    }
    LUITableViewCellModel *cellModel = [self cellModelAtIndexPath:indexPath];
    [self deselectCellModel:cellModel];
    if (cellModel.whenSelected) {
        cellModel.whenSelected(cellModel,NO);
    }
    if (tableView.allowsMultipleSelection) {//多选时,deselect代表选中行被点击了
        if (cellModel.whenClick) {
            cellModel.whenClick(cellModel);
        }
    }
    if ([self.forwardDelegate respondsToSelector:_cmd]) {
        [self.forwardDelegate tableView:tableView didDeselectRowAtIndexPath:indexPath];
    }
}

// Display customization

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell conformsToProtocol:@protocol(LUITableViewCellProtocol)] && [cell respondsToSelector:@selector(tableView:willDisplayCellModel:)]) {
        LUITableViewCellModel *cellModel = [self cellModelAtIndexPath:indexPath];
        [(UITableViewCell<LUITableViewCellProtocol> *)cell tableView:tableView willDisplayCellModel:cellModel];
    }
    if ([self.forwardDelegate respondsToSelector:_cmd]) {
        [self.forwardDelegate tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    }
}
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section API_AVAILABLE(ios(6.0)) {
    if ([view conformsToProtocol:@protocol(LUITableViewSectionViewProtocol)] && [view respondsToSelector:@selector(tableView:willDisplaySectionModel:kind:)]) {
        LUITableViewSectionModel *sectionModel = [self sectionModelAtIndex:section];
        [(UIView<LUITableViewSectionViewProtocol> *)view tableView:tableView willDisplaySectionModel:sectionModel kind:(LUITableViewSectionViewKindOfHead)];
    }
    if ([self.forwardDelegate respondsToSelector:_cmd]) {
        [self.forwardDelegate tableView:tableView willDisplayHeaderView:view forSection:section];
    }
}
- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section API_AVAILABLE(ios(6.0)){
    if ([view conformsToProtocol:@protocol(LUITableViewSectionViewProtocol)] && [view respondsToSelector:@selector(tableView:willDisplaySectionModel:kind:)]) {
        LUITableViewSectionModel *sectionModel = [self sectionModelAtIndex:section];
        [(UIView<LUITableViewSectionViewProtocol> *)view tableView:tableView willDisplaySectionModel:sectionModel kind:(LUITableViewSectionViewKindOfFoot)];
    }
    if ([self.forwardDelegate respondsToSelector:_cmd]) {
        [self.forwardDelegate tableView:tableView willDisplayFooterView:view forSection:section];
    }
}
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath API_AVAILABLE(ios(6.0)){
   if ([cell conformsToProtocol:@protocol(LUITableViewCellProtocol)] && [cell respondsToSelector:@selector(tableView:didEndDisplayingCellModel:)]) {
        LUITableViewCellModel *cellModel = [self cellModelAtIndexPath:indexPath];
        [(UITableViewCell<LUITableViewCellProtocol> *)cell tableView:tableView didEndDisplayingCellModel:cellModel];
    }
    if ([self.forwardDelegate respondsToSelector:_cmd]) {
        [self.forwardDelegate tableView:tableView didEndDisplayingCell:cell forRowAtIndexPath:indexPath];
    }
}
- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section API_AVAILABLE(ios(6.0)) {
    if([view conformsToProtocol:@protocol(LUITableViewSectionViewProtocol)] && [view respondsToSelector:@selector(tableView:didEndDisplayingSectionModel:kind:)]) {
        LUITableViewSectionModel *sectionModel = [self sectionModelAtIndex:section];
        [(UIView<LUITableViewSectionViewProtocol> *)view tableView:tableView didEndDisplayingSectionModel:sectionModel kind:(LUITableViewSectionViewKindOfHead)];
    }
    if ([self.forwardDelegate respondsToSelector:_cmd]) {
        [self.forwardDelegate tableView:tableView didEndDisplayingHeaderView:view forSection:section];
    }
}
- (void)tableView:(UITableView *)tableView didEndDisplayingFooterView:(UIView *)view forSection:(NSInteger)section API_AVAILABLE(ios(6.0)) {
    if ([view conformsToProtocol:@protocol(LUITableViewSectionViewProtocol)] && [view respondsToSelector:@selector(tableView:didEndDisplayingSectionModel:kind:)]) {
        LUITableViewSectionModel *sectionModel = [self sectionModelAtIndex:section];
        [(UIView<LUITableViewSectionViewProtocol> *)view tableView:tableView didEndDisplayingSectionModel:sectionModel kind:(LUITableViewSectionViewKindOfFoot)];
    }
    if ([self.forwardDelegate respondsToSelector:_cmd]) {
        [self.forwardDelegate tableView:tableView didEndDisplayingFooterView:view forSection:section];
    }
}
#pragma debug
- (NSString *)description {
    return [NSString stringWithFormat:@"%@:[sectionModels:%@,showSectionIndexTitle:%d,userInfo:%@]",NSStringFromClass(self.class),self.sectionModels,self.showSectionIndexTitle,self.userInfo];
}

- (void)dealloc {
    
}

@end
