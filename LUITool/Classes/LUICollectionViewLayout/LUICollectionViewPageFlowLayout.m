//
//  LUICollectionViewPageFlowLayout.m
//  LUITool
//
//  Created by 六月 on 2023/8/19.
//

#import "LUICollectionViewPageFlowLayout.h"
#import "NSArray+LUI_BinarySearch.h"
#import "UICollectionViewLayoutAttributes+LUI.h"
#import "NSValue+LUI.h"
#import "NSTimer+LUI.h"
#import "LUIMacro.h"
#import "UIScrollView+LUI.h"
@interface _LUICollectionViewPageFlowSectionModel : NSObject
//@property (nonatomic) UICollectionViewScrollDirection scrollDirection;
//@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes *> *cellAttributes;
@property (nonatomic) UIEdgeInsets sectionInsets;
@property (nonatomic) CGFloat interitemSpacing;
@property (nonatomic) NSInteger itemCount;
@end
@implementation _LUICollectionViewPageFlowSectionModel
@end

@interface LUICollectionViewPageFlowLayout () <UICollectionViewDelegate> {
    CGSize _contentSize;
    NSIndexPath *_indexPathAtPagingCell;
    NSMutableArray<UICollectionViewLayoutAttributes *> * _cellAttributes;
    NSMutableArray<UICollectionViewLayoutAttributes *> *_cycleCellAttributes;//会保存三倍的_cellAttributes
    BOOL _isSizeFitting;
    NSIndexPath *_l_indexPathAtPagingCellBeforeBoundsChange;//保存bounds改变之前，画面中中间单元格的索引
    NSIndexPath *_l_preffedCellIndexpathAtPaging;
    NSIndexPath *__cachedPrePagingIndexPath;
    
    CGPoint _preContentOffset;
    BOOL _shouldCycleScroll;
    
    struct {
        BOOL isAutoScorlling;
        NSInteger distance;
        NSTimeInterval duration;
    } _autoScrollingState;
    
    struct {
        NSDate *preScrollDate;
        NSIndexPath *preMinDisIndexPath;
        CGFloat preDis;
    } _preScrollState;
    //用于indexPathAtPagingCellThatShould方法中，缓存上一次的计算结果，判断上一次最小距离的单元格是否跨越了中线
    
    BOOL _needReload;
}
@property (nonatomic, strong) NSMutableArray<_LUICollectionViewPageFlowSectionModel *> *sectionModels;
@property (nonatomic) BOOL offsetChanging;
@property (nonatomic, weak) id<UICollectionViewDelegate> originDelegate;
@property (nonatomic, strong) NSIndexPath *firstIndexPath;
@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes *> *cellAttributes;
@property (nonatomic, strong) NSMutableDictionary<NSIndexPath *,UICollectionViewLayoutAttributes *> *cellAttributeMap;
@property (nonatomic, strong) NSTimer *autoScrollingTimer;
@end

@implementation LUICollectionViewPageFlowLayout
- (id)init {
    if (self = [super init])  {
        self.sectionModels = [[NSMutableArray alloc] init];
        _cellAttributes = [[NSMutableArray alloc] init];
        _cycleCellAttributes = [[NSMutableArray alloc] init];
        self.cellAttributeMap = [[NSMutableDictionary alloc] init];
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.itemAlignment = LUICGRectAlignmentMid;
    }
    return self;
}

- (LUICGAxis)scrollAxis {
    LUICGAxis X = self.scrollDirection == UICollectionViewScrollDirectionHorizontal ? LUICGAxisX:LUICGAxisY;
    return X;
}
- (CGFloat)_offsetUnit {
    CGFloat unit = 1.0 / [UIScreen mainScreen].scale;
    return unit;
}
- (NSArray<UICollectionViewLayoutAttributes *> *)cellAttributes {
    return [_cellAttributes copy];
}
- (CGFloat)maxContentoffset {
    CGRect bounds = self.collectionView.bounds;
    CGSize contentSize = _contentSize;
    UIEdgeInsets contentInset = self.collectionView.l_adjustedContentInset;
    LUICGAxis X = self.scrollAxis;
    CGFloat max = MAX([self minContentoffset],LUICGSizeGetLength(contentSize, X)-LUICGRectGetLength(bounds, X)+LUIEdgeInsetsGetEdge(contentInset, X, LUIEdgeInsetsMax));
    return max;
}
- (CGFloat)minContentoffset {
    UIEdgeInsets contentInset = self.collectionView.l_adjustedContentInset;
    LUICGAxis X = self.scrollAxis;
    CGFloat min = -LUIEdgeInsetsGetEdge(contentInset, X, LUIEdgeInsetsMin);
    return min;
}
- (CGFloat)pagingPositionForCellFrame:(CGRect)frame {
    CGFloat x = 0;
    LUICGAxis X = self.scrollAxis;
    x = LUICGRectGetMin(frame, X) + LUICGRectGetLength(frame, X) * self.pagingCellPosition;
    return x;
}
- (CGFloat)pagingOffsetForCellFrame:(CGRect)frame {
    CGFloat offset = 0;
    CGRect bounds = self.collectionView.bounds;
    LUICGAxis X = self.scrollAxis;
    offset = LUICGRectGetMin(frame, X) + LUICGRectGetLength(frame, X) * self.pagingCellPosition - LUICGRectGetLength(bounds, X) * self.pagingBoundsPositionForCollectionView;
    return offset;
}
- (CGFloat)pagingOffsetForCellIndexPath:(NSIndexPath *)indexpath {
    CGFloat offset = 0;
    UICollectionViewLayoutAttributes *attr = [self layoutAttributesForItemAtIndexPath:indexpath];
    if (attr) {
        CGRect frame = attr.l_frameSafety;
        offset = [self pagingOffsetForCellFrame:frame];
    }
    return offset;
}

- (NSInteger)_cellIndexForCellNearToOffset:(CGFloat)position scrollVelocity:(CGPoint)velocity {
    
    LUICGAxis X = [self scrollAxis];
    CGPoint offset = self.collectionView.contentOffset;
    NSInteger result = NSNotFound;
    
    //二分查找position相近及相交的单元格
    NSRange range = [self pagableCellIndexRangeNearToOffset:position];
    CGFloat unit = [self _offsetUnit];
    if (range.location != NSNotFound) {
        if (LUICGPointGetValue(velocity, X)>0) {
            for (NSUInteger i=0; i<range.length; i++)  {
                NSInteger index = i+range.location;
                UICollectionViewLayoutAttributes *c = _cellAttributes[index];
                if ([self isCellAttributesVisible:c]) {
                    CGFloat pagingOffset = [self pagingOffsetForCellIndexPath:c.indexPath];
                    if (pagingOffset>=LUICGPointGetValue(offset, X)-unit) {
                        result = index;
                        break;
                    }
                }
            }
        } else if (LUICGPointGetValue(velocity, X)<0) {
            for (NSUInteger i=0; i<range.length; i++)  {
                NSInteger index = range.location+range.length-1-i;
                UICollectionViewLayoutAttributes *c = _cellAttributes[index];
                if ([self isCellAttributesVisible:c]) {
                    CGFloat pagingOffset = [self pagingOffsetForCellIndexPath:c.indexPath];
                    if (pagingOffset<=LUICGPointGetValue(offset, X)+unit) {
                        result = index;
                        break;
                    }
                }
            }
        } else {
        }
    }
    if (result == NSNotFound) {
        CGFloat min = CGFLOAT_MAX;
        for (NSUInteger i=0; i<range.length; i++)  {
            NSInteger index = i+range.location;
            UICollectionViewLayoutAttributes *c = _cellAttributes[index];
            if ([self isCellAttributesVisible:c]) {
                CGFloat pagingOffset = [self pagingOffsetForCellIndexPath:c.indexPath];
                CGFloat dis = ABS(pagingOffset-LUICGPointGetValue(offset, X));
                if (dis<min) {
                    result = index;
                    min = dis;
                }
            }
        }
    }
    
    return result;
}
- (NSInteger)_cellIndexForCellAtOffset:(CGFloat)position {
    NSInteger p = NSNotFound;
    LUICGAxis X = [self scrollAxis];
    CGFloat unit = [self _offsetUnit];
    NSRange range = [_cellAttributes l_rangeOfSortedObjectsWithComparator:^NSComparisonResult(UICollectionViewLayoutAttributes *arrayObj, NSInteger idx)  {
        NSComparisonResult r = NSOrderedSame;
        CGRect frame = arrayObj.l_frameSafety;
        if (LUICGRectGetMin(frame, X)-unit<=position && position<= LUICGRectGetMax(frame, X)+unit) {
            r = NSOrderedSame;
        } else if (LUICGRectGetMax(frame, X)-unit<position) {
            r = NSOrderedAscending;
        } else {
            r = NSOrderedDescending;
        }
        return r;
    }];
    if (range.location!=NSNotFound) {
        for (NSUInteger i=0; i<range.length; i++)  {
            NSInteger index = i+range.location;
            UICollectionViewLayoutAttributes *c = _cellAttributes[index];
            if ([self isCellAttributesVisible:c]) {
                p = index;
                break;
            }
        }
    }
    return p;
}
- (NSIndexPath *)indexPathForCellAtOffset:(CGFloat)position {
    NSIndexPath *p = nil;
    NSInteger index = [self _cellIndexForCellAtOffset:position];
    if (index!=NSNotFound) {
        p = _cellAttributes[index].indexPath;
    }
    return p;
}
- (NSRange)pagableCellIndexRangeNearToOffset:(CGFloat)position {
    LUICGAxis X = [self scrollAxis];
    NSRange range = [_cellAttributes l_rangeOfSortedObjectsWithComparator:^NSComparisonResult(UICollectionViewLayoutAttributes *arrayObj, NSInteger idx)  {
        CGRect frame = arrayObj.l_frameSafety;
        NSComparisonResult r = NSOrderedSame;
        if (LUICGRectGetMin(frame, X)<=position && position<= LUICGRectGetMax(frame, X)) {
            r = NSOrderedSame;
        } else if (LUICGRectGetMax(frame, X)<position) {//位于position左侧
            if (idx==self->_cellAttributes.count-1) {
                r = NSOrderedSame;
            } else {
                r = NSOrderedAscending;
                for (NSInteger i=idx+1; i<self->_cellAttributes.count; i++)  {
                    UICollectionViewLayoutAttributes *c = self->_cellAttributes[i];
                    if ([self isCellAttributesVisible:c]) {
                        CGRect f1 = c.l_frameSafety;
                        if (LUICGRectGetMin(f1, X)<=position && position<= LUICGRectGetMax(f1, X)) {
                            r = NSOrderedSame;
                        } else if (LUICGRectGetMax(f1, X)<position) {
                            r = NSOrderedAscending;
                        } else {
                            r = NSOrderedSame;
                        }
                        break;
                    }
                }
            }
        } else {//位于position右侧
            if (idx==0) {
                r = NSOrderedSame;
            } else {
                r = NSOrderedDescending;
                for (NSInteger i=idx-1; i>=0; i--)  {
                    UICollectionViewLayoutAttributes *c = self->_cellAttributes[i];
                    if ([self isCellAttributesVisible:c]) {
                        CGRect f1 = c.l_frameSafety;
                        if (LUICGRectGetMin(f1, X)<=position && position<= LUICGRectGetMax(f1, X)) {
                            r = NSOrderedSame;
                        } else if (LUICGRectGetMin(f1, X)>position) {
                            r = NSOrderedDescending;
                        } else {
                            r = NSOrderedSame;
                        }
                        break;
                    }
                }
            }
        }
        return r;
    }];
    return range;
}
- (UICollectionViewLayoutAttributes *)firstVisibleCellAttributeIn:(NSArray<UICollectionViewLayoutAttributes *> *)cellAttributes {
    UICollectionViewLayoutAttributes *result = nil;
    for (UICollectionViewLayoutAttributes *cellAttr in cellAttributes)  {
        if ([self isCellAttributesVisible:cellAttr]) {
            result = cellAttr;
            break;
        }
    }
    return result;
}
- (UICollectionViewLayoutAttributes *)lastVisibleCellAttributeIn:(NSArray<UICollectionViewLayoutAttributes *> *)cellAttributes {
    UICollectionViewLayoutAttributes *result = nil;
    for (UICollectionViewLayoutAttributes *cellAttr in cellAttributes.reverseObjectEnumerator)  {
        if ([self isCellAttributesVisible:cellAttr]) {
            result = cellAttr;
            break;
        }
    }
    return result;
}
- (BOOL)isCellAttributesVisible:(UICollectionViewLayoutAttributes *)cellAttr {
    CGRect frame = cellAttr.l_frameSafety;
    BOOL is = frame.size.width>0&&frame.size.height>0;
    return is;
}
- (CGFloat)positionOfPagingForRect:(CGRect)bounds {
    LUICGAxis X = [self scrollAxis];
    CGFloat position = 0;
    position = LUICGRectGetMin(bounds, X)+LUICGRectGetLength(bounds, X)*self.pagingBoundsPositionForCollectionView;
    return position;
}

