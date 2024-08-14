//
//  LUIWaterFlowLayoutConstraint.m
//  LUITool
//
//  Created by 六月 on 2024/8/14.
//

#import "LUIWaterFlowLayoutConstraint.h"
#import "LUILayoutConstraintItemAttributeBase.h"

@interface LUIWaterFlowLayoutConstraint ()

@property (nonatomic,strong) LUILayoutConstraintItemAttributeSection *itemAttributeSection;

@end

@implementation LUIWaterFlowLayoutConstraint

- (LUICGAxis)layoutDirectionAxis {
    LUICGAxis X = self.layoutDirection == LUILayoutConstraintDirectionHorizontal?LUICGAxisX:LUICGAxisY;
    return X;
}
- (CGSize)itemSizeForItem:(id<LUILayoutConstraintItemProtocol>)item thatFits:(CGSize)size resizeItems:(BOOL)resizeItems {
    if (size.width<=0 || size.height<=0) {
        return CGSizeZero;
    }
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

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize sizeFits = [self sizeThatFits:size resizeItems:NO];
    return sizeFits;
}
- (nullable LUILayoutConstraintItemAttributeSection *)itemAttributeSectionThatFits:(CGSize)size resizeItems:(BOOL)resizeItems {
    NSArray *items = self.layoutedItems;
    NSInteger count = items.count;
    if (count == 0) return nil;
    LUILayoutConstraintItemAttributeSection *allLines = [[LUILayoutConstraintItemAttributeSection alloc] init];
    
    LUICGAxis X = [self layoutDirectionAxis];
    LUICGAxis Y = LUICGAxisReverse(X);
    
    UIEdgeInsets contentInsets = self.contentInsets;
    
    CGFloat xSpacing = X == LUICGAxisX?self.interitemSpacing:self.lineSpacing;
    CGFloat ySpacing = X == LUICGAxisX?self.lineSpacing:self.interitemSpacing;
    
    CGSize originLimitSize = CGSizeMake(size.width-contentInsets.left-contentInsets.right, size.height-contentInsets.top-contentInsets.bottom);//限制在 size -contentInsets 矩形内
    CGFloat originLimitWidth = LUICGSizeGetLength(originLimitSize, X);
    CGFloat originLimitHeight = LUICGSizeGetLength(originLimitSize, Y);
    
    //超出上限的元素，都放在第maxLines行（有效行是[0,maxLines-1]）
    NSInteger maxLines =  self.maxLines;
    CGSize lastLineItemSize = CGSizeZero;
    BOOL hadLastLineItem = NO;
    if (self.lastLineItem!=nil) {
        hadLastLineItem = YES;
        lastLineItemSize = [self itemSizeForItem:self.lastLineItem thatFits:originLimitSize resizeItems:resizeItems];
    }
    LUILayoutConstraintItemAttributeSection *overLine = [[LUILayoutConstraintItemAttributeSection alloc] init];//存放超出的行
    
    CGSize limitSize = originLimitSize;
    //以下类命名，以水平流动时为基准
    
    CGRect f1 = CGRectZero;
    LUILayoutConstraintItemAttributeSection *line = [[LUILayoutConstraintItemAttributeSection alloc] init];
    NSInteger effectCountAtOneLine = 0;
    NSInteger lineIndex = 0;
    for(int i=0;i<items.count;i++) {
        BOOL isLast = i == items.count-1;
        id<LUILayoutConstraintItemProtocol> item = items[i];
        
        if (maxLines>0 && lineIndex>=maxLines) {//元素都添加到超出行
            LUILayoutConstraintItemAttribute *itemAttr = [[LUILayoutConstraintItemAttribute alloc] initWithItem:item];
            itemAttr.size = CGSizeZero;
            [overLine addItemAttribute:itemAttr];
            continue;
        }
        
        CGFloat limitWidth = LUICGSizeGetLength(limitSize, X);
        
        CGSize itemSize = [self itemSizeForItem:item thatFits:limitSize resizeItems:resizeItems];
        CGFloat h = LUICGSizeGetLength(itemSize, Y);
        CGFloat w = LUICGSizeGetLength(itemSize, X);
        
        if (w>limitWidth && effectCountAtOneLine>0) {//当前行剩余空间不足以容纳item，且非第一个有效元素时，换行
            line.size = [line sizeThatFlowLayoutItemsWithSpacing:xSpacing axis:X];
            CGFloat maxRowHeight = LUICGRectGetLength(line.layoutFrame, Y);
            [allLines addItemAttribute:line];
            lineIndex++;
            
            if (maxLines>0 && lineIndex>=maxLines) {//超出行数限制,指针回退，将元素都添加到overLine
                i--;
                continue;
            }
            
            line = [[LUILayoutConstraintItemAttributeSection alloc] init];
            effectCountAtOneLine = 0;
            LUICGRectAddMin(&f1, Y, maxRowHeight+ySpacing);
            LUICGRectSetMin(&f1, X, 0);
            LUICGSizeSetLength(&limitSize, X, originLimitWidth);
            LUICGSizeSetLength(&limitSize, Y, originLimitHeight-LUICGRectGetMin(f1, Y));
            
            //指针回退，重新再算一次
            i--;
            continue;
        }
        
        f1.size = itemSize;
        if (w>limitWidth) {//限制元素不能超出容器
            LUICGRectAddLength(&f1, X, -(w-limitWidth));
        }
        
        if (w>0 && h>0) {
            LUICGRectSetMin(&f1, X, LUICGRectGetMax(f1, X)+xSpacing);
            limitWidth = MAX(0,limitWidth-w-xSpacing);
            effectCountAtOneLine++;
        }
        
        LUILayoutConstraintItemAttribute *itemAttr = [[LUILayoutConstraintItemAttribute alloc] initWithItem:item];
        itemAttr.size = f1.size;
        [line addItemAttribute:itemAttr];
        
        if (limitWidth<=0 || isLast) {//容器剩余尺寸为0时换行，或者到最后一个元素
            line.size = [line sizeThatFlowLayoutItemsWithSpacing:xSpacing axis:X];
            CGFloat maxRowHeight = LUICGRectGetLength(line.layoutFrame, Y);
            [allLines addItemAttribute:line];
            lineIndex++;
            
            if (maxLines>0 && lineIndex>=maxLines) {//超出行数限制将后续元素都添加到overLine
                continue;
            }
            
            line = [[LUILayoutConstraintItemAttributeSection alloc] init];
            effectCountAtOneLine = 0;
            LUICGRectAddMin(&f1, Y, maxRowHeight+ySpacing);
            LUICGRectSetMin(&f1, X, 0);
            LUICGSizeSetLength(&limitSize, X, originLimitWidth);
            LUICGSizeSetLength(&limitSize, Y, originLimitHeight-LUICGRectGetMin(f1, Y));
        } else {
            LUICGSizeSetLength(&limitSize, X, limitWidth);
        }
    }
    
    LUILayoutConstraintItemAttributeSection *lastLine = allLines.itemAttributs.lastObject;
    if (lastLine && hadLastLineItem) {
        BOOL needAddLastItem = maxLines>0 && ( overLine.itemAttributs.count>0  ||  self.showLastLineItemWithinMaxLine);
        
        if (needAddLastItem) {
            LUILayoutConstraintItemAttribute *lastLineItemAttr = [[LUILayoutConstraintItemAttribute alloc] initWithItem:self.lastLineItem];
            lastLineItemAttr.size = lastLineItemSize;
            //将lastItem添加到最后一行，同时最后一行元素的布局，并没有扣掉lastItem的尺寸，因此整个最后一行都要重新布局
            NSArray<id<LUILayoutConstraintItemAttributeProtocol> > *itemAttributs = lastLine.itemAttributs;
            CGSize limitSize = lastLine.layoutFrame.size;
            CGFloat lastLineItemWidth = LUICGSizeGetLength(lastLineItemSize, X);
            for(NSInteger i=itemAttributs.count-1;i>=0;i--) {
                LUILayoutConstraintItemAttribute *itemAttr = itemAttributs[i];
                CGSize itemSize = itemAttr.size;
                if (CGSizeEqualToSize(itemSize, CGSizeZero)) {//空尺寸跳过
                    continue;
                }
                CGFloat limitWidth = LUICGSizeGetLength(itemSize, X)+LUICGSizeGetLength(originLimitSize, X)-LUICGSizeGetLength(limitSize, X)-xSpacing-lastLineItemWidth;//容器尺寸扣除掉lastItem尺寸
                LUICGSizeSetLength(&limitSize, X,limitWidth);
                if (LUICGSizeGetLength(itemSize, X)>limitWidth) {
                    //扣除掉lastItem尺寸之后，剩余空间不足以容纳itemSize，需要重新计算itemSize
                    itemSize = [self itemSizeForItem:(id<LUILayoutConstraintItemProtocol>)itemAttr.item thatFits:limitSize resizeItems:resizeItems];
                }
                CGFloat w = LUICGSizeGetLength(itemSize, X);
                if (w>limitWidth) {
                    if (maxLines>0 && allLines.itemAttributs.count>=maxLines) {//设置为不显示
                        itemAttr.size = CGSizeZero;//移入overLine中
                        [lastLine removeItemAttributeAtIndex:i];
                        [overLine insertItemAttribute:itemAttr atIndex:0];
                        continue;
                    } else {
                        //另起一行放lastLineItem
                        LUILayoutConstraintItemAttributeSection *newLine = [[LUILayoutConstraintItemAttributeSection alloc] init];
                        [newLine addItemAttribute:lastLineItemAttr];
                        newLine.size = [newLine sizeThatFlowLayoutItemsWithSpacing:xSpacing axis:X];
                        [allLines addItemAttribute:newLine];
                        break;
                    }
                } else {
                    itemAttr.size = itemSize;
                }
                [lastLine addItemAttribute:lastLineItemAttr];
                lastLine.size = [lastLine sizeThatFlowLayoutItemsWithSpacing:xSpacing axis:X];
                break;
            }
        }
        
        if (overLine.itemAttributs.count>0) {
            [allLines addItemAttribute:overLine];
        }
    }
    
    allLines.size = [allLines sizeThatFlowLayoutItemsWithSpacing:ySpacing axis:Y];
    return allLines;
}
- (BOOL)overMaxLines {
    BOOL overMaxLines = self.maxLines>0 && self.itemAttributeSection.itemAttributs.count>self.maxLines;
    return overMaxLines;
}
- (CGSize)sizeThatFits:(CGSize)size resizeItems:(BOOL)resizeItems {
    CGSize sizeFits = CGSizeZero;
    UIEdgeInsets contentInsets = self.contentInsets;
    LUILayoutConstraintItemAttributeSection *allLines = [self itemAttributeSectionThatFits:size resizeItems:resizeItems];
    sizeFits = allLines.layoutFrame.size;
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
    BOOL needRevert = (self.layoutDirection == LUILayoutConstraintDirectionHorizontal&&self.layoutHorizontalAlignment == LUILayoutConstraintHorizontalAlignmentRight)
     || (self.layoutDirection == LUILayoutConstraintDirectionVertical&&self.layoutVerticalAlignment == LUILayoutConstraintVerticalAlignmentBottom)
    ;
    
    LUILayoutConstraintItemAttributeSection *allLines = [self itemAttributeSectionThatFits:size resizeItems:resizeItems];
    LUICGAxis X = [self layoutDirectionAxis];
    LUICGAxis Y = LUICGAxisReverse(X);
    
    UIEdgeInsets contentInsets = self.contentInsets;
    
    CGFloat xSpacing = X == LUICGAxisX?self.interitemSpacing:self.lineSpacing;
    CGFloat ySpacing = X == LUICGAxisX?self.lineSpacing:self.interitemSpacing;
    
    LUICGRectAlignment alignX = self.layoutDirection == LUILayoutConstraintDirectionVertical?LUICGRectAlignmentFromLUILayoutConstraintVerticalAlignment(self.layoutVerticalAlignment):LUICGRectAlignmentFromLUILayoutConstraintHorizontalAlignment(self.layoutHorizontalAlignment);
    LUICGRectAlignment alignY = self.layoutDirection == LUILayoutConstraintDirectionHorizontal?LUICGRectAlignmentFromLUILayoutConstraintVerticalAlignment(self.layoutVerticalAlignment):LUICGRectAlignmentFromLUILayoutConstraintHorizontalAlignment(self.layoutHorizontalAlignment);
    
    CGRect bounds = UIEdgeInsetsInsetRect(self.bounds, contentInsets);
    CGRect f1 = allLines.layoutFrame;
    LUICGRectAlignToRect(&f1, Y, alignY, bounds);
    LUICGRectAlignToRect(&f1, X, alignX, bounds);
    allLines.layoutFrame = f1;
    
    BOOL applyLastItemFrame = NO;
    [allLines flowLayoutItemsWithSpacing:ySpacing axis:Y alignment:alignX needRevert:NO];
    for(LUILayoutConstraintItemAttributeSection *line in allLines.itemAttributs) {
        [line flowLayoutItemsWithSpacing:xSpacing axis:X alignment:alignY needRevert:needRevert];
        for(LUILayoutConstraintItemAttribute *itemAttr in line.itemAttributs) {
            [itemAttr applyAttributeWithResizeItems:resizeItems];
            if (itemAttr.item == self.lastLineItem) {
                applyLastItemFrame = YES;
            }
        }
    }
    if (self.lastLineItem && !applyLastItemFrame) {
        CGRect f1 = self.lastLineItem.layoutFrame;
        f1.size = CGSizeZero;
        self.lastLineItem.layoutFrame = f1;
    }
    self.itemAttributeSection = allLines;
}
@end

