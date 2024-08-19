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

@interface LUIKeyboardButtonCell()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) LUIFlowLayoutConstraint *flowlayout;

@end

@implementation LUIKeyboardButtonCell
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self.contentView addSubview:self.titleLabel];
        
        LUILayoutConstraintItemWrapper *labelWrapper = [LUILayoutConstraintItemWrapper wrapItem:self.titleLabel sizeThatFitsBlock:^CGSize(LUILayoutConstraintItemWrapper * _Nonnull wrapper, CGSize size, BOOL resizeItems) {
            CGSize s = [wrapper.originItem sizeThatFits:size];
            s.width = size.width;
            return s;
        }];
        
        self.flowlayout = [[LUIFlowLayoutConstraint alloc] initWithItems:@[labelWrapper] constraintParam:LUIFlowLayoutConstraintParam_H_C_C contentInsets:UIEdgeInsetsZero interitemSpacing:0];
    }
    return self;
}

- (void)customReloadCellModel {
    [super customReloadCellModel];
    
    LUIKeyboardButtonModel *buttonModel = self.collectionCellModel.modelValue;
    self.titleLabel.text = buttonModel.title;
    self.titleLabel.textColor = buttonModel.titleColor ? : UIColor.blackColor;
}

- (void)customLayoutSubviews {
    [super customLayoutSubviews];
    
    CGRect bounds = self.contentView.bounds;
    
    self.flowlayout.bounds = bounds;
    [self.flowlayout layoutItemsWithResizeItems:YES];
}

- (CGSize)customSizeThatFits:(CGSize)size {
    CGSize s = [self.flowlayout sizeThatFits:size resizeItems:YES];
    NSInteger count = self.collectionCellModel.sectionModel.numberOfCells;
    CGFloat space = self.collectionCellModel.collectionView.l_collectionViewFlowLayout.minimumInteritemSpacing;
    if (count) {
        s.width = floor((size.width-(count-1)*space)/count);
    }
    
    return s;
}

#pragma -mark getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setBackgroundColor:[UIColor whiteColor]];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        _titleLabel.clipsToBounds = YES;
    }
    return _titleLabel;
}
@end
