//
//  LUIPageControl.m
//  LUITool
//
//  Created by 六月 on 2024/9/5.
//

#import "LUIPageControl.h"
#import "LUICollectionView.h"
#import "UIView+LUI.h"
#import "UICollectionViewFlowLayout+LUI.h"
#import "UIScrollView+LUI.h"
#import "LUICGRect.h"
#import "LUICollectionViewPageFlowLayout.h"
#import "NSArray+LUI_BinarySearch.h"
#import "LUIFlowLayoutConstraint.h"
@implementation LUIPageIndicatorCollectionViewModel
@end

@implementation LUIPageIndicatorCollectionViewBase
- (LUIPageIndicatorCollectionViewModel *)pageControlCellModel{
    return (LUIPageIndicatorCollectionViewModel *)self.collectionCellModel;
}
- (void)customReloadCellModel{
    [super customReloadCellModel];
    LUIPageIndicatorCollectionViewModel *pageControlCellModel = self.pageControlCellModel;
    LUIPageControl *pageControl = pageControlCellModel.pageControl;
    NSRange range = pageControlCellModel.visiblePages;
    self.transform = [self transformWithScaleEdgePageIndicatorWithCurrentPage:pageControl.currentPage visiblePages:range];
}
- (CGAffineTransform)transformWithScaleEdgePageIndicatorWithCurrentPage:(NSInteger)currentPage visiblePages:(NSRange)range{
    LUIPageIndicatorCollectionViewModel *pageControlCellModel = self.pageControlCellModel;
    LUIPageControl *pageControl = pageControlCellModel.pageControl;
    NSInteger page = pageControlCellModel.indexPathInModel.item;
    NSInteger numberOfPages = pageControl.numberOfPages;
    
    CGAffineTransform m = CGAffineTransformIdentity;
    if(pageControl.scaleEdgePageIndicator && range.location!=NSNotFound){
        CGFloat scale = 1;
        NSInteger minPage = range.location;
        NSInteger maxPage = NSMaxRange(range)-1;
        if(minPage>0 && page<currentPage){
            if(page==minPage){
                scale = 0.5;
            }else if(page==minPage+1){
                scale = 0.75;
            }else if(page<minPage){
                scale = 0;
            }
        }
        if(maxPage<numberOfPages-1 && page>currentPage){
            if(page==maxPage){
                scale = 0.5;
            }else if(page==maxPage-1){
                scale = 0.75;
            }else if(page>maxPage){
                scale = 0;
            }
        }
        m = CGAffineTransformMakeScale(scale,scale);
    }
    return m;
}
+ (CGSize)sizeForPageControl:(LUIPageControl *)pageControl pageIndex:(NSInteger)pageIndex selected:(BOOL)selected{
    return CGSizeMake(9, 9);
}
@end

@interface LUIDotPageIndicatorCollectionView()
@property(nonatomic,strong) UIView *pageDotView;//圆点视图
@property(nonatomic,strong) UIImageView *pageImageView;//页码图片
@end

