//
//  LUITableViewCellModel.m
//  LUITool
//
//  Created by 六月 on 2023/8/11.
//

#import "LUITableViewCellModel.h"
#import "LUITableViewModel.h"
#import "LUITableViewCellProtocol.h"
#import "UITableViewCell+LUITableViewCell.h"
#import "UIScrollView+LUI.h"

@implementation LUITableViewCellModel
+ (instancetype)modelWithValue:(id)modelValue cellClass:(Class)cellClass{
    return [self modelWithValue:modelValue cellClass:cellClass whenClick:nil];
}
+ (instancetype)modelWithValue:(nullable id)modelValue cellClass:(Class)cellClass whenClick:(nullable LUITableViewCellModelBlockC)whenClick{
    LUITableViewCellModel *cm = [self modelWithValue:modelValue];
    cm.cellClass = cellClass;
    cm.whenClick = whenClick;
    return cm;
}

- (id)init{
    if(self=[super init]){
        self.cellClass = [UITableViewCell class];
        self.performsFirstActionWithFullSwipe = YES;
    }
    return self;
}
- (id)copyWithZone:(NSZone *)zone{
    LUITableViewCellModel *obj = [super copyWithZone:zone];
    obj->_selected = self->_selected;
    obj.cellClass = self.cellClass;
    obj.indexTitle = self.indexTitle;
    obj.canEdit = self.canEdit;
    obj.canMove = self.canMove;
    obj.whenClick = [self.whenClick copy];
    obj.whenSelected = [self.whenSelected copy];
    obj.whenClickAccessory = [self.whenClickAccessory copy];
    obj.whenDelete = [self.whenDelete copy];
    obj.whenMove = [self.whenMove copy];
    obj.whenShow = [self.whenShow copy];
    obj.swipeActions = [self.swipeActions copy];
    obj.performsFirstActionWithFullSwipe = self.performsFirstActionWithFullSwipe;
    obj.leadingSwipeActions = [self.leadingSwipeActions copy];
    obj.tableViewCell = self.tableViewCell;
    obj.cellStyle = self.cellStyle;
    obj.reuseIdentity= self.reuseIdentity;
    obj.needReloadCell = self.needReloadCell;
    return obj;
}
- (UITableView *)tableView{
    return self.tableViewModel.tableView;
}
- (LUITableViewModel *)tableViewModel{
    LUICollectionModel *collectionModel = [super collectionModel];
    if([collectionModel isKindOfClass:[LUITableViewModel class]]){
        return (LUITableViewModel *)collectionModel;
    }
    return nil;
}
- (__kindof LUITableViewSectionModel *)sectionModel{
    LUICollectionSectionModel *sectionModel = [super sectionModel];
    if([sectionModel isKindOfClass:[LUITableViewSectionModel class]]){
        return (LUITableViewSectionModel *)sectionModel;
    }
    return nil;
}
- (void)displayCell:(UITableViewCell<LUITableViewCellProtocol> *)cell{
    BOOL isCellModelChanged =
       self.needReloadCell
    || cell.cellModel!=self
    || self.tableViewCell!=cell
    ;
    cell.cellModel = self;
    self.tableViewCell = cell;
    if(self.whenShow){
        self.whenShow(self,cell);
    }
    if(isCellModelChanged){
        [cell setNeedsLayout];
    }
}
- (NSString *)reuseIdentity{
    if(_reuseIdentity==nil){
        _reuseIdentity = NSStringFromClass(self.cellClass);
    }
    return _reuseIdentity;
}
- (void)refresh{
    NSIndexPath *indexPath = [self.tableViewModel indexPathOfCellModel:self];
    if(indexPath){
        self.needReloadCell = YES;
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}
- (void)refreshWithAnimated:(BOOL)animated{
    NSIndexPath *indexPath = [self.tableViewModel indexPathOfCellModel:self];
    if(indexPath){
        self.needReloadCell = YES;
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:animated?UITableViewRowAnimationAutomatic:UITableViewRowAnimationNone];
        if(self.selected){
//            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView selectRowAtIndexPath:indexPath animated:animated scrollPosition:(UITableViewScrollPositionNone)];
//            });
        }
    }
}
- (void)deselectCellWithAnimated:(BOOL)animated {
    [self setSelected:NO animated:animated];
}
- (void)selectCellWithAnimated:(BOOL)animated {
    [self setSelected:YES animated:animated];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [self.tableViewModel setCellModel:self selected:selected animated:animated];
}

- (void)didClickSelf{
    if(self.whenClick){
        self.whenClick(self);
    }
}
- (void)didClickAccessorySelf{
    if(self.whenClickAccessory){
        self.whenClickAccessory(self);
    }
}
- (void)didSelectedSelf:(BOOL)selected{
    if(self.whenSelected){
        self.whenSelected(self,selected);
    }
}
- (void)didDeleteSelf{
    if(self.whenDelete){
        self.whenDelete(self);
    }
}
- (void)setFocused:(BOOL)focused refreshed:(BOOL)refreshed{
    if(!self.tableViewModel){
        self.focused = focused;
        return;
    }
    if(focused){
        LUITableViewCellModel *oldCM = [self.tableViewModel cellModelForFocusedCellModel];
        if(oldCM==self){
            return;
        }
        oldCM.focused = NO;
        [oldCM refreshWithAnimated:YES];
        self.focused = YES;
        if(refreshed){
            [self refreshWithAnimated:YES];
            [self.tableView scrollToRowAtIndexPath:self.indexPathInModel atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        }
    }else{
        [self.tableViewModel focusCellModel:self focused:NO];
        if(refreshed){
            [self refreshWithAnimated:YES];
        }
    }
}
- (void)removeFromModelWithAnimated:(BOOL)animated{
    [self.tableViewModel removeCellModel:self animated:animated];
}
#pragma debug
- (NSString *)description{
    return [NSString stringWithFormat:@"%@:[cellClass:%@,userInfo:%@]",NSStringFromClass(self.class),NSStringFromClass(self.cellClass),self.userInfo];
}
- (void)dealloc{
//    NSLog(@"deallocLUITableViewCellModel:%@", self);
}
- (NSArray<UITableViewRowAction *> *)editActions{
    if(self.swipeActions.count==0){
        return nil;
    }
    NSMutableArray<UITableViewRowAction *> *editActions = [[NSMutableArray alloc] initWithCapacity:self.swipeActions.count];
    for (LUITableViewCellSwipeAction *swipeAction in self.swipeActions) {
        UITableViewRowAction *rowAction = [swipeAction tableViewRowActionWithCellModel:self];
        [editActions addObject:rowAction];
    }
    return editActions;
}
 - (nullable UISwipeActionsConfiguration *)swipeActionsConfigurationWithIndexPath:(NSIndexPath *)indexPath leading:(BOOL)leading{
     NSArray<LUITableViewCellSwipeAction *> *swipeActions = leading?self.leadingSwipeActions:self.swipeActions;
     if(swipeActions.count==0){
         return nil;
     }
     NSMutableArray<UIContextualAction *> *actions = [[NSMutableArray alloc] initWithCapacity:swipeActions.count];
     for (LUITableViewCellSwipeAction *swipeAction in swipeActions) {
         UIContextualAction *rowAction = [swipeAction contextualActionWithCellModel:self];
         [actions addObject:rowAction];
     }
     UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:actions];
     config.performsFirstActionWithFullSwipe = self.performsFirstActionWithFullSwipe;
     return config;
 }
@end
