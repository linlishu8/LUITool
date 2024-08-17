//
//  LUIFillingLayoutConstraint.m
//  LUITool
//
//  Created by 六月 on 2024/8/14.
//

#import "LUIFillingLayoutConstraint.h"
#import "LUIFlowLayoutConstraint.h"

@interface LUIFillingLayoutConstraint () {
    BOOL __needConfigSubFlowLayouts;
}

@property (nonatomic, strong) LUIFlowLayoutConstraint *beforeItemsFlowlayout;
@property (nonatomic, strong) LUIFlowLayoutConstraint *afterItemsFlowlayout;

@end

@implementation LUIFillingLayoutConstraint

- (id)copyWithZone:(NSZone *)zone {
    LUIFillingLayoutConstraint *obj = [super copyWithZone:zone];
    obj.layoutDirection = self.layoutDirection;
    obj.layoutVerticalAlignment = self.layoutVerticalAlignment;
    obj.layoutHorizontalAlignment = self.layoutHorizontalAlignment;
    obj.contentInsets = self.contentInsets;
    obj.interitemSpacing = self.interitemSpacing;
    obj.fillingItem = self.fillingItem;
    return obj;
}
- (id)init {
    if (self = [super init]) {
        self.beforeItemsFlowlayout = [[LUIFlowLayoutConstraint alloc] init];
        self.afterItemsFlowlayout = [[LUIFlowLayoutConstraint alloc] init];
        _layoutDirection = LUILayoutConstraintDirectionHorizontal;
        _layoutVerticalAlignment = LUILayoutConstraintVerticalAlignmentCenter;
        __needConfigSubFlowLayouts = YES;
    }
    return self;
}
- (void)setFillingItem:(id<LUILayoutConstraintItemProtocol>)fillingItem {
    _fillingItem = fillingItem;
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
    NSArray *items = self.layoutedItems;
    NSInteger fillingItemIndex = [items indexOfObject:self.fillingItem];
    if (fillingItemIndex!=NSNotFound) {
        self.beforeItemsFlowlayout.items = fillingItemIndex!=NSNotFound && fillingItemIndex>0?[items subarrayWithRange:NSMakeRange(0, fillingItemIndex)]:nil;
        self.afterItemsFlowlayout.items = fillingItemIndex!=NSNotFound && fillingItemIndex<items.count-1?[items subarrayWithRange:NSMakeRange(fillingItemIndex+1, items.count-fillingItemIndex-1)]:nil;
    }else {
        self.beforeItemsFlowlayout.items = items;
        self.afterItemsFlowlayout.items = @[];
    }
    //
    self.beforeItemsFlowlayout.interitemSpacing = self.interitemSpacing;
    self.afterItemsFlowlayout.interitemSpacing = self.interitemSpacing;
    //
    self.beforeItemsFlowlayout.layoutDirection = self.layoutDirection;
    self.afterItemsFlowlayout.layoutDirection = self.layoutDirection;
    //
    if (self.layoutDirection == LUILayoutConstraintDirectionHorizontal) {//水平方向布局,A B C
        self.beforeItemsFlowlayout.layoutVerticalAlignment = self.layoutVerticalAlignment;
        self.afterItemsFlowlayout.layoutVerticalAlignment = self.layoutVerticalAlignment;
        self.beforeItemsFlowlayout.layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentLeft;
        self.afterItemsFlowlayout.layoutHorizontalAlignment = LUILayoutConstraintHorizontalAlignmentRight;
    }else {//垂直方向布局
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
    CGRect f1 = bounds;
    CGRect f2 = bounds;
    CGRect f_filling = bounds;
    
    LUICGAxis axis = self.layoutDirection  ==  LUILayoutConstraintDirectionHorizontal ? LUICGAxisX : LUICGAxisY;
    LUICGAxis axisR = LUICGAxisReverse(axis);
    
    CGFloat maxLengthR = 0;
    //计算前半部分
    if (self.fillingItem) {
        LUICGRectSetLength(&f1, axis, LUICGRectGetLength(f1, axis)-space);
    }
    CGSize f1_size_fit = [self.beforeItemsFlowlayout sizeThatFits:f1.size resizeItems:resizeItems];
    
    maxLengthR = MAX(maxLengthR,LUICGSizeGetLength(f1_size_fit, axisR));
    //计算后半部分
    if (self.fillingItem) {
        LUICGRectSetLength(&f2, axis, LUICGRectGetLength(f2, axis)-space);
    }
    if (LUICGSizeGetLength(f1_size_fit, axis)>0) {
        LUICGRectSetLength(&f2, axis, LUICGRectGetLength(f2, axis)-(LUICGSizeGetLength(f1_size_fit, axis)+space));
        LUICGRectSetLength(&f_filling, axis, LUICGRectGetLength(f_filling, axis)-(LUICGSizeGetLength(f1_size_fit, axis)+space));
    }
    CGSize f2_size_fit = [self.afterItemsFlowlayout sizeThatFits:f2.size resizeItems:resizeItems];
    maxLengthR = MAX(maxLengthR,LUICGSizeGetLength(f2_size_fit, axisR));
    //布局填充元素
    if (LUICGSizeGetLength(f2_size_fit, axis) > 0) {
        LUICGRectSetLength(&f_filling, axis, LUICGRectGetLength(f_filling, axis)-(LUICGSizeGetLength(f2_size_fit, axis)+space));
    }
    CGSize f_filling_size_fit;
    if ([self.fillingItem respondsToSelector:@selector(sizeThatFits:resizeItems:)]) {
        f_filling_size_fit = [self.fillingItem sizeThatFits:f_filling.size resizeItems:resizeItems];
    }else {
        f_filling_size_fit = [self.fillingItem sizeThatFits:f_filling.size];
    }
    maxLengthR = MAX(maxLengthR,LUICGSizeGetLength(f_filling_size_fit, axisR));
    if (maxLengthR) {
        LUICGSizeSetLength(&sizeFits, axisR, maxLengthR+LUIEdgeInsetsGetEdge(insets, axisR, LUIEdgeInsetsMin)+LUIEdgeInsetsGetEdge(insets, axisR, LUIEdgeInsetsMax));
    }
    LUICGSizeSetLength(&sizeFits, axis, LUICGSizeGetLength(size, axis));
    
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
    CGRect f1 = bounds;
    CGRect f2 = bounds;
    CGRect f_filling = bounds;
    
    LUICGAxis axis = self.layoutDirection  ==  LUILayoutConstraintDirectionHorizontal ? LUICGAxisX : LUICGAxisY;
    LUICGAxis axisR = LUICGAxisReverse(axis);
    
    LUICGRectAlignment align = self.layoutDirection  ==  LUILayoutConstraintDirectionHorizontal? LUICGRectAlignmentFromLUILayoutConstraintVerticalAlignment(self.layoutVerticalAlignment):LUICGRectAlignmentFromLUILayoutConstraintHorizontalAlignment(self.layoutHorizontalAlignment);
    
    self.beforeItemsFlowlayout.bounds = f1;
    [self.beforeItemsFlowlayout layoutItemsWithResizeItems:resizeItems];
    //
    id<LUILayoutConstraintItemProtocol> item1 = [self.beforeItemsFlowlayout.layoutedItems lastObject];
    CGRect item1Frame = [item1 layoutFrame];
    if (item1 && LUICGRectGetMax(item1Frame,axis)!=LUICGRectGetMin(f1, axis)) {
        LUICGRectSetMin(&f_filling, axis, LUICGRectGetMax(item1Frame,axis)+space);
        LUICGRectSetLength(&f_filling, axis, LUICGRectGetMax(bounds,axis)-LUICGRectGetMin(f_filling, axis));
        LUICGRectSetMin(&f2, axis, LUICGRectGetMin(f_filling, axis));
        LUICGRectSetLength(&f2, axis, LUICGRectGetLength(f_filling, axis));
    }
    self.afterItemsFlowlayout.bounds = f2;
    [self.afterItemsFlowlayout layoutItemsWithResizeItems:resizeItems];
    id<LUILayoutConstraintItemProtocol> item2 = [self.afterItemsFlowlayout.layoutedItems firstObject];
    CGRect item2Frame = [item2 layoutFrame];
    if (item2 && LUICGRectGetMin(item2Frame, axis)!=LUICGRectGetMax(f2,axis)) {
        LUICGRectSetLength(&f_filling, axis, LUICGRectGetMin(item2Frame, axis)-space-LUICGRectGetMin(f_filling, axis));
    }
    if (resizeItems) {
        if ([self.fillingItem respondsToSelector:@selector(sizeThatFits:resizeItems:)]) {
            CGSize f_filling_size = [self.fillingItem sizeThatFits:f_filling.size resizeItems:resizeItems];
            LUICGRectSetLength(&f_filling, axisR, LUICGSizeGetLength(f_filling_size, axisR));
        }else if ([self.fillingItem respondsToSelector:@selector(sizeThatFits:)]) {
            CGSize f_filling_size = [self.fillingItem sizeThatFits:f_filling.size];
            LUICGRectSetLength(&f_filling, axisR, LUICGSizeGetLength(f_filling_size, axisR));
        }
    }
    LUICGRectAlignToRect(&f_filling, axisR, align, bounds);
    if ([self.fillingItem respondsToSelector:@selector(layoutItemsWithResizeItems:)]) {
        [self.fillingItem setLayoutFrame:f_filling];
        [self.fillingItem layoutItemsWithResizeItems:resizeItems];
    }else {
        [self.fillingItem setLayoutFrame:f_filling];
    }
}
@end
LUIDEF_EnumTypeCategories(LUIFillingLayoutConstraintParam,
(@{
   @(LUIFillingLayoutConstraint_H_C):@"H_C",
   @(LUIFillingLayoutConstraint_H_T):@"H_T",
   @(LUIFillingLayoutConstraint_H_B):@"H_B",
   @(LUIFillingLayoutConstraint_V_C):@"V_C",
   @(LUIFillingLayoutConstraint_V_L):@"V_L",
   @(LUIFillingLayoutConstraint_V_R):@"V_R",
   }))
@implementation LUIFillingLayoutConstraint (InitMethod)
//////////////////////////////////////////////////////////////////////////////
+ (NSDictionary<NSNumber *,NSArray<NSNumber *> *> *)ConstraintParamMapOfHorizontal {
    static NSDictionary<NSNumber *,NSArray<NSNumber *> *> * __share__;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        NSMutableDictionary<NSNumber *,NSArray<NSNumber *> *> *map = [[NSMutableDictionary alloc] init];
        map[@(LUIFillingLayoutConstraint_H_C)] = @[
          @(LUILayoutConstraintDirectionHorizontal),
          @(LUILayoutConstraintVerticalAlignmentCenter),
          ];
        map[@(LUIFillingLayoutConstraint_H_T)] = @[
          @(LUILayoutConstraintDirectionHorizontal),
          @(LUILayoutConstraintVerticalAlignmentTop),
          ];
        map[@(LUIFillingLayoutConstraint_H_B)] = @[
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
        map[@(LUIFillingLayoutConstraint_V_C)] = @[
          @(LUILayoutConstraintDirectionVertical),
          @(LUILayoutConstraintHorizontalAlignmentCenter),
          ];
        map[@(LUIFillingLayoutConstraint_V_L)] = @[
          @(LUILayoutConstraintDirectionVertical),
          @(LUILayoutConstraintHorizontalAlignmentLeft),
          ];
        map[@(LUIFillingLayoutConstraint_V_R)] = @[
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
+ (void)parseConstraintParam:(LUIFillingLayoutConstraintParam)param layoutDirection:(LUILayoutConstraintDirection *)layoutDirection layoutVerticalAlignment:(LUILayoutConstraintVerticalAlignment *)layoutVerticalAlignment layoutHorizontalAlignment:(LUILayoutConstraintHorizontalAlignment *)layoutHorizontalAlignment {
    NSDictionary<NSNumber *,NSArray<NSNumber *> *> *ConstraintParamMapOfHorizontal = [self.class ConstraintParamMapOfHorizontal];
    NSDictionary<NSNumber *,NSArray<NSNumber *> *> *ConstraintParamMapOfVertical = [self.class ConstraintParamMapOfVertical];
    NSArray<NSNumber *> *enums = ConstraintParamMapOfHorizontal[@(param)];
    if (enums) {
        *layoutDirection = [enums[0] integerValue];
        *layoutVerticalAlignment = [enums[1] integerValue];
    }else {
        enums = ConstraintParamMapOfVertical[@(param)];
        *layoutDirection = [enums[0] integerValue];
        *layoutHorizontalAlignment = [enums[1] integerValue];
    }
}
+ (LUIFillingLayoutConstraintParam)constraintParamWithLayoutDirection:(LUILayoutConstraintDirection)layoutDirection layoutVerticalAlignment:(LUILayoutConstraintVerticalAlignment)layoutVerticalAlignment layoutHorizontalAlignment:(LUILayoutConstraintHorizontalAlignment)layoutHorizontalAlignment {
    LUIFillingLayoutConstraintParam param;
    if (layoutDirection == LUILayoutConstraintDirectionHorizontal) {
        NSDictionary<NSArray<NSNumber *> *,NSNumber *> *ConstraintParamRevertMapOfHorizontal = [self.class ConstraintParamRevertMapOfHorizontal];
        param = (LUIFillingLayoutConstraintParam)[ConstraintParamRevertMapOfHorizontal[@[@(layoutDirection),@(layoutVerticalAlignment)]] integerValue];
    }else {
        NSDictionary<NSArray<NSNumber *> *,NSNumber *> *ConstraintParamRevertMapOfVertical = [self.class ConstraintParamRevertMapOfVertical];
        param = (LUIFillingLayoutConstraintParam)[ConstraintParamRevertMapOfVertical[@[@(layoutDirection),@(layoutHorizontalAlignment)]] integerValue];
    }
    return param;
}
//////////////////////////////////////////////////////////////////////////////
- (id)initWithItems:(NSArray<id<LUILayoutConstraintItemProtocol>> *)items fillingItem:(id<LUILayoutConstraintItemProtocol>)fillingItem constraintParam:(LUIFillingLayoutConstraintParam)param contentInsets:(UIEdgeInsets)contentInsets interitemSpacing:(CGFloat)interitemSpacing {
    if (self = [self init]) {
        self.items = items;
        self.fillingItem = fillingItem;
        [self configWithConstraintParam:param];
        self.contentInsets = contentInsets;
        self.interitemSpacing = interitemSpacing;
    }
    return self;
}
- (LUIFillingLayoutConstraintParam)constraintParam {
    LUIFillingLayoutConstraintParam param = [self.class constraintParamWithLayoutDirection:self.layoutDirection layoutVerticalAlignment:self.layoutVerticalAlignment layoutHorizontalAlignment:self.layoutHorizontalAlignment];
    return param;
}
- (void)setConstraintParam:(LUIFillingLayoutConstraintParam)constraintParam {
    [self configWithConstraintParam:constraintParam];
}
- (void)configWithConstraintParam:(LUIFillingLayoutConstraintParam)param {
    LUILayoutConstraintDirection layoutDirection;
    LUILayoutConstraintVerticalAlignment layoutVerticalAlignment;
    LUILayoutConstraintHorizontalAlignment layoutHorizontalAlignment;
    [self.class parseConstraintParam:param layoutDirection:&layoutDirection layoutVerticalAlignment:&layoutVerticalAlignment layoutHorizontalAlignment:&layoutHorizontalAlignment];
    self.layoutDirection = layoutDirection;
    self.layoutVerticalAlignment = layoutVerticalAlignment;
    self.layoutHorizontalAlignment = layoutHorizontalAlignment;
}

@end
