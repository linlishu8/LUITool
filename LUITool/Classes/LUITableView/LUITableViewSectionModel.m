//
//  LUITableViewSectionModel.m
//  LUITool
//
//  Created by 六月 on 2023/8/11.
//

#import "LUITableViewSectionModel.h"
#import "LUITableViewCellModel.h"
#import "LUITableViewModel.h"
#import "LUITableViewSectionViewProtocol.h"
#import "LUITableViewSectionView.h"

@implementation LUITableViewSectionModel
- (id)init{
    if (self = [super init]) {
        self.headViewClass = [LUITableViewSectionView class];
        self.footViewClass = [LUITableViewSectionView class];
    }
    return self;
}
- (id)copyWithZone:(NSZone *)zone{
    LUITableViewSectionModel *obj = [super copyWithZone:zone];
    obj.indexTitle = self.indexTitle;
    obj.headViewClass = self.headViewClass;
    obj.footViewClass = self.footViewClass;
    obj.showHeadView = self.showHeadView;
    obj.showFootView= self.showFootView;
    obj.showDefaultHeadView = self.showDefaultHeadView;
    obj.showDefaultFootView = self.showDefaultFootView;
    obj.headViewHeight = self.headViewHeight;
    obj.footViewHeight = self.footViewHeight;
    obj.headTitle = self.headTitle;
    obj.footTitle = self.footTitle;
    obj.tableViewModel = self.tableViewModel;
    obj.whenShowHeadView = [self.whenShowHeadView copy];
    obj.whenShowFootView = [self.whenShowFootView copy];
    return obj;
}
- (UITableView *)tableView {
    return self.tableViewModel.tableView;
}
- (LUITableViewModel *)tableViewModel {
    LUICollectionModel *collectionModel = [super collectionModel];
    if ([collectionModel isKindOfClass:[LUITableViewModel class]]) {
        return (LUITableViewModel *)collectionModel;
    }
    return nil;
}
- (void)setTableViewModel:(LUITableViewModel *)tableViewModel {
    self.collectionModel = tableViewModel;
}
- (__kindof LUITableViewCellModel *)cellModelAtIndex:(NSInteger)index {
    LUICollectionCellModel *cellModel = [super cellModelAtIndex:index];
    if ([cellModel isKindOfClass:[LUITableViewCellModel class]]) {
        return (LUITableViewCellModel *)cellModel;
    }
    return nil;
 }
- (id)initWithBlankHeadView:(CGFloat)height{
    if (self=[self init]) {
        [self showDefaultHeadViewWithHeight:height];
        [self showDefaultFootViewWithHeight:0.1];
    }
    return self;
}
- (id)initWithBlankFootView:(CGFloat)height{
    if (self=[self init]) {
        [self showDefaultHeadViewWithHeight:0.1];
        [self showDefaultFootViewWithHeight:height];
    }
    return self;
}
- (id)initWithBlankHeadView:(CGFloat)headViewHeight footView:(CGFloat)footViewHeight{
    if (self=[self init]) {
        [self showDefaultHeadViewWithHeight:headViewHeight];
        [self showDefaultFootViewWithHeight:footViewHeight];
    }
    return self;
}
- (void)showDefaultHeadViewWithHeight:(CGFloat)height{
    self.showHeadView = YES;
    self.showDefaultHeadView = YES;
    self.headViewHeight = height;
}
- (void)showDefaultFootViewWithHeight:(CGFloat)height{
    self.showFootView = YES;
    self.showDefaultFootView = YES;
    self.footViewHeight = height;
}
- (void)displayHeadView:(UIView<LUITableViewSectionViewProtocol> *)view {
    [view setSectionModel:self kind:LUITableViewSectionViewKindOfHead];
    if (self.whenShowHeadView) {
        self.whenShowHeadView(self,view);
    }
    [view setNeedsLayout];
}
- (void)displayFootView:(UIView<LUITableViewSectionViewProtocol> *)view {
    [view setSectionModel:self kind:LUITableViewSectionViewKindOfFoot];
    if (self.whenShowFootView) {
        self.whenShowFootView(self,view);
    }
    [view setNeedsLayout];
}

- (void)refresh {
    [self refreshWithAnimated:NO];
}
- (void)refreshWithAnimated:(BOOL)animated {
    if (self.tableView) {
        for (LUITableViewCellModel *cm in self.cellModels) {
            cm.needReloadCell = YES;
        }
        NSIndexSet *set = [self.tableViewModel indexSetOfSectionModel:self];
        if (set) {
            [self.tableView reloadSections:set withRowAnimation:animated?UITableViewRowAnimationNone:UITableViewRowAnimationAutomatic];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            for (LUITableViewCellModel *cm in self.cellModels) {
                if (cm.selected) {
                    [self.tableView selectRowAtIndexPath:cm.indexPathInModel animated:animated scrollPosition:(UITableViewScrollPositionNone)];
                }
            }
        });
    }
}
#pragma debug
- (NSString *)description{
    return [NSString stringWithFormat:@"%@:[indexTitle:%@,showHeadView:%d,headTitle:%@,headViewHeight:%f,showFootView:%d,footTitle:%@,footViewHeight:%f,cells:%@,userInfo:%@]",NSStringFromClass(self.class),self.indexTitle,self.showHeadView,self.headTitle,self.headViewHeight,self.showFootView,self.footTitle,self.footViewHeight,self.cellModels,self.userInfo];
}
- (void)dealloc{
//    NSLog(@"deallocLUITableViewSectionModel:%@", self);
}
@end
