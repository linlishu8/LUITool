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

@interface LUIKeyboardButtonCell()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) LUIFlowLayoutConstraint *flowlayout;

@end

@implementation LUIKeyboardButtonCell
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self.contentView addSubview:self.titleLabel];
        
        self.flowlayout = [[LUIFlowLayoutConstraint alloc] initWithItems:@[self.titleLabel] constraintParam:LUIFlowLayoutConstraintParam_H_C_C contentInsets:UIEdgeInsetsZero interitemSpacing:0];
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
    
    LUIKeyboardButtonModel *buttonModel = self.collectionCellModel.modelValue;
    CGRect f = bounds;
    if (!UIEdgeInsetsEqualToEdgeInsets(buttonModel.paddingSpacing, UIEdgeInsetsZero)) {
        f = UIEdgeInsetsInsetRect(bounds, buttonModel.paddingSpacing);
    }
    
    self.titleLabel.frame = f;
}

- (CGSize)customSizeThatFits:(CGSize)size {
    LUIKeyBoardSectionModel *sectionModel = (LUIKeyBoardSectionModel *)self.collectionCellModel.sectionModel;
    CGSize s = [self.flowlayout sizeThatFits:size resizeItems:YES];
    LUIKeyboardButtonModel *buttonModel = self.collectionCellModel.modelValue;
    if (CGSizeEqualToSize(buttonModel.size, CGSizeZero)) {
        NSInteger count = self.collectionCellModel.sectionModel.numberOfCells;
        CGFloat space = self.collectionCellModel.collectionView.l_collectionViewFlowLayout.minimumInteritemSpacing;
        if (count) {
            s.width = floor(((size.width - sectionModel.l_otherLength)-(count-1)*space)/(count - sectionModel.l_numberOfOtherButtons));
        }
    } else {
        s.width = buttonModel.size.width;
    }
    if (sectionModel.l_maxHeight > 0) {
        s.height = sectionModel.l_maxHeight;
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
