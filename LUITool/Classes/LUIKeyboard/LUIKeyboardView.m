//
//  LUIKeyboardView.m
//  LUITool
//
//  Created by 六月 on 2023/8/18.
//

#import "LUIKeyboardView.h"
#import "LUICollectionView.h"
#import "LUIKeyboardButtonCell.h"
#import "LUIKeyBoardSectionModel.h"
#import "LUIFlowLayoutConstraint.h"

@interface LUIKeyboardView ()

@property (nonatomic, strong) LUICollectionFlowLayoutView *collectionView;// 键盘按钮集合视图
@property (nonatomic, strong) NSArray<NSArray<LUIKeyboardButtonModel *> *> *keyboardLayout; // 键盘布局的二维数组

@property (nonatomic, strong) LUIFlowLayoutConstraint *flowlayout;

@end

@implementation LUIKeyboardView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addSubview:self.collectionView];
        self.flowlayout = [[LUIFlowLayoutConstraint alloc] initWithItems:@[self.collectionView] constraintParam:(LUIFlowLayoutConstraintParam_H_T_C) contentInsets:UIEdgeInsetsZero interitemSpacing:0];
    }
    return self;
}

- (instancetype)initWithTitleView:(UIView *)titleView
{
    self = [super init];
    if (self) {
        [self addSubview:titleView];
        [self addSubview:self.collectionView];
        self.flowlayout = [[LUIFlowLayoutConstraint alloc] initWithItems:@[titleView, self.collectionView] constraintParam:(LUIFlowLayoutConstraintParam_V_T_C) contentInsets:UIEdgeInsetsZero interitemSpacing:0];
    }
    return self;
}

- (void)__reloadKeyboardButtons:(NSArray <NSArray <LUIKeyboardButtonModel *> *> *)keyboardButtons {
    [self.collectionView.model removeAllSectionModels];
    [keyboardButtons enumerateObjectsUsingBlock:^(NSArray<LUIKeyboardButtonModel *> *lines, NSUInteger idx, BOOL * _Nonnull stop) {
        LUIKeyBoardSectionModel *sectionModel = [[LUIKeyBoardSectionModel alloc] init];
        sectionModel.l_maxHeight = 0;
        [lines enumerateObjectsUsingBlock:^(LUIKeyboardButtonModel *buttonModel, NSUInteger idx, BOOL * _Nonnull stop) {
            if (buttonModel.buttonWidth != 0) {
                sectionModel.l_otherLength += buttonModel.buttonWidth;
                sectionModel.l_numberOfOtherButtons += 1;
            }
            if (buttonModel.buttonHeight != 0) {
                sectionModel.l_maxHeight = MAX(sectionModel.l_maxHeight, buttonModel.buttonHeight);
            }
            LUICollectionViewCellModel *cm = [[LUICollectionViewCellModel alloc] init];
            cm.modelValue = buttonModel;
            cm.cellClass = [LUIKeyboardButtonCell class];
            [sectionModel addCellModel:cm];
        }];
        [self.collectionView.model addSectionModel:sectionModel];
    }];
    [self.collectionView.model reloadCollectionViewData];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    self.flowlayout.bounds = bounds;
    [self.flowlayout layoutItemsWithResizeItems:YES];
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize s = [self.flowlayout sizeThatFits:size resizeItems:YES];
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets safeInsets = [self l_safeAreaInsets];
        s.height += safeInsets.bottom;
    }
    return s;
}

- (void)setMinimumInteritemSpacing:(CGFloat)minimumInteritemSpacing {
    self.collectionView.collectionViewFlowLayout.minimumInteritemSpacing = minimumInteritemSpacing;
}

- (void)setSectionInset:(UIEdgeInsets)sectionInset {
    self.collectionView.collectionViewFlowLayout.sectionInset = sectionInset;
}

- (UIEdgeInsets)l_safeAreaInsets {
    if (@available(iOS 11.0, *)) {
        return [[[UIApplication sharedApplication] delegate] window].safeAreaInsets;
    }
    return UIEdgeInsetsZero;
}

#pragma mark - getters/setters

- (LUICollectionFlowLayoutView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[LUICollectionFlowLayoutView alloc] init];
        _collectionView.collectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView.scrollEnabled = NO;
        _collectionView.backgroundColor = [UIColor clearColor];
    }
    return _collectionView;
}

@end
