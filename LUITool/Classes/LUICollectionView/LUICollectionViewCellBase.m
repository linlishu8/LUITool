//
//  LUICollectionViewCellBase.m
//  LUITool
//
//  Created by 六月 on 2023/8/16.
//

#import "LUICollectionViewCellBase.h"
#import "LUICollectionViewCellModel.h"

#import "UICollectionViewCell+LUICollectionViewCellProtocol.h"

@interface LUICollectionViewCellBase ()
@property (nonatomic) BOOL isCellModelChanged;//cellmodel是否有变化
@property (nonatomic) BOOL isNeedLayoutCellSubviews;//是否要重新布局视图

@end

@implementation LUICollectionViewCellBase
LUIDEF_SINGLETON_SUBCLASS
- (void)setCollectionCellModel:(__kindof LUICollectionViewCellModel *)collectionCellModel {
    if (self.isSharedInstance) {
        _collectionCellModel = collectionCellModel;
        [self customReloadCellModel];
    } else {
        self.isCellModelChanged = collectionCellModel.needReloadCell || _collectionCellModel != collectionCellModel || collectionCellModel.collectionViewCell != self;
        _collectionCellModel = collectionCellModel;
        
        if (self.class.useCachedFitedSize && collectionCellModel.needReloadCell) {
            collectionCellModel[self.class.cachedFitedSizeKey] = nil;
        }
        _collectionCellModel.needReloadCell = NO;
        
        if (!self.isCellModelChanged) {
            return;
        }
        self.isNeedLayoutCellSubviews = YES;
        [self customReloadCellModel];
    }
}

+ (NSString *)cachedFitedSizeKey{
    return [NSString stringWithFormat:@"%@_cachedFitedSize",NSStringFromClass(self)];
}
+ (BOOL)useCachedFitedSize{
    return YES;
}
- (BOOL)isSharedInstance{
    return self == [self sharedInstance];
}
- (void)layoutSubviews{
    [super layoutSubviews];
    if (!self.isCellModelChanged&&!self.isNeedLayoutCellSubviews&&!self.isSharedInstance) {
        return;
    }
    [self customLayoutSubviews];
    self.isNeedLayoutCellSubviews = NO;
}
- (CGSize)sizeThatFits:(CGSize)size{
    return [self customSizeThatFits:size];
}
+ (CGSize)sizeWithCollectionView:(UICollectionView *)collectionView collectionCellModel:(__kindof LUICollectionViewCellModel *)collectionCellModel {
    if (self.useCachedFitedSize) {
        NSValue *cacheSizeValue = collectionCellModel[self.cachedFitedSizeKey];
        if (cacheSizeValue) {
            CGSize cacheSize = [cacheSizeValue CGSizeValue];
            return cacheSize;
        }
    }
    CGSize sizeFits = [self dynamicSizeWithCollectionView:collectionView collectionCellModel:collectionCellModel cellShareInstance:[self sharedInstance] calBlock:^CGSize(UICollectionView * _Nonnull collectionView, LUICollectionViewCellModel * _Nonnull cellModel, LUICollectionViewCellBase * _Nonnull cell) {
        CGRect bounds = cell.bounds;
        return [cell sizeThatFits:bounds.size];
    }];
    if (self.useCachedFitedSize) {
        collectionCellModel[self.cachedFitedSizeKey] = [NSValue valueWithCGSize:sizeFits];
    }
    return sizeFits;
}
#pragma mark - override
- (void)customReloadCellModel {
    
}
- (void)customLayoutSubviews{
    
}
- (CGSize)customSizeThatFits:(CGSize)size{
    return size;
}
@end