@implementation LUIDotPageIndicatorCollectionView
- (id)initWithFrame:(CGRect)frame{
    if(self=[super initWithFrame:frame]){
        self.pageDotView = [[UIView alloc] init];
        self.pageDotView.clipsToBounds = YES;
        [self.contentView addSubview:self.pageDotView];
        
        self.pageImageView = [[UIImageView alloc] init];
        self.pageImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.pageImageView];
    }
    return self;
}
+ (UIEdgeInsets)pageContentInsets{
    return UIEdgeInsetsZero;
}
- (void)customLayoutSubviews{
    [super customLayoutSubviews];
    CGRect bounds = self.contentView.bounds;
    UIEdgeInsets insets = [self.class pageContentInsets];
    CGRect contentBounds = UIEdgeInsetsInsetRect(bounds, insets);
    CGRect f1 = contentBounds;
    LUICGRectAlignMidXToRect(&f1, bounds);
    LUICGRectAlignMidYToRect(&f1, bounds);
    self.pageDotView.l_frameSafety = f1;
    self.pageDotView.layer.cornerRadius = MIN(f1.size.width,f1.size.height)/2.0;
    //
    CGRect f2 = contentBounds;
    self.pageImageView.frame = f2;
}
- (void)customReloadCellModel{
    [super customReloadCellModel];
    LUIPageIndicatorCollectionViewModel *cellModel = self.pageControlCellModel;
    LUIPageControl *pageControl = cellModel.pageControl;
    BOOL selected = self.collectionCellModel.selected;
    self.pageDotView.backgroundColor = selected?pageControl.currentPageIndicatorTintColor:pageControl.pageIndicatorTintColor;
    UIImage *image = selected?pageControl.currentPageIndicatorImage:pageControl.pageIndicatorImage;
    self.pageImageView.image = image;
    
    self.pageDotView.hidden = image!=nil;
    self.pageImageView.hidden = !self.pageDotView.hidden;
}
+ (CGSize)maxSize{
    return CGSizeMake(8, 8);
}
+ (CGSize)sizeForPageControl:(LUIPageControl *)pageControl pageIndex:(NSInteger)pageIndex selected:(BOOL)selected{
    UIEdgeInsets pageContentInsets = [self pageContentInsets];
    UIImage *image = selected?pageControl.currentPageIndicatorImage:pageControl.pageIndicatorImage;
    CGSize maxSize = [self.class maxSize];
    CGSize s = maxSize;
    if(image){
        LUICGAxis X = pageControl.scrollAxis;
        LUICGAxis Y = LUICGAxisReverse(X);
        CGSize maxSize = CGSizeZero;
        LUICGSizeSetLength(&maxSize, X, 9999999);
        LUICGSizeSetLength(&maxSize, Y, LUICGSizeGetLength(maxSize, Y)-LUIEdgeInsetsGetEdgeSum(pageContentInsets, Y));
        s = [LUICGRect scaleSize:image.size aspectFitToSize:maxSize];
        LUICGSizeAddLength(&s, X, LUIEdgeInsetsGetEdgeSum(pageContentInsets, X));
        LUICGSizeAddLength(&s, Y, LUIEdgeInsetsGetEdgeSum(pageContentInsets, Y));
    }
    return s;
}
@end