- (void)dealloc {
    self.collectionView.delegate = self.originDelegate;
    [self.autoScrollingTimer invalidate];
}
- (void)setOriginDelegate:(id<UICollectionViewDelegate>)originDelegate {
    if (originDelegate!=self) {//添加鲁棒性
        _originDelegate = originDelegate;
    }
}
- (void)_prepareDelegate {
    if (self.enableCycleScroll||self.pagingEnabled||_autoScrollingState.isAutoScorlling) {
        //循环滚动或分页对齐时，都需要添加scrollview的方法
        if (self.collectionView.delegate!=self) {
            self.originDelegate = self.collectionView.delegate;
            self.collectionView.delegate = self;
        }
    } else {
        if (self.originDelegate) {
            self.collectionView.delegate = self.originDelegate;
            self.originDelegate = nil;
        }
    }
}
- (void)setEnableCycleScroll:(BOOL)enableCycleScroll {
    if (_enableCycleScroll!=enableCycleScroll) {
        _needReload = YES;
        _enableCycleScroll = enableCycleScroll;
        [self _prepareDelegate];
    }
}
- (void)setPagingEnabled:(BOOL)pagingEnabled {
    if (_pagingEnabled!=pagingEnabled) {
        _needReload = YES;
        _pagingEnabled = pagingEnabled;
        [self _prepareDelegate];
    }
}
- (void)setPagingBoundsPosition:(CGFloat)pagingBoundsPosition {
    if (_pagingBoundsPosition!=pagingBoundsPosition) {
        _needReload = YES;
        _pagingBoundsPosition = pagingBoundsPosition;
    }
}
- (void)setPagingCellPosition:(CGFloat)pagingCellPosition {
    if (_pagingCellPosition!=pagingCellPosition) {
        _needReload = YES;
        _pagingCellPosition = pagingCellPosition;
    }
}

