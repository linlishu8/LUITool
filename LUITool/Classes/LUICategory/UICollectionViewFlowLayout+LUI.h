//
//  UICollectionViewFlowLayout+LUI.h
//  LUITool
//
//  Created by 六月 on 2024/8/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
//声明集合布局具有计算自适应尺寸的能力
@protocol LUICollectionViewLayoutSizeFitsProtocol <NSObject>
/// 指定collectionview的最大尺寸，返回collectionview最合适的尺寸值
/// @param size 外层最大尺寸
- (CGSize)l_sizeThatFits:(CGSize)size;
@end

@interface UICollectionViewFlowLayout (LUI)
@property (nonatomic, readonly, nullable) id<UICollectionViewDelegateFlowLayout> l_flowLayoutDelegate;
- (CGSize)l_sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
- (UIEdgeInsets)l_insetForSectionAtIndex:(NSInteger)index;
- (CGFloat)l_minimumLineSpacingForSectionAtIndex:(NSInteger)index;
- (CGFloat)l_minimumInteritemSpacingForSectionAtIndex:(NSInteger)index;
- (CGSize)l_referenceSizeForFooterInSection:(NSInteger)index;
- (CGSize)l_referenceSizeForHeaderInSection:(NSInteger)index;
- (CGRect)l_contentBoundsForSectionAtIndex:(NSInteger)index;
@end

@interface UICollectionViewFlowLayout (LUI_SizeFits)<LUICollectionViewLayoutSizeFitsProtocol>
@end

@interface UICollectionView (LUI_UICollectionViewFlowLayout)

@property (nonatomic, readonly, nullable) __kindof UICollectionViewFlowLayout *l_collectionViewFlowLayout;

@end

NS_ASSUME_NONNULL_END
