//
//  LUIFillingFlowLayoutConstraint.m
//  LUITool
//
//  Created by 六月 on 2023/8/14.
//

#import "LUIFillingFlowLayoutConstraint.h"

@implementation LUIFillingFlowLayoutConstraint

- (id)copyWithZone:(NSZone *)zone {
    LUIFillingFlowLayoutConstraint *obj = [super copyWithZone:zone];
    obj.layoutDirection = self.layoutDirection;
    obj.layoutVerticalAlignment = self.layoutVerticalAlignment;
    obj.layoutHorizontalAlignment = self.layoutHorizontalAlignment;
    obj.contentInsets = self.contentInsets;
    return obj;
}
- (CGSize)sizeThatFits:(CGSize)size resizeItems:(BOOL)resizeItems {
    CGSize sizeFits = CGSizeZero;
    NSArray<id<LUILayoutConstraintItemProtocol>> *items = self.layoutedItems;
    NSInteger count = items.count;
    if (count == 0) return CGSizeZero;
    UIEdgeInsets contentInsets = self.contentInsets;
    CGSize limitSize = CGSizeMake(size.width-contentInsets.left-contentInsets.right, size.height-contentInsets.top-contentInsets.bottom);//限制在 size -contentInsets 矩形内
    CGFloat interitemSpacing = 0;
    
    LUICGAxis axis = self.layoutDirection == LUILayoutConstraintDirectionHorizontal?LUICGAxisX:LUICGAxisY;
    LUICGAxis axisR = LUICGAxisReverse(axis);
    
    CGFloat maxLengthReverseAxis = 0;//元素的最大高度
    NSMutableArray<NSNumber *> *lengths = [[NSMutableArray alloc] initWithCapacity:items.count];
    for (id<LUILayoutConstraintItemProtocol> item in items) {
        CGSize itemSize = CGSizeZero;
        if (resizeItems) {
            if ([item respondsToSelector:@selector(sizeThatFits:resizeItems:)]) {
                itemSize = [item sizeThatFits:limitSize resizeItems:resizeItems];
            } else if ([item respondsToSelector:@selector(sizeThatFits:)]) {
                itemSize = [item sizeThatFits:limitSize];
            } else {
                itemSize = [item sizeOfLayout];
            }
        } else {
            itemSize = [item sizeOfLayout];
        }
        CGFloat l = LUICGSizeGetLength(itemSize,axis);
        if (l>0) {
            [lengths addObject:@(l)];
            maxLengthReverseAxis = MAX(maxLengthReverseAxis,LUICGSizeGetLength(itemSize,axisR));
            
            LUICGSizeSetLength(&itemSize, axis,LUICGSizeGetLength(limitSize, axis)+LUICGSizeGetLength(itemSize,axis)+interitemSpacing);
            LUICGSizeSetLength(&limitSize,axis ,MAX(LUICGSizeGetLength(limitSize, axis),0));
        }
    }
    LUICGSizeSetLength(&sizeFits, axis, LUICGSizeGetLength(size, axis));
    LUICGSizeSetLength(&sizeFits, axisR, maxLengthReverseAxis+LUIEdgeInsetsGetEdge(contentInsets,axisR,LUIEdgeInsetsMin)+LUIEdgeInsetsGetEdge(contentInsets,axisR,LUIEdgeInsetsMax));
    
    return sizeFits;
}
- (CGSize)sizeThatFits:(CGSize)size {
    return [self sizeThatFits:size resizeItems:NO];
}
- (void)layoutItemsWithResizeItems:(BOOL)resizeItems {
    NSArray<id<LUILayoutConstraintItemProtocol>> *items = self.layoutedItems;
    NSInteger count = items.count;
    if (count == 0) return;
    UIEdgeInsets contentInsets = self.contentInsets;
    CGRect bounds = UIEdgeInsetsInsetRect(self.bounds, contentInsets);
    CGSize limitSize = bounds.size;

    LUICGAxis axis = self.layoutDirection == LUILayoutConstraintDirectionHorizontal?LUICGAxisX:LUICGAxisY;
//    LUICGAxis axisR = LUICGAxisReverse(axis);
    LUICGRectAlignment align = self.layoutDirection == LUILayoutConstraintDirectionHorizontal?LUICGRectAlignmentFromLUILayoutConstraintVerticalAlignment(self.layoutVerticalAlignment):LUICGRectAlignmentFromLUILayoutConstraintHorizontalAlignment(self.layoutHorizontalAlignment);
    //分布局头尾元素
    id<LUILayoutConstraintItemProtocol> firstItem = items.firstObject;
    id<LUILayoutConstraintItemProtocol> lastItem = items.count>1?items.lastObject:nil;
    NSArray<id<LUILayoutConstraintItemProtocol>> *middleItems = items.count>2?[items subarrayWithRange:NSMakeRange(1, items.count-2)]:@[];
    CGRect middleItemsBounds = bounds;
    //布局头元素
    if (firstItem) {
        id<LUILayoutConstraintItemProtocol> item = firstItem;
        CGRect itemFrame = bounds;
        CGSize itemSize = CGSizeZero;
        if (resizeItems) {
            if ([item respondsToSelector:@selector(sizeThatFits:resizeItems:)]) {
                itemSize = [item sizeThatFits:limitSize resizeItems:resizeItems];
            } else if ([firstItem respondsToSelector:@selector(sizeThatFits:)]) {
                itemSize = [item sizeThatFits:limitSize];
            } else {
                itemSize = [item sizeOfLayout];
            }
        } else {
            itemSize = [item sizeOfLayout];
        }
        itemFrame.size = itemSize;
        LUICGRectSetMin(&itemFrame,axis,LUICGRectGetMin(bounds,axis));
        LUICGRectSetMin(&middleItemsBounds,axis,LUICGRectGetMax(itemFrame,axis));
        LUICGRectSetLength(&middleItemsBounds,axis,LUICGRectGetMax(bounds,axis)-LUICGRectGetMin(middleItemsBounds, axis));
        LUICGSizeSetLength(&limitSize, axis, LUICGSizeGetLength(limitSize, axis)-LUICGRectGetLength(itemFrame,axis));
        LUICGRectAlignToRect(&itemFrame,LUICGAxisReverse(axis),align,bounds);
        firstItem.layoutFrame = itemFrame;
    }
    //布局尾元素
    if (lastItem) {
        id<LUILayoutConstraintItemProtocol> item = lastItem;
        CGRect itemFrame = bounds;
        CGSize itemSize = CGSizeZero;
        if (resizeItems) {
            if ([item respondsToSelector:@selector(sizeThatFits:resizeItems:)]) {
                itemSize = [item sizeThatFits:limitSize resizeItems:resizeItems];
            } else if ([firstItem respondsToSelector:@selector(sizeThatFits:)]) {
                itemSize = [item sizeThatFits:limitSize];
            } else {
                itemSize = [item sizeOfLayout];
            }
        } else {
            itemSize = [item sizeOfLayout];
        }
        itemFrame.size = itemSize;
        LUICGRectSetMin(&itemFrame, axis, LUICGRectGetMax(bounds, axis)-LUICGRectGetLength(itemFrame,axis));
        LUICGRectSetLength(&middleItemsBounds, axis, LUICGRectGetMin(itemFrame, axis)-LUICGRectGetMin(middleItemsBounds,axis));
        LUICGSizeSetLength(&limitSize, axis, LUICGSizeGetLength(limitSize, axis)-LUICGRectGetLength(itemFrame, axis));
        LUICGRectAlignToRect(&itemFrame, LUICGAxisReverse(axis), align, bounds);
        lastItem.layoutFrame = itemFrame;
    }
    //布局中间元素
    if (middleItems.count) {
        NSMutableArray<NSValue *> *itemSizes = [[NSMutableArray alloc] initWithCapacity:middleItems.count];//每个元素的尺寸
        for (id<LUILayoutConstraintItemProtocol> item in middleItems) {
            CGSize itemSize = CGSizeZero;
            if (resizeItems) {
                if ([item respondsToSelector:@selector(sizeThatFits:resizeItems:)]) {
                    itemSize = [item sizeThatFits:limitSize resizeItems:resizeItems];
                } else if ([firstItem respondsToSelector:@selector(sizeThatFits:)]) {
                    itemSize = [item sizeThatFits:limitSize];
                } else {
                    itemSize = [item sizeOfLayout];
                }
            } else {
                itemSize = [item sizeOfLayout];
            }
            LUICGSizeSetLength(&limitSize, axis, LUICGSizeGetLength(limitSize, axis)-LUICGSizeGetLength(itemSize, axis));
            [itemSizes addObject:[NSValue valueWithCGSize:itemSize]];
        }
        CGFloat space = 0;//每个元素之间的间隔
        CGFloat sum = 0;
        for (NSValue *v in itemSizes) {
            CGSize itemSize = [v CGSizeValue];
            sum += LUICGSizeGetLength(itemSize, axis);
        }
        space = (LUICGRectGetLength(middleItemsBounds, axis)-sum)/(middleItems.count+1);
        CGRect itemFrame = middleItemsBounds;
        for (int i=0; i<middleItems.count; i++) {
            id<LUILayoutConstraintItemProtocol> item = middleItems[i];
            CGSize itemSize = [itemSizes[i] CGSizeValue];
            itemFrame.size = itemSize;
            LUICGRectSetMin(&itemFrame, axis, LUICGRectGetMin(itemFrame, axis)+space);
            LUICGRectAlignToRect(&itemFrame, LUICGAxisReverse(axis), align , bounds);
            item.layoutFrame = itemFrame;
            LUICGRectSetMin(&itemFrame, axis, LUICGRectGetMin(itemFrame, axis)+LUICGRectGetLength(itemFrame, axis));
        }
    }
}
- (void)layoutItems {
    [self layoutItemsWithResizeItems:NO];
}
@end

