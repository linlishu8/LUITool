//
//  LUISegmentFlowLayoutConstraint.m
//  LUITool
//
//  Created by 六月 on 2024/8/14.
//

#import "LUISegmentFlowLayoutConstraint.h"
#import "LUIFlowLayoutConstraint.h"

@interface LUISegmentFlowLayoutConstraint () {
    BOOL __needConfigSubFlowLayouts;
}

@property(nonatomic,strong) LUIFlowLayoutConstraint *beforeItemsFlowlayout;
@property(nonatomic,strong) LUIFlowLayoutConstraint *afterItemsFlowlayout;

@end

@implementation LUISegmentFlowLayoutConstraint

- (id)copyWithZone:(NSZone *)zone {
    LUISegmentFlowLayoutConstraint *obj = [super copyWithZone:zone];
    obj.layoutDirection = self.layoutDirection;
    obj.layoutVerticalAlignment = self.layoutVerticalAlignment;
    obj.layoutHorizontalAlignment = self.layoutHorizontalAlignment;
    obj.contentInsets = self.contentInsets;
    obj.interitemSpacing = self.interitemSpacing;
    obj.boundaryItemIndex = self.boundaryItemIndex;
    obj.isLayoutPriorityFirstItems = self.isLayoutPriorityFirstItems;
    obj.layoutPriorityItemsMaxBoundsPercent = self.layoutPriorityItemsMaxBoundsPercent;
    obj.fixSizeToFitsBounds = self.fixSizeToFitsBounds;
    return obj;
}
- (id)init {
    if (self = [super init]) {
        self.beforeItemsFlowlayout = [[LUIFlowLayoutConstraint alloc] init];
        self.afterItemsFlowlayout = [[LUIFlowLayoutConstraint alloc] init];
        _layoutDirection = LUILayoutConstraintDirectionHorizontal;
        _layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentCenter;
        _isLayoutPriorityFirstItems = NO;
        _layoutPriorityItemsMaxBoundsPercent= 0.75;
        __needConfigSubFlowLayouts = YES;
    }
    return self;
}
- (void)setBoundaryItemIndexWithItem:(id<LUILayoutConstraintItemProtocol>)item {
    NSInteger index = [self.items indexOfObject:item];
    if (index!=NSNotFound) {
        self.boundaryItemIndex = index;
    } else {
        //出错了
    }
}
- (void)setBoundaryItemIndex:(NSInteger)boundaryItemIndex {
    _boundaryItemIndex = boundaryItemIndex;
    __needConfigSubFlowLayouts = YES;
}
- (void)setLayoutDirection:(LUILayoutConstraintDirection)layoutDirection {
    _layoutDirection = layoutDirection;
    __needConfigSubFlowLayouts = YES;
}
- (void)setLayoutHorizontalAlignment:(LUILayoutConstraintHorizontalAlignment)layoutHorizontalAlignment {
    _layoutHorizontalAlignment = layoutHorizontalAlignment;
    __needConfigSubFlowLayouts = YES;
}
- (void)setLayoutVerticalAlignment:(LUILayoutConstraintVerticalAlignment)layoutVerticalAlignment {
    _layoutVerticalAlignment = layoutVerticalAlignment;
    __needConfigSubFlowLayouts = YES;
}
- (void)setItems:(NSArray *)items {
    [super setItems:items];
    __needConfigSubFlowLayouts = YES;
}
- (void)setInteritemSpacing:(CGFloat)interitemSpacing {
    _interitemSpacing = interitemSpacing;
    __needConfigSubFlowLayouts = YES;
}
- (void)setContentInsets:(UIEdgeInsets)contentInsets {
    _contentInsets = contentInsets;
    __needConfigSubFlowLayouts = YES;
}
- (void)__configSubFlowLayouts {
    __needConfigSubFlowLayouts = NO;
    self.beforeItemsFlowlayout.items = [self.items subarrayWithRange:NSMakeRange(0, self.boundaryItemIndex+1)];
    self.afterItemsFlowlayout.items = [self.items subarrayWithRange:NSMakeRange(self.boundaryItemIndex+1, self.items.count-self.boundaryItemIndex-1)];
    //
    self.beforeItemsFlowlayout.interitemSpacing = self.interitemSpacing;
    self.afterItemsFlowlayout.interitemSpacing = self.interitemSpacing;
    //
    self.beforeItemsFlowlayout.layoutDirection = self.layoutDirection;
    self.afterItemsFlowlayout.layoutDirection = self.layoutDirection;
    //
    if (self.layoutDirection==LUILayoutConstraintDirectionHorizontal) {//水平方向布局,A B C
        self.beforeItemsFlowlayout.layoutVerticalAlignment = self.layoutVerticalAlignment;
        self.afterItemsFlowlayout.layoutVerticalAlignment = self.layoutVerticalAlignment;
        self.beforeItemsFlowlayout.layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentLeft;
        self.afterItemsFlowlayout.layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentRight;
    } else {//垂直方向布局
        /**
         A
         B
         C
         */
        self.beforeItemsFlowlayout.layoutHorizontalAlignment = self.layoutHorizontalAlignment;
        self.afterItemsFlowlayout.layoutHorizontalAlignment = self.layoutHorizontalAlignment;
        self.beforeItemsFlowlayout.layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentTop;
        self.afterItemsFlowlayout.layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentBottom;
    }
}
- (CGSize)sizeThatFits:(CGSize)size resizeItems:(BOOL)resizeItems {
//    if (__needConfigSubFlowLayouts) {
        [self __configSubFlowLayouts];
//    }
    CGSize sizeFits = CGSizeZero;
    UIEdgeInsets insets = self.contentInsets;
    CGRect bounds = CGRectZero;
    bounds.size = size;
    bounds = UIEdgeInsetsInsetRect(bounds, insets);
    CGFloat space = self.interitemSpacing;
    if (self.beforeItemsFlowlayout.layoutedItems.count==0 || self.afterItemsFlowlayout.layoutedItems.count==0) {
        space = 0;
    }
    CGRect f1 = bounds;
    CGRect f2 = bounds;
    CGSize f1_size_fit  = [self.beforeItemsFlowlayout sizeThatFits:f1.size resizeItems:resizeItems];
    CGSize f2_size_fit = [self.afterItemsFlowlayout sizeThatFits:f2.size resizeItems:resizeItems];
    LUICGAxis axis = self.layoutDirection==LUILayoutConstraintDirectionHorizontal?LUICGAxisX:LUICGAxisY;
    LUICGAxis axisR = LUICGAxisReverse(axis);
    if (self.isLayoutPriorityFirstItems) {
        if (CGSizeEqualToSize(f2_size_fit, CGSizeZero)) {//后半部分没有占用空间,空间全部分配给前半部分
            if (!CGSizeEqualToSize(f1_size_fit, CGSizeZero)) {
                sizeFits.width = insets.left+insets.right+f1_size_fit.width;
                sizeFits.height = insets.top+insets.bottom+f1_size_fit.height;
            }
        } else {
            LUICGRectSetLength(&f1, axis, self.layoutPriorityItemsMaxBoundsPercent*(LUICGRectGetLength(bounds, axis)-space));
            CGSize f1_size = f1_size_fit.width<=f1.size.width && f1_size_fit.height<=f1.size.height?f1_size_fit:[self.beforeItemsFlowlayout sizeThatFits:f1.size resizeItems:resizeItems];
            f1.size.width = MIN(f1_size.width,f1.size.width);
            f1.size.height = MIN(f1_size.height,f1.size.height);
            //
            
            LUICGRectSetLength(&f2, axis, LUICGRectGetLength(bounds, axis)-LUICGRectGetLength(f1, axis));
            if (LUICGRectGetLength(f1, axis)>0) {
                LUICGRectAddLength(&f2, axis, -space);
            }
            CGSize f2_size = f2_size_fit.width<=f2.size.width && f2_size_fit.height<=f2.size.height?f2_size_fit:[self.afterItemsFlowlayout sizeThatFits:f2.size resizeItems:resizeItems];
            f2.size.width = MIN(f2_size.width,f2.size.width);
            f2.size.height = MIN(f2_size.height,f2.size.height);
            CGFloat maxLengthAxisR = MAX(LUICGRectGetLength(f1, axisR),LUICGRectGetLength(f2, axisR));
            if (maxLengthAxisR) {
                LUICGSizeSetLength(&sizeFits, axisR, maxLengthAxisR+LUIEdgeInsetsGetEdge(insets, axisR, LUIEdgeInsetsMin)+LUIEdgeInsetsGetEdge(insets, axisR, LUIEdgeInsetsMax));
            }
            if (LUICGRectGetLength(f1, axis)+LUICGRectGetLength(f2, axis)>0) {
                LUICGSizeSetLength(&sizeFits, axis, LUIEdgeInsetsGetEdge(insets, axis, LUIEdgeInsetsMin)+LUIEdgeInsetsGetEdge(insets, axis, LUIEdgeInsetsMax)+LUICGRectGetLength(f1, axis)+LUICGRectGetLength(f2, axis));
                if (LUICGRectGetLength(f1, axis)>0 && LUICGRectGetLength(f2, axis)>0) {
                    LUICGSizeAddLength(&sizeFits, axis, space);
                }
            }
        }
    } else {
        if (CGSizeEqualToSize(f1_size_fit, CGSizeZero)) {//前半部分没有占用空间,空间全部分配给后半部分
            if (!CGSizeEqualToSize(f2_size_fit, CGSizeZero)) {
                sizeFits.width = insets.left+insets.right+f2_size_fit.width;
                sizeFits.height = insets.top+insets.bottom+f2_size_fit.height;
            }
        } else {
            LUICGRectSetLength(&f2, axis, self.layoutPriorityItemsMaxBoundsPercent*(LUICGRectGetLength(bounds, axis)-space));
            CGSize f2_size = f2_size_fit.width<=f2.size.width && f2_size_fit.height<=f2.size.height?f2_size_fit:[self.afterItemsFlowlayout sizeThatFits:f2.size resizeItems:resizeItems];
            f2.size.width = MIN(f2_size.width,f2.size.width);
            f2.size.height = MIN(f2_size.height,f2.size.height);
            //
            LUICGRectSetLength(&f1, axis, LUICGRectGetLength(bounds, axis)-LUICGRectGetLength(f2, axis));
            if (LUICGRectGetLength(f2, axis)>0) {
                LUICGRectAddLength(&f1, axis, -space);
            }
            CGSize f1_size = f1_size_fit.width<=f1.size.width && f1_size_fit.height<=f1.size.height?f1_size_fit:[self.beforeItemsFlowlayout sizeThatFits:f1.size resizeItems:resizeItems];
            f1.size.width = MIN(f1_size.width,f1.size.width);
            f1.size.height = MIN(f1_size.height,f1.size.height);
            
            CGFloat maxLengthAxisR = MAX(LUICGRectGetLength(f1, axisR),LUICGRectGetLength(f2, axisR));
            if (maxLengthAxisR) {
                LUICGSizeSetLength(&sizeFits, axisR, maxLengthAxisR+LUIEdgeInsetsGetEdge(insets, axisR, LUIEdgeInsetsMin)+LUIEdgeInsetsGetEdge(insets, axisR, LUIEdgeInsetsMax));
            }
            if (LUICGRectGetLength(f1, axis)+LUICGRectGetLength(f2, axis)>0) {
                LUICGSizeSetLength(&sizeFits, axis, LUIEdgeInsetsGetEdge(insets, axis, LUIEdgeInsetsMin)+LUIEdgeInsetsGetEdge(insets, axis, LUIEdgeInsetsMax)+LUICGRectGetLength(f1, axis)+LUICGRectGetLength(f2, axis));
                if (LUICGRectGetLength(f1, axis)>0 && LUICGRectGetLength(f2, axis)>0) {
                    LUICGSizeAddLength(&sizeFits, axis, space);
                }
            }
        }
    }
    
    if (self.fixSizeToFitsBounds) {
        LUICGSizeSetLength(&sizeFits, axis, LUICGSizeGetLength(size, axis));
    }
    return sizeFits;
}
- (void)layoutItems {
//    if (__needConfigSubFlowLayouts) {
        [self __configSubFlowLayouts];
//    }
    [self layoutItemsWithResizeItems:NO];
}
- (void)layoutItemsWithResizeItems:(BOOL)resizeItems {
//    if (__needConfigSubFlowLayouts) {
        [self __configSubFlowLayouts];
//    }
    UIEdgeInsets insets = self.contentInsets;
    CGRect bounds = UIEdgeInsetsInsetRect(self.bounds, insets);
    CGFloat space = self.interitemSpacing;
    if (self.beforeItemsFlowlayout.layoutedItems.count==0 || self.afterItemsFlowlayout.layoutedItems.count==0) {
        space = 0;
    }
    CGRect f1 = bounds;
    CGRect f2 = bounds;
    LUICGAxis axis = self.layoutDirection==LUILayoutConstraintDirectionHorizontal?LUICGAxisX:LUICGAxisY;
//    LUICGAxis axisR = LUICGAxisReverse(axis);
    if (self.isLayoutPriorityFirstItems) {
        BOOL isAfterItemsEmpty = [self.afterItemsFlowlayout isEmptyBounds:f2 withResizeItems:resizeItems];
        if (isAfterItemsEmpty) {
            self.beforeItemsFlowlayout.bounds = f1;
            [self.beforeItemsFlowlayout layoutItemsWithResizeItems:resizeItems];
        } else {
            LUICGRectSetLength(&f1, axis, self.layoutPriorityItemsMaxBoundsPercent*(LUICGRectGetLength(bounds, axis)-space));
            CGSize f1_size = [self.beforeItemsFlowlayout sizeThatFits:f1.size resizeItems:resizeItems];
            LUICGRectSetLength(&f1, axis, MIN(LUICGSizeGetLength(f1_size, axis), LUICGRectGetLength(f1, axis)));
            self.beforeItemsFlowlayout.bounds = f1;
            [self.beforeItemsFlowlayout layoutItemsWithResizeItems:resizeItems];
            //
            LUICGRectSetMin(&f2, axis, LUICGRectGetMax(f1, axis));
            if (LUICGRectGetLength(f1, axis)>0) {
                LUICGRectAddMin(&f2, axis, space);
            }
            LUICGRectSetLength(&f2, axis, LUICGRectGetMax(bounds, axis)-LUICGRectGetMin(f2, axis));
            self.afterItemsFlowlayout.bounds = f2;
            [self.afterItemsFlowlayout layoutItemsWithResizeItems:resizeItems];
        }
    } else {
        BOOL isBeforeItemsEmpty = [self.beforeItemsFlowlayout isEmptyBounds:f1 withResizeItems:resizeItems];
        if (isBeforeItemsEmpty) {
            self.afterItemsFlowlayout.bounds = f2;
            [self.afterItemsFlowlayout layoutItemsWithResizeItems:resizeItems];
        } else {
            LUICGRectSetLength(&f2, axis, self.layoutPriorityItemsMaxBoundsPercent*(LUICGRectGetLength(bounds, axis)-space));
            CGSize f2_size = [self.afterItemsFlowlayout sizeThatFits:f2.size resizeItems:resizeItems];
            LUICGRectSetLength(&f2, axis, MIN(LUICGSizeGetLength(f2_size, axis),LUICGRectGetLength(f2, axis)));
            LUICGRectSetMin(&f2, axis, LUICGRectGetMax(bounds, axis)-LUICGRectGetLength(f2, axis));
            self.afterItemsFlowlayout.bounds = f2;
            [self.afterItemsFlowlayout layoutItemsWithResizeItems:resizeItems];
            //
            LUICGRectSetLength(&f1, axis, LUICGRectGetMin(f2, axis)-LUICGRectGetMin(f1, axis));
            if (LUICGRectGetLength(f2, axis)>0) {
                LUICGRectAddLength(&f1, axis, -space);
            }
            self.beforeItemsFlowlayout.bounds = f1;
            [self.beforeItemsFlowlayout layoutItemsWithResizeItems:resizeItems];
        }
    }
}
@end
LUIDEF_EnumTypeCategories(LUISegmentFlowLayoutConstraintParam,
(@ {
   @(LUISegmentFlowLayoutConstraint_H_C):@"H_C",
   @(LUISegmentFlowLayoutConstraint_H_T):@"H_T",
   @(LUISegmentFlowLayoutConstraint_H_B):@"H_B",
   @(LUISegmentFlowLayoutConstraint_V_C):@"V_C",
   @(LUISegmentFlowLayoutConstraint_V_L):@"V_L",
   @(LUISegmentFlowLayoutConstraint_V_R):@"V_R",
   }))
