//
//  LUIGridPageCollectionViewLayout.m
//  LUITool
//
//  Created by 六月 on 2024/8/18.
//

#import "LUIGridPageCollectionViewLayout.h"
#import "CGGeometry+LUI.h"
#import "NSArray+LUI_BinarySearch.h"
#import "UICollectionViewLayoutAttributes+LUI.h"
#import "NSTimer+LUI.h"
#import "LUIMacro.h"
#import "UIScrollView+LUI.h"
//NSString *const LUIGridPageCollectionElementKindOfSectionBackground=@"LUIGridPageCollectionElementKindOfSectionBackground";

@class LUIGridPageCollectionViewLayoutPage;
@class LUIGridPageCollectionViewLayoutSection;
@interface LUIGridPageCollectionViewLayout()<UICollectionViewDelegate>{
    NSIndexPath *_l_cellIndexPathAtCenterBeforeBoundsChange;//保存bounds改变之前，画面中中间单元格的索引
    NSIndexPath *_l_preffedCellIndexpathAtCenter;
    NSInteger _l_preffedPageAtCenter;
    NSInteger __cachedPrePage;
    BOOL _shouldCycleScroll;
    BOOL _isSizeFitting;
    struct{
        BOOL isAutoScorlling;
        NSInteger distance;
        NSTimeInterval duration;
    } _autoScrollingState;
    CGSize _contentSize;
    CGPoint _preContentOffset;
}
@property(nonatomic,strong) NSMutableArray<LUIGridPageCollectionViewLayoutPage *> *originPages;//按顺序保存的页面
@property(nonatomic,strong) NSMutableArray<LUIGridPageCollectionViewLayoutPage *> *pages;//按照显示顺序存储的页面（循环滚动时，第0页并非位于第一项）
@property(nonatomic,strong) NSMutableArray<LUIGridPageCollectionViewLayoutPage *> *cyclePages;//会保存三倍的pages,用于循环滚动
@property(nonatomic,strong) NSMutableArray<LUIGridPageCollectionViewLayoutSection *> *sections;
@property(nonatomic,strong) NSTimer *autoScrollingTimer;
@property(nonatomic,assign) BOOL offsetChanging;
@property(nonatomic,weak) id<UICollectionViewDelegate> originDelegate;
@property(nonatomic,strong,nullable) LUIGridPageCollectionViewLayoutPage *currentPageObject;
@end

@interface LUIGridPageCollectionViewLayoutPage : NSObject<NSCopying>
@property(nonatomic,weak) LUIGridPageCollectionViewLayout *layout;
@property(nonatomic,weak) LUIGridPageCollectionViewLayoutSection *section;
@property(nonatomic) NSInteger sectionIndex;//所属分组索引
@property(nonatomic) NSInteger pageIndex;//在layout.originPages中的数组位置
@property(nonatomic) NSInteger pagePositionForShow;//在layout.pages中的数组位置
@property(nonatomic) CGFloat interitemSpacing;//元素之间默认的左右的间隔
@property(nonatomic) CGFloat lineSpacing;//元素之间默认的上下的间隔
@property(nonatomic) CGSize itemSize;//每个元素的大小
@property(nonatomic) UIEdgeInsets sectionInset;//每页的内边距
@property(nonatomic) NSInteger itemsPerRow;//每行最多的元素个数
@property(nonatomic) NSInteger lines;//最多行数
@property(nonatomic) NSRange itemRange;
@property(nonatomic,strong) NSMutableArray<UICollectionViewLayoutAttributes *> *itemAttributes;
@property(nonatomic) BOOL invalidItemAttributes;
@property(nonatomic,readonly) NSArray<UICollectionViewLayoutAttributes *> *layoutAttributesForElements;
@property(nonatomic,assign) CGRect frame;
//@property(nonatomic,assign) CGPoint contentOffset;
@property(nonatomic,readonly) NSIndexPath *centerCellIndexPath;
- (void)adjustCellsContentOffset:(CGFloat)delta;
@end
@implementation LUIGridPageCollectionViewLayoutPage
- (id)init{
    if(self = [super init]){
        self.itemAttributes = [[NSMutableArray alloc] init];
        self.invalidItemAttributes = YES;
    }
    return self;
}
- (NSString *)description{
    return [NSString stringWithFormat:@"<LUIGridPageCollectionViewLayoutPage:%p,pageIndex:%@,frame:%@>",self,@(self.pageIndex),NSStringFromCGRect(self.frame)];
}
- (id)copyWithZone:(NSZone *)zone{
    LUIGridPageCollectionViewLayoutPage *page = [[LUIGridPageCollectionViewLayoutPage alloc] init];
    page.layout = self.layout;
    page.pageIndex = self.pageIndex;
    page.pagePositionForShow = self.pagePositionForShow;
    page.interitemSpacing = self.interitemSpacing;
    page.lineSpacing = self.lineSpacing;
    page.itemSize = self.itemSize;
    page.sectionInset = self.sectionInset;
    page.itemsPerRow = self.itemsPerRow;
    page.lines = self.lines;
    page.itemRange = self.itemRange;
    page.itemAttributes = self.itemAttributes;
    page.invalidItemAttributes = self.invalidItemAttributes;
    page.frame = self.frame;
    page.section = self.section;
    return page;
}
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElements{
    if(self.invalidItemAttributes){
        self.invalidItemAttributes = NO;
        [self.itemAttributes removeAllObjects];
        NSInteger max = NSMaxRange(self.itemRange);
        CGRect contentBounds = UIEdgeInsetsInsetRect(self.frame, self.sectionInset);
        for (NSInteger i=self.itemRange.location; i<max; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:self.sectionIndex];
            UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            CGRect frame = CGRectZero;
            frame.size = self.itemSize;
            NSInteger col = (i-self.itemRange.location)%self.itemsPerRow;
            NSInteger line = (i-self.itemRange.location)/self.itemsPerRow;
            frame.origin.x = contentBounds.origin.x+col*(self.itemSize.width+self.interitemSpacing);
            frame.origin.y = contentBounds.origin.y+line*(self.itemSize.height+self.lineSpacing);
            attr.frame = frame;
            [self.itemAttributes addObject:attr];
        }
    }
    return self.itemAttributes;
}
- (UICollectionViewLayoutAttributes *)layoutAttributesForCellIndex:(NSInteger)index{
    NSArray<UICollectionViewLayoutAttributes *> *elements = self.layoutAttributesForElements;
    UICollectionViewLayoutAttributes *attr = elements[index-self.itemRange.location];
    return attr;
}
- (NSIndexPath *)centerCellIndexPath{
    NSIndexPath *indexpath = nil;
    if(self.itemRange.length){
        indexpath = [NSIndexPath indexPathForItem:self.itemRange.location+self.itemRange.length*0.5 inSection:self.sectionIndex];
    }
    return indexpath;
}
- (void)adjustCellsContentOffset:(CGFloat)delta{
    NSArray<UICollectionViewLayoutAttributes *> *cellAttrs = self.layoutAttributesForElements;
    for (UICollectionViewLayoutAttributes *c in cellAttrs) {
        CGRect f1 = c.l_frameSafety;
        f1.origin.x += delta;
        c.l_frameSafety = f1;
    }
}
@end

@interface LUIGridPageCollectionViewLayoutSection : NSObject
@property(nonatomic,strong) NSArray<LUIGridPageCollectionViewLayoutPage *> *pages;
@property(nonatomic,assign) NSRange pageRange;
@end
@implementation LUIGridPageCollectionViewLayoutSection
- (LUIGridPageCollectionViewLayoutPage *)pageAtCellIndex:(NSInteger)index{
    LUIGridPageCollectionViewLayoutPage *page = nil;
    //使用二分查找
    NSInteger pageIndex = [self.pages l_indexOfSortedObjectsWithComparator:^NSComparisonResult(LUIGridPageCollectionViewLayoutPage *arrayObj, NSInteger idx) {
        NSRange itemRange = arrayObj.itemRange;
        NSComparisonResult result = NSOrderedSame;
        if(index<itemRange.location){
            result = NSOrderedAscending;
        }else if(index>NSMaxRange(itemRange)){
            result = NSOrderedDescending;
        }
        return result;
    }];
    if(pageIndex!=NSNotFound && pageIndex>=0 && pageIndex<self.pages.count){
        page = self.pages[pageIndex];
    }
    return page;
}
@end

@interface LUIGridPageCollectionViewLayout(){
    BOOL _needReload;
}
@end