- (NSIndexPath *)indexPathAtPagingCell {
    if (!_indexPathAtPagingCell) {
        _indexPathAtPagingCell = [self indexPathAtPagingCellWithMinDistance];
    }
    return _indexPathAtPagingCell;
}
- (NSIndexPath *)indexPathAtPagingCellWithMinDistance {
    NSIndexPath *indexPath = nil;
    CGRect bounds = self.collectionView.bounds;
    CGFloat position = [self positionOfPagingForRect:bounds];
    NSRange range = [self pagableCellIndexRangeNearToOffset:position];
    if (range.length) {
        CGFloat minDis = CGFLOAT_MAX;
        NSIndexPath *minIndexPath = nil;
        for (NSInteger i=0;i<range.length;i++) {
            NSInteger index = range.location+i;
            UICollectionViewLayoutAttributes *c = _cellAttributes[index];
            CGRect f1 = c.frame;
            CGFloat x1 = [self pagingPositionForCellFrame:f1];
            CGFloat dis = ABS(position-x1);
            if (dis<minDis) {
                minDis = dis;
                minIndexPath = c.indexPath;
            }
        }
        indexPath = minIndexPath;
    }
    return indexPath;
}
- (CGFloat)scrollProgressWithContentOffset:(CGPoint)offset fromPagingCell:(NSIndexPath *_Nullable*_Nullable)fromPadingCellIndexPathPoint toPagingCell:(NSIndexPath *_Nullable*_Nullable)toPadingCellIndexPathPoint {
    CGFloat progress = 0;
    CGRect bounds = self.collectionView.bounds;
    bounds.origin = offset;
    CGFloat position = [self positionOfPagingForRect:bounds];
    NSRange range = [self pagableCellIndexRangeNearToOffset:position];
//    NSLog(@"range:%@",NSStringFromRange(range));
    if (range.length) {
        NSIndexPath *p1,*p2;
        CGFloat x1=0,x2=0;
        for (NSInteger i=0;i<range.length;i++) {
            NSInteger index = range.location+i;
            UICollectionViewLayoutAttributes *c = _cellAttributes[index];
            CGFloat x = [self pagingPositionForCellFrame:c.frame];
            if (x<=position) {
                p1 = c.indexPath;
                x1 = x;
            } else if (x>position && !p2) {
                p2 = c.indexPath;
                x2 = x;
            }
        }
        if (fromPadingCellIndexPathPoint!=NULL) {
            *fromPadingCellIndexPathPoint = p1;
        }
        if (toPadingCellIndexPathPoint!=NULL) {
            *toPadingCellIndexPathPoint = p2;
        }
        if (p1 && p2 && x1!=x2) {
            progress = (position-x1)/(x2-x1);
        }
//        NSLog(@"from:%@,to:%@,progress:%.2f",@(p1.item),@(p2.item),progress);
    }
    return progress;
}
- (CGFloat)scrollProgressWithContentOffset:(CGPoint)offset toPagingCell:(NSIndexPath *_Nullable*_Nullable)toPadingCellIndexPathPoint {
    NSIndexPath *p1,*p2;
    NSIndexPath *currentIndexPath = self.indexPathAtPagingCell;
    CGFloat progress = [self scrollProgressWithContentOffset:offset fromPagingCell:&p1 toPagingCell:&p2];
    
    if (p1==currentIndexPath || [p1 isEqual:currentIndexPath]) {
    } else {
        p2 = p1;
        progress = 1-progress;
    }
    if (toPadingCellIndexPathPoint!=NULL) {
        *toPadingCellIndexPathPoint = p2;
    }
//    NSLog(@"from:%@,to:%@,progress:%.2f",@(currentIndexPath.item),@(p2.item),progress);
    return progress;
}
- (NSInteger)__numberOfItemsInSetionModelWithIndex:(NSInteger)index {
    NSInteger count = 0;
    if (index>=0&&index<self.sectionModels.count) {
        count = self.sectionModels[index].itemCount;
    }
    return count;
}
- (void)setIndexPathAtPagingCell:(NSIndexPath *)indexPathAtPagingCell animated:(BOOL)animated {
    if (!indexPathAtPagingCell) {
        return;
    }
    NSIndexPath *p = indexPathAtPagingCell;
    if (p.section<0||p.section>=self.collectionView.numberOfSections) {
        return;
    }
    NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:p.section];
    if (p && p.section>=0&&p.section<self.collectionView.numberOfSections && p.item>=0 && p.item<numberOfItems) {
        NSInteger numberOfItemsInSetionModel = [self __numberOfItemsInSetionModelWithIndex:p.section];
        if (
           numberOfItemsInSetionModel!=numberOfItems //判断self.sectionModels中的数据，是否与collectionView.dataSource中数量上一致.数量不一致，代表dataSource变化了，但prepare方法还未被执行
           || CGSizeEqualToSize(self.collectionView.bounds.size, CGSizeZero) //bounds.size为0时，需要保存期望滚动到中线的值，等待size被重新赋值时，再滚动到该位置
           ) {
            _l_preffedCellIndexpathAtPaging = p;
            _l_indexPathAtPagingCellBeforeBoundsChange = nil;
        } else {
            _l_preffedCellIndexpathAtPaging = nil;
            _l_indexPathAtPagingCellBeforeBoundsChange = nil;
            LUICGAxis X = [self scrollAxis];
            
            CGFloat pagingOffset = [self pagingOffsetForCellIndexPath:p];
            CGPoint offset = self.collectionView.contentOffset;
            LUICGPointSetValue(&offset, X, pagingOffset);
            
            CGFloat minOffset = [self minContentoffset];
            CGFloat maxOffset = [self maxContentoffset];
            
            BOOL outOfScollRange = pagingOffset<minOffset || pagingOffset>maxOffset;
            if (self.enableCycleScroll && outOfScollRange && !animated) {
                //超出滚动范围了,需要重排一次，然后计算新的位置
                [self __setContentViewContentOffset:offset animated:NO];
                [self.collectionView layoutIfNeeded];
                pagingOffset = [self pagingOffsetForCellIndexPath:p];
                LUICGPointSetValue(&offset, X, pagingOffset);
            }
            [self __setContentViewContentOffset:offset animated:animated];
        }
    }
}
- (void)setIndexPathAtPagingCellWithDistance:(NSInteger)distance animated:(BOOL)animated {
    CGFloat position = [self positionOfPagingForRect:self.collectionView.bounds];
    LUICGAxis X = [self scrollAxis];
    CGPoint velocity = CGPointZero;
    LUICGPointSetValue(&velocity, X, distance);
    NSInteger index = [self _cellIndexForCellNearToOffset:position scrollVelocity:velocity];
    if (index!=NSNotFound) {
        NSInteger dis = distance;
        if (dis<0) {
            dis = -((-distance)%_cellAttributes.count);
        }
        NSInteger newIndex = (index+dis+_cellAttributes.count)%_cellAttributes.count;
        NSIndexPath *newIndexPath = _cellAttributes[newIndex].indexPath;
        if (index!=newIndex) {
            if ((self.enableCycleScroll && _shouldCycleScroll) && distance*(newIndex-index) < 0) {
                //方向反了。需要进行一次重排
                NSInteger nextBeginIndex = distance>0 ? index : newIndex;
                [self __resortCellAttributeWithBeginIndex:nextBeginIndex];
            }
            [self setIndexPathAtPagingCell:newIndexPath animated:animated];
        }
    }
}
- (CGRect)visibleRectForOriginBounds:(CGRect)bounds {
    return bounds;
}
- (CGFloat)distanceToPagingPositionForCellLayoutAttributes:(UICollectionViewLayoutAttributes *)cellAttr {
    LUICGAxis X = [self scrollAxis];
    CGFloat dis = 0;
    if (cellAttr) {
        CGFloat position = [self positionOfPagingForRect:self.collectionView.bounds];
        CGRect frame = cellAttr.l_frameSafety;
        dis = (LUICGRectGetMin(frame, X)+LUICGRectGetLength(frame, X)*self.pagingCellPosition) - position;
    }
    return dis;
}
- (void)highlightPagingCellAttributes:(UICollectionViewLayoutAttributes *)cellAttr {
}
- (BOOL)isAutoScrolling {
    return _autoScrollingState.isAutoScorlling;
}
- (void)startAutoScrollingWithDistance:(NSInteger)distance duration:(NSTimeInterval)duration {
    if (_autoScrollingState.isAutoScorlling&&_autoScrollingState.distance==distance&&_autoScrollingState.duration==duration) {
        return;
    }
    memset(&_autoScrollingState, 0, sizeof(_autoScrollingState));
    _autoScrollingState.distance = distance;
    _autoScrollingState.duration = duration;
    _autoScrollingState.isAutoScorlling = YES;
    [self.autoScrollingTimer invalidate];
    
    @LUI_WEAKIFY(self);
    self.autoScrollingTimer = [NSTimer l_scheduledTimerWithTimeInterval:_autoScrollingState.duration repeats:YES block:^(NSTimer * _Nonnull timer)  {
        @LUI_NORMALIZE(self);
        [self _onAudoScrollingTimer:timer];
    }];
}
- (void)stopAutoScrolling {
    memset(&_autoScrollingState, 0, sizeof(_autoScrollingState));
    [self.autoScrollingTimer invalidate];
    self.autoScrollingTimer = nil;
}
- (void)_pauseAutoScrolling {
    if (!self.isAutoScrolling) {
        return;
    }
    [self.autoScrollingTimer invalidate];
}
- (void)_resumeAutoScrolling {
    if (!self.isAutoScrolling) {
        return;
    }
    if (!self.autoScrollingTimer.isValid) {
        self.autoScrollingTimer = [NSTimer scheduledTimerWithTimeInterval:_autoScrollingState.duration target:self selector:@selector(_onAudoScrollingTimer:) userInfo:nil repeats:YES];
    }
}
- (void)_onAudoScrollingTimer:(NSTimer *)timer {
    NSInteger distance = _autoScrollingState.distance;
    [self setIndexPathAtPagingCellWithDistance:distance animated:YES];
}

#pragma mark - Forward Invocations
/**
 *根據指定的Selector返回該類支持的方法簽名,一般用於prototol或者消息轉發forwardInvocation:中NSInvocation參數的methodSignature屬性
 注:系統調用- (void)forwardInvocation:(NSInvocation *)invocation方法前,會先調用此方法獲取NSMethodSignature,然後生成方法所需要的NSInvocation
 */
- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector  {
    NSMethodSignature *signature = [super methodSignatureForSelector:selector];
    if (signature == nil)  {
        id delegate = self.originDelegate;
        if ([delegate respondsToSelector:selector])  {
            signature = [delegate methodSignatureForSelector:selector];
        }
    }
    return signature;
}
- (BOOL)respondsToSelector:(SEL)selector  {
    if ([super respondsToSelector:selector])  {
        return YES;
    } else  {
        if ([self.originDelegate respondsToSelector:selector]) {
            return YES;
        }
    }
    return NO;
}
- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    BOOL conforms = NO;
    if ([super conformsToProtocol:aProtocol]) {
        conforms = YES;
    } else {
        if ([self.originDelegate conformsToProtocol:aProtocol]) {
            conforms = YES;
        }
    }
    return conforms;
}
//对调用未定义的方法进行消息重定向
- (void)forwardInvocation:(NSInvocation *)invocation  {
    BOOL didForward = NO;
    id delegate = self.originDelegate;
    if ([delegate respondsToSelector:invocation.selector])  {
        [invocation invokeWithTarget:delegate];
        didForward = YES;
    }
    if (!didForward)  {
        [super forwardInvocation:invocation];
    }
}
- (void)doesNotRecognizeSelector:(SEL)aSelector {
    if (self.collectionView.dataSource==nil) {
        //ios内存释放机制，导致dataSource已经空了，但delegate还保持为自己。此时不应该响应任何方法了
        return;
    }
    if (aSelector==@selector(collectionView:didEndDisplayingCell:forItemAtIndexPath:)) {
        return;
    }
    [super doesNotRecognizeSelector:aSelector];
}
#pragma mark - scroll delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self _pauseAutoScrolling];
    if ([self.originDelegate respondsToSelector:_cmd]) {
        [self.originDelegate scrollViewWillBeginDragging:scrollView];
    }
}
// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self _resumeAutoScrolling];
    }
    if ([self.originDelegate respondsToSelector:_cmd]) {
        [self.originDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self _resumeAutoScrolling];
    
    if ((self.enableCycleScroll && _shouldCycleScroll)&&self.pagingEnabled) {
        [self __scrollviewDidEndScrolling:scrollView];
    } else {
        [self __scrollviewDidEndScrolling:scrollView];
        if (self.playPagingSound&&self.pagingEnabled&&self.indexPathAtPagingCell) {
            [self _play3DTouchSound];
        }
    }
    if ([self.originDelegate respondsToSelector:_cmd]) {
        [self.originDelegate scrollViewDidEndDecelerating:scrollView];
    }
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self _updateIndexPathAtPagingCellForScrolling];
    [self __scrollviewDidEndScrolling:scrollView];
    if (self.playPagingSound&&self.pagingEnabled&&self.indexPathAtPagingCell) {
        [self _play3DTouchSound];
    }
    if ([self.originDelegate respondsToSelector:_cmd]) {
        [self.originDelegate scrollViewDidEndScrollingAnimation:scrollView];
    }
}
- (NSIndexPath *)indexPathAtPagingCellThatShould {
    NSIndexPath *currentIndexPath = _indexPathAtPagingCell;
    CGRect bounds = self.collectionView.bounds;
    CGFloat position = [self positionOfPagingForRect:bounds];
    NSRange range = [self pagableCellIndexRangeNearToOffset:position];
//    NSLog(@"range:%@",NSStringFromRange(range));
    NSDate *preScrollDate = _preScrollState.preScrollDate;
    NSIndexPath *preMinDisIndexPath = _preScrollState.preMinDisIndexPath;
    CGFloat preDis = _preScrollState.preDis;
    
    BOOL currentInRange = NO;
    if (range.length) {
        CGFloat minDis = CGFLOAT_MAX;
        CGFloat minDisValue = 0;
        BOOL minDisOver = NO;
        NSIndexPath *minIndexPath = nil;
        for (NSInteger i=0;i<range.length;i++) {
            NSInteger index = range.location+i;
            UICollectionViewLayoutAttributes *c = _cellAttributes[index];
            NSIndexPath *p = c.indexPath;
            CGRect f1 = c.frame;
            CGFloat x1 = [self pagingPositionForCellFrame:f1];
            CGFloat dis = ABS(position-x1);
            if (dis<minDis) {
                minDisValue = position-x1;
                minDis = dis;
                minIndexPath = p;
                minDisOver = minDis<1;
            }
            if ([currentIndexPath isEqual:p]) {
                currentInRange = YES;
            }
        }
        NSDate *now = [NSDate date];
        if (!minDisOver && preMinDisIndexPath && preScrollDate && [preMinDisIndexPath isEqual:minIndexPath]) {
            BOOL inShortTime = [now timeIntervalSinceDate:preScrollDate]<1;
            BOOL isOverPoistion = preDis*minDisValue<0;//跨过中线
            if (inShortTime && isOverPoistion) {
                minDisOver = YES;
            }
        }
        _preScrollState.preScrollDate = now;
        _preScrollState.preMinDisIndexPath = minIndexPath;
        _preScrollState.preDis = minDisValue;
        
        if (!currentInRange || minDisOver) {
            currentIndexPath = minIndexPath;
        }
        if (![currentIndexPath isEqual:_indexPathAtPagingCell]) {
            
        }
//        NSLog(@"minDis:%.2f,currentIndexPath:%@,minIndexPath:%@",minDis,@(currentIndexPath.item),@(minIndexPath.item));
    }
    return currentIndexPath;
}
- (void)_updateIndexPathAtPagingCellForScrolling {
    NSIndexPath *oldIndexPath = _indexPathAtPagingCell;
    if (!_indexPathAtPagingCell) {
        [self indexPathAtPagingCell];
    } else {
        //判断是否要更新
        _indexPathAtPagingCell = [self indexPathAtPagingCellThatShould];
    }
    
    if (self.pagingEnabled&&self.playPagingSound) {
        NSIndexPath *p = self.indexPathAtPagingCell;
        if (!(_indexPathAtPagingCell==p||[_indexPathAtPagingCell isEqual:p])) {
            _indexPathAtPagingCell = p;
            if (_indexPathAtPagingCell&&(self.collectionView.isTracking||self.collectionView.isDecelerating||self.collectionView.dragging)) {
                [self _play3DTouchSound];
            }
        }
    }
    if (oldIndexPath==_indexPathAtPagingCell || [oldIndexPath isEqual:_indexPathAtPagingCell]) {
        
    } else {
//        NSLog(@"__nofityScrollToPaging:%@",_indexPathAtPagingCell);
        [self __nofityScrollToPaging];
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //计算
    [self _updateIndexPathAtPagingCellForScrolling];
    if ([self.originDelegate respondsToSelector:_cmd]) {
        [self.originDelegate scrollViewDidScroll:scrollView];
    }
}
- (void)__nofityScrollToPaging {
//    NSLog(@"__nofityScrollToPaging:%@",@(self.indexPathAtPagingCell.item));
    if ([self.pageFlowDelegate respondsToSelector:@selector(collectionView:pageFlowLayout:didScrollToPagingCell:)]) {
        NSIndexPath *indexPathAtPagingCell = self.indexPathAtPagingCell;
        [self.pageFlowDelegate collectionView:self.collectionView pageFlowLayout:self didScrollToPagingCell:indexPathAtPagingCell];
    }
}
- (void)__scrollviewDidEndScrolling:(UIScrollView *)scrollView {
    _l_preffedCellIndexpathAtPaging = self.indexPathAtPagingCell;
}
- (void)_play3DTouchSound {
    if (@available(iOS 10.0, *))  {
        UIImpactFeedbackGenerator *impactFeedBack = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
        [impactFeedBack prepare];
        [impactFeedBack impactOccurred];
    } else {
//        AudioServicesPlaySystemSound(1519);//普通短震(3D Touch 中 Peek 震动反馈)
//    AudioServicesPlaySystemSound(1520);//普通短震(3D Touch 中 Pop 震动反馈)
//    AudioServicesPlaySystemSound(1521);//连续三次短震
    }
}

#pragma mark - LUICollectionViewDelegatePageFlowLayout
- (id<LUICollectionViewDelegatePageFlowLayout>)pageFlowDelegate {
    if ([self.collectionView.delegate conformsToProtocol:@protocol(LUICollectionViewDelegatePageFlowLayout)]) {
        return (id<LUICollectionViewDelegatePageFlowLayout>)self.collectionView.delegate;
    }
    return nil;
}
- (CGSize)itemSizeForSectionAtIndexPath:(NSIndexPath *)indexPath {
    id<LUICollectionViewDelegatePageFlowLayout> pageFlowDelegate = self.pageFlowDelegate;
    CGSize value = self.itemSize;
    if ([pageFlowDelegate respondsToSelector:@selector(collectionView:pageFlowLayout:itemSizeForItemAtIndexPath:)]) {
        value = [pageFlowDelegate collectionView:self.collectionView pageFlowLayout:self itemSizeForItemAtIndexPath:indexPath];
    }
    return value;
}
- (UIEdgeInsets)insetForSectionAtIndex:(NSInteger)section {
    id<LUICollectionViewDelegatePageFlowLayout> pageFlowDelegate = self.pageFlowDelegate;
    UIEdgeInsets value = self.sectionInset;
    if ([pageFlowDelegate respondsToSelector:@selector(collectionView:pageFlowLayout:insetForSectionAtIndex:)]) {
        value = [pageFlowDelegate collectionView:self.collectionView pageFlowLayout:self insetForSectionAtIndex:section];
    }
    return value;
}
- (CGFloat)interitemSpacingForSectionAtIndex:(NSInteger)section {
    id<LUICollectionViewDelegatePageFlowLayout> pageFlowDelegate = self.pageFlowDelegate;
    CGFloat value = self.interitemSpacing;
    if ([pageFlowDelegate respondsToSelector:@selector(collectionView:pageFlowLayout:interitemSpacingForSectionAtIndex:)]) {
        value = [pageFlowDelegate collectionView:self.collectionView pageFlowLayout:self interitemSpacingForSectionAtIndex:section];
    }
    return value;
}
- (CGFloat)pagingBoundsPositionForCollectionView {
    id<LUICollectionViewDelegatePageFlowLayout> pageFlowDelegate = self.pageFlowDelegate;
    CGFloat value = self.pagingBoundsPosition;
    if ([pageFlowDelegate respondsToSelector:@selector(pagingBoundsPositionForCollectionView:pageFlowLayout:)]) {
        value = [pageFlowDelegate pagingBoundsPositionForCollectionView:self.collectionView pageFlowLayout:self];
    }
    return value;
}
- (void)reloadData {
    self.offsetChanging = NO;
    _needReload = YES;
    [self.collectionView reloadData];
}
#pragma mark - UISubclassingHooks

//@property(class, nonatomic,  readonly) Class invalidationContextClass API_AVAILABLE(ios(7.0)); // override this method to provide a custom class to be used for invalidation contexts

// The collection view calls -prepareLayout once at its first layout as the first message to the layout instance.
// The collection view calls -prepareLayout again after layout is invalidated and before requerying the layout information.
// Subclasses should always call super if they override.
- (void)prepareLayout {
    [super prepareLayout];
    [self _prepareDelegate];
    if ((self.highlightPagingCell||(self.enableCycleScroll && _shouldCycleScroll)||self.pagingEnabled) && self.offsetChanging && !_needReload) {
        if (_shouldCycleScroll) {
            [self _prepareForCycleScroll:YES preffedCellIndexpathAtPaging:nil];
        }
        if (self.highlightPagingCell) {
            [self _prepareForHighlightCell];
        }
    } else {
        [self _prepareAllLayout];
        if ((self.enableCycleScroll && _shouldCycleScroll)) {
            [self _prepareForCycleScroll:NO preffedCellIndexpathAtPaging:_l_preffedCellIndexpathAtPaging];
            _l_preffedCellIndexpathAtPaging = self.indexPathAtPagingCell;
        } else {
            if (self.pagingEnabled) {
                if (_l_preffedCellIndexpathAtPaging) {
                    CGPoint offset = self.collectionView.contentOffset;
                    CGFloat pagingOffset = [self pagingOffsetForCellIndexPath:_l_preffedCellIndexpathAtPaging];
                    LUICGPointSetValue(&offset, [self scrollAxis], pagingOffset);
                    self.collectionView.contentOffset = offset;
                } else {
                    CGPoint offset = [self targetContentOffsetForProposedContentOffset:self.collectionView.contentOffset withScrollingVelocity:CGPointZero];
                    self.collectionView.contentOffset = offset;
                    _l_preffedCellIndexpathAtPaging = self.indexPathAtPagingCell;
                }
            }
        }
        if (self.highlightPagingCell) {
            [self _prepareForHighlightCell];
        }
    }
    _preContentOffset = self.collectionView.contentOffset;
    self.offsetChanging = NO;
    _needReload = NO;
}
- (void)_prepareForHighlightCell {
    CGRect bounds = [self visibleRectForOriginBounds:self.collectionView.bounds];
     
    NSArray<UICollectionViewLayoutAttributes *> *cellAttrs = [self layoutAttributesForElementsInRect:bounds];
    for (UICollectionViewLayoutAttributes *cellAttr in cellAttrs)  {
        if (cellAttr.representedElementCategory==UICollectionElementCategoryCell) {
            [self highlightPagingCellAttributes:cellAttr];
        }
    }
}
- (void)_prepareAllLayout {
    _indexPathAtPagingCell = nil;
    [self.cellAttributeMap removeAllObjects];
    [_cellAttributes removeAllObjects];
    [_cycleCellAttributes removeAllObjects];
    _contentSize = [self _prepareCellLayouts:_cellAttributes cellAttributeMap:self.cellAttributeMap cycleCellAttributes:_cycleCellAttributes sectionModels:self.sectionModels shouldCycleScroll:&_shouldCycleScroll isSizeFit:NO];
}
- (CGSize)_prepareCellLayouts:(NSMutableArray<UICollectionViewLayoutAttributes *> *)cellAttributes cellAttributeMap:(NSMutableDictionary<NSIndexPath *,UICollectionViewLayoutAttributes *> *)cellAttributeMap cycleCellAttributes:(NSMutableArray<UICollectionViewLayoutAttributes *> *)cycleCellAttributes sectionModels:(NSMutableArray<_LUICollectionViewPageFlowSectionModel *> *)sectionModels shouldCycleScroll:(BOOL *)shouldCycleScrollRef isSizeFit:(BOOL)isSizeFit {
    if (!cellAttributes) {
        cellAttributes = [[NSMutableArray alloc] init];
    }
    if (!cycleCellAttributes) {
        cycleCellAttributes = [[NSMutableArray alloc] init];
    }
    if (!sectionModels) {
        sectionModels = [[NSMutableArray alloc] init];
    }
    [cellAttributes removeAllObjects];
    [sectionModels removeAllObjects];
    [cycleCellAttributes removeAllObjects];
    
    //产生所有的cell attr
    LUICGAxis X = [self scrollAxis];
    LUICGAxis Y = LUICGAxisReverse(X);
    NSInteger sc = self.collectionView.numberOfSections;
    CGRect bounds = self.collectionView.bounds;
    CGRect f = CGRectZero;
    for (int i=0; i<sc; i++)  {
        _LUICollectionViewPageFlowSectionModel *sm = [[_LUICollectionViewPageFlowSectionModel alloc] init];
        
        NSInteger cellCount = [self.collectionView numberOfItemsInSection:i];
        UIEdgeInsets sectionInsets = [self insetForSectionAtIndex:i];
        
        CGFloat interitemSpacing = [self interitemSpacingForSectionAtIndex:i];
        CGRect sectionBounds = UIEdgeInsetsInsetRect(bounds, sectionInsets);
        BOOL hadFirstVisibleCell = NO;
//        NSMutableArray<UICollectionViewLayoutAttributes *> *sectionCellAttributes = [[NSMutableArray alloc] initWithCapacity:cellCount];
        
        CGFloat tmp = LUICGRectGetMin(f, X);
        LUICGRectSetMin(&f, X, LUICGRectGetMin(f, X)+LUIEdgeInsetsGetEdge(sectionInsets, X, LUIEdgeInsetsMin));
        
        for (int j=0; j<cellCount; j++)  {
            NSIndexPath *p = [NSIndexPath indexPathForItem:j inSection:i];
            f.size = [self itemSizeForSectionAtIndexPath:p];
            if (LUICGSizeGetLength(f.size, X)>0) {
                if (!hadFirstVisibleCell) {
                    hadFirstVisibleCell = YES;
                } else {
                    LUICGRectSetMin(&f, X, LUICGRectGetMin(f, X)+interitemSpacing);
                }
            }
            LUICGRectAlignToRect(&f, Y, self.itemAlignment, sectionBounds);
            UICollectionViewLayoutAttributes *cellAttr = [self.class.layoutAttributesClass layoutAttributesForCellWithIndexPath:p];
            cellAttr.l_frameSafety = f;
//            [sectionCellAttributes addObject:cellAttr];
            [cellAttributes addObject:cellAttr];
            //下一个cell起始位置
            if (LUICGRectGetLength(f, X)) {
                LUICGRectSetMin(&f, X, LUICGRectGetMin(f, X)+LUICGRectGetLength(f, X));
            }
        }
        LUICGRectSetMin(&f, X, LUICGRectGetMin(f, X)+LUIEdgeInsetsGetEdge(sectionInsets, X, LUIEdgeInsetsMax));
        if ((tmp+LUIEdgeInsetsGetEdgeSum(sectionInsets, X)) == LUICGRectGetMin(f, X)) {
            LUICGRectSetMin(&f, X, tmp);
        }
        sm.sectionInsets = sectionInsets;
        sm.itemCount = cellCount;
        [sectionModels addObject:sm];
    }
    if (cellAttributeMap) {
        for (UICollectionViewLayoutAttributes *cellAttr in cellAttributes)  {
            cellAttributeMap[cellAttr.indexPath] = cellAttr;
        }
    }
    
    //计算contentSize
    CGSize size = CGSizeZero;
     {
        LUICGSizeSetLength(&size, Y, LUICGRectGetLength(bounds, Y));
        UICollectionViewLayoutAttributes *lastCell = [self lastVisibleCellAttributeIn:cellAttributes];
        if (lastCell) {
            CGRect frame = lastCell.l_frameSafety;
            UIEdgeInsets sectionInsets = sectionModels[lastCell.indexPath.section].sectionInsets;
            LUICGSizeSetLength(&size, X, LUICGRectGetMax(frame, X)+LUIEdgeInsetsGetEdge(sectionInsets, X, LUIEdgeInsetsMax));
        }
    }
    
    //判断元素数量是否足以支持循环滚动
    BOOL shouldCycleScroll = self.enableCycleScroll;
    if (self.enableCycleScroll) {
        [cycleCellAttributes addObjectsFromArray:[self __genCycleCellAttributesWithCellAttributes:cellAttributes contentSize:size]];
        
        NSMutableArray<UICollectionViewLayoutAttributes *> *tryCells = [[NSMutableArray alloc] initWithCapacity:3];
        
        UICollectionViewLayoutAttributes *firstCell = [self firstVisibleCellAttributeIn:cellAttributes];
        if (firstCell&&![tryCells containsObject:firstCell]) {
            [tryCells addObject:firstCell];
        }
        
        UICollectionViewLayoutAttributes *lastCell = [self lastVisibleCellAttributeIn:cellAttributes];
        if (lastCell&&![tryCells containsObject:lastCell]) {
            [tryCells addObject:lastCell];
        }
        
        if (tryCells.count) {
            for (UICollectionViewLayoutAttributes *cellAttr in tryCells)  {
                CGRect cellFrame = cellAttr.l_frameSafety;
                CGFloat offset = [self pagingOffsetForCellFrame:cellFrame];
                CGRect tryBounds = bounds;
                LUICGRectSetMin(&tryBounds, X, offset);
                NSRange cellRange = [self __rangeForCycleScrollWithBounds:tryBounds cellCount:cellAttributes.count cycleCellAttributes:cycleCellAttributes contentSize:size scrollVector:CGVectorMake(0, 0)];
                if (cellRange.location==NSNotFound || cellRange.length>cellAttributes.count) {
                    shouldCycleScroll = NO;
                    break;
                }
            }
        } else {
            shouldCycleScroll = NO;
        }
    }
    if (shouldCycleScrollRef!=NULL) {
        *shouldCycleScrollRef = shouldCycleScroll;
    }
    
    //调整collectionView的contentInset，使得paging时，contentOffset能够超出原始的范围
    if (!isSizeFit) {
        UIEdgeInsets contentInsets = [self __calContentInsetsWithCellAttributes:cellAttributes contentSize:size];
        self.collectionView.contentInset = contentInsets;
    }

    return size;
}
- (NSArray<UICollectionViewLayoutAttributes *> *)__genCycleCellAttributesWithCellAttributes:(NSArray<UICollectionViewLayoutAttributes *> *)cellAttributes contentSize:(CGSize)contentSize {//根据所有的cell，产生用于循环滚动计算的cells
    NSMutableArray<UICollectionViewLayoutAttributes *> *cycleCellAttributes = [[NSMutableArray alloc] initWithCapacity:cellAttributes.count*3];
    LUICGAxis X = [self scrollAxis];
    for (UICollectionViewLayoutAttributes *cellAttr in cellAttributes)  {
        UICollectionViewLayoutAttributes *newCellAttr = [cellAttr copy];
        CGRect f1 = cellAttr.l_frameSafety;
        LUICGRectSetMin(&f1, X, LUICGRectGetMin(f1, X)-LUICGSizeGetLength(contentSize, X));
        newCellAttr.l_frameSafety = f1;
        [cycleCellAttributes addObject:newCellAttr];
    }
    [cycleCellAttributes addObjectsFromArray:cellAttributes];
    
    for (UICollectionViewLayoutAttributes *cellAttr in cellAttributes)  {
        UICollectionViewLayoutAttributes *newCellAttr = [cellAttr copy];
        CGRect f1 = cellAttr.l_frameSafety;
        LUICGRectSetMin(&f1, X, LUICGRectGetMin(f1, X)+LUICGSizeGetLength(contentSize, X));
        newCellAttr.l_frameSafety = f1;
        [cycleCellAttributes addObject:newCellAttr];
    }
    return cycleCellAttributes;
}
- (NSRange)__rangeForCycleScrollWithBounds:(CGRect)contentBounds cellCount:(NSInteger)cellCount cycleCellAttributes:(NSArray<UICollectionViewLayoutAttributes *> *)cycleCellAttributes contentSize:(CGSize)contentSize scrollVector:(CGVector)vector {
    //具体算法为：将cells扩展为三份（左中右），然后计算bounds覆盖的cell范围。得到范围，如果范围超过总元素数，代表元素数量不足以支持循环滚动。
    LUICGAxis X = [self scrollAxis];
    CGRect bounds = [self visibleRectForOriginBounds:contentBounds];
    LUICGRange boundsRange = LUICGRectGetRange(bounds, X);
    //使用二分法，查找bounds中的cell
    NSRange resultRange = [cycleCellAttributes l_rangeOfSortedObjectsWithComparator:^NSComparisonResult(UICollectionViewLayoutAttributes *  _Nonnull arrayObj, NSInteger idx)  {
        LUICGRange r = LUICGRectGetRange(arrayObj.l_frameSafety, X);
        NSComparisonResult result = NSOrderedSame;
        if (LUICGRangeIntersectsRange(boundsRange, r)) {
//            if (LUICGVectorGetValue(vector, X)<0) {//手指右划,左侧留出空白
            LUICGRange t = LUICGRangeIntersection(boundsRange, r);
            if (t.end==t.begin) {//相切时，不认为在显示范围中
                if (r.begin<boundsRange.begin) {
                    result = NSOrderedAscending;
                } else {
                    result = NSOrderedDescending;
                }
            } else {
                result = NSOrderedSame;
            }
        } else if (LUICGRangeGetMax(r)<LUICGRangeGetMin(boundsRange)) {
            result = NSOrderedAscending;
        } else {
            result = NSOrderedDescending;
        }
        return result;
    }];
    if (resultRange.location!=NSNotFound) {
        resultRange.location %= cellCount;
    }
    return resultRange;
}

- (void)__resortCellAttributeWithBeginIndex:(NSInteger)beginIndex {
    CGPoint offset = self.collectionView.contentOffset;

    CGSize contentSize = _contentSize;
    
    CGRect bounds = [self visibleRectForOriginBounds:self.collectionView.bounds];
    LUICGAxis X = [self scrollAxis];
    NSArray<NSNumber *> *cellIndexes = [self _cellLayoutAttributesIndexForElements:_cellAttributes inRect:bounds];
    
    NSInteger firstIndex = cellIndexes.firstObject.integerValue;
    UICollectionViewLayoutAttributes *firstCellAttr = _cellAttributes[firstIndex];
    CGRect firstFrame = firstCellAttr.l_frameSafety;
    
    CGPoint newOffset = offset;
    NSMutableArray<UICollectionViewLayoutAttributes *> *newCellAttrs = [[NSMutableArray alloc] initWithCapacity:_cellAttributes.count];
    
    CGRect beginFrame = _cellAttributes[beginIndex].l_frameSafety;
    CGFloat deltaX = -LUICGRectGetMin(beginFrame, X);
    CGFloat deltaX2 = LUICGSizeGetLength(contentSize, X)-LUICGRectGetMin(beginFrame, X);
    
    CGRect firstFrame2 = firstFrame;
    if (beginIndex<=firstIndex) {
        LUICGRectSetMin(&firstFrame2, X, LUICGRectGetMin(firstFrame2, X)+deltaX);
    } else {
        LUICGRectSetMin(&firstFrame2, X, LUICGRectGetMin(firstFrame2, X)+deltaX2);
    }
    CGFloat deltaX3 = LUICGRectGetMin(firstFrame2, X)-LUICGRectGetMin(firstFrame, X);
    LUICGPointSetValue(&newOffset, X, LUICGPointGetValue(offset, X)+deltaX3);
    
    LUICGPointSetValue(&newOffset, X, LUICGPointGetValue(offset, X)+deltaX3);
    
    for (NSInteger i=beginIndex; i<_cellAttributes.count; i++)  {
        UICollectionViewLayoutAttributes *c = _cellAttributes[i];
        CGRect f1 = c.l_frameSafety;
        LUICGRectSetMin(&f1, X, LUICGRectGetMin(f1, X)+deltaX);
        c.l_frameSafety = f1;
        [newCellAttrs addObject:c];
    }
    for (NSInteger i=0; i<beginIndex; i++)  {
        UICollectionViewLayoutAttributes *c = _cellAttributes[i];
        CGRect f1 = c.l_frameSafety;
        LUICGRectSetMin(&f1, X, LUICGRectGetMin(f1, X)+deltaX2);
        c.l_frameSafety = f1;
        [newCellAttrs addObject:c];
    }
    [_cellAttributes removeAllObjects];
    [_cellAttributes addObjectsFromArray:newCellAttrs];
    for (UICollectionViewLayoutAttributes *cellAttr in _cellAttributes)  {
        self.cellAttributeMap[cellAttr.indexPath] = cellAttr;
    }
    
    [_cycleCellAttributes removeAllObjects];
    [_cycleCellAttributes addObjectsFromArray:[self __genCycleCellAttributesWithCellAttributes:_cellAttributes contentSize:contentSize]];
    
    //调整contentInsets
    UIEdgeInsets contentInsets = [self __calContentInsetsWithCellAttributes:_cellAttributes contentSize:contentSize];
    self.collectionView.contentInset = contentInsets;
    
    self.collectionView.contentOffset = newOffset;
//    NSLog(@"newOffset:%@,beginIndex:%@",NSStringFromCGPoint(newOffset),@(beginIndex));
    _preContentOffset = self.collectionView.contentOffset;

}
- (UIEdgeInsets)__calContentInsetsWithCellAttributes:(NSArray<UICollectionViewLayoutAttributes *> *)cellAttributes contentSize:(CGSize)contentSize {
    LUICGAxis X = [self scrollAxis];
    CGRect bounds = [self visibleRectForOriginBounds:self.collectionView.bounds];
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    if (self.pagingEnabled) {
        UICollectionViewLayoutAttributes *firstCell = [self firstVisibleCellAttributeIn:cellAttributes];
        if (firstCell) {
            CGFloat firstPagingOffset = [self pagingOffsetForCellFrame:firstCell.l_frameSafety];
            CGFloat minOffset = 0;
            if (firstPagingOffset<minOffset) {
                LUIEdgeInsetsSetEdge(&contentInsets, X, LUIEdgeInsetsMin, minOffset-firstPagingOffset);
            }
        }
        
        UICollectionViewLayoutAttributes *lastCell = [self lastVisibleCellAttributeIn:cellAttributes];
        if (lastCell) {
            CGFloat lastPagingOffset = [self pagingOffsetForCellFrame:lastCell.l_frameSafety];
            
            CGFloat maxOffset = LUICGSizeGetLength(contentSize, X)-LUICGRectGetLength(bounds, X);
            if (lastPagingOffset>maxOffset) {
                LUIEdgeInsetsSetEdge(&contentInsets, X, LUIEdgeInsetsMax, lastPagingOffset-maxOffset);
            }
        }
    }
    return contentInsets;
}
- (void)__setContentViewContentOffset:(CGPoint)contentOffset animated:(BOOL)animated {
    if (CGPointEqualToPoint(contentOffset, self.collectionView.contentOffset)) {
        return;
    }
    //如果collectionView处于可视状态时，修改contentOffset，会触发shouldInvalidateLayoutForBoundsChange方法。在后台，则不会，只是做一个标记而已，不会触发shouldInvalidateLayoutForBoundsChange，也不会调用prepareLayout方法。
    self.offsetChanging = YES;
    [self.collectionView setContentOffset:contentOffset animated:animated];
    _preContentOffset = self.collectionView.contentOffset;
}
- (void)_prepareForCycleScroll:(BOOL)isOffsetChanging preffedCellIndexpathAtPaging:(NSIndexPath *)preffedCellIndexpathAtPaging {
    if (_cellAttributes.count==0) {
        return;
    }
    CGRect bounds =  self.collectionView.bounds;
    LUICGAxis X = [self scrollAxis];
    
    if (preffedCellIndexpathAtPaging) {
        CGFloat pagingOffset = [self pagingOffsetForCellIndexPath:preffedCellIndexpathAtPaging];
        LUICGRectSetMin(&bounds, X, pagingOffset);
        self.collectionView.contentOffset = bounds.origin;
    }
    
//    NSLog(@"offset:%@",NSStringFromCGPoint(self.collectionView.contentOffset));
    CGPoint preOffset = _preContentOffset;
    CGPoint offset = self.collectionView.contentOffset;
    CGVector vector = CGVectorMake(offset.x-preOffset.x, offset.y-preOffset.y);//防止元素个数刚好允许循环滚动时，左右来回移动元素
    CGSize contentSize = _contentSize;
    
    NSInteger beginIndex = -1;
    
    CGRect bounds2 = bounds;
    //如果在刷新时，当前显示中的cell，没有与paging位置对齐，可能在后续的paging调整中，超出contentOffset的范围，从而导致paging失败。这里需要手动判断可能的paging失效，然后进行重排
    BOOL needResetOffset = NO;
    if (!isOffsetChanging && self.pagingEnabled) {
        bounds2.origin = offset;
        CGFloat position = [self positionOfPagingForRect:bounds2];
        
        NSInteger nearIndex = [self _cellIndexForCellNearToOffset:position scrollVelocity:CGPointMake(vector.dx, vector.dy)];
        if (nearIndex!=NSNotFound) {
            UICollectionViewLayoutAttributes *c = _cellAttributes[nearIndex];
            CGFloat pagingOffset = [self pagingOffsetForCellIndexPath:c.indexPath];
            CGFloat minOffset = [self minContentoffset];
            CGFloat maxOffset = [self maxContentoffset];
            if (pagingOffset<minOffset) {
                LUICGVectorSetValue(&vector, X, -1);
                needResetOffset = YES;
            } else if (pagingOffset>maxOffset) {
                LUICGVectorSetValue(&vector, X, 1);
                needResetOffset = YES;
            }
        }
    }
    
    NSRange cellRange = [self __rangeForCycleScrollWithBounds:bounds2 cellCount:_cellAttributes.count cycleCellAttributes:_cycleCellAttributes contentSize:contentSize scrollVector:vector];
    if (cellRange.location==NSNotFound || cellRange.length==0) {
        return;
    }
    
    if (NSMaxRange(cellRange)>_cellAttributes.count) {
        beginIndex = cellRange.location;
    } else {
        if (LUICGVectorGetValue(vector, X)<0) {//手指右划,左侧留出空白
            if (cellRange.location==0 && cellRange.length<_cellAttributes.count) {
                beginIndex = MIN(NSMaxRange(cellRange),_cellAttributes.count-1);
            }
        }
    }
    if (beginIndex>0) {
//        NSLog(@"beginIndex:%@,%@,%@",@(beginIndex),NSStringFromRange(cellRange),NSStringFromCGVector(vector));
        [self __resortCellAttributeWithBeginIndex:beginIndex];
        if (needResetOffset) {
            CGPoint offset = [self targetContentOffsetForProposedContentOffset:self.collectionView.contentOffset withScrollingVelocity:CGPointMake(vector.dx, vector.dy)];
            self.collectionView.contentOffset = offset;
        }
    }
}
- (nullable NSArray<NSNumber *> *)_cellLayoutAttributesIndexForElements:(NSArray<UICollectionViewLayoutAttributes *> *)cellAttributes inRect:(CGRect)rect {
    NSMutableArray<NSNumber *> *indexes = [[NSMutableArray alloc] init];
    //二分查找
    LUICGAxis X = [self scrollAxis];
    NSRange range = [cellAttributes l_rangeOfSortedObjectsWithComparator:^NSComparisonResult(UICollectionViewLayoutAttributes *arrayObj, NSInteger idx)  {
        CGRect frame = arrayObj.l_frameSafety;
        if (CGRectIntersectsRect(rect, frame)) {
            return NSOrderedSame;
        } else if (LUICGRectGetMin(frame, X)<LUICGRectGetMin(rect, X)) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
    }];
    for (NSUInteger i=0; i<range.length; i++)  {
        [indexes addObject:@(i+range.location)];
    }
    return indexes;
}
//
//// UICollectionView calls these four methods to determine the layout information.
//// Implement -layoutAttributesForElementsInRect: to return layout attributes for for supplementary or decoration views, or to perform layout in an as-needed-on-screen fashion.
//// Additionally, all layout subclasses should implement -layoutAttributesForItemAtIndexPath: to return layout attributes instances on demand for specific index paths.
//// If the layout supports any supplementary or decoration view types, it should also implement the respective atIndexPath: methods for those types.
- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray<UICollectionViewLayoutAttributes *> *attrs = [[NSMutableArray alloc] init];
    NSArray<NSNumber *> *indexes = [self _cellLayoutAttributesIndexForElements:_cellAttributes inRect:rect];
    for (NSNumber *num in indexes)  {
        [attrs addObject:_cellAttributes[num.integerValue]];
    }
    return attrs;
} // return an array layout attributes instances for all the views in the given rect
- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attr = self.cellAttributeMap[indexPath];
    return attr;
}
//- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath;
//- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString*)elementKind atIndexPath:(NSIndexPath *)indexPath;
//
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    if (_isSizeFitting) return NO;
    CGRect bounds = self.collectionView.bounds;
    CGSize contentSize = self.collectionView.contentSize;
    BOOL originChange = !CGPointEqualToPoint(bounds.origin, newBounds.origin);
    BOOL sizeChange = !CGSizeEqualToSize(bounds.size, newBounds.size);
    if (!originChange&&!sizeChange) return NO;
    
    if (sizeChange) {//尺寸变更了
        BOOL emptySize = CGSizeEqualToSize(bounds.size, CGSizeZero);
        if (!emptySize) {//同时旧尺寸非0时，需要计算旧尺寸下的paging位置，设置为新尺寸时，需要恢复到该位置
            NSIndexPath *indexPathAtPagingCell = self.indexPathAtPagingCell;
            if (!indexPathAtPagingCell) {
                CGFloat position = [self positionOfPagingForRect:bounds];
                NSRange range = [self pagableCellIndexRangeNearToOffset:position];
                if (range.location!=NSNotFound) {
                    for (NSUInteger i=0; i<range.length; i++)  {
                        NSInteger index = i+range.location;
                        UICollectionViewLayoutAttributes *c = _cellAttributes[index];
                        if ([self isCellAttributesVisible:c]) {
                            indexPathAtPagingCell = c.indexPath;
                            break;
                        }
                    }
                }
            }
            _l_indexPathAtPagingCellBeforeBoundsChange = indexPathAtPagingCell;
        }
        return YES;
    }
    
    if (originChange) {//仅发生位置变更，尺寸不变化
        BOOL emptyContentSize = CGSizeEqualToSize(contentSize, CGSizeZero);
        BOOL offsetNeedChanging = self.highlightPagingCell||(self.enableCycleScroll && _shouldCycleScroll);
        if (!emptyContentSize && offsetNeedChanging) {
            self.offsetChanging = YES;
            return YES;
        }
    }
    return NO;
} // return YES to cause the collection view to requery the layout for geometry information
//- (UICollectionViewLayoutInvalidationContext *)invalidationContextForBoundsChange:(CGRect)newBounds API_AVAILABLE(ios(7.0));
//
//- (BOOL)shouldInvalidateLayoutForPreferredLayoutAttributes:(UICollectionViewLayoutAttributes *)preferredAttributes withOriginalAttributes:(UICollectionViewLayoutAttributes *)originalAttributes API_AVAILABLE(ios(8.0));
//- (UICollectionViewLayoutInvalidationContext *)invalidationContextForPreferredLayoutAttributes:(UICollectionViewLayoutAttributes *)preferredAttributes withOriginalAttributes:(UICollectionViewLayoutAttributes *)originalAttributes API_AVAILABLE(ios(8.0));
//

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    CGPoint targetOffset = proposedContentOffset;
    if (!self.pagingEnabled) {
        return targetOffset;
    }
    LUICGAxis X = [self scrollAxis];
    
    if (_l_indexPathAtPagingCellBeforeBoundsChange) {
        CGFloat pagingOffset = [self pagingOffsetForCellIndexPath:_l_indexPathAtPagingCellBeforeBoundsChange];
        LUICGPointSetValue(&targetOffset, X, pagingOffset);
        _l_indexPathAtPagingCellBeforeBoundsChange = nil;
        return targetOffset;
    }
    
    CGRect bounds =  self.collectionView.bounds;
    CGPoint offset = proposedContentOffset;//快速滚动多项
    bounds.origin = offset;
    CGFloat position = [self positionOfPagingForRect:bounds];
    
    NSInteger nearIndex = [self _cellIndexForCellNearToOffset:position scrollVelocity:velocity];
    if (nearIndex!=NSNotFound) {
        UICollectionViewLayoutAttributes *c = _cellAttributes[nearIndex];
        CGFloat pagingOffset = [self pagingOffsetForCellIndexPath:c.indexPath];
        LUICGPointSetValue(&targetOffset, X, pagingOffset);
    }
