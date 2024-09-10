//
//  LUIMenuViewController.m
//  LUITool_Example
//
//  Created by 六月 on 2023/9/9.
//  Copyright © 2024 Your Name. All rights reserved.
//

#import "LUIMenuViewController.h"
#import "LUIItemFlowView.h"
#import "LUIItemFlowSectionView.h"
#import "LUIItemFlowSectionView_Vertical.h"
#import "LUIMenuGroup.h"
#import "LUITestItemFlow_Cell1.h"
#import "LUITestItemHead_Vertical.h"
#import "LUIMenuCollectionViewCell.h"
#import "LUIItemFlowCell.h"
#import "LUIItemFlowCell_Vertical.h"

@interface LUIMenuViewController () <LUItemFlowCollectionViewDelegate>

@property (nonatomic, strong) LUICollectionView *collectionView;

@property (nonatomic, strong) LUICollectionViewTitleSupplementarySectionModel *firstSeciton;
@property (nonatomic, strong) LUICollectionViewTitleSupplementarySectionModel *secorndSeciton;
@property (nonatomic, strong) LUICollectionViewTitleSupplementarySectionModel *groupCategoryHeadSeciton;
@property (nonatomic, strong) NSArray<LUICollectionViewTitleSupplementarySectionModel *> *menuGroupSecitons;
@property (nonatomic, strong) NSArray<LUIMenuGroup *> *menuGroups;

@property (nonatomic, strong) LUICollectionViewFlowLayout *collectionViewFlowLayout;
@property (nonatomic, strong) LUIItemFlowView *tabItemFlowView;//分组
@property (nonatomic, assign) BOOL directionVertical;//横竖排列

@end

@implementation LUIMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.collectionViewFlowLayout = [[LUICollectionViewFlowLayout alloc] init];
    
    self.collectionView = [[LUICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.collectionViewFlowLayout];
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

- (void)reloadData {
    [self.collectionView.model removeAllSectionModels];
    [self.collectionView.model addSectionModel:self.firstSeciton];
    [self.collectionView.model addSectionModel:self.secorndSeciton];
    
    self.groupCategoryHeadSeciton.headClass = self.directionVertical ? LUIItemFlowSectionView_Vertical.class : LUIItemFlowSectionView.class;
    [self.collectionView.model addSectionModel:self.groupCategoryHeadSeciton];
    
    for (LUICollectionViewTitleSupplementarySectionModel *sectionModel in self.menuGroupSecitons) {
        [self configSectionModel:sectionModel];
        [self.collectionView.model addSectionModel:sectionModel];
    }
    
    [self.collectionView.model reloadCollectionViewData];
    [self.collectionView layoutIfNeeded];
    
    self.tabItemFlowView.directionVertical = self.directionVertical;
    self.tabItemFlowView.itemFlowView.items = self.menuGroups;
    [self.collectionView addSubview:self.tabItemFlowView];
    [self.collectionView bringSubviewToFront:self.tabItemFlowView];
    
    [self _configCategoryFrame];
    [self.tabItemFlowView.itemFlowView reloadDataWithAnimated:YES];
    
    [self _adjustConlectionContentInsets];
}

- (void)_configCategoryFrame{
    UICollectionViewLayoutAttributes *attr = [self.collectionViewFlowLayout layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathWithIndex:self.groupCategoryHeadSeciton.indexInModel]];
    CGRect f1 = attr.frame;
    [self _configCategoryFrameWithSMFrame:f1];
}
- (void)_configCategoryFrameWithSMFrame:(CGRect)frame{
    CGRect bounds = self.collectionView.bounds;
    UIEdgeInsets insets = self.collectionView.l_adjustedContentInset;
    CGRect f1 = frame;
    if(self.directionVertical) {
        f1.size.width = [LUIItemFlowView sizeWithDirectionVertical:self.directionVertical];
        f1.size.height = bounds.size.height-insets.top;
    }else{
        f1.size.height = [LUIItemFlowView sizeWithDirectionVertical:self.directionVertical];;
        f1.size.width = bounds.size.width;
    }
    self.tabItemFlowView.l_frameSafety = f1;
    [self.tabItemFlowView layoutIfNeeded];//马上布局
    
    UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        safeAreaInsets = self.view.safeAreaInsets;
    }
    UIEdgeInsets cinsets = UIEdgeInsetsZero;
    if(self.directionVertical){
        cinsets.bottom = safeAreaInsets.bottom;
    }
    self.tabItemFlowView.itemFlowView.collectionView.contentInset = cinsets;
}