@interface LUIColorDotPageIndicatorCollectionView()
@property(nonatomic,strong) UIView *pageDotView;//圆点视图
@end
@implementation LUIColorDotPageIndicatorCollectionView
- (id)initWithFrame:(CGRect)frame{
    if(self=[super initWithFrame:frame]){
        self.clipsToBounds = NO;
        self.pageDotView = [[UIView alloc] init];
        self.pageDotView.clipsToBounds = YES;
        [self.contentView addSubview:self.pageDotView];
    }
    return self;
}
+ (UIEdgeInsets)pageContentInsets{
    return UIEdgeInsetsZero;
}
- (void)customLayoutSubviews{
    [super customLayoutSubviews];
    CGRect bounds = self.contentView.bounds;
    UIEdgeInsets insets = [self.class pageContentInsets];
    CGRect contentBounds = UIEdgeInsetsInsetRect(bounds, insets);
    CGRect f1 = contentBounds;
    self.pageDotView.l_frameSafety = f1;
    self.pageDotView.layer.cornerRadius = MIN(f1.size.width,f1.size.height)/2.0;
}
- (void)customReloadCellModel{
    [super customReloadCellModel];
    LUIPageIndicatorCollectionViewModel *cellModel = self.pageControlCellModel;
    LUIPageControl *pageControl = cellModel.pageControl;
    BOOL selected = self.collectionCellModel.selected;
    self.pageDotView.backgroundColor = selected?pageControl.currentPageIndicatorTintColor:pageControl.pageIndicatorTintColor;
}
- (void)pageControl:(LUIPageControl *)pageControl didScrollToPage:(NSInteger)pageIndex progress:(CGFloat)progress{
    NSInteger currentPageIndex = pageControl.currentPage;
    NSInteger numberOfPages = pageControl.numberOfPages;
    NSInteger myPageIndex = self.pageControlCellModel.indexInSectionModel;
    LUICGAxis X = pageControl.scrollAxis;
    LUICGAxis Y = LUICGAxisReverse(X);
    CGRect bounds = self.contentView.bounds;
    UIEdgeInsets insets = [self.class pageContentInsets];
    CGRect contentBounds = UIEdgeInsetsInsetRect(bounds, insets);
    CGRect f1 = contentBounds;
    UIColor *selectedColor = pageControl.currentPageIndicatorTintColor;
    UIColor *normalColor = pageControl.pageIndicatorTintColor;
    UIColor *color;
    CGAffineTransform m = self.transform;
    if(myPageIndex==currentPageIndex && currentPageIndex!=pageIndex){//从选中过渡到未选中
        CGSize size = [pageControl pageIndicatorCellSizeForPageIndex:currentPageIndex selected:NO];
        CGRect tmpBounds = bounds;
        tmpBounds.size = size;
        LUICGRectAlignMidToRect(&tmpBounds, Y, bounds);
        CGRect f2 = UIEdgeInsetsInsetRect(tmpBounds, insets);
        if(pageIndex<currentPageIndex){
            LUICGRectAlignMaxToRect(&f2, X, contentBounds);
        }
        f1 = LUICGRectInterpolate(f1, f2, progress);
        //颜色渐变
        color = LUIColorInterpolate(selectedColor, normalColor, progress);
    }else if(myPageIndex==pageIndex && currentPageIndex!=pageIndex){//从未选中过渡到选中
        CGSize size = [pageControl pageIndicatorCellSizeForPageIndex:currentPageIndex selected:YES];
        CGRect tmpBounds = bounds;
        tmpBounds.size = size;
        LUICGRectAlignMidToRect(&tmpBounds, Y, bounds);
        CGRect f2 = UIEdgeInsetsInsetRect(tmpBounds, insets);
        if(currentPageIndex<pageIndex){
            LUICGRectAlignMaxToRect(&f2, X, contentBounds);
        }
        f1 = LUICGRectInterpolate(f1, f2, progress);
        //颜色渐变
        color = LUIColorInterpolate(normalColor, selectedColor, progress);
    }else{//恢复为选中、未选中状态
        if(currentPageIndex==numberOfPages-1 && pageIndex==0){//从末尾选中，过渡到头部选中
            CGSize size1 = [pageControl pageIndicatorCellSizeForPageIndex:currentPageIndex selected:NO];
            CGSize size2 = [pageControl pageIndicatorCellSizeForPageIndex:currentPageIndex selected:YES];
            CGFloat deltaWidth = LUICGSizeGetLength(size2, X)-LUICGSizeGetLength(size1, X);
            CGFloat dx = LUICGFloatInterpolate(0, deltaWidth, progress);
            LUICGRectAddMin(&f1, X, dx);
        }else if(currentPageIndex==0 && pageIndex==numberOfPages-1){//从头部选中，过渡到末尾选中
            CGSize size1 = [pageControl pageIndicatorCellSizeForPageIndex:currentPageIndex selected:NO];
            CGSize size2 = [pageControl pageIndicatorCellSizeForPageIndex:currentPageIndex selected:YES];
            CGFloat deltaWidth = LUICGSizeGetLength(size2, X)-LUICGSizeGetLength(size1, X);
            CGFloat dx = LUICGFloatInterpolate(0, deltaWidth, progress);
            LUICGRectAddMin(&f1, X, -dx);
        }
        color = self.pageControlCellModel.selected?selectedColor:normalColor;
        NSRange range1 = [pageControl visiblePagesForCurrentPage:currentPageIndex];
        NSRange range2 = [pageControl visiblePagesForCurrentPage:pageIndex];
        CGAffineTransform m1 = [self transformWithScaleEdgePageIndicatorWithCurrentPage:currentPageIndex visiblePages:range1];
        CGAffineTransform m2 = m1;
        if(range2.length>0 && myPageIndex>=range2.location && myPageIndex<NSMaxRange(range2)){
            m2 = [self transformWithScaleEdgePageIndicatorWithCurrentPage:pageIndex visiblePages:range2];
        }
        m = LUICGAffineTransformInterpolate(m1, m2, progress);
    }
    self.pageDotView.l_frameSafety = f1;
    self.pageDotView.layer.cornerRadius = MIN(f1.size.width,f1.size.height)/2.0;
    self.pageDotView.backgroundColor = color;
    self.transform = m;
}
@end