//    NSLog(@"offset:%@,targetOffset:%@,proposedContentOffset:%@,velocity:%@,decelerationRate:%@",NSStringFromCGPoint(self.collectionView.contentOffset),NSStringFromCGPoint(targetOffset),NSStringFromCGPoint(proposedContentOffset),NSStringFromCGPoint(velocity),@(self.collectionView.decelerationRate));
    return targetOffset;
    
} // return a point at which to rest after scrolling - for layouts that want snap-to-point scrolling behavior
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset API_AVAILABLE(ios(7.0)) {
    return [self targetContentOffsetForProposedContentOffset:proposedContentOffset withScrollingVelocity:CGPointZero];
} // a layout can return the content offset to be applied during transition or update animations
//
//@property (nonatomic,  readonly) CGSize collectionViewContentSize; // Subclasses must override this method and use it to return the width and height of the collection view’s content. These values represent the width and height of all the content, not just the content that is currently visible. The collection view uses this information to configure its own content size to facilitate scrolling.
- (CGSize)collectionViewContentSize {
    CGSize size = _contentSize;
    return size;
}
//
- (UIUserInterfaceLayoutDirection)developmentLayoutDirection {
    return UIUserInterfaceLayoutDirectionLeftToRight;
} // Default implementation returns the layout direction of the main bundle's development region; FlowLayout returns leftToRight. Subclasses may override this to specify the implementation-time layout direction of the layout.
//@property (nonatomic,  readonly) BOOL flipsHorizontallyInOppositeLayoutDirection; // Base implementation returns false. If your subclass’s implementation overrides this property to return true, a UICollectionView showing this layout will ensure its bounds.origin is always found at the leading edge, flipping its coordinate system horizontally if necessary.
//
@end