@implementation LUIGridPageCollectionViewLayout
- (id)init{
    if(self = [super init]){
        self.pages = [[NSMutableArray alloc] init];
        self.originPages = [[NSMutableArray alloc] init];
        self.cyclePages = [[NSMutableArray alloc] init];
        self.sections = [[NSMutableArray alloc] init];
        _l_preffedPageAtCenter = NSNotFound;
        __cachedPrePage = -1;
    }
    return self;
}
- (void)dealloc{
    self.collectionView.delegate = self.originDelegate;
    [self.autoScrollingTimer invalidate];
}
- (void)setOriginDelegate:(id<UICollectionViewDelegate>)originDelegate{
    if(originDelegate!=self){//添加鲁棒性
        _originDelegate = originDelegate;
    }
}
- (void)_prepareDelegate{
    //循环滚动或分页对齐时，都需要添加scrollview的方法
    if(self.collectionView.delegate!=self){
        self.originDelegate = self.collectionView.delegate;
        self.collectionView.delegate = self;
    }
}
- (void)setEnableCycleScroll:(BOOL)enableCycleScroll{
    if(_enableCycleScroll!=enableCycleScroll){
        _needReload = YES;
        _enableCycleScroll = enableCycleScroll;
        [self _prepareDelegate];
    }
}


#pragma mark - Forward Invocations
/**
 *根據指定的Selector返回該類支持的方法簽名,一般用於prototol或者消息轉發forwardInvocation:中NSInvocation參數的methodSignature屬性
 注:系統調用- (void)forwardInvocation:(NSInvocation *)invocation方法前,會先調用此方法獲取NSMethodSignature,然後生成方法所需要的NSInvocation
 */
- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    NSMethodSignature *signature = [super methodSignatureForSelector:selector];
    if (signature == nil) {
        id delegate = self.originDelegate;
        if ([delegate respondsToSelector:selector]) {
            signature = [delegate methodSignatureForSelector:selector];
        }
    }
    return signature;
}
- (BOOL)respondsToSelector:(SEL)selector {
    if ([super respondsToSelector:selector]) {
        return YES;
    } else {
        if([self.originDelegate respondsToSelector:selector]){
            return YES;
        }
    }
    return NO;
}
- (BOOL)conformsToProtocol:(Protocol *)aProtocol{
    BOOL conforms = NO;
    if([super conformsToProtocol:aProtocol]){
        conforms = YES;
    }else{
        if([self.originDelegate conformsToProtocol:aProtocol]){
            conforms = YES;
        }
    }
    return conforms;
}
//对调用未定义的方法进行消息重定向
- (void)forwardInvocation:(NSInvocation *)invocation {
    BOOL didForward = NO;
    id delegate = self.originDelegate;
    if ([delegate respondsToSelector:invocation.selector]) {
        [invocation invokeWithTarget:delegate];
        didForward = YES;
    }
    if (!didForward) {
        [super forwardInvocation:invocation];
    }
}
- (void)doesNotRecognizeSelector:(SEL)aSelector{
    if(self.collectionView.dataSource==nil){
        //ios内存释放机制，导致dataSource已经空了，但delegate还保持为自己。此时不应该响应任何方法了
        return;
    }
    if(aSelector==@selector(collectionView:didEndDisplayingCell:forItemAtIndexPath:)){
        return;
    }
    [super doesNotRecognizeSelector:aSelector];
}