- (void)_adjustConlectionContentInsets{
    if(self.menuGroups.count==0)return;
    CGPoint offset = [self contentOffsetWithSelectedIndex:self.menuGroups.count-1 limitInRange:NO];
    
    CGRect bounds = self.collectionView.bounds;
    CGSize contentSize = self.collectionView.contentSize;
    UIEdgeInsets contentInset = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        contentInset = self.collectionView.safeAreaInsets;
    }
    CGFloat maxY = contentSize.height-bounds.size.height+contentInset.bottom;
    
    UIEdgeInsets insets = self.collectionView.contentInset;
    if(offset.y>maxY){
        insets.bottom = offset.y-maxY;
    }else{
        insets.bottom = 0;
    }
    self.collectionView.contentInset = insets;
}

+ (CGSize)menuItemSize{
    return CGSizeMake(80, 80);
}
- (UIEdgeInsets)menuGroupInsets{
    UIEdgeInsets insets = UIEdgeInsetsMake(10, 10, 10, 10);
    if(self.directionVertical){
        insets.left += [LUIItemFlowView sizeWithDirectionVertical:YES];
    }
    return insets;
}
+ (CGFloat)groupInteritem{
    return 10;
}

- (void)configSectionModel:(LUICollectionViewTitleSupplementarySectionModel *)sectionModel {
    [sectionModel removeAllCellModels];
    sectionModel.headClass = self.directionVertical?LUITestItemHead_Vertical.class:LUICollectionViewTitleSupplementaryView.class;
    LUIMenuGroup *menuGroup = sectionModel[@"menuGroup"];
    
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
    BOOL expandAll = [sectionModel l_boolForKeyPath:@"expandAll"];
    for(int i=0;i<numberOfCells;i++){
        if(!expandAll && needExpand && i>=expandCount-1) break;
        LUICollectionViewCellModel *cm = [[LUICollectionViewCellModel alloc] init];
        cm.modelValue = menuGroup.menus[i];
        cm.cellClass = LUIMenuCollectionViewCell.class;
        @LUI_WEAKIFY(self);
        @LUI_WEAKIFY(sectionModel);
        cm.whenClick = ^(LUICollectionViewCellModel *cm) {
            @LUI_NORMALIZE(self);
            @LUI_NORMALIZE(sectionModel);
            if(i!=0){
                [menuGroup removeMenu:cm.modelValue];
                [self configSectionModel:sectionModel];
                [self.collectionView performBatchUpdates:^{
                    [sectionModel refresh];
                } completion:^(BOOL finished) {
                    [self _adjustConlectionContentInsets];
                }];
            }else{
                NSMutableArray *menuGroups = [self.menuGroups mutableCopy];
                [menuGroups removeObject:menuGroup];
                self.menuGroups = menuGroups;
                
                NSMutableArray *menuGroupSecitons = [self.menuGroupSecitons mutableCopy];
                [menuGroupSecitons removeObject:sectionModel];
                self.menuGroupSecitons = menuGroupSecitons;
                [self reloadData];
            }
        };
        [sectionModel addCellModel:cm];
    }
    if(needExpand){
        //添加空白
        NSInteger lastLineItemCount = numberOfCells%countPerRow;
        if (expandAll) {
            if (lastLineItemCount>0&&lastLineItemCount<countPerRow-1) {
                for (int i=0;i<countPerRow-1-lastLineItemCount;i++) {
                    LUICollectionViewCellModel *cm = [[LUICollectionViewCellModel alloc] init];//添加空白
                    cm.cellClass = LUIMenuCollectionViewCell.class;
                    [sectionModel addCellModel:cm];
                }
            }
        }
        
        LUIMenu *expandMenu = [[LUIMenu alloc] init];
        expandMenu.title = expandAll ? @"收起" : @"展开";
        expandMenu.iconName = expandAll?nil:@"app-icon-6.png";
        LUICollectionViewCellModel *cm = [[LUICollectionViewCellModel alloc] init];
        cm.modelValue = expandMenu;
        cm.cellClass = LUIMenuCollectionViewCell.class;
        @LUI_WEAKIFY(self);
        cm.whenClick = ^(__kindof LUICollectionViewCellModel * _Nonnull cm) {
            @LUI_NORMALIZE(self);
            LUICollectionViewTitleSupplementarySectionModel *sm = cm.sectionModel;
            BOOL expand = [sectionModel l_boolForKeyPath:@"expandAll"];
            expand = !expand;
            sm[@"expandAll"] = @(expand);
            [self configSectionModel:sm];
            [self.collectionView performBatchUpdates:^{
                [sm refresh];
            } completion:^(BOOL finished) {
                [self _adjustConlectionContentInsets];
            }];
        };
        cm.cellClass = LUIMenuCollectionViewCell.class;
        if(expandAll && lastLineItemCount==0){
            cm[@"unExpandStyle"] = @(YES);//占用一整行的收起按钮
        }
        [sectionModel addCellModel:cm];
    }
}

