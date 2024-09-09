//
//  LUIMenuViewController.m
//  LUITool_Example
//
//  Created by 六月 on 2024/9/9.
//  Copyright © 2024 Your Name. All rights reserved.
//

#import "LUIMenuViewController.h"
#import "LUIItemFlowView.h"
#import "LUIMenuItemFlowSectionView.h"
#import "LUIMenuItemFlowSectionView_Vertical.h"
#import "LUIMenuGroup.h"

@interface LUIMenuViewController ()

@property (nonatomic, strong) LUICollectionView *collectionView;
@property (nonatomic, strong) LUICollectionViewTitleSupplementarySectionModel *groupCategoryHeadSeciton;
@property (nonatomic, strong) NSArray<LUICollectionViewTitleSupplementarySectionModel *> *menuGroupSecitons;
@property (nonatomic, strong) NSArray<LUIMenuGroup *> *menuGroups;
@property (nonatomic, strong) LUIItemFlowView *tabItemFlowView;//分组
@property (nonatomic, assign) BOOL directionVertical;//横竖排列

@end

@implementation LUIMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    LUICollectionViewFlowLayout *pageFlowLayout = [[LUICollectionViewFlowLayout alloc] init];
    
    self.collectionView = [[LUICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:pageFlowLayout];
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.contentInset = UIEdgeInsetsZero;
    self.collectionView.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:self.collectionView];
    
    self.directionVertical = [NSUserDefaults.standardUserDefaults boolForKey:@"TestItemFlowCollectionViewController_direction"];
    
    [self reloadData];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    CGRect bounds = self.view.bounds;
    BOOL sizeChange = !CGSizeEqualToSize(bounds.size, self.collectionView.bounds.size);
    self.collectionView.frame = bounds;
    if (sizeChange) {
        [self reloadData];
    }
}

- (void)reloadData{
    [self.collectionView.model removeAllSectionModels];
    self.groupCategoryHeadSeciton.headClass = self.directionVertical ? LUIMenuItemFlowSectionView_Vertical.class : LUIMenuItemFlowSectionView.class;
    [self.collectionView.model addSectionModel:self.groupCategoryHeadSeciton];
    
    for (LUICollectionViewTitleSupplementarySectionModel *sectionModel in self.menuGroupSecitons) {
        [self configSectionModel:sectionModel];
        [self.model addSectionModel:sectionModel];
    }
    
    [self.model reloadCollectionViewData];
    [self.collectionView layoutIfNeeded];
    
    self.tabItemFlowView.directionVertical = self.directionVertical;
    self.tabItemFlowView.itemFlowView.items = self.menuGroups;
    [self.collectionView addSubview:self.tabItemFlowView];
    [self.collectionView bringSubviewToFront:self.tabItemFlowView];
    
    [self _configCategoryFrame];
    [self.categoryView.categoryView reloadDataWithAnimated:YES];
    
    [self _adjustConlectionContentInsets];
}