#pragma mark - scroll delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self _pauseAutoScrolling];
    if([self.originDelegate respondsToSelector:_cmd]){
        [self.originDelegate scrollViewWillBeginDragging:scrollView];
    }
}
// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if(!decelerate){
        [self _resumeAutoScrolling];
    }
    if([self.originDelegate respondsToSelector:_cmd]){
        [self.originDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self _resumeAutoScrolling];
    
    if(self.enableCycleScroll && _shouldCycleScroll){
        [self _autoScrollToPagingPositionWithAnimated:YES];
        [self __scrollviewDidEndScrolling:scrollView];
    }else{
        [self __scrollviewDidEndScrolling:scrollView];
    }
    if([self.originDelegate respondsToSelector:_cmd]){
        [self.originDelegate scrollViewDidEndDecelerating:scrollView];
    }
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    [self __scrollviewDidEndScrolling:scrollView];
    if([self.originDelegate respondsToSelector:_cmd]){
        [self.originDelegate scrollViewDidEndScrollingAnimation:scrollView];
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if([self.originDelegate respondsToSelector:_cmd]){
        [self.originDelegate scrollViewDidScroll:scrollView];
    }
    //计算currentPageObject
    if(!self.currentPageObject){
        self.currentPageObject = [self currentPageObjectWithMaxArea];
    }else{
        CGRect bounds = self.collectionView.bounds;
        NSRange range = [self pageRangeWithRect:bounds];
        if(range.length==1){
            
        }
        CGFloat maxArea = -1;
        LUIGridPageCollectionViewLayoutPage *maxPage = nil;
        BOOL currentInRange = NO;
        for (NSInteger i=0; i<range.length; i++) {
            LUIGridPageCollectionViewLayoutPage *p = self.pages[i+range.location];
            CGRect f1 = p.frame;
            CGRect f_i = CGRectIntersection(f1, bounds);
            CGFloat s = f_i.size.width*f_i.size.height;
            if(s>maxArea){
                maxArea = s;
                maxPage = p;
            }
            if(p.pageIndex==self.currentPageObject.pageIndex && s>MAX(1,0.05*bounds.size.width*bounds.size.height)){
                currentInRange = YES;
            }
        }
        if(!currentInRange){
            self.currentPageObject = maxPage;
        }
    }
    [self __notifyScrollToPage];
}
- (void)__scrollviewDidEndScrolling:(UIScrollView *)scrollView{
    _l_preffedCellIndexpathAtCenter = [self currentPageObject].centerCellIndexPath;
    [self __notifyScrollToPage];
}
- (void)__notifyScrollToPage{
    if([self.gridPageDelegate respondsToSelector:@selector(collectionView:gridPageLayout:didScrollToPage:)]){
        NSInteger page = self.currentPage;
        if(page!=__cachedPrePage && page!=NSNotFound){
            [self.gridPageDelegate collectionView:self.collectionView gridPageLayout:self didScrollToPage:page];
        }
        __cachedPrePage = page;
    }
}

- (void)_autoScrollToPagingPositionWithAnimated:(BOOL)animated{
//    if(CGRectIsEmpty(self.collectionView.bounds)){
//        return;
//    }
}


- (void)__setContentViewContentOffset:(CGPoint)contentOffset animated:(BOOL)animated{
    if(CGPointEqualToPoint(contentOffset, self.collectionView.contentOffset)){
        return;
    }
    self.offsetChanging = YES;
    [self.collectionView setContentOffset:contentOffset animated:animated];
    _preContentOffset = self.collectionView.contentOffset;
}
- (NSInteger)numberOfPages{
    return self.pages.count;
}
- (LUIGridPageCollectionViewLayoutPage *)currentPageObjectWithMaxArea{//查找显示面积最大的页
    if(!self.pages.count){
        return nil;
    }
    CGRect bounds = self.collectionView.bounds;
    NSRange range = [self pageRangeWithRect:bounds];
    CGFloat maxArea = -1;
    LUIGridPageCollectionViewLayoutPage *maxPage = nil;
    for (NSInteger i=0; i<range.length; i++) {
        LUIGridPageCollectionViewLayoutPage *p = self.pages[i+range.location];
        CGRect f1 = p.frame;
        CGRect f_i = CGRectIntersection(f1, bounds);
        CGFloat s = f_i.size.width*f_i.size.height;
        if(s>maxArea){
            maxArea = s;
            maxPage = p;
        }
    }
    return maxPage;
}
- (NSInteger)currentPage{
    if(!self.currentPageObject){
        self.currentPageObject = [self currentPageObjectWithMaxArea];
    }
    LUIGridPageCollectionViewLayoutPage *page = [self currentPageObject];
    NSInteger result = page?page.pageIndex:NSNotFound;
    return result;
}
- (void)setCurrentPage:(NSInteger)currentPage{
    [self scrollToPage:currentPage animated:NO];
}
- (NSInteger)currentSection{
    LUIGridPageCollectionViewLayoutPage *page = [self currentPageObject];
    NSInteger result = page?page.sectionIndex:NSNotFound;
    return result;
}
- (void)setCurrentSection:(NSInteger)currentSection{
    NSInteger section = currentSection;
    while (YES) {
        if (section>=0&&section<self.sections.count) {
            LUIGridPageCollectionViewLayoutSection *sectionModel = self.sections[currentSection];
            if(sectionModel.pages.count==0){
                section++;
                continue;
            }else{
                LUIGridPageCollectionViewLayoutPage *page = sectionModel.pages.firstObject;
                self.currentPage = page.pageIndex;
            }
        }else{
            break;
        }
    }
}
- (NSInteger)numberOfPagesInSection:(NSInteger)section{
    if(section>=0&&section<self.sections.count){
        return self.sections[section].pages.count;
    }
    return 0;
}
- (NSInteger)sectionOfPageIndex:(NSInteger)page{
    //使用二分法查找对应的section
    NSInteger section = [self.sections l_indexOfSortedObjectsWithComparator:^NSComparisonResult(LUIGridPageCollectionViewLayoutSection * _Nonnull arrayObj, NSInteger idx) {
        NSComparisonResult r = NSOrderedSame;
        NSRange pageRange = arrayObj.pageRange;
        if(page<pageRange.location){
            r = NSOrderedAscending;
        }else if(page>NSMaxRange(pageRange)){
            r = NSOrderedDescending;
        }
        return r;
    }];
    return section;
}
- (LUIGridPageCollectionViewLayoutSection *)sectionObjectOfPageIndex:(NSInteger)page{
    LUIGridPageCollectionViewLayoutSection *sectionObj = nil;
    NSInteger sectionIndex = [self sectionOfPageIndex:page];
    if(sectionIndex!=NSNotFound){
        sectionObj = self.sections[sectionIndex];
    }
    return sectionObj;
}
- (NSArray<NSNumber *> *)visiblePages{
    NSMutableArray<NSNumber *> *pageIndexes = [[NSMutableArray alloc] init];
    NSRange r = [self pageRangeWithRect:self.collectionView.bounds];
    if(r.length>0){
        NSInteger max = NSMaxRange(r);
        for (NSInteger i=r.location; i<max; i++) {
            LUIGridPageCollectionViewLayoutPage *page = self.pages[i];
            [pageIndexes addObject:@(page.pageIndex)];
        }
    }
    return pageIndexes;
}
- (NSInteger)visiblePage{
    LUIGridPageCollectionViewLayoutPage *maxPage = [self currentPageObject];
    return maxPage?maxPage.pageIndex:NSNotFound;
}
//滚动到指定的页
- (void)scrollToPage:(NSInteger)page animated:(BOOL)animated{
    if (CGSizeEqualToSize(self.collectionView.bounds.size, CGSizeZero)) {
        _l_cellIndexPathAtCenterBeforeBoundsChange = nil;
        _l_preffedCellIndexpathAtCenter = nil;
        _l_preffedPageAtCenter = page;
        return;
    }
    if(page>=0&&page<self.originPages.count){
        _l_cellIndexPathAtCenterBeforeBoundsChange = nil;
        _l_preffedCellIndexpathAtCenter = nil;
        _l_preffedPageAtCenter = NSNotFound;
        CGPoint offset = self.originPages[page].frame.origin;
        [self __setContentViewContentOffset:offset animated:animated];
    }
}
- (NSInteger)__pageWithContentOffsetX:(CGFloat)x{
    CGRect bounds = self.collectionView.bounds;
    //第i页，其x范围为：[inset.left+i*bounds.size.width,inset.left+(i+1)*bounds.size.width]
    NSInteger i = floor((x)/bounds.size.width);
    i = MAX(i,0);
    i = MIN(i,self.pages.count-1);
    return i;
}
- (NSArray<NSNumber *> *)pagesWithRect:(CGRect)rect{
    NSMutableArray<NSNumber *> * pages = [[NSMutableArray alloc] init];
    NSRange r = [self pageRangeWithRect:rect];
    if(r.length>0){
        NSInteger max = NSMaxRange(r);
        for (NSInteger i=r.location; i<max; i++) {
            LUIGridPageCollectionViewLayoutPage *page = self.pages[i];
            [pages addObject:@(page.pageIndex)];
        }
    }
    return pages;
}
- (NSRange)pageRangeWithRect:(CGRect)rect{//返回指定rect中，page在self.pages中的位置
    CGRect effectRect = rect;
    effectRect.origin.x = MAX(effectRect.origin.x,0);
    effectRect.origin.x = MIN(effectRect.origin.x,_contentSize.width-effectRect.size.width);
    NSRange range = NSMakeRange(0, 0);
    if(self.pages.count){
        NSInteger pageBegin = [self __pageWithContentOffsetX:CGRectGetMinX(effectRect)];
        NSInteger pageEnd = [self __pageWithContentOffsetX:CGRectGetMaxX(effectRect)];
        NSInteger pageCount = self.pages.count;
        if((pageBegin<0&&pageEnd<0) || (pageBegin>=pageCount&&pageEnd>=pageCount)){
            
        }else{
            pageBegin = MAX(pageBegin,0);
            pageEnd = MIN(pageEnd,self.pages.count-1);
            if(pageEnd>=pageBegin){
                range.location = (NSUInteger)pageBegin;
                range.length = (NSUInteger)(pageEnd-pageBegin+1);
            }
        }
    }
    return range;
}
- (NSArray<NSIndexPath *> *)itemIndexPathsForPage:(NSInteger)pageIndex{
    if(!(pageIndex>=0&&pageIndex<self.originPages.count)){
        return @[];
    }
    LUIGridPageCollectionViewLayoutPage *page = self.originPages[pageIndex];
    NSRange range = page.itemRange;
    NSMutableArray<NSIndexPath *> *itemIndexPaths = [[NSMutableArray alloc] initWithCapacity:range.length];
    for (int i=0; i<range.length; i++) {
        NSIndexPath *p = [NSIndexPath indexPathForItem:range.location+i inSection:page.sectionIndex];
        [itemIndexPaths addObject:p];
    }
    return itemIndexPaths;
}
- (NSRange)pagesRangeForSection:(NSInteger)section{;
    if(section>=0&&section<self.sections.count){
        LUIGridPageCollectionViewLayoutSection *sectionModel = self.sections[section];
        return sectionModel.pageRange;
    }else{
        return NSMakeRange(0, 0);
    }
}
- (CGFloat)scrollProgressWithContentOffset:(CGPoint)offset fromPage:(NSInteger *)fromPage toPage:(NSInteger *)toPage{
    CGFloat progress = 0;
    CGRect bounds = self.collectionView.bounds;
    CGRect r = bounds;
    r.origin = offset;
    NSRange range = [self pageRangeWithRect:r];
    if(range.length){
        NSInteger p1 = range.location;
        NSInteger p2 = range.location+range.length-1;
        LUIGridPageCollectionViewLayoutPage *page1 = self.pages[p1];
        LUIGridPageCollectionViewLayoutPage *page2 = self.pages[p2];
        if(fromPage!=NULL){*fromPage = page1.pageIndex;}
        if(toPage!=NULL){*toPage = page2.pageIndex;}
        if(p1!=p2){
            CGFloat x1 = page1.frame.origin.x;
            CGFloat x2 = page2.frame.origin.x;
            progress = MAX(0,(offset.x-x1)/(x2-x1));
        }
    }
    return progress;
}
- (CGFloat)scrollProgressWithContentOffset:(CGPoint)offset toPage:(NSInteger *)toPagePoint{
    NSInteger fromPage = 0;
    NSInteger toPage = 0;
    NSInteger currentPage = self.currentPage;
    CGFloat progress = [self scrollProgressWithContentOffset:offset fromPage:&fromPage toPage:&toPage];
    if(fromPage!=currentPage){
        toPage = fromPage;
        progress = 1-progress;
    }
    if(toPagePoint!=NULL) *toPagePoint = toPage;
    return progress;
}


- (BOOL)isAutoScrolling{
    return _autoScrollingState.isAutoScorlling;
}
- (void)_pauseAutoScrolling{
    if(!self.isAutoScrolling){
        return;
    }
    [self.autoScrollingTimer invalidate];
}
- (void)_resumeAutoScrolling{
    if(!self.isAutoScrolling){
        return;
    }
    if(!self.autoScrollingTimer.isValid){
        self.autoScrollingTimer = [NSTimer scheduledTimerWithTimeInterval:_autoScrollingState.duration target:self selector:@selector(_onAudoScrollingTimer:) userInfo:nil repeats:YES];
    }
}

- (void)startAutoScrollingWithDistance:(NSInteger)distance duration:(NSTimeInterval)duration{
    if(_autoScrollingState.isAutoScorlling&&_autoScrollingState.distance==distance&&_autoScrollingState.duration==duration){
        return;
    }
    memset(&_autoScrollingState, 0, sizeof(_autoScrollingState));
    _autoScrollingState.distance = distance;
    _autoScrollingState.duration = duration;
    _autoScrollingState.isAutoScorlling = YES;
    [self.autoScrollingTimer invalidate];
    
    @LUI_WEAKIFY(self);
    self.autoScrollingTimer = [NSTimer l_scheduledTimerWithTimeInterval:_autoScrollingState.duration repeats:YES block:^(NSTimer * _Nonnull timer) {
        @LUI_NORMALIZE(self);
        [self _onAudoScrollingTimer:timer];
    }];
}
- (void)stopAutoScrolling{
    memset(&_autoScrollingState, 0, sizeof(_autoScrollingState));
    [self.autoScrollingTimer invalidate];
    self.autoScrollingTimer = nil;
}
- (void)_onAudoScrollingTimer:(NSTimer *)timer{
    NSInteger distance = _autoScrollingState.distance;
    [self scrollToPageWithDistance:distance animated:YES];
}
- (void)scrollToPageWithDistance:(NSInteger)distance animated:(BOOL)animated{
    LUIGridPageCollectionViewLayoutPage *pageObj = [self currentPageObject];
    if(pageObj){
        NSInteger pageShowed = pageObj.pagePositionForShow;
        
        NSInteger dis = distance;
        if(dis<0){
            dis = -((-distance)%self.pages.count);
        }
        NSInteger newPageShowed = (pageShowed+dis+self.pages.count)%self.pages.count;
        LUIGridPageCollectionViewLayoutPage *nextPageObj = self.pages[newPageShowed];
        if(pageShowed!=newPageShowed){
            if(self.enableCycleScroll && _shouldCycleScroll && distance*(newPageShowed-pageShowed)<0){
                //方向反了，需要进行一次重排
                NSInteger nextBeginIndex = distance>0?pageShowed:newPageShowed;
                [self __resortPagesWithBeginIndex:nextBeginIndex];
            }
            NSInteger newPage = nextPageObj.pageIndex;
            [self scrollToPage:newPage animated:animated];
        }
    }
}
- (NSArray<LUIGridPageCollectionViewLayoutSection *> *)_createSectionModels{
    CGRect bounds = self.collectionView.bounds;
    bounds.origin = CGPointZero;
    CGRect pageContentBounds = bounds;
    NSMutableArray<LUIGridPageCollectionViewLayoutSection *> *sectionModels = [[NSMutableArray alloc] init];
    NSMutableArray<LUIGridPageCollectionViewLayoutPage *> *pages = [[NSMutableArray alloc] init];
    NSInteger numberOfSections = self.collectionView.numberOfSections;
    NSInteger pageIndex = 0;
    NSRange pageRange = NSMakeRange(0, 0);
    for (int section=0; section<numberOfSections; section++) {
        NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:section];
        CGFloat interitemSpacing = [self interitemSpacingForSectionAtIndex:section];
        CGFloat lineSpacing = [self lineSpacingForSectionAtIndex:section];
        CGSize itemSize = [self itemSizeForSectionAtIndex:section];
        UIEdgeInsets sectionInset = [self insetForSectionAtIndex:section];
        CGRect sectionBounds = UIEdgeInsetsInsetRect(pageContentBounds, sectionInset);
        if(sectionBounds.size.width>0&&sectionBounds.size.height>0){
            if(sectionBounds.size.width<itemSize.width){
                NSLog(@"itemSize.width(%@)应该小于Section尺寸(%@)",@(itemSize.width),@(sectionBounds.size.width));
                itemSize.width = sectionBounds.size.width;
            }
            if(sectionBounds.size.height<itemSize.height){
                NSLog(@"itemSize.height(%@)应该小于Section尺寸(%@)",@(itemSize.height),@(sectionBounds.size.height));
                itemSize.height = sectionBounds.size.height;
            }
            //x*(itemSize.width)+(x-1)*space<=sectionBounds.size.width;
            NSInteger itemsPerRow = floor((sectionBounds.size.width+interitemSpacing)/(itemSize.width+interitemSpacing));
            NSInteger lines = floor((sectionBounds.size.height+lineSpacing)/(itemSize.height+lineSpacing));
            NSInteger itemsPerPage = itemsPerRow*lines;
            NSInteger pageCount = ceil(numberOfItems*1.0/itemsPerPage);
            
            LUIGridPageCollectionViewLayoutSection *sectionModel = [[LUIGridPageCollectionViewLayoutSection alloc] init];
            pageRange.location = pageIndex;
            NSMutableArray<LUIGridPageCollectionViewLayoutPage *> *sectionPages = [[NSMutableArray alloc] initWithCapacity:pageCount];
            NSInteger itemIndex = 0;
            for (int i=0; i<pageCount; i++) {
                LUIGridPageCollectionViewLayoutPage *page = [[LUIGridPageCollectionViewLayoutPage alloc] init];
                page.itemSize = itemSize;
                page.interitemSpacing = interitemSpacing;
                page.lineSpacing = lineSpacing;
                page.sectionInset = sectionInset;
                page.sectionIndex = section;
                page.itemsPerRow = itemsPerRow;
                page.lines = lines;
                page.pageIndex = pageIndex;
                page.layout = self;
                if(i!=pageCount-1){
                    page.itemRange = NSMakeRange(itemIndex, itemsPerPage);
                }else{
                    page.itemRange = NSMakeRange(itemIndex, numberOfItems);
                }
                CGRect f1 = CGRectZero;
                f1.origin.y = 0;
                f1.origin.x = pageIndex*pageContentBounds.size.width;
                f1.size = pageContentBounds.size;
                page.frame = f1;

                [sectionPages addObject:page];
                [pages addObject:page];
                pageIndex++;
                itemIndex = NSMaxRange(page.itemRange);
                numberOfItems -= page.itemRange.length;
            }
            sectionModel.pages = sectionPages;
            for (LUIGridPageCollectionViewLayoutPage *page in sectionPages) {
                page.section = sectionModel;
            }
            pageRange.length = sectionPages.count;
            sectionModel.pageRange = pageRange;
            [sectionModels addObject:sectionModel];
        }
    }
    return sectionModels;
}
- (LUIGridPageCollectionViewLayoutPage *)_pageAtIndexPath:(NSIndexPath *)indexpath{
    LUIGridPageCollectionViewLayoutPage *page = nil;
    NSInteger section = indexpath.section;
    if(section>=0&&section<self.sections.count){
        LUIGridPageCollectionViewLayoutSection *sectionModel = self.sections[section];
        page = [sectionModel pageAtCellIndex:indexpath.item];
    }
    return page;
}

