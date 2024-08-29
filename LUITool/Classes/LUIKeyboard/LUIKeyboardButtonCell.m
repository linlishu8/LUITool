//
//  LUIKeyboardButtonCell.m
//  LUITool
//
//  Created by 六月 on 2024/8/19.
//

#import "LUIKeyboardButtonCell.h"
#import "LUIFlowLayoutConstraint.h"
#import "LUIKeyboardButtonModel.h"
#import "UICollectionViewFlowLayout+LUI.h"
#import "LUILayoutConstraintItemWrapper.h"
#import "LUIKeyBoardSectionModel.h"
#import "LUILayoutButton.h"

@interface LUIKeyboardButtonCell()

@property (nonatomic, strong) LUILayoutButton *cellButton;
@property (nonatomic, strong) LUIFlowLayoutConstraint *flowlayout;

@end

@implementation LUIKeyboardButtonCell
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self.contentView addSubview:self.cellButton];
        self.flowlayout = [[LUIFlowLayoutConstraint alloc] initWithItems:@[self.cellButton] constraintParam:LUIFlowLayoutConstraintParam_H_C_C contentInsets:UIEdgeInsetsZero interitemSpacing:0];
    }
    return self;
}

- (void)customReloadCellModel {
    [super customReloadCellModel];
    
    LUIKeyboardButtonModel *buttonModel = self.collectionCellModel.modelValue;
    if (!buttonModel) return;
    if (buttonModel.title.length > 0) [self.cellButton setTitle:buttonModel.title forState:UIControlStateNormal];
    [self.cellButton setTitleColor:buttonModel.titleColor ? : UIColor.blackColor forState:UIControlStateNormal];
    if (buttonModel.backgroundImage) {
        [self.cellButton setBackgroundImage:buttonModel.backgroundImage forState:UIControlStateNormal];
    } else if (buttonModel.backgroundColor) {
        [self.cellButton setBackgroundColor:buttonModel.backgroundColor];
    }
}

- (void)applyCornerRadii:(LUICornerRadiiConfiguration *)cornerRadii toView:(UIView *)view {
    if (!cornerRadii) return;
    // 创建路径来定义按钮的圆角
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    // 处理四个角的圆角
    [path moveToPoint:CGPointMake(view.bounds.size.width - cornerRadii.topRight, 0)];
    [path addArcWithCenter:CGPointMake(view.bounds.size.width - cornerRadii.topRight, cornerRadii.topRight)
                    radius:cornerRadii.topRight startAngle:-M_PI_2 endAngle:0 clockwise:YES];
    
    [path addArcWithCenter:CGPointMake(view.bounds.size.width - cornerRadii.bottomRight, view.bounds.size.height - cornerRadii.bottomRight)
                    radius:cornerRadii.bottomRight startAngle:0 endAngle:M_PI_2 clockwise:YES];
    
    [path addArcWithCenter:CGPointMake(cornerRadii.bottomLeft, view.bounds.size.height - cornerRadii.bottomLeft)
                    radius:cornerRadii.bottomLeft startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    
    [path addArcWithCenter:CGPointMake(cornerRadii.topLeft, cornerRadii.topLeft)
                    radius:cornerRadii.topLeft startAngle:M_PI endAngle:-M_PI_2 clockwise:YES];
    
    [path closePath];
    
    // 设置遮罩层，应用圆角
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = path.CGPath;
    view.layer.mask = maskLayer;
}

- (void)addBorderToLayer:(CALayer *)layer withConfiguration:(LUIBorderConfiguration *)config startPoint:(CGPoint)start endPoint:(CGPoint)end {
    if (!config || config.width == 0) return;
    
    CAShapeLayer *border = [CAShapeLayer layer];
    border.strokeColor = config.color.CGColor;
    border.lineWidth = config.width;
    border.fillColor = nil;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:start];
    [path addLineToPoint:end];
    border.path = path.CGPath;
    [layer addSublayer:border];
}

- (void)customLayoutSubviews {
    [super customLayoutSubviews];
    
    CGRect bounds = self.contentView.bounds;
    
    self.flowlayout.bounds = bounds;
    [self.flowlayout layoutItemsWithResizeItems:YES];
    
    LUIKeyboardButtonModel *buttonModel = self.collectionCellModel.modelValue;
    CGRect f = bounds;
    if (!UIEdgeInsetsEqualToEdgeInsets(buttonModel.marginInsets, UIEdgeInsetsZero)) {
        f = UIEdgeInsetsInsetRect(bounds, buttonModel.marginInsets);
    }
    
    self.cellButton.frame = f;
    
    // 为四个角分别设置圆角
    [self applyCornerRadii:buttonModel.cornerRadii toView:self.cellButton];
    [self addBorderWithButtonModel:buttonModel];
}

- (void)addBorderWithButtonModel:(LUIKeyboardButtonModel *)buttonModel {
    // 为四边分别设置边框
    [self addBorderToLayer:self.contentView.layer
         withConfiguration:buttonModel.topBorder
                startPoint:CGPointMake(0, 0)
                  endPoint:CGPointMake(self.cellButton.frame.size.width, 0)];

    [self addBorderToLayer:self.contentView.layer
         withConfiguration:buttonModel.leftBorder
                startPoint:CGPointMake(0, 0)
                  endPoint:CGPointMake(0, self.cellButton.frame.size.height)];

    [self addBorderToLayer:self.contentView.layer
         withConfiguration:buttonModel.bottomBorder
                startPoint:CGPointMake(0, self.cellButton.frame.size.height)
                  endPoint:CGPointMake(self.cellButton.frame.size.width, self.cellButton.frame.size.height)];

    [self addBorderToLayer:self.contentView.layer
         withConfiguration:buttonModel.rightBorder
                startPoint:CGPointMake(self.cellButton.frame.size.width, 0)
                  endPoint:CGPointMake(self.cellButton.frame.size.width, self.cellButton.frame.size.height)];
}

- (CGSize)customSizeThatFits:(CGSize)size {
    LUIKeyBoardSectionModel *sectionModel = (LUIKeyBoardSectionModel *)self.collectionCellModel.sectionModel;
    CGSize s = [self.flowlayout sizeThatFits:size resizeItems:YES];
    LUIKeyboardButtonModel *buttonModel = self.collectionCellModel.modelValue;
    if (buttonModel.buttonWidth == 0) {
        NSInteger count = self.collectionCellModel.sectionModel.numberOfCells;
        CGFloat space = self.collectionCellModel.collectionView.l_collectionViewFlowLayout.minimumInteritemSpacing;
        CGFloat totalSpacing = (count - 1) * space;
        CGFloat availableWidth = size.width - totalSpacing;
        if (count) {
            s.width = floor(((size.width - sectionModel.l_otherLength)-(count-1)*space)/(count - sectionModel.l_numberOfOtherButtons));
            CGFloat remainingWidth = availableWidth - (s.width * count);
            if ((self.collectionCellModel.indexPathInModel.item + 1) % count == 0) {
                s.width += remainingWidth;
            }
        }
    } else {
        s.width = buttonModel.buttonWidth;
    }
    if (sectionModel.l_maxHeight > 0) {
        s.height = sectionModel.l_maxHeight;
    }
    return s;
}

#pragma mark - getters/setters

- (LUILayoutButton *)cellButton {
    if (!_cellButton) {
        _cellButton = [[LUILayoutButton alloc] init];
    }
    return _cellButton;
}

@end
