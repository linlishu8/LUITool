//
//  UICollectionViewCell+LUICollectionViewCellProtocol.h
//  LUITool
//
//  Created by 六月 on 2024/8/16.
//

#import <UIKit/UIKit.h>
#import "LUICollectionViewCellProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface UICollectionViewCell (LUICollectionViewCellProtocol)<LUICollectionViewCellProtocol>
/**
 *  动态计算单元格的尺寸,一般是使用单例cell进行动态尺寸计算.block中只需要计算尺寸,不需要再配置单例cell的bounds,collectionCellModel等属性
 *
 *  @param collectionView      集合视图
 *  @param collectionCellModel 单元格数据
 *  @param cell                单例单元格,其bounds在block中，已经被设置为一个很大的值
 *  @param block               计算block
 *
 *  @return 动态尺寸
 */
+ (CGSize)dynamicSizeWithCollectionView:(UICollectionView *)collectionView collectionCellModel:(LUICollectionViewCellModel *)collectionCellModel cellShareInstance:(UICollectionViewCell<LUICollectionViewCellProtocol> *)cell calBlock:(CGSize(^)(UICollectionView *collectionView,LUICollectionViewCellModel *cellModel,id cell))block;
@end

NS_ASSUME_NONNULL_END