- (void)reloadData{
    self.offsetChanging = NO;
    _needReload = YES;
    [self.collectionView reloadData];
}
//- (Class)layoutAttributesClass{
//    return [UICollectionViewLayoutAttributes class];
//} // override this method to provide a custom class to be used when instantiating instances of UICollectionViewLayoutAttributes
//- (Class)invalidationContextClass API_AVAILABLE(ios(7.0)){
//    return [UICollectionViewLayoutInvalidationContext class];
//} // override this method to provide a custom class to be used for invalidation contexts

// The collection view calls -prepareLayout once at its first layout as the first message to the layout instance.
// The collection view calls -prepareLayout again after layout is invalidated and before requerying the layout information.
// Subclasses should always call super if they override.
- (void)prepareLayout{
    //NSLog(@"%@",NSStringFromSelector(_cmd));
     [super prepareLayout];
    [self _prepareDelegate];
    if(self.offsetChanging && !_needReload){
        if(self.enableCycleScroll && _shouldCycleScroll){
            [self _prepareForCycleScroll:YES preffedCellIndexpathAtPaging:nil preffedPageAtCenter:NSNotFound];
        }
    }else{
        __cachedPrePage = -1;
        [self.pages removeAllObjects];
        [self.originPages removeAllObjects];
        [self.sections removeAllObjects];
        
        NSArray<LUIGridPageCollectionViewLayoutSection *> *sectionModels = [self _createSectionModels];
        for (LUIGridPageCollectionViewLayoutSection *section in sectionModels) {
            [self.sections addObject:section];
            [self.pages addObjectsFromArray:section.pages];
            [self.originPages addObjectsFromArray:section.pages];
        }
        for (int i=0; i<self.pages.count; i++) {
            LUIGridPageCollectionViewLayoutPage *page = self.pages[i];
            page.pagePositionForShow = i;
        }
        
        [self _prepareContentSize];
        
        _shouldCycleScroll = NO;
        if(self.enableCycleScroll){
            [self.cyclePages removeAllObjects];
            [self.cyclePages addObjectsFromArray:[self __genCyclePages:self.pages contentSize:_contentSize]];
            _shouldCycleScroll = self.pages.count>1;
            [self _prepareForCycleScroll:NO preffedCellIndexpathAtPaging:_l_preffedCellIndexpathAtCenter preffedPageAtCenter:_l_preffedPageAtCenter];
            _l_preffedCellIndexpathAtCenter = [self currentPageObject].centerCellIndexPath;
            _l_preffedPageAtCenter = NSNotFound;
        }
    }
    _needReload = NO;
    self.offsetChanging = NO;
}
- (void)_prepareContentSize{//
    CGSize contentSize = CGSizeZero;
    CGRect bounds = self.collectionView.bounds;
    if(self.pages.count>0){
        contentSize.height = bounds.size.height;
        contentSize.width = self.pages.count*(bounds.size.width);
    }
    _contentSize = contentSize;
}

