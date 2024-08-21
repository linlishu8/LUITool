//
//  LUIKeyboardView.m
//  LUITool
//
//  Created by 六月 on 2024/8/18.
//

#import "LUIKeyboardView.h"
#import "LUICollectionView.h"
#import "LUIKeyboardButtonCell.h"
#import "LUIKeyBoardSectionModel.h"

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
    [self.collectionView.model removeAllSectionModels];
    [keyboardButtons enumerateObjectsUsingBlock:^(NSArray<LUIKeyboardButtonModel *> *lines, NSUInteger idx, BOOL * _Nonnull stop) {
        LUIKeyBoardSectionModel *sectionModel = [[LUIKeyBoardSectionModel alloc] init];
        sectionModel.l_maxHeight = 0;
        [lines enumerateObjectsUsingBlock:^(LUIKeyboardButtonModel *buttonModel, NSUInteger idx, BOOL * _Nonnull stop) {
            if (!CGSizeEqualToSize(buttonModel.size, CGSizeZero)) {
                sectionModel.l_otherLength += buttonModel.size.width;
                sectionModel.l_numberOfOtherButtons += 1;
                sectionModel.l_maxHeight = MAX(sectionModel.l_maxHeight, buttonModel.size.height);
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
    
    self.collectionView.frame = bounds;
}

@end