@implementation LUICollectionViewPageFlowLayout (UIUpdateSupportHooks)
//
//// This method is called when there is an update with deletes/inserts to the collection view.
//// It will be called prior to calling the initial/final layout attribute methods below to give the layout an opportunity to do batch computations for the insertion and deletion layout attributes.
//// The updateItems parameter is an array of UICollectionViewUpdateItem instances for each element that is moving to a new index path.
//- (void)prepareForCollectionViewUpdates:(NSArray<UICollectionViewUpdateItem *> *)updateItems;
//- (void)finalizeCollectionViewUpdates; // called inside an animation block after the update
//
//- (void)prepareForAnimatedBoundsChange:(CGRect)oldBounds; // UICollectionView calls this when its bounds have changed inside an animation block before displaying cells in its new bounds
//- (void)finalizeAnimatedBoundsChange; // also called inside the animation block
//
//// UICollectionView calls this when prior the layout transition animation on the incoming and outgoing layout
//- (void)prepareForTransitionToLayout:(UICollectionViewLayout *)newLayout API_AVAILABLE(ios(7.0));
//- (void)prepareForTransitionFromLayout:(UICollectionViewLayout *)oldLayout API_AVAILABLE(ios(7.0));
//- (void)finalizeLayoutTransition API_AVAILABLE(ios(7.0));  // called inside an animation block after the transition
//
//
//// This set of methods is called when the collection view undergoes an animated transition such as a batch update block or an animated bounds change.
//// For each element on screen before the invalidation, finalLayoutAttributesForDisappearingXXX will be called and an animation setup from what is on screen to those final attributes.
//// For each element on screen after the invalidation, initialLayoutAttributesForAppearingXXX will be called and an animation setup from those initial attributes to what ends up on screen.
//- (nullable UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath;
//- (nullable UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath;
//- (nullable UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)elementIndexPath;
//- (nullable UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)elementIndexPath;
//- (nullable UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingDecorationElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)decorationIndexPath;
//- (nullable UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingDecorationElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)decorationIndexPath;
//
//// These methods are called by collection view during an update block.
//// Return an array of index paths to indicate views that the layout is deleting or inserting in response to the update.
//- (NSArray<NSIndexPath *> *)indexPathsToDeleteForSupplementaryViewOfKind:(NSString *)elementKind API_AVAILABLE(ios(7.0));
//- (NSArray<NSIndexPath *> *)indexPathsToDeleteForDecorationViewOfKind:(NSString *)elementKind API_AVAILABLE(ios(7.0));
//- (NSArray<NSIndexPath *> *)indexPathsToInsertForSupplementaryViewOfKind:(NSString *)elementKind API_AVAILABLE(ios(7.0));
//- (NSArray<NSIndexPath *> *)indexPathsToInsertForDecorationViewOfKind:(NSString *)elementKind API_AVAILABLE(ios(7.0));