- (CGFloat)maxContentoffset{
    CGRect bounds = self.collectionView.bounds;
    CGSize contentSize = _contentSize;
    UIEdgeInsets contentInset = self.collectionView.l_adjustedContentInset;
    LUICGAxis X = LUICGAxisX;
    CGFloat max = MAX([self minContentoffset],LUICGSizeGetLength(contentSize, X)-LUICGRectGetLength(bounds, X)+LUIEdgeInsetsGetEdge(contentInset, X, LUIEdgeInsetsMax));
    return max;
}
- (CGFloat)minContentoffset{
    UIEdgeInsets contentInset = self.collectionView.l_adjustedContentInset;
    LUICGAxis X = LUICGAxisX;
    CGFloat min = -LUIEdgeInsetsGetEdge(contentInset, X, LUIEdgeInsetsMin);
    return min;
}
- (void)_prepareForCycleScroll:(BOOL)isOffsetChanging preffedCellIndexpathAtPaging:(NSIndexPath *)preffedCellIndexpathAtCenter preffedPageAtCenter:(NSInteger)preffedPageAtCenter{
    if(self.pages.count==0){
        return;
    }
    LUICGAxis X = LUICGAxisX;
    CGRect bounds = self.collectionView.bounds;
    LUIGridPageCollectionViewLayoutPage *preffedPage = nil;
    CGFloat offsetDelta = 0;
    if(preffedPageAtCenter!=NSNotFound&&preffedPageAtCenter>=0&&preffedPageAtCenter<self.originPages.count){
        preffedPage = self.originPages[preffedPageAtCenter];
    }else if(preffedCellIndexpathAtCenter){
        preffedPage = [self _pageAtIndexPath:preffedCellIndexpathAtCenter];
    }
    if(preffedPage){
        offsetDelta = preffedPage.pageIndex*bounds.size.width - bounds.origin.x;
        bounds.origin.x += offsetDelta;
        self.collectionView.contentOffset = bounds.origin;
    }
    
    CGSize contentSize = _contentSize;
    CGVector vector = CGVectorMake(0, 0);
    NSInteger beginIndex = -1;
    
    CGPoint offset = self.collectionView.contentOffset;
    //如果在刷新时，当前显示中的cell，没有与paging位置对齐，可能在后续的paging调整中，超出contentOffset的范围，从而导致paging失败。这里需要手动判断可能的paging失效，然后进行重排
    BOOL needResetOffset = NO;
    if(!isOffsetChanging){
        NSInteger nearIndex = [self _pageIndexNearToOffset:offset scrollVelocity:CGPointMake(vector.dx, vector.dy)];
        if(nearIndex!=NSNotFound){
            CGFloat pagingOffset = LUICGPointGetValue(self.pages[nearIndex].frame.origin, X);
            CGFloat minOffset = [self minContentoffset];
            CGFloat maxOffset = [self maxContentoffset];
            if(pagingOffset<minOffset){
                LUICGVectorSetValue(&vector, X, -1);
                needResetOffset = YES;
            }else if(pagingOffset>maxOffset){
                LUICGVectorSetValue(&vector, X, 1);
                needResetOffset = YES;
            }
        }
    }
    
    NSRange cellRange = [self __rangeForCycleScrollWithBounds:bounds pageCount:self.pages.count cyclePages:self.cyclePages contentSize:contentSize scrollVector:vector];
    if(cellRange.location==NSNotFound || cellRange.length==0){
        return;
    }
    if(NSMaxRange(cellRange)>self.pages.count){
        beginIndex = cellRange.location;
    }else{
        if(LUICGVectorGetValue(vector, X)<0){//手指右划,左侧留出空白
            if(cellRange.location==0 && cellRange.length<self.pages.count){
                beginIndex = MIN(NSMaxRange(cellRange),self.pages.count-1);
            }
        }
    }
    if(beginIndex>0){
//        NSLog(@"beginIndex:%@,%@,%@",@(beginIndex),NSStringFromRange(cellRange),NSStringFromCGVector(vector));
        [self __resortPagesWithBeginIndex:beginIndex];
        if(needResetOffset){
            CGPoint offset = [self targetContentOffsetForProposedContentOffset:self.collectionView.contentOffset withScrollingVelocity:CGPointMake(vector.dx, vector.dy)];
            self.collectionView.contentOffset = offset;
        }
    }
}
- (NSArray<LUIGridPageCollectionViewLayoutPage *> *)__genCyclePages:(NSArray<LUIGridPageCollectionViewLayoutPage *> *)pages contentSize:(CGSize)contentSize{
    NSMutableArray<LUIGridPageCollectionViewLayoutPage *> *cyclePages = [[NSMutableArray alloc] initWithCapacity:pages.count*3];
    for (LUIGridPageCollectionViewLayoutPage *page in self.pages) {
        LUIGridPageCollectionViewLayoutPage *newPage = [page copy];
        CGRect frame = newPage.frame;
        frame.origin.x -= contentSize.width;
        newPage.frame = frame;
        [cyclePages addObject:newPage];
    }
    
    for (LUIGridPageCollectionViewLayoutPage *page in self.pages) {
        [cyclePages addObject:page];
    }
    
    for (LUIGridPageCollectionViewLayoutPage *page in self.pages) {
        LUIGridPageCollectionViewLayoutPage *newPage = [page copy];
        CGRect frame = newPage.frame;
        frame.origin.x += contentSize.width;
        newPage.frame = frame;
        [cyclePages addObject:newPage];
    }
    return cyclePages;
}
- (void)__resortPagesWithBeginIndex:(NSInteger)beginIndex{
    CGPoint offset = self.collectionView.contentOffset;

    CGSize contentSize = _contentSize;
    
    CGRect bounds = self.collectionView.bounds;
    LUICGAxis X = LUICGAxisX;
    
    NSRange range = [self pageRangeWithRect:bounds];
    NSInteger firstIndex = range.location;
    LUIGridPageCollectionViewLayoutPage *firstPage = self.pages[firstIndex];
    CGRect firstFrame = firstPage.frame;
    
    CGPoint newOffset = offset;
    
    CGRect beginFrame = self.pages[beginIndex].frame;
    CGFloat deltaX = -LUICGRectGetMin(beginFrame, X);
    CGFloat deltaX2 = LUICGSizeGetLength(contentSize, X)-LUICGRectGetMin(beginFrame, X);
    
    CGRect firstFrame2 = firstFrame;
    if(beginIndex<=firstIndex){
        LUICGRectSetMin(&firstFrame2, X, LUICGRectGetMin(firstFrame2, X)+deltaX);
    }else{
        LUICGRectSetMin(&firstFrame2, X, LUICGRectGetMin(firstFrame2, X)+deltaX2);
    }
    CGFloat deltaX3 = LUICGRectGetMin(firstFrame2, X)-LUICGRectGetMin(firstFrame, X);
    LUICGPointSetValue(&newOffset, X, LUICGPointGetValue(offset, X)+deltaX3);
    
    LUICGPointSetValue(&newOffset, X, LUICGPointGetValue(offset, X)+deltaX3);
    
    NSMutableArray<LUIGridPageCollectionViewLayoutPage *> *newPages = [[NSMutableArray alloc] initWithCapacity:self.pages.count];
    for (NSInteger i=beginIndex; i<self.pages.count; i++) {
        LUIGridPageCollectionViewLayoutPage *c = self.pages[i];
        CGRect f1 = c.frame;
        LUICGRectSetMin(&f1, X, LUICGRectGetMin(f1, X)+deltaX);
        c.frame = f1;
        [newPages addObject:c];
    }
    for (NSInteger i=0; i<beginIndex; i++) {
        LUIGridPageCollectionViewLayoutPage *c = self.pages[i];
        CGRect f1 = c.frame;
        LUICGRectSetMin(&f1, X, LUICGRectGetMin(f1, X)+deltaX2);
        c.frame = f1;
        [newPages addObject:c];
    }
    [self.pages removeAllObjects];
    [self.pages addObjectsFromArray:newPages];
    for (int i=0; i<self.pages.count; i++) {
        LUIGridPageCollectionViewLayoutPage *page = self.pages[i];
        page.pagePositionForShow = i;
    }
    
    for (LUIGridPageCollectionViewLayoutPage *c in self.pages) {
        c.invalidItemAttributes = YES;
    }
    
    [self.cyclePages removeAllObjects];
    [self.cyclePages addObjectsFromArray:[self __genCyclePages:self.pages contentSize:contentSize]];
    
    self.collectionView.contentOffset = newOffset;
//    NSLog(@"newOffset:%@,beginIndex:%@",NSStringFromCGPoint(newOffset),@(beginIndex));
    _preContentOffset = self.collectionView.contentOffset;
}