@interface _LUIPageControlPageCellAttributes : NSObject
@property(nonatomic,assign) CGRect frame;
@property(nonatomic,assign) CGRect selectedFrame;
@property(nonatomic,assign) NSInteger index;
@end
@implementation _LUIPageControlPageCellAttributes
@end

@interface LUIPageControl()<LUICollectionViewDelegatePageFlowLayout>{
    BOOL _reloadWithAnimated;
}
@property(nonatomic,strong) LUICollectionView *collectionView;
@property(nonatomic,strong) LUICollectionViewPageFlowLayout *collectionLayout;
@property(nonatomic,strong) NSArray<_LUIPageControlPageCellAttributes *> *pageCellAttributes;
@property(nonatomic,assign) CGFloat allCellContentWidth;
@end

@implementation LUIPageControl
- (id)initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        [self __LUIPageControl_initViews];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)coder{
    if (self=[super initWithCoder:coder]) {
        [self __LUIPageControl_initViews];
    }
    return self;
}
- (void)__LUIPageControl_initViews{
    self.userInteractionEnabled = NO;
    self.scaleEdgePageIndicator = YES;
    self.direction = LUIPageControlDirectionHorizontal;
    self.interitemSpacing = 9;
    self.contentInsets = UIEdgeInsetsZero;
    self.pageIndicatorCellClass = [LUIDotPageIndicatorCollectionView class];
    self.currentPageIndicatorCellClass = [LUIDotPageIndicatorCollectionView class];
    
    self.collectionLayout = [[LUICollectionViewPageFlowLayout alloc] init];
    self.collectionLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.collectionView = [[LUICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.collectionLayout];
    self.collectionView.scrollsToTop = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.clipsToBounds = NO;
    self.collectionView.model.forwardDelegate = self;
    [self addSubview:self.collectionView];
    
    //    self.layer.borderColor = [UIColor grayColor].CGColor;
    //    self.layer.borderWidth = 1;
    //    self.collectionView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    //    self.collectionView.layer.borderWidth = 1;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    CGRect b1 = UIEdgeInsetsInsetRect(bounds, self.contentInsets);
    CGRect f1 = b1;
    CGSize s1 = [self __collectionSizeForNumberOfPages:self.numberOfPages];
    f1.size.height = MIN(f1.size.height,s1.height);
    f1.size.width = MIN(f1.size.width,s1.width);
    LUICGRectAlignMidXToRect(&f1, b1);
    LUICGRectAlignMidYToRect(&f1, b1);
    self.collectionView.frame = f1;
    [self __reloadData];
}
- (CGSize)sizeThatFits:(CGSize)size{
    LUICGAxis X = self.scrollAxis;
    LUICGAxis Y = LUICGAxisReverse(X);
    CGSize fitSize = [self sizeForNumberOfPages:self.numberOfPages];
    LUICGSizeSetLength(&fitSize, X, MIN(LUICGSizeGetLength(size, X),LUICGSizeGetLength(fitSize, X)));
    LUICGSizeSetLength(&fitSize, Y, MIN(LUICGSizeGetLength(size, Y),LUICGSizeGetLength(fitSize, Y)));
    return fitSize;
}
- (CGSize)intrinsicContentSize{
    CGSize fitSize = [self sizeForNumberOfPages:self.numberOfPages];
    return fitSize;
}
- (LUICGAxis)scrollAxis{
    return (self.direction==LUIPageControlDirectionHorizontal)?LUICGAxisX:LUICGAxisY;
}
- (void)setNumberOfPages:(NSInteger)numberOfPages{
    if(numberOfPages>=0&&_numberOfPages!=numberOfPages){
        _numberOfPages = numberOfPages;
        [self setCurrentPage:MIN(self.numberOfPages-1,self.currentPage) animated:NO];
        [self __setNeedReloadView];
    }
}
- (void)setCurrentPage:(NSInteger)currentPage{
    [self setCurrentPage:currentPage animated:YES];
}
- (void)setCurrentPage:(NSInteger)currentPage animated:(BOOL)animated{
    if(currentPage>=0&&currentPage<self.numberOfPages&&_currentPage!=currentPage){
        _reloadWithAnimated = animated;
        _currentPage = currentPage;
        [self __setNeedReloadView];
    }
}
- (void)setHidesForSinglePage:(BOOL)hidesForSinglePage{
    if(_hidesForSinglePage==hidesForSinglePage)return;
    _hidesForSinglePage = hidesForSinglePage;
    [self __setNeedReloadView];
}
- (void)setPageIndicatorTintColor:(UIColor *)pageIndicatorTintColor{
    if(_pageIndicatorTintColor==pageIndicatorTintColor || [_pageIndicatorTintColor isEqual:pageIndicatorTintColor])return;
    _pageIndicatorTintColor = pageIndicatorTintColor;
    [self __setNeedReloadView];
}
- (void)setCurrentPageIndicatorTintColor:(UIColor *)currentPageIndicatorTintColor{
    if(_currentPageIndicatorTintColor==currentPageIndicatorTintColor || [_currentPageIndicatorTintColor isEqual:currentPageIndicatorTintColor])return;
    _currentPageIndicatorTintColor = currentPageIndicatorTintColor;
    [self __setNeedReloadView];
}
- (void)setPageIndicatorImage:(UIImage *)pageIndicatorImage{
    if(_pageIndicatorImage==pageIndicatorImage || [_pageIndicatorImage isEqual:pageIndicatorImage])return;
    _pageIndicatorImage = pageIndicatorImage;
    [self __setNeedReloadView];
}
- (void)setCurrentPageIndicatorImage:(UIImage *)currentPageIndicatorImage{
    if(_currentPageIndicatorImage==currentPageIndicatorImage || [_currentPageIndicatorImage isEqual:currentPageIndicatorImage])return;
    _currentPageIndicatorImage = currentPageIndicatorImage;
    [self __setNeedReloadView];
}
- (void)setDirection:(LUIPageControlDirection)direction{
    if(_direction==direction)return;
    _direction = direction;
    [self __setNeedReloadView];
}
- (void)setContentInsets:(UIEdgeInsets)contentInsets{
    if(UIEdgeInsetsEqualToEdgeInsets(_contentInsets, contentInsets))return;
    _contentInsets = contentInsets;
    [self __setNeedReloadView];
}
- (void)setInteritemSpacing:(CGFloat)interitemSpacing{
    if(_interitemSpacing==interitemSpacing)return;
    _interitemSpacing = interitemSpacing;
    [self __setNeedReloadView];
}
- (void)setScaleEdgePageIndicator:(BOOL)scaleEdgePageIndicator{
    if(_scaleEdgePageIndicator==scaleEdgePageIndicator)return;
    _scaleEdgePageIndicator = scaleEdgePageIndicator;
    [self __setNeedReloadView];
}
- (void)setPageIndicatorCellClass:(Class<LUIPageIndicatorCollectionViewProtocol>)pageIndicatorCellClass{
    if(_pageIndicatorCellClass==pageIndicatorCellClass)return;
    _pageIndicatorCellClass = pageIndicatorCellClass;
    [self __setNeedReloadView];
}
- (void)setCurrentPageIndicatorCellClass:(Class<LUIPageIndicatorCollectionViewProtocol>)currentPageIndicatorCellClass{
    if(_currentPageIndicatorCellClass==currentPageIndicatorCellClass)return;
    _currentPageIndicatorCellClass = currentPageIndicatorCellClass;
    [self __setNeedReloadView];
}
- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount{
    if(pageCount==0||(pageCount==1&&self.hidesForSinglePage)){
        return CGSizeZero;
    }
    UIEdgeInsets contentInsets = self.contentInsets;
    CGSize size = [self __collectionSizeForNumberOfPages:pageCount];
    size.width += contentInsets.left+contentInsets.right;
    size.height += contentInsets.top+contentInsets.bottom;
    return size;
}
- (Class)pageIndicatorCellClassForPage:(NSInteger)page{
    return self.pageIndicatorCellClass;
}
- (Class)currentPageIndicatorCellClassForPage:(NSInteger)page{
    return self.currentPageIndicatorCellClass;
}
- (LUIPageIndicatorCollectionViewModel *)createPageIndicatorCollectionViewModelForPage:(NSInteger)page{
    LUIPageIndicatorCollectionViewModel *cm = [[LUIPageIndicatorCollectionViewModel alloc] init];
    return cm;
}
- (NSRange)visiblePages{
    return [self visiblePagesForCurrentPage:self.currentPage];
}
- (NSRange)visiblePagesForCurrentPage:(NSInteger)currentPage{
    NSInteger pageCount = self.numberOfPages;
    if(pageCount<0||currentPage<0||currentPage>=pageCount){
        return NSMakeRange(NSNotFound, 0);
    }
    LUICGAxis X = [self scrollAxis];
    CGRect bounds = self.collectionView.bounds;
    CGRect visiableBounds = bounds;
    CGRect selectedFrame = self.pageCellAttributes[currentPage].selectedFrame;
    CGFloat x = LUICGRectGetMid(selectedFrame, X)-LUICGRectGetLength(bounds, X)*0.5;
    x = MAX(x,0);
    x = MIN(x,self.allCellContentWidth-LUICGRectGetLength(bounds, X));
    LUICGRectSetMin(&visiableBounds, X, x);
    
    NSRange range = [self.pageCellAttributes l_rangeOfSortedObjectsWithComparator:^NSComparisonResult(_LUIPageControlPageCellAttributes * _Nonnull arrayObj, NSInteger idx) {
        CGRect f1 = currentPage==idx?arrayObj.selectedFrame:arrayObj.frame;
        NSComparisonResult r = LUICGRectCompareWithCGRect(f1, visiableBounds, X);
//        NSLog(@"l_rangeOfSortedObjectsWithComparator");
        return r;
    }];
//    NSLog(@"visiblePagesForCurrentPage:%@",NSStringFromRange(range));
    return range;
}
- (CGSize)pageIndicatorCellSizeForPageIndex:(NSInteger)pageIndex selected:(BOOL)selected{
    CGSize s = selected?self.currentPageIndicatorSize:self.pageIndicatorSize;
    if(!CGSizeEqualToSize(s, CGSizeZero)){
        return s;
    }
    Class c1 = selected?[self currentPageIndicatorCellClassForPage:pageIndex]:[self pageIndicatorCellClassForPage:pageIndex];
    CGSize s1 = [c1 sizeForPageControl:self pageIndex:pageIndex selected:selected];
    return s1;
}
- (void)scrollToPageIndex:(NSInteger)pageIndex progress:(CGFloat)progress{
    if(pageIndex<0||pageIndex>=self.numberOfPages) return;
    [self layoutIfNeeded];
    NSArray<UICollectionViewCell *> *cells = [self.collectionView visibleCells];
    
    for(UICollectionViewCell *c in cells){
        if(![c conformsToProtocol:@protocol(LUIPageIndicatorCollectionViewProtocol)]) continue;
        UICollectionViewCell<LUIPageIndicatorCollectionViewProtocol> *cell = (UICollectionViewCell<LUIPageIndicatorCollectionViewProtocol> *)c;
        if([cell respondsToSelector:@selector(pageControl:didScrollToPage:progress:)]){
            [cell pageControl:self didScrollToPage:pageIndex progress:progress];
        }
    }
    LUICGAxis X = self.scrollAxis;
    UICollectionViewCell *c1 = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentPage inSection:0]];
    UICollectionViewCell *c2 = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:pageIndex inSection:0]];
    if(c1 && c2 && c1 != c2){
        CGRect bounds = self.collectionView.bounds;
        CGFloat w = LUICGRectGetLength(bounds, X);
        CGRect f1 = c1.l_frameSafety;
        CGFloat x1 = LUICGRectGetMid(f1, X)-w*0.5;
        
        CGRect f2 = c2.l_frameSafety;
        CGSize s2 = [self pageIndicatorCellSizeForPageIndex:pageIndex selected:YES];
        f2.size = s2;
        if(pageIndex>self.currentPage){
            CGSize s1 = [self pageIndicatorCellSizeForPageIndex:self.currentPage selected:NO];
            LUICGRectAddMin(&f2, X, LUICGSizeGetLength(s1, X)-LUICGSizeGetLength(f1.size, X));
        }
        CGFloat x2 = LUICGRectGetMid(f2, X)-w*0.5;
        
        CGFloat x = LUICGFloatInterpolate(x1, x2, progress);
        UIEdgeInsets range = self.collectionView.l_contentOffsetOfRange;
        CGFloat minX = LUIEdgeInsetsGetEdge(range, X, LUIEdgeInsetsMin);
        CGFloat maxX = LUIEdgeInsetsGetEdge(range, X, LUIEdgeInsetsMax);
        CGPoint offset = self.collectionView.contentOffset;
        x = MAX(minX,x);
        x = MIN(maxX,x);
        LUICGPointSetValue(&offset, X, x);
        [self.collectionView setContentOffset:offset animated:NO];
//        NSLog(@"offset:%@,%@,progress:%.2f,x1:%.2f,x2:%.2f",NSStringFromCGPoint(self.collectionView.contentOffset),NSStringFromCGPoint(offset),progress,x1,x2);
    }
}
#pragma mark - delegate:LUICollectionViewDelegatePageFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView pageFlowLayout:(LUICollectionViewPageFlowLayout *)collectionViewLayout itemSizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger page = indexPath.item;
    CGSize s = [self pageIndicatorCellSizeForPageIndex:page selected:self.currentPage==page];
    return s;
}
#pragma mark - private
- (NSArray<_LUIPageControlPageCellAttributes *> *)pageCellAttributes{
    if(!_pageCellAttributes){
        NSInteger numberOfPages = self.numberOfPages;
        NSMutableArray<_LUIPageControlPageCellAttributes *> *list = [[NSMutableArray alloc] initWithCapacity:numberOfPages];
        LUICGAxis X = self.scrollAxis;
        CGRect bounds = self.collectionView.bounds;
        CGFloat interitemSpacing = self.interitemSpacing;
        CGRect f1 = bounds;
        CGRect f2 = bounds;
        f1.origin = CGPointZero;
        f2.origin = CGPointZero;
        self.allCellContentWidth = 0;
        for(int i=0;i<numberOfPages;i++){
            _LUIPageControlPageCellAttributes *attr = [[_LUIPageControlPageCellAttributes alloc] init];
            attr.index = i;
            f1.size = [self pageIndicatorCellSizeForPageIndex:i selected:NO];
            f2.size = [self pageIndicatorCellSizeForPageIndex:i selected:YES];
            attr.frame = f1;
            attr.selectedFrame = f2;
            self.allCellContentWidth += LUICGRectGetLength(f1, X);
            
            LUICGRectAddMin(&f1, X, interitemSpacing+LUICGRectGetLength(f1, X));
            LUICGRectAddMin(&f2, X, interitemSpacing+LUICGRectGetLength(f1, X));
            [list addObject:attr];
        }
        if(numberOfPages>0){
            self.allCellContentWidth += (numberOfPages-1)*interitemSpacing;
        }
        _pageCellAttributes = list;
    }
    return _pageCellAttributes;
}
- (CGSize)__collectionSizeForNumberOfPages:(NSInteger)pageCount{
    if(pageCount==0||(pageCount==1&&self.hidesForSinglePage)){
        return CGSizeZero;
    }
    CGSize size = CGSizeZero;
    CGFloat interitemSpacing = self.interitemSpacing;
    NSArray<_LUIPageControlPageCellAttributes *> *cellAttributes = self.pageCellAttributes;
    
    LUICGAxis X = [self scrollAxis];
    LUICGAxis Y = LUICGAxisReverse(X);
    for (int i=0; i<pageCount; i++) {
        _LUIPageControlPageCellAttributes *cellAttr = cellAttributes[i];
        CGSize s1 = cellAttr.selectedFrame.size;
        CGSize s2 = cellAttr.frame.size;
        LUICGSizeSetLength(&size, Y, MAX(size.height,LUICGSizeGetLength(s1, Y)));
        LUICGSizeSetLength(&size, Y, MAX(size.height,LUICGSizeGetLength(s2, Y)));
    }
    CGFloat sumWidth = 0;
    for (int i=0; i<pageCount; i++) {
        _LUIPageControlPageCellAttributes *cellAttr = cellAttributes[i];
        CGSize s2 = cellAttr.frame.size;
        sumWidth += LUICGSizeGetLength(s2, X);
    }
    CGFloat maxSumWidth = 0;
    for (int i=0; i<pageCount; i++) {
        _LUIPageControlPageCellAttributes *cellAttr = cellAttributes[i];
        CGFloat tmpSumWidth = sumWidth;
        CGSize s1 = cellAttr.selectedFrame.size;
        CGSize s2 = cellAttr.frame.size;
        CGFloat w1 = LUICGSizeGetLength(s1, X);//选中
        CGFloat w2 = LUICGSizeGetLength(s2, X);//未选中
        tmpSumWidth += (w1-w2);
        maxSumWidth = MAX(maxSumWidth,tmpSumWidth);
    }
    if(pageCount>1){
        maxSumWidth += (pageCount-1)*interitemSpacing;
    }
    LUICGSizeSetLength(&size, X, maxSumWidth);
    return size;
}

