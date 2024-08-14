//
//  LUIFlowLayoutConstraint.m
//  LUITool
//
//  Created by 六月 on 2024/8/14.
//

#import "LUIFlowLayoutConstraint.h"

@interface LUIFlowLayoutConstraint ()

@property (nonatomic, strong) LUILayoutConstraintItemAttributeSection *itemAttributeSection;

@end

@implementation LUIFlowLayoutConstraint

- (LUICGAxis)layoutDirectionAxis {
    LUICGAxis X = self.layoutDirection==LUILayoutConstraintDirectionHorizontal?LUICGAxisX:LUICGAxisY;
    return X;
}
- (CGSize)itemSizeForItem:(id<LUILayoutConstraintItemProtocol>)item thatFits:(CGSize)size resizeItems:(BOOL)resizeItems {
    CGSize itemSize = CGSizeZero;
    CGSize limitSize = size;
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
    return itemSize;
}
- (nullable LUILayoutConstraintItemAttributeSection *)itemAttributeSectionThatFits:(CGSize)size resizeItems:(BOOL)resizeItems needLimitSize:(BOOL)needLimitSize {
    NSArray *items = self.layoutedItems;
    NSInteger count = items.count;
    if (count==0) return nil;
    BOOL needRevert = (self.layoutDirection==LUILayoutConstraintDirectionHorizontal&&self.layoutHorizontalAlignment==LUILayoutConstraintHorizontalAlignmentRight)
    ||(self.layoutDirection==LUILayoutConstraintDirectionVertical&&self.layoutVerticalAlignment==LUILayoutConstraintVerticalAlignmentBottom)
    ;
    if (needRevert) {
        NSMutableArray *tmp = [[NSMutableArray alloc] init];
        for (id<LUILayoutConstraintItemProtocol> item in items.reverseObjectEnumerator) {
            [tmp addObject:item];
        }
        items = tmp;
    }
    
    LUICGAxis X = [self layoutDirectionAxis];
    LUICGAxis Y = LUICGAxisReverse(X);
    
    UIEdgeInsets contentInsets = self.contentInsets;
    
    CGFloat xSpacing = self.interitemSpacing;
    
    CGSize originLimitSize = CGSizeMake(size.width-contentInsets.left-contentInsets.right, size.height-contentInsets.top-contentInsets.bottom);//限制在 size -contentInsets 矩形内
    
    CGSize limitSize = originLimitSize;
    limitSize.width = MAX(0,limitSize.width);
    limitSize.height = MAX(0,limitSize.height);
    //以下类命名，以水平流动时为基准
    
    LUILayoutConstraintItemAttributeSection *line = [[LUILayoutConstraintItemAttributeSection alloc] init];
    for (int i=0;i<items.count;i++) {
        id<LUILayoutConstraintItemProtocol> item = items[i];
        CGFloat limitWidth = LUICGSizeGetLength(limitSize, X);
//        CGFloat limitHeight = LUICGSizeGetLength(limitSize, Y);
        CGSize itemSize = [self itemSizeForItem:item thatFits:limitSize resizeItems:resizeItems];
        LUILayoutConstraintItemAttribute *itemAttr = [[LUILayoutConstraintItemAttribute alloc] initWithItem:item];
        [line addItemAttribute:itemAttr];
        CGFloat w = LUICGSizeGetLength(itemSize, X);
        CGFloat h = LUICGSizeGetLength(itemSize, Y);
        if (needLimitSize) {
            w = MIN(w,LUICGSizeGetLength(limitSize, X));
            h = MIN(h,LUICGSizeGetLength(limitSize, Y));
            LUICGSizeSetLength(&itemSize, X, w);
            LUICGSizeSetLength(&itemSize, Y, h);
        }
        itemAttr.size = itemSize;
        if (w>0 && h>0) {
            limitWidth -= xSpacing+w;
            limitWidth = MAX(0,limitWidth);
            LUICGSizeSetLength(&limitSize, X, limitWidth);
        }
    }
    if (needRevert) {
        NSMutableArray *tmp = [[NSMutableArray alloc] init];
        for (id<LUILayoutConstraintItemProtocol> item in line.itemAttributs.reverseObjectEnumerator) {
            [tmp addObject:item];
        }
        line.itemAttributs = tmp;
    }
    
    line.size = [line sizeThatFlowLayoutItemsWithSpacing:xSpacing axis:X];
    return line;
}