@implementation LUISegmentFlowLayoutConstraint (InitMethod)
//////////////////////////////////////////////////////////////////////////////
+ (NSDictionary<NSNumber *,NSArray<NSNumber *> *> *)ConstraintParamMapOfHorizontal {
    static NSDictionary<NSNumber *,NSArray<NSNumber *> *> * __share__;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        NSMutableDictionary<NSNumber *,NSArray<NSNumber *> *> *map = [[NSMutableDictionary alloc] init];
        map[@(LUISegmentFlowLayoutConstraint_H_C)] = @[
          @(LUILayoutConstraintDirectionHorizontal),
          @(LUILayoutConstraintVerticalAlignmentCenter),
          ];
        map[@(LUISegmentFlowLayoutConstraint_H_T)] = @[
          @(LUILayoutConstraintDirectionHorizontal),
          @(LUILayoutConstraintVerticalAlignmentTop),
          ];
        map[@(LUISegmentFlowLayoutConstraint_H_B)] = @[
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
        map[@(LUISegmentFlowLayoutConstraint_V_C)] = @[
          @(LUILayoutConstraintDirectionVertical),
          @(LUILayoutConstraintHorizontalAlignmentCenter),
          ];
        map[@(LUISegmentFlowLayoutConstraint_V_L)] = @[
          @(LUILayoutConstraintDirectionVertical),
          @(LUILayoutConstraintHorizontalAlignmentLeft),
          ];
        map[@(LUISegmentFlowLayoutConstraint_V_R)] = @[
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
+ (void)parseConstraintParam:(LUISegmentFlowLayoutConstraintParam)param layoutDirection:(LUILayoutConstraintDirection *)layoutDirection layoutVerticalAlignment:(LUILayoutConstraintVerticalAlignment *)layoutVerticalAlignment layoutHorizontalAlignment:(LUILayoutConstraintHorizontalAlignment *)layoutHorizontalAlignment {
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
+ (LUISegmentFlowLayoutConstraintParam)constraintParamWithLayoutDirection:(LUILayoutConstraintDirection)layoutDirection layoutVerticalAlignment:(LUILayoutConstraintVerticalAlignment)layoutVerticalAlignment layoutHorizontalAlignment:(LUILayoutConstraintHorizontalAlignment)layoutHorizontalAlignment {
    LUISegmentFlowLayoutConstraintParam param;
    if (layoutDirection==LUILayoutConstraintDirectionHorizontal) {
        NSDictionary<NSArray<NSNumber *> *,NSNumber *> *ConstraintParamRevertMapOfHorizontal = [self.class ConstraintParamRevertMapOfHorizontal];
        param = (LUISegmentFlowLayoutConstraintParam)[ConstraintParamRevertMapOfHorizontal[@[@(layoutDirection),@(layoutVerticalAlignment)]] integerValue];
    } else {
        NSDictionary<NSArray<NSNumber *> *,NSNumber *> *ConstraintParamRevertMapOfVertical = [self.class ConstraintParamRevertMapOfVertical];
        param = (LUISegmentFlowLayoutConstraintParam)[ConstraintParamRevertMapOfVertical[@[@(layoutDirection),@(layoutHorizontalAlignment)]] integerValue];
    }
    return param;
}
//////////////////////////////////////////////////////////////////////////////
- (id)initWithItems:(NSArray<id<LUILayoutConstraintItemProtocol>> *)items constraintParam:(LUISegmentFlowLayoutConstraintParam)param contentInsets:(UIEdgeInsets)contentInsets interitemSpacing:(CGFloat)interitemSpacing {
    if (self = [self init]) {
        self.items = items;
        [self configWithConstraintParam:param];
        self.contentInsets = contentInsets;
        self.interitemSpacing = interitemSpacing;
    }
    return self;
}
- (LUISegmentFlowLayoutConstraintParam)constraintParam {
    LUISegmentFlowLayoutConstraintParam param = [self.class constraintParamWithLayoutDirection:self.layoutDirection layoutVerticalAlignment:self.layoutVerticalAlignment layoutHorizontalAlignment:self.layoutHorizontalAlignment];
    return param;
}
- (void)setConstraintParam:(LUISegmentFlowLayoutConstraintParam)constraintParam {
    [self configWithConstraintParam:constraintParam];
}
- (void)configWithConstraintParam:(LUISegmentFlowLayoutConstraintParam)param {
    LUILayoutConstraintDirection layoutDirection;
    LUILayoutConstraintVerticalAlignment layoutVerticalAlignment;
    LUILayoutConstraintHorizontalAlignment layoutHorizontalAlignment;
    [self.class parseConstraintParam:param layoutDirection:&layoutDirection layoutVerticalAlignment:&layoutVerticalAlignment layoutHorizontalAlignment:&layoutHorizontalAlignment];
    self.layoutDirection = layoutDirection;
    self.layoutVerticalAlignment = layoutVerticalAlignment;
    self.layoutHorizontalAlignment = layoutHorizontalAlignment;
}

@end