LUIDEF_EnumTypeCategories(LUIFillingFlowLayoutConstraintParam,
(@ {
   @(LUIFillingFlowLayoutConstraint_H_C):@"H_C",
   @(LUIFillingFlowLayoutConstraint_H_T):@"H_T",
   @(LUIFillingFlowLayoutConstraint_H_B):@"H_B",
   @(LUIFillingFlowLayoutConstraint_V_C):@"V_C",
   @(LUIFillingFlowLayoutConstraint_V_L):@"V_L",
   @(LUIFillingFlowLayoutConstraint_V_R):@"V_R",
   }))
@implementation LUIFillingFlowLayoutConstraint (InitMethod)
//////////////////////////////////////////////////////////////////////////////
+ (NSDictionary<NSNumber *,NSArray<NSNumber *> *> *)ConstraintParamMapOfHorizontal {
    static NSDictionary<NSNumber *,NSArray<NSNumber *> *> * __share__;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        NSMutableDictionary<NSNumber *,NSArray<NSNumber *> *> *map = [[NSMutableDictionary alloc] init];
        map[@(LUIFillingFlowLayoutConstraint_H_C)] = @[
          @(LUILayoutConstraintDirectionHorizontal),
          @(LUILayoutConstraintVerticalAlignmentCenter),
          ];
        map[@(LUIFillingFlowLayoutConstraint_H_T)] = @[
          @(LUILayoutConstraintDirectionHorizontal),
          @(LUILayoutConstraintVerticalAlignmentTop),
          ];
        map[@(LUIFillingFlowLayoutConstraint_H_B)] = @[
          @(LUILayoutConstraintDirectionHorizontal),
          @(LUILayoutConstraintVerticalAlignmentBottom),
          ];
        __share__ = map;
    });
    return __share__;
}
+ (NSDictionary<NSNumber *,NSArray<NSNumber *> *> *)ConstraintParamMapOfVertical {
    static NSDictionary<NSNumber *,NSArray<NSNumber *> *> * __share__;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        NSMutableDictionary<NSNumber *,NSArray<NSNumber *> *> *map = [[NSMutableDictionary alloc] init];
        map[@(LUIFillingFlowLayoutConstraint_V_C)] = @[
          @(LUILayoutConstraintDirectionVertical),
          @(LUILayoutConstraintHorizontalAlignmentCenter),
          ];
        map[@(LUIFillingFlowLayoutConstraint_V_L)] = @[
          @(LUILayoutConstraintDirectionVertical),
          @(LUILayoutConstraintHorizontalAlignmentLeft),
          ];
        map[@(LUIFillingFlowLayoutConstraint_V_R)] = @[
          @(LUILayoutConstraintDirectionVertical),
          @(LUILayoutConstraintHorizontalAlignmentRight),
          ];
        __share__ = map;
    });
    return __share__;
}
+ (NSDictionary<NSArray<NSNumber *> *,NSNumber *> *)ConstraintParamRevertMapOfHorizontal {
    static NSDictionary<NSArray<NSNumber *> *,NSNumber *> * __share__;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        NSDictionary<NSNumber *,NSArray<NSNumber *> *> *ConstraintParamMap = [self ConstraintParamMapOfHorizontal];
        NSMutableDictionary<NSArray<NSNumber *> *,NSNumber *> *map = [[NSMutableDictionary alloc] initWithCapacity:ConstraintParamMap.count];
        for (NSNumber *key in ConstraintParamMap) {
            map[ConstraintParamMap[key]] = key;
        }
        __share__ = map;
    });
    return __share__;
}
+ (NSDictionary<NSArray<NSNumber *> *,NSNumber *> *)ConstraintParamRevertMapOfVertical {
    static NSDictionary<NSArray<NSNumber *> *,NSNumber *> * __share__;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        NSDictionary<NSNumber *,NSArray<NSNumber *> *> *ConstraintParamMap = [self ConstraintParamMapOfVertical];
        NSMutableDictionary<NSArray<NSNumber *> *,NSNumber *> *map = [[NSMutableDictionary alloc] initWithCapacity:ConstraintParamMap.count];
        for (NSNumber *key in ConstraintParamMap) {
            map[ConstraintParamMap[key]] = key;
        }
        __share__ = map;
    });
    return __share__;
}
+ (void)parseConstraintParam:(LUIFillingFlowLayoutConstraintParam)param layoutDirection:(LUILayoutConstraintDirection *)layoutDirection layoutVerticalAlignment:(LUILayoutConstraintVerticalAlignment *)layoutVerticalAlignment layoutHorizontalAlignment:(LUILayoutConstraintHorizontalAlignment *)layoutHorizontalAlignment {
    NSDictionary<NSNumber *,NSArray<NSNumber *> *> *ConstraintParamMapOfHorizontal = [self.class ConstraintParamMapOfHorizontal];
    NSDictionary<NSNumber *,NSArray<NSNumber *> *> *ConstraintParamMapOfVertical = [self.class ConstraintParamMapOfVertical];
    NSArray<NSNumber *> *enums = ConstraintParamMapOfHorizontal[@(param)];
    if (enums) {
        *layoutDirection = [enums[0] integerValue];
        *layoutVerticalAlignment = [enums[1] integerValue];
    } else {
        enums = ConstraintParamMapOfVertical[@(param)];
        *layoutDirection = [enums[0] integerValue];
        *layoutHorizontalAlignment = [enums[1] integerValue];
    }
}
+ (LUIFillingFlowLayoutConstraintParam)constraintParamWithLayoutDirection:(LUILayoutConstraintDirection)layoutDirection layoutVerticalAlignment:(LUILayoutConstraintVerticalAlignment)layoutVerticalAlignment layoutHorizontalAlignment:(LUILayoutConstraintHorizontalAlignment)layoutHorizontalAlignment {
    LUIFillingFlowLayoutConstraintParam param;
    if (layoutDirection == LUILayoutConstraintDirectionHorizontal) {
        NSDictionary<NSArray<NSNumber *> *,NSNumber *> *ConstraintParamRevertMapOfHorizontal = [self.class ConstraintParamRevertMapOfHorizontal];
        param = (LUIFillingFlowLayoutConstraintParam)[ConstraintParamRevertMapOfHorizontal[@[@(layoutDirection),@(layoutVerticalAlignment)]] integerValue];
    } else {
        NSDictionary<NSArray<NSNumber *> *,NSNumber *> *ConstraintParamRevertMapOfVertical = [self.class ConstraintParamRevertMapOfVertical];
        param = (LUIFillingFlowLayoutConstraintParam)[ConstraintParamRevertMapOfVertical[@[@(layoutDirection),@(layoutHorizontalAlignment)]] integerValue];
    }
    return param;
}
//////////////////////////////////////////////////////////////////////////////
- (id)initWithItems:(NSArray<id<LUILayoutConstraintItemProtocol>> *)items constraintParam:(LUIFillingFlowLayoutConstraintParam)param contentInsets:(UIEdgeInsets)contentInsets {
    if (self = [self init]) {
        self.items = items;
        [self configWithConstraintParam:param];
        self.contentInsets = contentInsets;
    }
    return self;
}
- (LUIFillingFlowLayoutConstraintParam)constraintParam {
    LUIFillingFlowLayoutConstraintParam param = [self.class constraintParamWithLayoutDirection:self.layoutDirection layoutVerticalAlignment:self.layoutVerticalAlignment layoutHorizontalAlignment:self.layoutHorizontalAlignment];
    return param;
}
- (void)setConstraintParam:(LUIFillingFlowLayoutConstraintParam)constraintParam {
    [self configWithConstraintParam:constraintParam];
}
- (void)configWithConstraintParam:(LUIFillingFlowLayoutConstraintParam)param {
    LUILayoutConstraintDirection layoutDirection;
    LUILayoutConstraintVerticalAlignment layoutVerticalAlignment;
    LUILayoutConstraintHorizontalAlignment layoutHorizontalAlignment;
    [self.class parseConstraintParam:param layoutDirection:&layoutDirection layoutVerticalAlignment:&layoutVerticalAlignment layoutHorizontalAlignment:&layoutHorizontalAlignment];
    self.layoutDirection = layoutDirection;
    self.layoutVerticalAlignment = layoutVerticalAlignment;
    self.layoutHorizontalAlignment = layoutHorizontalAlignment;
}

@end