@end

@implementation LUICollectionViewPageFlowLayout (UIReorderingSupportHooks)

//- (NSIndexPath *)targetIndexPathForInteractivelyMovingItem:(NSIndexPath *)previousIndexPath withPosition:(CGPoint)position API_AVAILABLE(ios(9.0));
//- (UICollectionViewLayoutAttributes *)layoutAttributesForInteractivelyMovingItemAtIndexPath:(NSIndexPath *)indexPath withTargetPosition:(CGPoint)position API_AVAILABLE(ios(9.0));
//
//- (UICollectionViewLayoutInvalidationContext *)invalidationContextForInteractivelyMovingItems:(NSArray<NSIndexPath *> *)targetIndexPaths withTargetPosition:(CGPoint)targetPosition previousIndexPaths:(NSArray<NSIndexPath *> *)previousIndexPaths previousPosition:(CGPoint)previousPosition API_AVAILABLE(ios(9.0));
//- (UICollectionViewLayoutInvalidationContext *)invalidationContextForEndingInteractiveMovementOfItemsToFinalIndexPaths:(NSArray<NSIndexPath *> *)indexPaths previousIndexPaths:(NSArray<NSIndexPath *> *)previousIndexPaths movementCancelled:(BOOL)movementCancelled API_AVAILABLE(ios(9.0));

