//
//  LUICollectionViewCellProtocol.h
//  LUITool
//
//  Created by 六月 on 2024/8/15.
//

#import <Foundation/Foundation.h>

#ifndef LUIDEF_LUICollectionViewCellModel
#define LUIDEF_LUICollectionViewCellModel(clazz,property) \
- (LUICollectionViewCellModel *)collectionCellModel {\
    return self.property;\
}\
- (void)setCollectionCellModel:(LUICollectionViewCellModel *)collectionCellModel {\
    self.property = (clazz *)collectionCellModel;\
}
#endif

NS_ASSUME_NONNULL_BEGIN

@class LUICollectionViewCellModel;

@protocol LUICollectionViewCellProtocol <NSObject>
@property (nonatomic, strong, nullable) __kindof  LUICollectionViewCellModel *collectionCellModel;//数据模型
@optional
/**
 *  返回单元格的尺寸信息
 *
 *  @param collectionView      集合视图
 *  @param collectionCellModel 数据对象
 *
 *  @return 尺寸信息
 */
+ (CGSize)sizeWithCollectionView:(UICollectionView *)collectionView collectionCellModel:(__kindof LUICollectionViewCellModel *)collectionCellModel;
//选中/取消选中单元格
- (void)collectionView:(UICollectionView *)collectionView didSelectCell:(BOOL)selected;

/// /// cell要被显示前的回调。可在此处进行异步加载图片等资源。
/// @param collectionView 集合视图
/// @param cellModel 单元格数据模型
- (void)collectionView:(UICollectionView *)collectionView willDisplayCellModel:(__kindof LUICollectionViewCellModel *)cellModel;

/// cell完成显示的回调。该方法的回调时机不确定。
/// @param collectionView 集合视图
/// @param cellModel 单元格数据模型
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCellModel:(__kindof LUICollectionViewCellModel *)cellModel;
@end

NS_ASSUME_NONNULL_END
