//
//  LUIItemFlowView.m
//  LUITool_Example
//
//  Created by 六月 on 2023/9/9.
//  Copyright © 2024 Your Name. All rights reserved.
//

#import "LUIItemFlowView.h"
#import "LUItemVerticalLineView.h"

@interface LUIItemFlowView ()
@property (nonatomic, strong) LUIFlowLayoutConstraint *flowlayout;
@end

@implementation LUIItemFlowView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = UIColor.whiteColor;
        [self addSubview:self.directionButton];
        //
        [self addSubview:self.itemFlowView];
        LUILayoutConstraintItemWrapper *itemWrapper = [LUILayoutConstraintItemWrapper wrapItem:self.itemFlowView sizeThatFitsBlock:^CGSize(LUILayoutConstraintItemWrapper * _Nonnull wrapper, CGSize size, BOOL resizeItems) {
            return size;
        }];
        self.flowlayout = [[LUIFlowLayoutConstraint alloc] initWithItems:@[self.directionButton, itemWrapper] constraintParam:(LUIFlowLayoutConstraintParam_H_C_L) contentInsets:UIEdgeInsetsZero interitemSpacing:10];
        [self __configDirection];
    }
    return self;
}

- (void)setDirectionVertical:(BOOL)directionVertical{
    _directionVertical = directionVertical;
    [self __configDirection];
    [self setNeedsLayout];
}

- (void)__configDirection {
    self.directionButton.selected = self.directionVertical;
    self.flowlayout.constraintParam = self.directionVertical ? LUIFlowLayoutConstraintParam_V_T_C : LUIFlowLayoutConstraintParam_H_C_L;
    self.itemFlowView.scrollDirection = self.directionVertical ? LUItemFlowCollectionViewScrollDirectionVertical : LUItemFlowCollectionViewScrollDirectionHorizontal;
    self.itemFlowView.separatorSize = self.directionVertical ? CGSizeMake(60, 1):CGSizeMake(1, 30);
    self.itemFlowView.itemIndicatorViewClass = self.directionVertical ? LUItemVerticalLineView.class : LUItemFlowIndicatorLineView.class;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        safeAreaInsets = self.safeAreaInsets;
    }
    UIEdgeInsets insets = UIEdgeInsetsZero;
    if (self.directionVertical) {
        insets.bottom = safeAreaInsets.bottom;
    }
    self.itemFlowView.collectionView.contentInset = insets;
    
    self.flowlayout.bounds = bounds;
    [self.flowlayout layoutItemsWithResizeItems:YES];
}
+ (CGFloat)sizeWithDirectionVertical:(BOOL)directionVertical {
    return directionVertical ? 90 : 50;//横向时，高度为50；竖向时，宽度为90
}

#pragma mark - getters/setters

- (LUILayoutButton *)directionButton {
    if (!_directionButton) {
        _directionButton = [[LUILayoutButton alloc] init];
        _directionButton.contentInsets = LUIEdgeInsetsMakeSameEdge(10);
        [_directionButton setTitleColor:[UIColor l_colorWithLight:UIColor.blackColor] forState:(UIControlStateNormal)];
        [_directionButton setTitle:@"横向" forState:(UIControlStateNormal)];
        [_directionButton setTitle:@"纵向" forState:(UIControlStateSelected)];
        _directionButton.backgroundColor = UIColor.whiteColor;
    }
    return _directionButton;
}

- (LUItemFlowCollectionView *)itemFlowView {
    if (!_itemFlowView) {
        _itemFlowView = [[LUItemFlowCollectionView alloc] init];
        _itemFlowView.separatorViewClass = LUItemFlowSeparatorView.class;
        _itemFlowView.separatorColor = UIColor.blackColor;
        _itemFlowView.separatorSize = self.directionVertical ? CGSizeMake(60, 1):CGSizeMake(1, 30);
        _itemFlowView.scrollDirection = LUItemFlowCollectionViewScrollDirectionHorizontal;
        _itemFlowView.selectedIndex = 0;
        [_itemFlowView scrollItemIndicatorViewToIndex:_itemFlowView.selectedIndex animated:NO];
        _itemFlowView.backgroundColor = UIColor.grayColor;
        _itemFlowView.itemIndicatorViewClass = self.directionVertical ? LUItemVerticalLineView.class : LUItemFlowIndicatorLineView.class;
        LUItemFlowIndicatorLineView *itemIndicatorView = _itemFlowView.itemIndicatorLineView;
        itemIndicatorView.indicatorLineMarggin = 3;
    }
    return _itemFlowView;
}

@end