- (NSRange)__rangeForCycleScrollWithBounds:(CGRect)contentBounds pageCount:(NSInteger)pageCount cyclePages:(NSArray<LUIGridPageCollectionViewLayoutPage *> *)cyclePages contentSize:(CGSize)contentSize scrollVector:(CGVector)vector{
    //具体算法为：将pages扩展为三份（左中右），然后计算bounds覆盖的cell范围。得到范围，如果范围超过总元素数，代表元素数量不足以支持循环滚动。
    CGRect bounds = contentBounds;
    LUICGAxis X = LUICGAxisX;
    LUICGRange boundsRange = LUICGRectGetRange(bounds, X);
    //使用二分法，查找bounds中的cell
    NSRange resultRange = [cyclePages l_rangeOfSortedObjectsWithComparator:^NSComparisonResult(LUIGridPageCollectionViewLayoutPage *  _Nonnull arrayObj, NSInteger idx) {
        LUICGRange r = LUICGRectGetRange(arrayObj.frame, X);
        NSComparisonResult result = NSOrderedSame;
        if(LUICGRangeIntersectsRange(boundsRange, r)){
//            if(LUICGVectorGetValue(vector, X)<0){//手指右划,左侧留出空白
            LUICGRange t = LUICGRangeIntersection(boundsRange, r);
            if(t.end==t.begin){//相切时，不认为在显示范围中
                if(r.begin<boundsRange.begin){
                    result = NSOrderedAscending;
                }else{
                    result = NSOrderedDescending;
                }
            }else{
                result = NSOrderedSame;
            }
        }else if(LUICGRangeGetMax(r)<LUICGRangeGetMin(boundsRange)){
            result = NSOrderedAscending;
        }else{
            result = NSOrderedDescending;
        }
        return result;
    }];
    if(resultRange.location!=NSNotFound){
        resultRange.location %= pageCount;
    }
    return resultRange;
}

// UICollectionView calls these four methods to determine the layout information.
// Implement -layoutAttributesForElementsInRect: to return layout attributes for for supplementary or decoration views, or to perform layout in an as-needed-on-screen fashion.
// Additionally, all layout subclasses should implement -layoutAttributesForItemAtIndexPath: to return layout attributes instances on demand for specific index paths.
// If the layout supports any supplementary or decoration view types, it should also implement the respective atIndexPath: methods for those types.
- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
    if(!self.pages.count){
        return nil;
    }
    NSRange range = [self pageRangeWithRect:rect];
    if(!range.length){
        return nil;
    }
    NSMutableArray<UICollectionViewLayoutAttributes *> *elements = [[NSMutableArray alloc] init];
    for (int i=0;i<range.length;i++) {
        LUIGridPageCollectionViewLayoutPage *page = self.pages[i+range.location];
        //添加page的背景 todo
//        UICollectionViewLayoutAttributes *bgAttr = [self layoutAttributesForSupplementaryViewOfKind:LUIGridPageCollectionElementKindOfSectionBackground atIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
//        if(bgAttr){
//            [elements addObject:bgAttr];
//        }
        //添加page中的cell
        [elements addObjectsFromArray:page.layoutAttributesForElements];
    }
    return elements;
} // return an array layout attributes instances for all the views in the given rect
- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewLayoutAttributes *attr = nil;
    LUIGridPageCollectionViewLayoutSection *sectionModel = self.sections[indexPath.section];
    LUIGridPageCollectionViewLayoutPage *page = [sectionModel pageAtCellIndex:indexPath.item];
    if(page){
        attr = [page layoutAttributesForCellIndex:indexPath.item];
    }
    return attr;
}
//- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath{
//    return nil;
//    UICollectionViewLayoutAttributes *attr = nil;
//    if([elementKind isEqualToString:LUIGridPageCollectionElementKindOfSectionBackground]){
//        NSInteger section = indexPath.section;
//        CGRect bounds = self.collectionView.bounds;
//        if([self.collectionView.dataSource respondsToSelector:@selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)]){
//            attr = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:elementKind withIndexPath:indexPath];
//            CGRect frame = CGRectZero;
//            frame.size = bounds.size;
//            frame.origin.x = CGRectGetMinX(bounds)+section*bounds.size.width;
//            frame.origin.y = CGRectGetMinX(bounds);
//            attr.frame = frame;
//        }
//    }
//    return attr;
//}
- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString*)elementKind atIndexPath:(NSIndexPath *)indexPath{
    return [super layoutAttributesForDecorationViewOfKind:elementKind atIndexPath:indexPath];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
    if(_isSizeFitting) return NO;
    CGRect bounds = self.collectionView.bounds;
    CGSize contentSize = self.collectionView.contentSize;
    BOOL originChange = !CGPointEqualToPoint(bounds.origin, newBounds.origin);
    BOOL sizeChange = !CGSizeEqualToSize(bounds.size, newBounds.size);
    if(!originChange&&!sizeChange) return NO;
    if(sizeChange){//尺寸变更了
        BOOL emptySize = CGSizeEqualToSize(bounds.size, CGSizeZero);
        if(!emptySize){//同时旧尺寸非0时，需要计算旧尺寸下的paging位置，设置为新尺寸时，需要恢复到该位置
            LUIGridPageCollectionViewLayoutPage *page = [self currentPageObject];
            if(page){
                _l_cellIndexPathAtCenterBeforeBoundsChange = page.centerCellIndexPath;
            }
        }
        return YES;
    }
    
    if(originChange){//仅发生位置变更，尺寸不变化
        BOOL emptyContentSize = CGSizeEqualToSize(contentSize, CGSizeZero);
        BOOL offsetNeedChanging = (self.enableCycleScroll && _shouldCycleScroll);
        if(!emptyContentSize && offsetNeedChanging){
            self.offsetChanging = YES;
            return YES;
        }
    }
    return NO;
} // return YES to cause the collection view to requery the layout for geometry information
- (UICollectionViewLayoutInvalidationContext *)invalidationContextForBoundsChange:(CGRect)newBounds API_AVAILABLE(ios(7.0)){
    //NSLog(@"%@",NSStringFromSelector(_cmd));
    UICollectionViewLayoutInvalidationContext *context = [super invalidationContextForBoundsChange:newBounds];
    return context;
}