LUIDEF_EnumTypeCategories(LUIWaterFlowLayoutConstraintParam,
(@ {
   @(LUIWaterFlowLayoutConstraintParam_H_C_C):@"H_C_C",
   @(LUIWaterFlowLayoutConstraintParam_H_C_L):@"H_C_L",
   @(LUIWaterFlowLayoutConstraintParam_H_C_R):@"H_C_R",
   @(LUIWaterFlowLayoutConstraintParam_H_T_C):@"H_T_C",
   @(LUIWaterFlowLayoutConstraintParam_H_T_L):@"H_T_L",
   @(LUIWaterFlowLayoutConstraintParam_H_T_R):@"H_T_R",
   @(LUIWaterFlowLayoutConstraintParam_H_B_L):@"H_B_L",
   @(LUIWaterFlowLayoutConstraintParam_H_B_C):@"H_B_C",
   @(LUIWaterFlowLayoutConstraintParam_H_B_R):@"H_B_R",
   @(LUIWaterFlowLayoutConstraintParam_V_C_C):@"V_C_C",
   @(LUIWaterFlowLayoutConstraintParam_V_C_L):@"V_C_L",
   @(LUIWaterFlowLayoutConstraintParam_V_C_R):@"V_C_R",
   @(LUIWaterFlowLayoutConstraintParam_V_T_C):@"V_T_C",
   @(LUIWaterFlowLayoutConstraintParam_V_T_L):@"V_T_L",
   @(LUIWaterFlowLayoutConstraintParam_V_T_R):@"V_T_R",
   @(LUIWaterFlowLayoutConstraintParam_V_B_C):@"V_B_C",
   @(LUIWaterFlowLayoutConstraintParam_V_B_L):@"V_B_L",
   @(LUIWaterFlowLayoutConstraintParam_V_B_R):@"V_B_R",
   }))