- (CGSize)sizeThatFits:(CGSize)size resizeItems:(BOOL)resizeItems {
    CGSize sizeFits = CGSizeZero;
    UIEdgeInsets contentInsets = self.contentInsets;
    LUILayoutConstraintItemAttributeSection *line = [self itemAttributeSectionThatFits:size resizeItems:resizeItems needLimitSize:NO];
    sizeFits = line.layoutFrame.size;
    if (sizeFits.width>0&&sizeFits.height>0) {
        sizeFits.width += contentInsets.left+contentInsets.right;
        sizeFits.height += contentInsets.top+contentInsets.bottom;
    }
    return sizeFits;
}
- (void)layoutItems {
    [self layoutItemsWithResizeItems:NO];
}
- (void)layoutItemsWithResizeItems:(BOOL)resizeItems {
    CGSize size = self.bounds.size;
    
    LUILayoutConstraintItemAttributeSection *line = [self itemAttributeSectionThatFits:size resizeItems:resizeItems needLimitSize:!self.unLimitItemSizeInBounds];
    LUICGAxis X = [self layoutDirectionAxis];
    LUICGAxis Y = LUICGAxisReverse(X);
    
    UIEdgeInsets contentInsets = self.contentInsets;
    
    CGFloat xSpacing = self.interitemSpacing;
    
    LUICGRectAlignment alignX = self.layoutDirection==LUILayoutConstraintDirectionVertical?LUICGRectAlignmentFromLUILayoutConstraintVerticalAlignment(self.layoutVerticalAlignment):LUICGRectAlignmentFromLUILayoutConstraintHorizontalAlignment(self.layoutHorizontalAlignment);
    LUICGRectAlignment alignY = self.layoutDirection==LUILayoutConstraintDirectionHorizontal?LUICGRectAlignmentFromLUILayoutConstraintVerticalAlignment(self.layoutVerticalAlignment):LUICGRectAlignmentFromLUILayoutConstraintHorizontalAlignment(self.layoutHorizontalAlignment);
    
    CGRect bounds = UIEdgeInsetsInsetRect(self.bounds, contentInsets);
    CGRect f1 = line.layoutFrame;
    LUICGRectAlignToRect(&f1, Y, alignY, bounds);
    LUICGRectAlignToRect(&f1, X, alignX, bounds);
    line.layoutFrame = f1;
    
    [line flowLayoutItemsWithSpacing:xSpacing axis:X alignment:alignY needRevert:NO];
    for (LUILayoutConstraintItemAttribute *item in line.itemAttributs) {
        [item applyAttributeWithResizeItems:resizeItems];
    }
    self.itemAttributeSection = line;
}

- (id)copyWithZone:(NSZone *)zone {
    LUIFlowLayoutConstraint *obj = [super copyWithZone:zone];
    obj.layoutDirection = self.layoutDirection;
    obj.layoutVerticalAlignment = self.layoutVerticalAlignment;
    obj.layoutHorizontalAlignment = self.layoutHorizontalAlignment;
    obj.contentInsets = self.contentInsets;
    obj.interitemSpacing = self.interitemSpacing;
    obj.unLimitItemSizeInBounds = self.unLimitItemSizeInBounds;
    return obj;
}
- (BOOL)isEmptyBounds:(CGRect)bounds withResizeItems:(BOOL)resizeItems {
    BOOL is = NO;
    NSArray *items = self.layoutedItems;
    if (items.count) {
        CGRect b = UIEdgeInsetsInsetRect(bounds, self.contentInsets);
        
        CGFloat interitemSpacing = self.interitemSpacing;
        CGSize limitSize = b.size;
        LUICGAxis axis = self.layoutDirection==LUILayoutConstraintDirectionHorizontal?LUICGAxisX:LUICGAxisY;
        is = YES;
        for (id<LUILayoutConstraintItemProtocol> item in items) {
            CGRect f1 = b;
            CGSize f1_size;
            if (resizeItems) {
                if ([item respondsToSelector:@selector(sizeThatFits:resizeItems:)]) {
                    f1_size = [item sizeThatFits:limitSize resizeItems:resizeItems];
                } else if ([item respondsToSelector:@selector(sizeThatFits:)]) {
                    f1_size = [item sizeThatFits:limitSize];
                } else {
                    f1_size = [item sizeOfLayout];
                }
            } else {
                if ([item respondsToSelector:@selector(sizeThatFits:)]) {
                    f1_size = [item sizeThatFits:limitSize];
                } else if ([item respondsToSelector:@selector(sizeThatFits:resizeItems:)]) {
                    f1_size = [item sizeThatFits:limitSize resizeItems:resizeItems];
                } else {
                    f1_size = [item sizeOfLayout];
                }
            }
            if (!CGSizeEqualToSize(f1_size, CGSizeZero)) {
                is = NO;
                break;
            }
            f1.size.width = MIN(f1.size.width,f1_size.width);
            f1.size.height = MIN(f1.size.height,f1_size.height);
            LUICGRectSetLength(&f1, axis, MIN(LUICGSizeGetLength(limitSize, axis),LUICGRectGetLength(f1, axis)));
            LUICGSizeSetLength(&limitSize, axis, LUICGSizeGetLength(limitSize, axis)-(LUICGRectGetLength(f1, axis)+interitemSpacing));
            LUICGSizeSetLength(&limitSize, axis, MAX(0, LUICGSizeGetLength(limitSize, axis)));
        }
    } else {
        is = YES;
    }
    return is;
}
@end