- (BOOL)shouldInvalidateLayoutForPreferredLayoutAttributes:(UICollectionViewLayoutAttributes *)preferredAttributes withOriginalAttributes:(UICollectionViewLayoutAttributes *)originalAttributes API_AVAILABLE(ios(8.0)){
    //NSLog(@"%@",NSStringFromSelector(_cmd));
    return NO;
}
- (UICollectionViewLayoutInvalidationContext *)invalidationContextForPreferredLayoutAttributes:(UICollectionViewLayoutAttributes *)preferredAttributes withOriginalAttributes:(UICollectionViewLayoutAttributes *)originalAttributes API_AVAILABLE(ios(8.0)){
    //NSLog(@"%@",NSStringFromSelector(_cmd));
    UICollectionViewLayoutInvalidationContext *context = [super invalidationContextForPreferredLayoutAttributes:preferredAttributes withOriginalAttributes:originalAttributes];
    return context;
}
- (NSInteger)_pageIndexNearToOffset:(CGPoint)offset scrollVelocity:(CGPoint)velocity{
    if(self.pages.count==0){
        return NSNotFound;
    }
    LUICGAxis X = LUICGAxisX;
    CGRect bounds = self.collectionView.bounds;
    bounds.origin = CGPointZero;
    NSInteger pageIndex = 0;
    CGFloat indexProgress = (LUICGPointGetValue(offset, X))/LUICGRectGetLength(bounds, X);
    CGFloat v = LUICGPointGetValue(velocity, X);
    if(v>0){
        pageIndex = ceil(indexProgress);
    }else if(v<0){
        pageIndex = floor(indexProgress);
    }else{
        NSInteger i = (NSInteger)indexProgress;
        i = MAX(i,0);
        i = MIN(i,self.pages.count-1);
        CGFloat midX = LUICGRectGetMid(self.pages[i].frame, X);
        if(LUICGPointGetValue(offset, X)<=midX){
            pageIndex = i;
        }else{
            pageIndex = i+1;
        }
    }
    pageIndex = MAX(pageIndex,0);
    pageIndex = MIN(pageIndex,self.pages.count-1);
    return pageIndex;
}
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity{
    if(!self.pages.count){
        return proposedContentOffset;
    }
    if(_l_cellIndexPathAtCenterBeforeBoundsChange){
        CGPoint offset = proposedContentOffset;
        LUIGridPageCollectionViewLayoutPage *page = [self _pageAtIndexPath:_l_cellIndexPathAtCenterBeforeBoundsChange];
        if(page){
            offset = page.frame.origin;
        }
        _l_cellIndexPathAtCenterBeforeBoundsChange = nil;
        return offset;
    }
    CGPoint offset = proposedContentOffset;
    NSInteger pageIndex = [self _pageIndexNearToOffset:offset scrollVelocity:velocity];
    if(pageIndex>=0&&pageIndex<self.pages.count){
        offset = self.pages[pageIndex].frame.origin;
    }
    return offset;
    
} // return a point at which to rest after scrolling - for layouts that want snap-to-point scrolling behavior
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset API_AVAILABLE(ios(7.0)){
    CGPoint offset = [self targetContentOffsetForProposedContentOffset:proposedContentOffset withScrollingVelocity:CGPointZero];
    return offset;
    
} // a layout can return the content offset to be applied during transition or update animations

- (CGSize)collectionViewContentSize{//
    return _contentSize;
} // Subclasses must override this method and use it to return the width and height of the collection view’s content. These values represent the width and height of all the content, not just the content that is currently visible. The collection view uses this information to configure its own content size to facilitate scrolling.

- (UIUserInterfaceLayoutDirection)developmentLayoutDirection{
    return UIUserInterfaceLayoutDirectionLeftToRight;
} // Default implementation returns the layout direction of the main bundle's development region; FlowLayout returns leftToRight. Subclasses may override this to specify the implementation-time layout direction of the layout.
- (BOOL)flipsHorizontallyInOppositeLayoutDirection{
    return NO;
} // Base implementation returns false. If your subclass’s implementation overrides this property to return true, a UICollectionView showing this layout will ensure its bounds.origin is always found at the leading edge, flipping its coordinate system horizontally if necessary.

@end

@implementation LUIGridPageCollectionViewLayout (UIUpdateSupportHooks)
//
//// This method is called when there is an update with deletes/inserts to the collection view.
//// It will be called prior to calling the initial/final layout attribute methods below to give the layout an opportunity to do batch computations for the insertion and deletion layout attributes.
//// The updateItems parameter is an array of UICollectionViewUpdateItem instances for each element that is moving to a new index path.
- (void)prepareForCollectionViewUpdates:(NSArray<UICollectionViewUpdateItem *> *)updateItems{
    //NSLog(@"%@",NSStringFromSelector(_cmd));
    [super prepareForCollectionViewUpdates:updateItems];
}
//- (void)finalizeCollectionViewUpdates{
//    //NSLog(@"%@",NSStringFromSelector(_cmd));
//    [super finalizeCollectionViewUpdates];
//} // called inside an animation block after the update
//
- (void)prepareForAnimatedBoundsChange:(CGRect)oldBounds{
    //NSLog(@"%@",NSStringFromSelector(_cmd));
    [super prepareForAnimatedBoundsChange:oldBounds];
} // UICollectionView calls this when its bounds have changed inside an animation block before displaying cells in its new bounds
- (void)finalizeAnimatedBoundsChange{
    //NSLog(@"%@",NSStringFromSelector(_cmd));
    [super finalizeAnimatedBoundsChange];
} // also called inside the animation block
//
//// UICollectionView calls this when prior the layout transition animation on the incoming and outgoing layout
//- (void)prepareForTransitionToLayout:(UICollectionViewLayout *)newLayout API_AVAILABLE(ios(7.0)){
//    //NSLog(@"%@",NSStringFromSelector(_cmd));
//    [super prepareForTransitionToLayout:newLayout];
//}
//- (void)prepareForTransitionFromLayout:(UICollectionViewLayout *)oldLayout API_AVAILABLE(ios(7.0)){
//    //NSLog(@"%@",NSStringFromSelector(_cmd));
//    [super prepareForTransitionFromLayout:oldLayout];
//}
//- (void)finalizeLayoutTransition API_AVAILABLE(ios(7.0)){
//    //NSLog(@"%@",NSStringFromSelector(_cmd));
//    [super finalizeLayoutTransition];
//}  // called inside an animation block after the transition
//
//
//// This set of methods is called when the collection view undergoes an animated transition such as a batch update block or an animated bounds change.
//// For each element on screen before the invalidation, finalLayoutAttributesForDisappearingXXX will be called and an animation setup from what is on screen to those final attributes.
//// For each element on screen after the invalidation, initialLayoutAttributesForAppearingXXX will be called and an animation setup from those initial attributes to what ends up on screen.
//- (nullable UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath{
//    //NSLog(@"%@",NSStringFromSelector(_cmd));
//    return [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
//}
//- (nullable UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath{
//    //NSLog(@"%@",NSStringFromSelector(_cmd));
//    return [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];
//}
//- (nullable UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)elementIndexPath{
//    //NSLog(@"%@",NSStringFromSelector(_cmd));
//    return [super initialLayoutAttributesForAppearingSupplementaryElementOfKind:elementKind atIndexPath:elementIndexPath];
//}
//- (nullable UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)elementIndexPath{
//    //NSLog(@"%@",NSStringFromSelector(_cmd));
//    return [super finalLayoutAttributesForDisappearingSupplementaryElementOfKind:elementKind atIndexPath:elementIndexPath];
//}
//- (nullable UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingDecorationElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)decorationIndexPath{
//    //NSLog(@"%@",NSStringFromSelector(_cmd));
//    return [super initialLayoutAttributesForAppearingDecorationElementOfKind:elementKind atIndexPath:decorationIndexPath];
//}
//- (nullable UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingDecorationElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)decorationIndexPath{
//    //NSLog(@"%@",NSStringFromSelector(_cmd));
//    return [super finalLayoutAttributesForDisappearingDecorationElementOfKind:elementKind atIndexPath:decorationIndexPath];
//}
//
//// These methods are called by collection view during an update block.
//// Return an array of index paths to indicate views that the layout is deleting or inserting in response to the update.
//- (NSArray<NSIndexPath *> *)indexPathsToDeleteForSupplementaryViewOfKind:(NSString *)elementKind API_AVAILABLE(ios(7.0)){
//    //NSLog(@"%@",NSStringFromSelector(_cmd));
//    return [super indexPathsToDeleteForSupplementaryViewOfKind:elementKind];
//}
//- (NSArray<NSIndexPath *> *)indexPathsToDeleteForDecorationViewOfKind:(NSString *)elementKind API_AVAILABLE(ios(7.0)){
//    //NSLog(@"%@",NSStringFromSelector(_cmd));
//    return [super indexPathsToDeleteForDecorationViewOfKind:elementKind];
//}
//- (NSArray<NSIndexPath *> *)indexPathsToInsertForSupplementaryViewOfKind:(NSString *)elementKind API_AVAILABLE(ios(7.0)){
//    //NSLog(@"%@",NSStringFromSelector(_cmd));
//    return [super indexPathsToInsertForSupplementaryViewOfKind:elementKind];
//}
//- (NSArray<NSIndexPath *> *)indexPathsToInsertForDecorationViewOfKind:(NSString *)elementKind API_AVAILABLE(ios(7.0)){
//    //NSLog(@"%@",NSStringFromSelector(_cmd));
//    return [super indexPathsToInsertForDecorationViewOfKind:elementKind];
//}
//
@end
//
//@implementation LUIGridPageCollectionViewLayout (UIReorderingSupportHooks)
//
//- (NSIndexPath *)targetIndexPathForInteractivelyMovingItem:(NSIndexPath *)previousIndexPath withPosition:(CGPoint)position API_AVAILABLE(ios(9.0)){
//
//}
//- (UICollectionViewLayoutAttributes *)layoutAttributesForInteractivelyMovingItemAtIndexPath:(NSIndexPath *)indexPath withTargetPosition:(CGPoint)position API_AVAILABLE(ios(9.0)){
//
//}
//
//- (UICollectionViewLayoutInvalidationContext *)invalidationContextForInteractivelyMovingItems:(NSArray<NSIndexPath *> *)targetIndexPaths withTargetPosition:(CGPoint)targetPosition previousIndexPaths:(NSArray<NSIndexPath *> *)previousIndexPaths previousPosition:(CGPoint)previousPosition API_AVAILABLE(ios(9.0)){
//
//}
//- (UICollectionViewLayoutInvalidationContext *)invalidationContextForEndingInteractiveMovementOfItemsToFinalIndexPaths:(NSArray<NSIndexPath *> *)indexPaths previousIndexPaths:(NSArray<NSIndexPath *> *)previousIndexPaths movementCancelled:(BOOL)movementCancelled API_AVAILABLE(ios(9.0)){
//
//}
//
//@end