- (void)__setNeedReloadView{
    _pageCellAttributes = nil;
    [self setNeedsLayout];
}
- (void)__reloadData{
    LUICGAxis X = [self scrollAxis];
    self.collectionLayout.scrollDirection = X==LUICGAxisX?UICollectionViewScrollDirectionHorizontal:UICollectionViewScrollDirectionVertical;
    self.collectionLayout.interitemSpacing = self.interitemSpacing;
    
    [self.collectionView.model removeAllSectionModels];
    NSRange visiblePages = self.visiblePages;
    for(int i=0;i<self.numberOfPages;i++){
        LUIPageIndicatorCollectionViewModel *cm = [self createPageIndicatorCollectionViewModelForPage:i];
        cm.pageControl = self;
        BOOL selected = i==self.currentPage;
        cm.cellClass = selected?[self currentPageIndicatorCellClassForPage:i]:[self pageIndicatorCellClassForPage:i];
        cm.selected = selected;
        
        cm.visiblePages = visiblePages;
        [self.collectionView.model addCellModel:cm];
    }
    [self.collectionView.model reloadCollectionViewData];
    [self.collectionView layoutIfNeeded];
    if(self.numberOfPages>0){
        [self __scrollToPage:self.currentPage animated:_reloadWithAnimated];
    }
    self.collectionView.hidden = self.hidesForSinglePage&&self.numberOfPages<=1;
    _reloadWithAnimated = NO;
}
- (void)__scrollToPage:(NSInteger)page animated:(BOOL)animated{
    LUICGAxis X = [self scrollAxis];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:page inSection:0];
    
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:(X==LUICGAxisX?UICollectionViewScrollPositionCenteredHorizontally:UICollectionViewScrollPositionCenteredVertically) animated:animated];
}
@end