@end

@implementation LUICollectionViewPageFlowLayout(SizeFits)
/// 指定collectionview的最大尺寸，返回collectionview最合适的尺寸值
/// @param size 外层最大尺寸
- (CGSize)l_sizeThatFits:(CGSize)size {
    CGSize sizeFits = CGSizeZero;
    CGRect originBounds = self.collectionView.bounds;
    CGRect bounds = self.collectionView.bounds;
    LUICGAxis X = [self scrollAxis];
    LUICGAxis Y = LUICGAxisReverse(X);
    _isSizeFitting = YES;
    BOOL sizeChange = !CGSizeEqualToSize(originBounds.size, size);
    if (sizeChange) {
        bounds.size = size;
        self.collectionView.bounds = bounds;
    }
    NSMutableArray<UICollectionViewLayoutAttributes *> *cellAttributes = [[NSMutableArray alloc] init];
    NSMutableArray<UICollectionViewLayoutAttributes *> *cycleCellAttributes = [[NSMutableArray alloc] init];
    NSMutableArray<_LUICollectionViewPageFlowSectionModel *> *sectionModels = [[NSMutableArray alloc] init];
    CGSize contentSize = [self _prepareCellLayouts:cellAttributes cellAttributeMap:nil cycleCellAttributes:cycleCellAttributes sectionModels:sectionModels shouldCycleScroll:NULL isSizeFit:YES];
    CGFloat maxHeight = 0;
    for (UICollectionViewLayoutAttributes *cellAttr in cellAttributes)  {
        CGRect frame = cellAttr.l_frameSafety;
        UIEdgeInsets sectionInsets = sectionModels[cellAttr.indexPath.section].sectionInsets;
        if ([self isCellAttributesVisible:cellAttr]) {
            CGFloat height = LUICGRectGetLength(frame, Y)+LUIEdgeInsetsGetEdgeSum(sectionInsets, Y);
            maxHeight = MAX(maxHeight,height);
        }
    }
    LUICGSizeSetLength(&contentSize, Y, maxHeight);
    if (sizeChange) {
        self.collectionView.bounds = originBounds;
    }
    sizeFits = contentSize;
    //消除浮点误差
    sizeFits.width = ceil(sizeFits.width);
    sizeFits.height = ceil(sizeFits.height);
    _isSizeFitting = NO;
    return sizeFits;
}
@end

@implementation UICollectionView(LUICollectionViewPageFlowLayout)
- (nullable LUICollectionViewPageFlowLayout *)l_collectionViewPageFlowLayout {
    if ([self.collectionViewLayout isKindOfClass:[LUICollectionViewPageFlowLayout class]]) {
        return (LUICollectionViewPageFlowLayout *)self.collectionViewLayout;
    }
    return nil;
}
@end

@implementation LUICollectionViewPagePickerFlowLayout
- (id)init {
    if (self = [super init])  {
        self.pagingEnabled = YES;
        self.highlightPagingCell = YES;
        self.playPagingSound = YES;
        self.pagingBoundsPosition = 0.5;
        self.pagingCellPosition = 0.5;
        self.scaleRange = LUICGRangeMake(1, 0.75);
        self.alphaRange = LUICGRangeMake(1, 0.75);
        self.m34 = -1.0/800;
    }
    return self;
}
- (CGFloat)pickerRoundRadius {
    CGFloat radius = self.roundRadius;
    if (radius<=0) {
        CGRect bounds = self.collectionView.bounds;
        LUICGAxis X = [self scrollAxis];
        radius = LUICGRectGetLength(bounds, X)*MAX(self.pagingBoundsPositionForCollectionView,1-self.pagingBoundsPosition);
    }
    return radius;
}
- (CGRect)visibleRectForOriginBounds:(CGRect)bounds {
    LUICGAxis X = [self scrollAxis];
    CGFloat radius = [self pickerRoundRadius];
    CGFloat width = M_PI*radius;
    CGFloat position = [self positionOfPagingForRect:bounds];
    
    LUICGRectSetLength(&bounds, X, width);
    LUICGRectSetMin(&bounds, X, position-LUICGRectGetLength(bounds, X)*self.pagingBoundsPositionForCollectionView);
    
    return bounds;
}
- (void)highlightPagingCellAttributes:(UICollectionViewLayoutAttributes *)cellAttr {
    CGFloat radius = [self pickerRoundRadius];
    LUICGAxis X = [self scrollAxis];
    LUICGAxis Y = LUICGAxisReverse(X);
    CGRect frame = cellAttr.l_frameSafety;
    CGFloat dx = LUICGRectGetLength(frame, X)*(self.pagingCellPosition-0.5);
    
    CGFloat dis = [self distanceToPagingPositionForCellLayoutAttributes:cellAttr];
    CGFloat progress = ABS(dis)/(radius*M_PI_4);
    CGFloat angle = dis/radius;
    CGFloat z = radius*cos(angle);
    CGFloat rotate = angle;
    CGFloat t_x = radius*sin(angle)-dis;
    CGFloat scale = 1;
    
    if (ABS(angle)>M_PI_2) {
        scale = 0;
        t_x = radius*sin(M_PI_4*(angle>0?1:-1))-dis;
        rotate = M_PI_4*(angle>0?1:-1);
    } else {
        scale = LUICGRangeInterpolate(self.scaleRange, ABS(progress));
    }
    scale = MAX(scale,0);
    
    CATransform3D t1 = CATransform3DIdentity;
    t1 = CATransform3DConcat(t1, LUICATransform3DMakeTranslation(X, -dx));//将变换中心从0.5，变为pagingCellPosition
    t1 = CATransform3DConcat(t1,CATransform3DMakeScale(scale, scale, 1));//scale
    t1 = CATransform3DConcat(t1,LUICATransform3DMakeRotation(Y, rotate));//rotate
    t1 = CATransform3DConcat(t1, LUICATransform3DMakeTranslation(X, dx));//恢复变换中心为0.5
    t1 = CATransform3DConcat(t1,LUICATransform3DMakeTranslation(X, t_x));//平移
    t1 = CATransform3DConcat(t1,CATransform3DMakeTranslation(0, 0, z));//zIndex
    
    LUICGRectAlignment itemAlignment = self.itemAlignment;
    if (itemAlignment!=LUICGRectAlignmentMid) {
        CATransform3D t2 = CATransform3DIdentity;
        t2 = CATransform3DConcat(t2, LUICATransform3DMakeTranslation(X, -dx));//将变换中心从0.5，变为pagingCellPosition
        t2 = CATransform3DConcat(t2,CATransform3DMakeScale(scale, scale, 1));//scale
        t2 = CATransform3DConcat(t2, LUICATransform3DMakeTranslation(X, dx));//恢复变换中心为0.5
        
        CGAffineTransform m2 = CATransform3DGetAffineTransform(t2);
        
        CGAffineTransform m = CGAffineTransformIdentity;
        m = CGAffineTransformConcat(m, CGAffineTransformMakeTranslation(-CGRectGetMidX(frame), -CGRectGetMidY(frame)));//将变换中心移至frame的中心点
        m = CGAffineTransformConcat(m, m2);
        m = CGAffineTransformConcat(m, CGAffineTransformMakeTranslation(CGRectGetMidX(frame), CGRectGetMidY(frame)));
        
        CGRect f1 = CGRectApplyAffineTransform(frame, m);//CGRectApplyAffineTransform是以rect的(0,0)为变换原点。而celAttr.transform3D是以frame中心点为变换原点。
        
        CGRect f2 = f1;
        LUICGRectAlignToRect(&f2, Y, itemAlignment, frame);

        CGFloat t_y = LUICGRectGetMin(f2, Y)-LUICGRectGetMin(f1, Y);
        t1 = CATransform3DConcat(t1,LUICATransform3DMakeTranslation(Y, t_y));//平移至对齐
    }
    
    t1.m34 = self.m34;
    cellAttr.zIndex = 0;//zIndex要归零
    cellAttr.transform3D = t1;
    
    CGFloat alpha = LUICGRangeInterpolate(self.alphaRange, ABS(progress));
    cellAttr.alpha = alpha;
}
@end