- (CGPoint)contentOffsetWithSelectedIndex:(NSInteger)selectedIndex{
    return [self contentOffsetWithSelectedIndex:selectedIndex limitInRange:YES];
}
- (CGPoint)contentOffsetWithSelectedIndex:(NSInteger)selectedIndex limitInRange:(BOOL)limitInRange{
    if(selectedIndex<0||selectedIndex>=self.tabItemFlowView.itemFlowView.items.count)return CGPointZero;
    LUICollectionViewTitleSupplementarySectionModel *sm = self.menuGroupSecitons[selectedIndex];
    UIEdgeInsets contentInsets = self.collectionView.l_adjustedContentInset;
    CGPoint offset = self.collectionView.contentOffset;
    UICollectionViewLayoutAttributes *attr = [self.collectionViewFlowLayout layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathWithIndex:sm.indexInModel]];
//    UICollectionViewLayoutAttributes *attr = [self.collectionViewFlowLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:sm.indexInModel]];
    CGRect f1 = attr.frame;
    
    offset.y = f1.origin.y+contentInsets.top;
    if(self.directionVertical){
        offset.y = f1.origin.y-contentInsets.top;
    }else{
        CGRect f2 = self.tabItemFlowView.l_frameSafety;
        offset.y = f1.origin.y-f2.size.height-contentInsets.top;
    }
    if(limitInRange){
        offset.y = MIN(self.collectionView.l_contentOffsetOfMaxY,offset.y);
    }
//    NSLog(@"contentOffsetWithSelectedIndex:%@,offset:%@",@(selectedIndex).stringValue,NSStringFromCGPoint(offset));
    return offset;
    
}

- (LUICollectionViewTitleSupplementarySectionModel *)createEmptySection{
    LUICollectionViewTitleSupplementarySectionModel *sm = [[LUICollectionViewTitleSupplementarySectionModel alloc] init];
    sm.footClass = LUIItemFlowSectionView.class;
    sm.showFoot = YES;
    return sm;
}

- (LUICollectionViewTitleSupplementarySectionModel *)createSectionWithTitle:(NSString *)title{
    LUICollectionViewTitleSupplementarySectionModel *sm = [[LUICollectionViewTitleSupplementarySectionModel alloc] init];
    sm.showHead = YES;
    sm.headTitle = title;
    sm.headClass = LUICollectionViewTitleSupplementaryView.class;
    sm.footClass = LUIItemFlowSectionView.class;
    sm.showFoot = YES;
    return sm;
}

#pragma mark - delegate:LUItemFlowCollectionViewDelegate