- (void)configSectionModel:(LUICollectionViewTitleSupplementarySectionModel *)sectionModel {
    [sectionModel removeAllCellModels];
    sectionModel.headClass = self.directionVertical?TestItem_SMHead_Vertical.class:MKUICollectionViewTitleSupplementaryView.class;
    MenuGroup *menuGroup = sm[@"menuGroup"];
    
    CGRect bounds = self.collectionView.bounds;
    CGSize itemSize = [self.class menuItemSize];
    UIEdgeInsets insets = [self menuGroupInsets];
    CGFloat space = [self.class groupInteritem];
    NSInteger lineCount = 2;
    NSInteger countPerRow = 0;
    if(bounds.size.width>0){
        countPerRow = (bounds.size.width-insets.left-insets.right+space)/(space+itemSize.width);
    }
    NSInteger expandCount = countPerRow*lineCount;
    
    BOOL needExpand = NO;
    NSInteger numberOfCells = menuGroup.menus.count;
    if(countPerRow>0){
        needExpand = numberOfCells>expandCount;
    }
    BOOL expandAll = [sm mk_boolForKeyPath:@"expandAll"];
    for(int i=0;i<numberOfCells;i++){
        if(!expandAll && needExpand && i>=expandCount-1) break;
        MenuCollectionViewCellModel *cm = [self _createCellModelWithMenu:menuGroup.menus[i]];
        @MK_WEAKIFY(self);
        @MK_WEAKIFY(sm);
        cm.whenClick = ^(MenuCollectionViewCellModel *cm) {
            @MK_NORMALIZE(self);
            @MK_NORMALIZE(sm);
            if(i!=0){
                [menuGroup removeMenu:cm.modelValue];
                [self configSectionModel:sm];
                [self.collectionView performBatchUpdates:^{
                    [sm refresh];
                } completion:^(BOOL finished) {
                    [self _adjustConlectionContentInsets];
                }];
            }else{
                NSMutableArray *menuGroups = [self.menuGroups mutableCopy];
                [menuGroups removeObject:menuGroup];
                self.menuGroups = menuGroups;
                
                NSMutableArray *menuGroupSecitons = [self.menuGroupSecitons mutableCopy];
                [menuGroupSecitons removeObject:sm];
                self.menuGroupSecitons = menuGroupSecitons;
                [self reloadData];
            }
        };
        [sm addCellModel:cm];
    }
    if(needExpand){
        //添加空白
        NSInteger lastLineItemCount = numberOfCells%countPerRow;
        if(expandAll){
            if(lastLineItemCount>0&&lastLineItemCount<countPerRow-1){
                for(int i=0;i<countPerRow-1-lastLineItemCount;i++){
                    MenuCollectionViewCellModel *cm = [[MenuCollectionViewCellModel alloc] initWithModelObject:nil];//添加空白
                    cm.cellClass = MenuCollectionViewCell.class;
                    [sm addCellModel:cm];
                }
            }
        }
        
        Menu *expandMenu = [[Menu alloc] init];
        expandMenu.title = expandAll?@"收起":@"展开";
        expandMenu.iconName = expandAll?nil:@"app-icon-6.png";
        MenuCollectionViewCellModel *cm = [[MenuCollectionViewCellModel alloc] initWithModelObject:expandMenu];
        @MK_WEAKIFY(self);
        cm.whenClick = ^(__kindof MKUICollectionViewCellModel * _Nonnull cm) {
            @MK_NORMALIZE(self);
            MKUICollectionViewTitleSupplementarySectionModel *sm = cm.sectionModel;
            BOOL expand = [sm mk_boolForKeyPath:@"expandAll"];
            expand = !expand;
            sm[@"expandAll"] = @(expand);
            [self configSectionModel:sm];
            [self.collectionView performBatchUpdates:^{
                [sm refresh];
            } completion:^(BOOL finished) {
                [self _adjustConlectionContentInsets];
            }];
        };
        cm.cellClass = MenuCollectionViewCell.class;
        if(expandAll && lastLineItemCount==0){
            cm[@"unExpandStyle"] = @(YES);//占用一整行的收起按钮
        }
        [sm addCellModel:cm];
    }
}

#pragma mark - getters/setters

- (LUICollectionViewTitleSupplementarySectionModel *)groupCategoryHeadSeciton {
    if (!_groupCategoryHeadSeciton) {
        _groupCategoryHeadSeciton = [[LUICollectionViewTitleSupplementarySectionModel alloc] init];
        _groupCategoryHeadSeciton.showHead = YES;
        _groupCategoryHeadSeciton.headClass = LUIMenuItemFlowSectionView.class;
    }
    return _groupCategoryHeadSeciton;
}

- (NSArray<LUICollectionViewTitleSupplementarySectionModel *> *)menuGroupSecitons {
    if(_menuGroupSecitons)return _menuGroupSecitons;
    NSMutableArray *sections = [[NSMutableArray alloc] init];
    for (MenuGroup *group in self.menuGroups) {
        LUICollectionViewTitleSupplementarySectionModel *sm = [self createSectionWithTitle:group.title];
        sm[@"isMenuGroup"] = @(YES);
        sm[@"menuGroup"] = group;
        sm[@"expandAll"] = @(NO);
        sm.headClass = self.directionVertical?TestItem_SMHead_Vertical.class:MKUICollectionViewTitleSupplementaryView.class;
        [sections addObject:sm];
    }
    _menuGroupSecitons = sections;
    return _menuGroupSecitons;
}

- (NSArray<LUIMenuGroup *> *)menuGroups {
    if(_menuGroups)return _menuGroups;
    NSMutableArray<LUIMenuGroup *> *groups = [[NSMutableArray alloc] init];
    for(int i=0;i<=30;i++){
        NSString *title = i%2==0?[NSString stringWithFormat:@"菜单(%@)",@(i).stringValue]:[NSString stringWithFormat:@"长长菜单(%@)",@(i).stringValue];
        NSArray<LUIMenu *> *menus = [LUIMenu sharedMenusWithCount:i+1];
        LUIMenuGroup *group = [LUIMenuGroup menuGroupWithTitle:title menus:menus];
        [groups addObject:group];
    }
    _menuGroups = groups;
    return _menuGroups;
}

@end
