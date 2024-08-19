//
//  LUIKeyboardView.m
//  LUITool
//
//  Created by 六月 on 2024/8/18.
//

#import "LUIKeyboardView.h"
#import "LUICollectionView.h"
#import "LUIKeyboardButtonCell.h"

@interface LUIKeyboardView ()

@property (nonatomic, strong) LUICollectionFlowLayoutView *collectionView;// 键盘按钮集合视图
@property (nonatomic, strong) NSArray<NSArray<LUIKeyboardButtonModel *> *> *keyboardLayout; // 键盘布局的二维数组

@end

@implementation LUIKeyboardView

- (instancetype)initWithKeyboardButtons:(NSArray <NSArray <LUIKeyboardButtonModel *> *> *)keyboardButtons
{
    self = [super init];
    if (self) {
        self.collectionView = [[LUICollectionFlowLayoutView alloc] init];
        
        self.collectionView.collectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.collectionView.collectionViewFlowLayout.minimumLineSpacing = 10;
        self.collectionView.collectionViewFlowLayout.minimumInteritemSpacing = 10;
        
        self.collectionView.scrollEnabled = NO;
        self.collectionView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.collectionView];
        
        [self __reloadKeyboardButtons:keyboardButtons];
    }
    return self;
}

- (void)__reloadKeyboardButtons:(NSArray <NSArray <LUIKeyboardButtonModel *> *> *)keyboardButtons {
    [keyboardButtons enumerateObjectsUsingBlock:^(NSArray<LUIKeyboardButtonModel *> *lines, NSUInteger idx, BOOL * _Nonnull stop) {
        LUICollectionViewSectionModel *sectionModel = [[LUICollectionViewSectionModel alloc] init];
        [lines enumerateObjectsUsingBlock:^(LUIKeyboardButtonModel *buttonModel, NSUInteger idx, BOOL * _Nonnull stop) {
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
    
    self.collectionView.frame = bounds;
}

@end