- (CGSize)itemFlowCollectionView:(LUItemFlowCollectionView *)view itemSizeAtIndex:(NSInteger)index collectionCellModel:(LUICollectionViewCellModel *)cellModel{
    Class cls = self.directionVertical?LUIItemFlowCell_Vertical.class: LUIItemFlowCell.class;
    CGSize size = [cls sizeWithCollectionView:view.collectionView collectionCellModel:cellModel];
    return size;
}
- (Class)itemFlowCollectionView:(LUItemFlowCollectionView *)view itemCellClassAtIndex:(NSInteger)index{
    return self.directionVertical?LUIItemFlowCell_Vertical.class:LUIItemFlowCell.class;
}
- (void)itemFlowCollectionView:(LUItemFlowCollectionView *)view didSelectIndex:(NSInteger)selectedIndex{
    [view setSelectedIndex:selectedIndex animated:YES];
    CGPoint offset = [self contentOffsetWithSelectedIndex:selectedIndex];
    [self.collectionView setContentOffset:offset animated:YES];
}

#pragma mark - getters/setters

- (LUICollectionViewTitleSupplementarySectionModel *)firstSeciton{
    if(_firstSeciton)return _firstSeciton;
    LUICollectionViewTitleSupplementarySectionModel *sm = [self createEmptySection];
    _firstSeciton = sm;
    [sm addCellModel:[LUICollectionViewCellModel modelWithValue:@"第一行" cellClass:LUITestItemFlow_Cell1.class]];
    return _firstSeciton;
}
- (LUICollectionViewTitleSupplementarySectionModel *)secorndSeciton{
    if(_secorndSeciton)return _secorndSeciton;
    LUICollectionViewTitleSupplementarySectionModel *sm = [self createSectionWithTitle:@"左右滑动菜单"];
    _secorndSeciton = sm;
    [sm addCellModel:[LUICollectionViewCellModel modelWithValue:@"第二行" cellClass:LUITestItemFlow_Cell1.class]];
    return _secorndSeciton;
}

- (LUICollectionViewTitleSupplementarySectionModel *)groupCategoryHeadSeciton {
    if (!_groupCategoryHeadSeciton) {
        _groupCategoryHeadSeciton = [[LUICollectionViewTitleSupplementarySectionModel alloc] init];
        _groupCategoryHeadSeciton.showHead = YES;
        _groupCategoryHeadSeciton.headClass = LUIItemFlowSectionView.class;
    }
    return _groupCategoryHeadSeciton;
}

- (NSArray<LUICollectionViewTitleSupplementarySectionModel *> *)menuGroupSecitons {
    if(_menuGroupSecitons)return _menuGroupSecitons;
    NSMutableArray *sections = [[NSMutableArray alloc] init];
    for (LUIMenuGroup *group in self.menuGroups) {
        LUICollectionViewTitleSupplementarySectionModel *sm = [self createSectionWithTitle:group.title];
        sm[@"isMenuGroup"] = @(YES);
        sm[@"menuGroup"] = group;
        sm[@"expandAll"] = @(NO);
        sm.headClass = self.directionVertical?LUITestItemHead_Vertical.class:LUICollectionViewTitleSupplementaryView.class;
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

- (LUIItemFlowView *)tabItemFlowView {
    if (!_tabItemFlowView) {
        _tabItemFlowView = [[LUIItemFlowView alloc] init];
        [_tabItemFlowView.directionButton l_addClickActionBlock:^(id  _Nullable conext) {
            self.directionVertical = !self.directionVertical;
            [NSUserDefaults.standardUserDefaults setBool:self.directionVertical forKey:@"TestItemFlowCollectionViewController_direction"];
            _tabItemFlowView.directionVertical = self.directionVertical;
            [self reloadData];
        } context:self];
        _tabItemFlowView.itemFlowView.delegate = self;
        _tabItemFlowView.itemFlowView.items = self.menuGroups;
        _tabItemFlowView.itemFlowView.selectedIndex = 0;
    }
    return _tabItemFlowView;
}

@end
