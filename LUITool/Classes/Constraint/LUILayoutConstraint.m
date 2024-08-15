//
//  LUILayoutConstraint.m
//  LUITool
//
//  Created by 六月 on 2023/8/14.
//

#import "LUILayoutConstraint.h"
#import "LUILayoutConstraintItemWrapper.h"

LUIDEF_EnumTypeCategories(LUILayoutConstraintVerticalAlignment,
(@{
   @(LUILayoutConstraintVerticalAlignmentCenter):@"Center",
   @(LUILayoutConstraintVerticalAlignmentTop):@"Top",
   @(LUILayoutConstraintVerticalAlignmentBottom):@"Bottom",
}))
LUIDEF_EnumTypeCategories(LUILayoutConstraintHorizontalAlignment,
(@{
   @(LUILayoutConstraintHorizontalAlignmentCenter):@"Center",
   @(LUILayoutConstraintHorizontalAlignmentLeft):@"Left",
   @(LUILayoutConstraintHorizontalAlignmentRight):@"Right",
}))
LUIDEF_EnumTypeCategories(LUILayoutConstraintDirection,
(@{
   @(LUILayoutConstraintDirectionVertical):@"Vertical",
   @(LUILayoutConstraintDirectionHorizontal):@"Horizontal",
}))

@implementation LUILayoutConstraint
- (id)copyWithZone:(NSZone *)zone {
    LUILayoutConstraint *obj = [[self.class alloc] init];
    obj.hidden = self.hidden;
    obj->_items = [_items copy];
    obj.bounds = self.bounds;
    obj.layoutHiddenItem = self.layoutHiddenItem;
    return obj;
}
- (id)init {
    if (self = [super init]) {
        _items = [[NSMutableArray alloc] init];
    }
    return self;
}
- (id)initWithItems:(NSArray *)items bounds:(CGRect)bounds {
    if (self = [self init]) {
        self.items = items;
        self.bounds = bounds;
    }
    return self;
}
- (void)setItems:(NSArray *)items {
    [_items removeAllObjects];
    [_items addObjectsFromArray:items];
}
- (CGSize)sizeThatFits:(CGSize)size {
    if (self.hidden) {
        return CGSizeZero;
    }
    return size;
}
- (NSArray *)items {
    return [_items copy];
}
- (NSArray *)visiableItems {
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (id<LUILayoutConstraintItemProtocol> item in _items) {
        if (![item hidden]) {
            [items addObject:item];
        }
    }
    return items;
}
- (NSArray *)layoutedItems {
    if (self.layoutHiddenItem) {
        return _items;
    } else {
        return self.visiableItems;
    }
}
- (void)addItem:(id<LUILayoutConstraintItemProtocol>)item {
    if (item&&![_items containsObject:item]) {
        [_items addObject:item];
    }
}
- (void)removeItem:(id<LUILayoutConstraintItemProtocol>)item {
    if (item) {
        [_items removeObject:item];
    }
}
- (void)replaceItem:(id<LUILayoutConstraintItemProtocol>)oldItem with:(id<LUILayoutConstraintItemProtocol>)newItem {
    NSUInteger index = [_items indexOfObjectPassingTest:^BOOL(id<LUILayoutConstraintItemProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj == oldItem) {
            return YES;
        }
        if ([obj isKindOfClass:[LUILayoutConstraintItemWrapper class]]) {
            LUILayoutConstraintItemWrapper *w = (LUILayoutConstraintItemWrapper *)obj;
            if (w.originItem == oldItem) {
                return YES;
            }
        }
        return NO;
    }];
    if (index != NSNotFound) {
        [_items replaceObjectAtIndex:index withObject:newItem];
    }
}
- (void)layoutItems {
}
#pragma mark - delegate:LUILayoutConstraintItemProtocol
- (void)setLayoutFrame:(CGRect)frame {
    self.bounds = frame;
    [self layoutItems];
}
- (CGRect)layoutFrame {
    return self.bounds;
}
- (CGSize)sizeOfLayout {
    CGSize size = self.bounds.size;
    return size;
}
- (void)setLayoutTransform:(CGAffineTransform)transform {
    CGRect bounds = self.bounds;
    CGPoint c1 = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    for (id<LUILayoutConstraintItemProtocol> item in self.items) {
        CGRect f = [item layoutFrame];
        CGPoint c = CGPointMake(CGRectGetMidX(f), CGRectGetMidY(f));
        CGAffineTransform m = CGAffineTransformIdentity;
        m = CGAffineTransformConcat(m,CGAffineTransformMakeTranslation(c.x-c1.x,c.y-c1.y));
        m = CGAffineTransformConcat(m,transform);
        m = CGAffineTransformConcat(m,CGAffineTransformMakeTranslation(-(c.x-c1.x),-(c.y-c1.y)));
        [item setLayoutTransform:m];
    }
}
- (CGAffineTransform)convertTransfromWith:(CGAffineTransform)transform toItem:(id<LUILayoutConstraintItemProtocol>)item {
    CGRect bounds = self.bounds;
    CGPoint c1 = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    CGRect f = [item layoutFrame];
    CGPoint c = CGPointMake(CGRectGetMidX(f), CGRectGetMidY(f));
    CGAffineTransform m = CGAffineTransformIdentity;
    m = CGAffineTransformConcat(m,CGAffineTransformMakeTranslation(c.x-c1.x,c.y-c1.y));
    m = CGAffineTransformConcat(m,transform);
    m = CGAffineTransformConcat(m,CGAffineTransformMakeTranslation(-(c.x-c1.x),-(c.y-c1.y)));
    return m;
}
@end

@implementation UIView(LUILayoutConstraintItemProtocol)
- (void)setLayoutFrame:(CGRect)frame {
    if (CGAffineTransformIsIdentity(self.transform)) {
        self.frame = frame;
    } else {
        CGRect bounds = self.bounds;
        bounds.size = frame.size;
        self.bounds = bounds;
        CGPoint center = frame.origin;
        center.x += frame.size.width/2;
        center.y += frame.size.height/2;
        self.center = center;
    }
}
- (CGRect)layoutFrame {
    CGRect frame = self.bounds;
    CGPoint center = self.center;
    frame.origin.x = center.x-frame.size.width/2;
    frame.origin.y = center.y-frame.size.height/2;
    return frame;
}
- (CGSize)sizeOfLayout {
    CGSize size = self.bounds.size;
    return size;
}
- (BOOL)hidden {
    return self.isHidden;
}
- (void)setLayoutTransform:(CGAffineTransform)transform {
    self.transform = transform;
}
@end

@implementation UICollectionViewLayoutAttributes (LUILayoutConstraintItemProtocol)
- (void)setLayoutFrame:(CGRect)frame {
    if (!CGAffineTransformIsIdentity(self.transform)  ||  !CATransform3DIsIdentity(self.transform3D)) {
        self.size = frame.size;
        self.center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
    } else {
        self.frame = frame;
    }
}
- (CGRect)layoutFrame {
    CGRect f = self.frame;
    if (!CGAffineTransformIsIdentity(self.transform)  ||  !CATransform3DIsIdentity(self.transform3D)) {
        f.size = self.size;
        f.origin.x = self.center.x-self.size.width/2;
        f.origin.y = self.center.y-self.size.height/2;
    }
    return f;
}
- (CGSize)sizeOfLayout {
    CGSize size = self.bounds.size;
    return size;
}
- (BOOL)hidden {
    return self.isHidden;
}
- (void)setLayoutTransform:(CGAffineTransform)transform {
    self.transform = transform;
}

@end