LUIDEF_EnumTypeCategories(LUIFlowLayoutConstraintParam,
(@{
   @(LUIFlowLayoutConstraintParam_H_C_C):@"H_C_C",
   @(LUIFlowLayoutConstraintParam_H_C_L):@"H_C_L",
   @(LUIFlowLayoutConstraintParam_H_C_R):@"H_C_R",
   @(LUIFlowLayoutConstraintParam_H_T_C):@"H_T_C",
   @(LUIFlowLayoutConstraintParam_H_T_L):@"H_T_L",
   @(LUIFlowLayoutConstraintParam_H_T_R):@"H_T_R",
   @(LUIFlowLayoutConstraintParam_H_B_L):@"H_B_L",
   @(LUIFlowLayoutConstraintParam_H_B_C):@"H_B_C",
   @(LUIFlowLayoutConstraintParam_H_B_R):@"H_B_R",
   @(LUIFlowLayoutConstraintParam_V_C_C):@"V_C_C",
   @(LUIFlowLayoutConstraintParam_V_C_L):@"V_C_L",
   @(LUIFlowLayoutConstraintParam_V_C_R):@"V_C_R",
   @(LUIFlowLayoutConstraintParam_V_T_C):@"V_T_C",
   @(LUIFlowLayoutConstraintParam_V_T_L):@"V_T_L",
   @(LUIFlowLayoutConstraintParam_V_T_R):@"V_T_R",
   @(LUIFlowLayoutConstraintParam_V_B_C):@"V_B_C",
   @(LUIFlowLayoutConstraintParam_V_B_L):@"V_B_L",
   @(LUIFlowLayoutConstraintParam_V_B_R):@"V_B_R",
   }))
