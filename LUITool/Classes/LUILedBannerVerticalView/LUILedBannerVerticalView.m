//
//  LUILedBannerVerticalView.m
//  LUITool
//
//  Created by 六月 on 2024/9/2.
//

#import "LUICollectionViewPageFlowLayout.h"
#import "LUILedBannerVerticalView.h"
#import "LUICollectionView.h"
#import "LUIMacro.h"
#import "LUICollectionViewCellBase.h"

@interface LUILedBannerVerticalView () <LUICollectionViewDelegatePageFlowLayout>
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) LUICollectionView *collectionView;
@property (nonatomic, strong) LUICollectionViewPageFlowLayout *pageFlowLayout;
@end

@implementation LUILedBannerVerticalView
- (id)initWithFrame:(CGRect)frame {
    if (self=[super initWithFrame:frame]) {
        self.defaultContentCellClass = [LUICollectionViewCellBase class];
        self.contentView = [[UIView alloc] init];
        [self addSubview:self.contentView];
        
        self.pageFlowLayout = [[LUICollectionViewPageFlowLayout alloc] init];
        self.pageFlowLayout.pagingEnabled = YES;
        self.pageFlowLayout.enableCycleScroll = YES;
        self.pageFlowLayout.itemAlignment = LUICGRectAlignmentMin;
        self.pageFlowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.pageFlowLayout.interitemSpacing = 0;
        self.pageFlowLayout.sectionInset = UIEdgeInsetsMake(self.pageFlowLayout.interitemSpacing*0.5, 0, self.pageFlowLayout.interitemSpacing*0.5, 0);
        self.pageFlowLayout.pagingCellPosition = 0.5;
        self.pageFlowLayout.pagingBoundsPosition = 0.5;
        
        self.collectionView = [[LUICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.pageFlowLayout];
        self.collectionView.scrollsToTop = NO;
        self.collectionView.showsVerticalScrollIndicator = NO;
        self.collectionView.showsHorizontalScrollIndicator = NO;
        self.collectionView.backgroundColor = [UIColor clearColor];
        self.collectionView.scrollEnabled = NO;
        self.collectionView.model.forwardDelegate = self;
        [self.contentView addSubview:self.collectionView];
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    self.contentView.frame = bounds;
    {
        CGRect bounds = self.contentView.bounds;
        BOOL frameChange = !CGSizeEqualToSize(bounds.size, self.collectionView.frame.size);
        self.collectionView.frame = bounds;
        if (frameChange) {
            [self.collectionView reloadData];
        }
    }
}
- (void)__reloadData {
    [self.collectionView.model removeAllSectionModels];
    @LUI_WEAKIFY(self);
    for (int i=0; i<self.contents.count; i++) {
        NSObject *obj = self.contents[i];
        Class cellClass = self.defaultContentCellClass;
        if ([self.delegate respondsToSelector:@selector(ledBannerVerticalView:cellClassForBannerContent:)]) {
            cellClass = [self.delegate ledBannerVerticalView:self cellClassForBannerContent:obj];
        }
        if (!cellClass) {
            cellClass = self.defaultContentCellClass;
        }
        LUICollectionViewCellModel *cm = [LUICollectionViewCellModel modelWithValue:obj cellClass:cellClass whenClick:^(__kindof LUICollectionViewCellModel * _Nonnull cellModel) {
            @LUI_NORMALIZE(self);
            if ([self.delegate respondsToSelector:@selector(ledBannerVerticalView:didClickBannerWithIndex:bannerContent:)]) {
                [self.delegate ledBannerVerticalView:self didClickBannerWithIndex:i bannerContent:obj];
            }
        }];
        [self.collectionView.model addCellModel:cm];
    }
    [self.pageFlowLayout reloadData];
    [self.collectionView.model reloadCollectionViewData];
    
    if (self.currentIndex>=0 && self.currentIndex < self.contents.count) {
        [self.pageFlowLayout setIndexPathAtPagingCell:[NSIndexPath indexPathForItem:self.currentIndex inSection:0] animated:NO];
    }
}
- (void)reloadData {
    [self __reloadData];
}
- (void)setContents:(NSArray<NSObject *> *)contents {
    _contents = contents;
    [self reloadData];
}
- (NSInteger)currentIndex {
    NSInteger currentIndex = NSNotFound;
    NSIndexPath *indexpath = self.pageFlowLayout.indexPathAtPagingCell;
    if (indexpath) {
        currentIndex = indexpath.item;
    }
    return currentIndex;
}
- (void)setCurrentIndex:(NSInteger)currentIndex animated:(BOOL)animated {
    if (currentIndex>=0 && currentIndex<self.contents.count) {
        NSIndexPath *indexpath = [NSIndexPath indexPathForItem:currentIndex inSection:0];
        [self.pageFlowLayout setIndexPathAtPagingCell:indexpath animated:animated];
    }
}
- (void)setCurrentIndex:(NSInteger)currentIndex {
    [self setCurrentIndex:currentIndex animated:NO];
}
- (void)setCurrentIndexWithDistance:(NSInteger)distance animated:(BOOL)animated {
    [self.pageFlowLayout setIndexPathAtPagingCellWithDistance:distance animated:animated];
}
- (BOOL)isAutoScrolling {
    return self.pageFlowLayout.isAutoScrolling;
}
- (void)startAutoScrollingWithDistance:(NSInteger)distance duration:(NSTimeInterval)duration {
    [self.pageFlowLayout startAutoScrollingWithDistance:distance duration:duration];
}
- (void)stopAutoScrolling {
    [self.pageFlowLayout stopAutoScrolling];
}
- (void)dealloc {
    
}
#pragma mark - delegate:LUICollectionViewDelegatePageFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView pageFlowLayout:(LUICollectionViewPageFlowLayout *)collectionViewLayout itemSizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return collectionView.bounds.size;
}
- (void)collectionView:(UICollectionView *)collectionView pageFlowLayout:(LUICollectionViewPageFlowLayout *)collectionViewLayout didScrollToPagingCell:(NSIndexPath *)indexPathAtPagingCell {
    if ([self.delegate respondsToSelector:@selector(ledBannerVerticalView:didScrollToBannerWithIndex:)]) {
        [self.delegate ledBannerVerticalView:self didScrollToBannerWithIndex:indexPathAtPagingCell.item];
    }
}
@end
