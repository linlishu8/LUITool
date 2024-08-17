//
//  LUILayoutConstraintItemAttributeBase.m
//  LUITool
//
//  Created by 六月 on 2023/8/14.
//

#import "LUILayoutConstraintItemAttributeBase.h"
#import "LUILayoutConstraint.h"

@implementation LUILayoutConstraintItemAttributeBase

- (CGSize)size {
    return self.layoutFrame.size;
}
- (void)setSize:(CGSize)size {
    CGRect f = self.layoutFrame;
    f.size = size;
    self.layoutFrame = f;
}
- (CGPoint)origin {
    return self.layoutFrame.origin;
}
- (void)setOrigin:(CGPoint)origin {
    CGRect f = self.layoutFrame;
    f.origin = origin;
    self.layoutFrame = f;
}
@end

@implementation LUILayoutConstraintItemAttribute
- (id)initWithItem:(id<LUILayoutConstraintItemAttributeProtocol>)item {
    if (self = [self init]) {
        self.item = item;
    }
    return self;
}
- (void)applyAttribute {
    self.item.layoutFrame = self.layoutFrame;
}
- (void)applyAttributeWithResizeItems:(BOOL)resizeItems {
    if ([self.item isKindOfClass:[LUILayoutConstraint class]]) {
        LUILayoutConstraint *item = (LUILayoutConstraint *)self.item;
        [item setBounds:self.layoutFrame];
    }else {
        self.item.layoutFrame = self.layoutFrame;
    }
    if ([self.item conformsToProtocol:@protocol(LUILayoutConstraintItemProtocol)]) {
        id<LUILayoutConstraintItemProtocol> item = (id<LUILayoutConstraintItemProtocol>)self.item;
        if ([item respondsToSelector:@selector(layoutItemsWithResizeItems:)]) {
            [item layoutItemsWithResizeItems:resizeItems];
        }
    }
}
@end

@interface LUILayoutConstraintItemAttributeSection() {
    NSMutableArray<id<LUILayoutConstraintItemAttributeProtocol>> *_allItemAttributes;
}
@end

@implementation LUILayoutConstraintItemAttributeSection
- (id)init {
    if (self = [super init]) {
        _allItemAttributes = [[NSMutableArray alloc] init];
    }
    return self;
}
- (void)addItemAttribute:(id<LUILayoutConstraintItemAttributeProtocol>)itemAttribute {
    [_allItemAttributes addObject:itemAttribute];
}
- (void)insertItemAttribute:(id<LUILayoutConstraintItemAttributeProtocol>)itemAttribute atIndex:(NSInteger)index {
    [_allItemAttributes insertObject:itemAttribute atIndex:index];
}
- (void)removeItemAttributeAtIndex:(NSInteger)index {
    [_allItemAttributes removeObjectAtIndex:index];
}
- (void)setItemAttributs:(NSArray<id<LUILayoutConstraintItemAttributeProtocol>> *)itemAttributes {
    [_allItemAttributes removeAllObjects];
    [_allItemAttributes addObjectsFromArray:itemAttributes];
}
- (NSArray<id<LUILayoutConstraintItemAttributeProtocol>> *)itemAttributs {
    return _allItemAttributes;
}
- (CGSize)sizeThatFlowLayoutItemsWithSpacing:(CGFloat)itemSpacing axis:(LUICGAxis)X {
    CGSize size = CGSizeZero;
    CGFloat sumWidth = 0;
    CGFloat maxHeight = 0;
    int count = 0;
    CGFloat w = 0;
    CGFloat h = 0;
    CGRect f = CGRectZero;
    LUICGAxis Y = LUICGAxisReverse(X);
    for (id<LUILayoutConstraintItemAttributeProtocol> attr in _allItemAttributes) {
        f = attr.layoutFrame;
        w = LUICGRectGetLength(f, X);
        h = LUICGRectGetLength(f, Y);
        if (w>0 && h>0) {
            count++;
            sumWidth += w;
            maxHeight = MAX(maxHeight,h);
        }
    }
    if (count>0) {
        sumWidth += itemSpacing*(count-1);
        LUICGSizeSetLength(&size, X, sumWidth);
        LUICGSizeSetLength(&size, Y, maxHeight);
    }
    return size;
}
- (void)flowLayoutItemsWithSpacing:(CGFloat)itemSpacing axis:(LUICGAxis)X alignment:(LUICGRectAlignment)alignY needRevert:(BOOL)needRevert {
    LUICGAxis Y = LUICGAxisReverse(X);
    CGRect bounds = self.layoutFrame;
    CGRect f1 = CGRectZero;
    f1.origin = bounds.origin;
    for (id<LUILayoutConstraintItemAttributeProtocol> item in needRevert?_allItemAttributes.reverseObjectEnumerator:_allItemAttributes) {
        f1.size = item.layoutFrame.size;
        LUICGRectAlignToRect(&f1, Y, alignY, bounds);
        item.layoutFrame = f1;
        if (LUICGRectGetLength(f1, X)>0 && LUICGRectGetLength(f1, Y)>0) {
            LUICGRectSetMin(&f1, X, LUICGRectGetMax(f1, X)+itemSpacing);
        }
    }
}
@end