@implementation LUIFlowLayoutConstraint(InitMethod)
//////////////////////////////////////////////////////////////////////////////
+ (NSDictionary<NSNumber *,NSArray<NSNumber *> *> *)ConstraintParamMap {
    static NSDictionary<NSNumber *,NSArray<NSNumber *> *> * __share__;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        NSMutableDictionary<NSNumber *,NSArray<NSNumber *> *> *map = [[NSMutableDictionary alloc] init];
        map[@(LUIFlowLayoutConstraintParam_H_C_C)] = @[
          @(LUILayoutConstraintDirectionHorizontal),
          @(LUILayoutConstraintVerticalAlignmentCenter),
          @(LUILayoutConstraintHorizontalAlignmentCenter),
          ];
        map[@(LUIFlowLayoutConstraintParam_H_C_L)] = @[
          @(LUILayoutConstraintDirectionHorizontal),
          @(LUILayoutConstraintVerticalAlignmentCenter),
          @(LUILayoutConstraintHorizontalAlignmentLeft),
          ];
        map[@(LUIFlowLayoutConstraintParam_H_C_R)] = @[
          @(LUILayoutConstraintDirectionHorizontal),
          @(LUILayoutConstraintVerticalAlignmentCenter),
          @(LUILayoutConstraintHorizontalAlignmentRight),
          ];
        map[@(LUIFlowLayoutConstraintParam_H_T_C)] = @[
          @(LUILayoutConstraintDirectionHorizontal),
          @(LUILayoutConstraintVerticalAlignmentTop),
          @(LUILayoutConstraintHorizontalAlignmentCenter),
          ];
        map[@(LUIFlowLayoutConstraintParam_H_T_L)] = @[
          @(LUILayoutConstraintDirectionHorizontal),
          @(LUILayoutConstraintVerticalAlignmentTop),
          @(LUILayoutConstraintHorizontalAlignmentLeft),
          ];
        map[@(LUIFlowLayoutConstraintParam_H_T_R)] = @[
          @(LUILayoutConstraintDirectionHorizontal),
          @(LUILayoutConstraintVerticalAlignmentTop),
          @(LUILayoutConstraintHorizontalAlignmentRight),
          ];
        map[@(LUIFlowLayoutConstraintParam_H_B_L)] = @[
          @(LUILayoutConstraintDirectionHorizontal),
          @(LUILayoutConstraintVerticalAlignmentBottom),
          @(LUILayoutConstraintHorizontalAlignmentLeft),
          ];
        map[@(LUIFlowLayoutConstraintParam_H_B_C)] = @[
          @(LUILayoutConstraintDirectionHorizontal),
          @(LUILayoutConstraintVerticalAlignmentBottom),
          @(LUILayoutConstraintHorizontalAlignmentCenter),
          ];
        map[@(LUIFlowLayoutConstraintParam_H_B_R)] = @[
          @(LUILayoutConstraintDirectionHorizontal),
          @(LUILayoutConstraintVerticalAlignmentBottom),
          @(LUILayoutConstraintHorizontalAlignmentRight),
          ];
        map[@(LUIFlowLayoutConstraintParam_V_C_C)] = @[
          @(LUILayoutConstraintDirectionVertical),
          @(LUILayoutConstraintVerticalAlignmentCenter),
          @(LUILayoutConstraintHorizontalAlignmentCenter),
          ];
        map[@(LUIFlowLayoutConstraintParam_V_C_L)] = @[
          @(LUILayoutConstraintDirectionVertical),
          @(LUILayoutConstraintVerticalAlignmentCenter),
          @(LUILayoutConstraintHorizontalAlignmentLeft),
          ];
        map[@(LUIFlowLayoutConstraintParam_V_C_R)] = @[
          @(LUILayoutConstraintDirectionVertical),
          @(LUILayoutConstraintVerticalAlignmentCenter),
          @(LUILayoutConstraintHorizontalAlignmentRight),
          ];
        map[@(LUIFlowLayoutConstraintParam_V_T_C)] = @[
          @(LUILayoutConstraintDirectionVertical),
          @(LUILayoutConstraintVerticalAlignmentTop),
          @(LUILayoutConstraintHorizontalAlignmentCenter),
          ];
        map[@(LUIFlowLayoutConstraintParam_V_T_L)] = @[
          @(LUILayoutConstraintDirectionVertical),
          @(LUILayoutConstraintVerticalAlignmentTop),
          @(LUILayoutConstraintHorizontalAlignmentLeft),
          ];
        map[@(LUIFlowLayoutConstraintParam_V_T_R)] = @[
          @(LUILayoutConstraintDirectionVertical),
          @(LUILayoutConstraintVerticalAlignmentTop),
          @(LUILayoutConstraintHorizontalAlignmentRight),
          ];
        map[@(LUIFlowLayoutConstraintParam_V_B_C)] = @[
          @(LUILayoutConstraintDirectionVertical),
          @(LUILayoutConstraintVerticalAlignmentBottom),
          @(LUILayoutConstraintHorizontalAlignmentCenter),
          ];
        map[@(LUIFlowLayoutConstraintParam_V_B_L)] = @[
          @(LUILayoutConstraintDirectionVertical),
          @(LUILayoutConstraintVerticalAlignmentBottom),
          @(LUILayoutConstraintHorizontalAlignmentLeft),
          ];
        map[@(LUIFlowLayoutConstraintParam_V_B_R)] = @[
          @(LUILayoutConstraintDirectionVertical),
          @(LUILayoutConstraintVerticalAlignmentBottom),
          @(LUILayoutConstraintHorizontalAlignmentRight),
          ];
        __share__ = map;
    });
    return __share__;
}
+ (NSDictionary<NSArray<NSNumber *> *,NSNumber *> *)ConstraintParamRevertMap {
    static NSDictionary<NSArray<NSNumber *> *,NSNumber *> * __share__;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        NSDictionary<NSNumber *,NSArray<NSNumber *> *> *ConstraintParamMap = [self ConstraintParamMap];
        NSMutableDictionary<NSArray<NSNumber *> *,NSNumber *> *map = [[NSMutableDictionary alloc] initWithCapacity:ConstraintParamMap.count];
        for (NSNumber *key in ConstraintParamMap)  {
            map[ConstraintParamMap[key]] = key;
        }
        __share__ = map;
    });
    return __share__;
}
+ (void)parseConstraintParam:(LUIFlowLayoutConstraintParam)param layoutDirection:(LUILayoutConstraintDirection *)layoutDirection layoutVerticalAlignment:(LUILayoutConstraintVerticalAlignment *)layoutVerticalAlignment layoutHorizontalAlignment:(LUILayoutConstraintHorizontalAlignment *)layoutHorizontalAlignment {
    NSDictionary<NSNumber *,NSArray<NSNumber *> *> *ConstraintParamMap = [self.class ConstraintParamMap];
    NSArray<NSNumber *> *enums = ConstraintParamMap[@(param)];
    *layoutDirection = [enums[0] integerValue];
    *layoutVerticalAlignment = [enums[1] integerValue];
    *layoutHorizontalAlignment = [enums[2] integerValue];
}
+ (LUIFlowLayoutConstraintParam)constraintParamWithLayoutDirection:(LUILayoutConstraintDirection)layoutDirection layoutVerticalAlignment:(LUILayoutConstraintVerticalAlignment)layoutVerticalAlignment layoutHorizontalAlignment:(LUILayoutConstraintHorizontalAlignment)layoutHorizontalAlignment {
    NSDictionary<NSArray<NSNumber *> *,NSNumber *> *ConstraintParamRevertMap = [self.class ConstraintParamRevertMap];
    LUIFlowLayoutConstraintParam param = (LUIFlowLayoutConstraintParam)[ConstraintParamRevertMap[@[@(layoutDirection),@(layoutVerticalAlignment),@(layoutHorizontalAlignment)]] integerValue];
    return param;
}
//////////////////////////////////////////////////////////////////////////////
- (id)initWithItems:(NSArray<id<LUILayoutConstraintItemProtocol>> *)items constraintParam:(LUIFlowLayoutConstraintParam)param contentInsets:(UIEdgeInsets)contentInsets interitemSpacing:(CGFloat)interitemSpacing {
    if (self = [self init]) {
        self.items = items;
        self.contentInsets = contentInsets;
        self.interitemSpacing = interitemSpacing;
        [self configWithConstraintParam:param];
    }
    return self;
}
- (void)setConstraintParam:(LUIFlowLayoutConstraintParam)constraintParam {
    [self configWithConstraintParam:constraintParam];
}
- (LUIFlowLayoutConstraintParam)constraintParam {
    LUIFlowLayoutConstraintParam param = [self.class constraintParamWithLayoutDirection:self.layoutDirection layoutVerticalAlignment:self.layoutVerticalAlignment layoutHorizontalAlignment:self.layoutHorizontalAlignment];
    return param;
}
- (void)configWithConstraintParam:(LUIFlowLayoutConstraintParam)param {
    LUILayoutConstraintDirection layoutDirection;
    LUILayoutConstraintVerticalAlignment layoutVerticalAlignment;
    LUILayoutConstraintHorizontalAlignment layoutHorizontalAlignment;
    [self.class parseConstraintParam:param layoutDirection:&layoutDirection layoutVerticalAlignment:&layoutVerticalAlignment layoutHorizontalAlignment:&layoutHorizontalAlignment];
    self.layoutDirection = layoutDirection;
    self.layoutVerticalAlignment = layoutVerticalAlignment;
    self.layoutHorizontalAlignment = layoutHorizontalAlignment;
}
@end