@implementation LUIGridPageCollectionViewLayout(LUICollectionViewDelegateGridPageLayout)
- (id<LUICollectionViewDelegateGridPageLayout>)gridPageDelegate{
    if([self.collectionView.delegate conformsToProtocol:@protocol(LUICollectionViewDelegateGridPageLayout)]){
        return (id<LUICollectionViewDelegateGridPageLayout>)self.collectionView.delegate;
    }
    return nil;
}
- (CGSize)itemSizeForSectionAtIndex:(NSInteger)section{
    id<LUICollectionViewDelegateGridPageLayout> delegate = self.gridPageDelegate;
    CGSize value = self.itemSize;
    if([delegate respondsToSelector:@selector(collectionView:gridPageLayout:itemSizeForSectionAtIndex:)]){
        value = [delegate collectionView:self.collectionView gridPageLayout:self itemSizeForSectionAtIndex:section];
    }
    return value;
}
- (UIEdgeInsets)insetForSectionAtIndex:(NSInteger)section{
    id<LUICollectionViewDelegateGridPageLayout> delegate = self.gridPageDelegate;
    UIEdgeInsets value = self.sectionInset;
    if([delegate respondsToSelector:@selector(collectionView:gridPageLayout:insetForSectionAtIndex:)]){
        value = [delegate collectionView:self.collectionView gridPageLayout:self insetForSectionAtIndex:section];
    }
    return value;
}
- (CGFloat)lineSpacingForSectionAtIndex:(NSInteger)section{
    id<LUICollectionViewDelegateGridPageLayout> delegate = self.gridPageDelegate;
    CGFloat value = self.lineSpacing;
    if([delegate respondsToSelector:@selector(collectionView:gridPageLayout:lineSpacingForSectionAtIndex:)]){
        value = [delegate collectionView:self.collectionView gridPageLayout:self lineSpacingForSectionAtIndex:section];
    }
    return value;
}
- (CGFloat)interitemSpacingForSectionAtIndex:(NSInteger)section{
    id<LUICollectionViewDelegateGridPageLayout> delegate = self.gridPageDelegate;
    CGFloat value = self.interitemSpacing;
    if([delegate respondsToSelector:@selector(collectionView:gridPageLayout:interitemSpacingForSectionAtIndex:)]){
        value = [delegate collectionView:self.collectionView gridPageLayout:self interitemSpacingForSectionAtIndex:section];
    }
    return value;
}
@end
@implementation LUIGridPageCollectionViewLayout(SizeFits)
#define kLUIGridPageCollectionViewLayoutFloatDelta 0.00000001
- (CGSize)itemSizeThatFitsItemsPerRow:(NSInteger)itemsPerRow lines:(NSInteger)lines interitemSpacing:(CGFloat)interitemSpacing lineSpacing:(CGFloat)lineSpacing sectionInsets:(UIEdgeInsets)sectionInsets{
    CGRect bounds = self.collectionView.bounds;
    bounds = UIEdgeInsetsInsetRect(bounds, sectionInsets);
    CGSize itemSize = CGSizeZero;
    itemSize.width = (bounds.size.width-(itemsPerRow-1)*interitemSpacing)/itemsPerRow;
    itemSize.height = (bounds.size.height-(lines-1)*lineSpacing)/lines;
    //消除浮点误差
    if(itemSize.width>0){
        itemSize.width -= kLUIGridPageCollectionViewLayoutFloatDelta;
    }
    if(itemSize.height>0){
        itemSize.height -= kLUIGridPageCollectionViewLayoutFloatDelta;
    }
    return itemSize;
}
- (CGFloat)interitemSpacingThatFitsItemSize:(CGSize)itemSize minimumInteritemSpacing:(CGFloat)minimumInteritemSpacing sectionInsets:(UIEdgeInsets)sectionInsets{
    CGFloat interitemSpacing = 0;
    CGRect bounds = self.collectionView.bounds;
    bounds = UIEdgeInsetsInsetRect(bounds, sectionInsets);
    NSInteger count = (bounds.size.width+minimumInteritemSpacing)/(itemSize.width+minimumInteritemSpacing);
    if(count>1){
        interitemSpacing = (bounds.size.width-count*itemSize.width)/(count-1);
        //消除浮点误差
        if(interitemSpacing>0){
            interitemSpacing -= kLUIGridPageCollectionViewLayoutFloatDelta;
        }
    }
    interitemSpacing = MAX(0,interitemSpacing);
    return interitemSpacing;
}
- (CGFloat)lineSpacingThatFitsItemSize:(CGSize)itemSize minimumLineSpacing:(CGFloat)minimumLineSpacing sectionInsets:(UIEdgeInsets)sectionInsets{
    CGFloat lineSpacing = 0;
    CGRect bounds = self.collectionView.bounds;
    bounds = UIEdgeInsetsInsetRect(bounds, sectionInsets);
    NSInteger count = (bounds.size.height+minimumLineSpacing)/(itemSize.height+minimumLineSpacing);
    if(count>1){
        lineSpacing = (bounds.size.height-count*itemSize.height)/(count-1);
        //消除浮点误差
        if(lineSpacing>0){
            lineSpacing -= kLUIGridPageCollectionViewLayoutFloatDelta;
        }
    }
    lineSpacing = MAX(0,lineSpacing);
    return lineSpacing;
}
- (CGFloat)interitemSpacingThatFitsItemSize:(CGSize)itemSize itemsPerRow:(NSInteger)itemsPerRow sectionInsets:(UIEdgeInsets)sectionInsets{
    CGFloat interitemSpacing = 0;
    CGRect bounds = self.collectionView.bounds;
    bounds = UIEdgeInsetsInsetRect(bounds, sectionInsets);
    NSInteger count = itemsPerRow;
    if(count>1){
        interitemSpacing = (bounds.size.width-count*itemSize.width)/(count-1);
        //消除浮点误差
        if(interitemSpacing>0){
            interitemSpacing -= kLUIGridPageCollectionViewLayoutFloatDelta;
        }
    }
    interitemSpacing = MAX(0,interitemSpacing);
    return interitemSpacing;
}
- (CGSize)l_sizeThatFits:(CGSize)size{
    CGSize sizeFits = CGSizeZero;
    CGRect originBounds = self.collectionView.bounds;
    CGRect bounds = self.collectionView.bounds;
    _isSizeFitting = YES;
    BOOL sizeChange = !CGSizeEqualToSize(originBounds.size, size);
    if(sizeChange){
        bounds.size = size;
        self.collectionView.bounds = bounds;
    }
    
    NSArray<LUIGridPageCollectionViewLayoutSection *> *sectionModels = [self _createSectionModels];
    NSMutableArray<LUIGridPageCollectionViewLayoutPage *> *pages = [[NSMutableArray alloc] initWithCapacity:sectionModels.count];
    for (LUIGridPageCollectionViewLayoutSection *section in sectionModels) {
        [pages addObjectsFromArray:section.pages];
    }
    if(pages.count){
        sizeFits.height = bounds.size.height;
        sizeFits.width = pages.count*bounds.size.width;
    }
    
    if(sizeChange){
        self.collectionView.bounds = originBounds;
    }
    //消除浮点误差
    sizeFits.width = ceil(sizeFits.width);
    sizeFits.height = ceil(sizeFits.height);
    _isSizeFitting = NO;
    return sizeFits;
}
@end
@implementation UICollectionView(LUIGridPageCollectionViewLayout)
- (nullable LUIGridPageCollectionViewLayout *)l_collectionViewGridPageLayout{
    if([self.collectionViewLayout isKindOfClass:[LUIGridPageCollectionViewLayout class]]){
        return (LUIGridPageCollectionViewLayout *)self.collectionViewLayout;
    }
    return nil;
}
@end
