//
//  LUITestItemFlow_Cell2.m
//  LUITool_Example
//
//  Created by 六月 on 2024/9/10.
//  Copyright © 2024 Your Name. All rights reserved.
//

#import "LUITestItemFlow_Cell2.h"
#import "LUIMenuGroup.h"
#import "LUIMenuCollectionViewCell.h"

@interface LUITestItemFlow_Cell2 ()<LUICollectionViewDelegateGridPageLayout>
@property(nonatomic,strong) LUICollectionView *collectionView;
@property(nonatomic,strong) LUIGridPageCollectionViewLayout *collectionlayout;
@property(nonatomic,strong) LUIPageControl *pageControl;
@end

@implementation LUITestItemFlow_Cell2
- (id)initWithFrame:(CGRect)frame{
    if(self=[super initWithFrame:frame]){
        self.backgroundColor = UIColor.l_listViewGroupBackgroundColor;
        self.collectionlayout = [[LUIGridPageCollectionViewLayout alloc] init];
        self.collectionlayout.itemSize = CGSizeMake(80, 80);
        self.collectionlayout.interitemSpacing = 10;
        self.collectionlayout.enableCycleScroll = YES;
        self.collectionlayout.sectionInset = LUIEdgeInsetsMakeSameEdge(10);
        self.collectionView = [[LUICollectionView alloc] initWithFrame:frame collectionViewLayout:self.collectionlayout];
        self.collectionView.backgroundColor = self.backgroundColor;
        self.collectionView.showsHorizontalScrollIndicator = NO;
        [self.contentView addSubview:self.collectionView];
        self.collectionView.model.forwardDelegate = self;
        self.collectionView.pagingEnabled = YES;
        //
        self.pageControl = [[LUIPageControl alloc] init];
        self.pageControl.pageIndicatorTintColor = [UIColor grayColor];
        self.pageControl.currentPageIndicatorTintColor = UIColor.systemBlueColor;
        [self.contentView addSubview:self.pageControl];
    }
    return self;
}
- (void)customLayoutSubviews{
    [super customLayoutSubviews];
    CGRect bounds = self.contentView.bounds;
    self.collectionView.frame = bounds;
    //
    CGRect f2 = self.pageControl.frame;
    f2.size.height = 10;
    f2.size.width = bounds.size.width;
    LUICGRectSetMaxYEdgeToRect(&f2, bounds, 2);
    self.pageControl.frame = f2;
}
- (void)customReloadCellModel{
    [super customReloadCellModel];
    NSArray<LUIMenu *> *menus = self.collectionCellModel.modelValue;
    LUICollectionViewModel *model = self.collectionView.model;
    [model removeAllSectionModels];
    for(LUIMenu *menu in menus){
        LUICollectionViewCellModel *cm = [[LUICollectionViewCellModel alloc] init];
        cm.modelValue = menu;
        cm.cellClass = LUIMenuCollectionViewCell.class;
        [model addCellModel:cm];
    }
    [model reloadCollectionViewData];
    [self.collectionlayout reloadData];
    self.pageControl.numberOfPages = self.collectionlayout.numberOfPages;
    self.pageControl.currentPage = self.collectionlayout.currentPage;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSInteger toPage;
    CGFloat progress = [self.collectionlayout scrollProgressWithContentOffset:scrollView.contentOffset toPage:&toPage];
    [self.pageControl scrollToPageIndex:toPage progress:progress];
}
- (void)collectionView:(UICollectionView *)collectionView gridPageLayout:(LUIGridPageCollectionViewLayout *)collectionViewLayout didScrollToPage:(NSInteger)page{
    self.pageControl.numberOfPages = self.collectionlayout.numberOfPages;
    self.pageControl.currentPage = self.collectionlayout.currentPage;
}
- (void)collectionView:(UICollectionView *)collectionView willDisplayCellModel:(__kindof LUICollectionViewCellModel *)cellModel{
    [self.collectionlayout reloadData];
    [self.collectionView layoutIfNeeded];
    self.pageControl.numberOfPages = self.collectionlayout.numberOfPages;
    self.pageControl.currentPage = self.collectionlayout.currentPage;
}
+ (CGSize)sizeWithCollectionView:(UICollectionView *)collectionView collectionCellModel:(__kindof LUICollectionViewCellModel *)collectionCellModel{
    CGRect bounds = collectionView.bounds;
    return CGSizeMake(bounds.size.width, 120);
}
@end