@implementation LUIWaterFlowLayoutConstraint(InitMethod)
//////////////////////////////////////////////////////////////////////////////
+ (NSDictionary<NSNumber *,NSArray<NSNumber *> *> *)ConstraintParamMap {
    static NSDictionary<NSNumber *,NSArray<NSNumber *> *> * __share__;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        NSMutableDictionary<NSNumber *,NSArray<NSNumber *> *> *map = [[NSMutableDictionary alloc] init];
        map[@(LUIWaterFlowLayoutConstraintParam_H_C_C)] = @[
          @(LUILayoutConstraintDirectionHorizontal),
          @(LUILayoutConstraintVerticalAlignmentCenter),
          @(LUILayoutConstraintHorizontalAlignmentCenter),
          ];
        map[@(LUIWaterFlowLayoutConstraintParam_H_C_L)] = @[
          @(LUILayoutConstraintDirectionHorizontal),
          @(LUILayoutConstraintVerticalAlignmentCenter),
          @(LUILayoutConstraintHorizontalAlignmentLeft),
          ];
        map[@(LUIWaterFlowLayoutConstraintParam_H_C_R)] = @[
          @(LUILayoutConstraintDirectionHorizontal),
          @(LUILayoutConstraintVerticalAlignmentCenter),
          @(LUILayoutConstraintHorizontalAlignmentRight),
          ];
        map[@(LUIWaterFlowLayoutConstraintParam_H_T_C)] = @[
          @(LUILayoutConstraintDirectionHorizontal),
          @(LUILayoutConstraintVerticalAlignmentTop),
          @(LUILayoutConstraintHorizontalAlignmentCenter),
          ];
        map[@(LUIWaterFlowLayoutConstraintParam_H_T_L)] = @[
          @(LUILayoutConstraintDirectionHorizontal),
          @(LUILayoutConstraintVerticalAlignmentTop),
          @(LUILayoutConstraintHorizontalAlignmentLeft),
          ];
        map[@(LUIWaterFlowLayoutConstraintParam_H_T_R)] = @[
          @(LUILayoutConstraintDirectionHorizontal),
          @(LUILayoutConstraintVerticalAlignmentTop),
          @(LUILayoutConstraintHorizontalAlignmentRight),
          ];
        map[@(LUIWaterFlowLayoutConstraintParam_H_B_L)] = @[
          @(LUILayoutConstraintDirectionHorizontal),
          @(LUILayoutConstraintVerticalAlignmentBottom),
          @(LUILayoutConstraintHorizontalAlignmentLeft),
          ];
        map[@(LUIWaterFlowLayoutConstraintParam_H_B_C)] = @[
          @(LUILayoutConstraintDirectionHorizontal),
          @(LUILayoutConstraintVerticalAlignmentBottom),
          @(LUILayoutConstraintHorizontalAlignmentCenter),
          ];
        map[@(LUIWaterFlowLayoutConstraintParam_H_B_R)] = @[
          @(LUILayoutConstraintDirectionHorizontal),
          @(LUILayoutConstraintVerticalAlignmentBottom),
          @(LUILayoutConstraintHorizontalAlignmentRight),
          ];
        map[@(LUIWaterFlowLayoutConstraintParam_V_C_C)] = @[
          @(LUILayoutConstraintDirectionVertical),
          @(LUILayoutConstraintVerticalAlignmentCenter),
          @(LUILayoutConstraintHorizontalAlignmentCenter),
          ];
        map[@(LUIWaterFlowLayoutConstraintParam_V_C_L)] = @[
          @(LUILayoutConstraintDirectionVertical),
          @(LUILayoutConstraintVerticalAlignmentCenter),
          @(LUILayoutConstraintHorizontalAlignmentLeft),
          ];
        map[@(LUIWaterFlowLayoutConstraintParam_V_C_R)] = @[
          @(LUILayoutConstraintDirectionVertical),
          @(LUILayoutConstraintVerticalAlignmentCenter),
          @(LUILayoutConstraintHorizontalAlignmentRight),
          ];
        map[@(LUIWaterFlowLayoutConstraintParam_V_T_C)] = @[
          @(LUILayoutConstraintDirectionVertical),
          @(LUILayoutConstraintVerticalAlignmentTop),
          @(LUILayoutConstraintHorizontalAlignmentCenter),
          ];
        map[@(LUIWaterFlowLayoutConstraintParam_V_T_L)] = @[
          @(LUILayoutConstraintDirectionVertical),
          @(LUILayoutConstraintVerticalAlignmentTop),
          @(LUILayoutConstraintHorizontalAlignmentLeft),
          ];
        map[@(LUIWaterFlowLayoutConstraintParam_V_T_R)] = @[
          @(LUILayoutConstraintDirectionVertical),
          @(LUILayoutConstraintVerticalAlignmentTop),
          @(LUILayoutConstraintHorizontalAlignmentRight),
          ];
        map[@(LUIWaterFlowLayoutConstraintParam_V_B_C)] = @[
          @(LUILayoutConstraintDirectionVertical),
          @(LUILayoutConstraintVerticalAlignmentBottom),
          @(LUILayoutConstraintHorizontalAlignmentCenter),
          ];
        map[@(LUIWaterFlowLayoutConstraintParam_V_B_L)] = @[
          @(LUILayoutConstraintDirectionVertical),
          @(LUILayoutConstraintVerticalAlignmentBottom),
          @(LUILayoutConstraintHorizontalAlignmentLeft),
          ];
        map[@(LUIWaterFlowLayoutConstraintParam_V_B_R)] = @[
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
+ (void)parseConstraintParam:(LUIWaterFlowLayoutConstraintParam)param layoutDirection:(LUILayoutConstraintDirection *)layoutDirection layoutVerticalAlignment:(LUILayoutConstraintVerticalAlignment *)layoutVerticalAlignment layoutHorizontalAlignment:(LUILayoutConstraintHorizontalAlignment *)layoutHorizontalAlignment {
    NSDictionary<NSNumber *,NSArray<NSNumber *> *> *ConstraintParamMap = [self.class ConstraintParamMap];
    NSArray<NSNumber *> *enums = ConstraintParamMap[@(param)];
    *layoutDirection = [enums[0] integerValue];
    *layoutVerticalAlignment = [enums[1] integerValue];
    *layoutHorizontalAlignment = [enums[2] integerValue];
}
+ (LUIWaterFlowLayoutConstraintParam)constraintParamWithLayoutDirection:(LUILayoutConstraintDirection)layoutDirection layoutVerticalAlignment:(LUILayoutConstraintVerticalAlignment)layoutVerticalAlignment layoutHorizontalAlignment:(LUILayoutConstraintHorizontalAlignment)layoutHorizontalAlignment {
    NSDictionary<NSArray<NSNumber *> *,NSNumber *> *ConstraintParamRevertMap = [self.class ConstraintParamRevertMap];
    LUIWaterFlowLayoutConstraintParam param = (LUIWaterFlowLayoutConstraintParam)[ConstraintParamRevertMap[@[@(layoutDirection),@(layoutVerticalAlignment),@(layoutHorizontalAlignment)]] integerValue];
    return param;
}
//////////////////////////////////////////////////////////////////////////////
- (id)initWithItems:(NSArray<id<LUILayoutConstraintItemProtocol>> *)items constraintParam:(LUIWaterFlowLayoutConstraintParam)param contentInsets:(UIEdgeInsets)contentInsets interitemSpacing:(CGFloat)interitemSpacing lineSpacing:(CGFloat)lineSpacing {
    if (self = [self init]) {
        self.items = items;
        self.contentInsets = contentInsets;
        self.interitemSpacing = interitemSpacing;
        self.lineSpacing = lineSpacing;
        [self configWithConstraintParam:param];
    }
    return self;
}
- (void)setConstraintParam:(LUIWaterFlowLayoutConstraintParam)constraintParam {
    [self configWithConstraintParam:constraintParam];
}
- (LUIWaterFlowLayoutConstraintParam)constraintParam {
    LUIWaterFlowLayoutConstraintParam param = [self.class constraintParamWithLayoutDirection:self.layoutDirection layoutVerticalAlignment:self.layoutVerticalAlignment layoutHorizontalAlignment:self.layoutHorizontalAlignment];
    return param;
}
- (void)configWithConstraintParam:(LUIWaterFlowLayoutConstraintParam)param {
    LUILayoutConstraintDirection layoutDirection;
    LUILayoutConstraintVerticalAlignment layoutVerticalAlignment;
    LUILayoutConstraintHorizontalAlignment layoutHorizontalAlignment;
    [self.class parseConstraintParam:param layoutDirection:&layoutDirection layoutVerticalAlignment:&layoutVerticalAlignment layoutHorizontalAlignment:&layoutHorizontalAlignment];
    self.layoutDirection = layoutDirection;
    self.layoutVerticalAlignment = layoutVerticalAlignment;
    self.layoutHorizontalAlignment = layoutHorizontalAlignment;
}

@end
