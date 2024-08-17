//
//  LUICollectionViewSupplementaryElementProtocol.h
//  LUITool
//
//  Created by 六月 on 2024/8/15.
//

#import <Foundation/Foundation.h>

#ifndef LUIDEF_LUICollectionViewSectionModel
#define LUIDEF_LUICollectionViewSectionModel(clazz,property) \
- (LUICollectionViewSectionModel *)sectionModel{\
    return self.property;\
}\
- (void)setCollectionSectionModel:(LUICollectionViewSectionModel *)sectionModel forKind:(NSString *)kind{\
    self.property = (clazz *)sectionModel;\
}
#endif

NS_ASSUME_NONNULL_BEGIN

@class LUICollectionViewSectionModel;

@protocol LUICollectionViewSupplementaryElementProtocol <NSObject>
/**
 *  设置补充视图所在的分组以及类型
 *
 *  @param sectionModel 分组数据
 *  @param kind         类型
 */
- (void)setCollectionSectionModel:(nullable __kindof  LUICollectionViewSectionModel *)sectionModel forKind:(NSString *)kind;

@optional
/**
 *  返回视图的尺寸,UICollectionViewDelegateFlowLayout使用
 *
 *  @param collectionView 集合
 *  @param sectionModel   分组
 *  @param kind           类型
 *
 *  @return 尺寸值
 */
+ (CGSize)referenceSizeWithCollectionView:(UICollectionView *)collectionView collectionSectionModel:(__kindof LUICollectionViewSectionModel *)sectionModel forKind:(NSString *)kind;

/// 集合分组视图将要被显示的回调。
/// @param collectionView 集合视图
/// @param sectionModel 分组
/// @param kind 类别
- (void)collectionView:(UICollectionView *)collectionView willDisplaySectionModel:(__kindof LUICollectionViewSectionModel *)sectionModel kind:(NSString *)kind;

/// 集合分组视图完成显示的回调。
/// @param collectionView 集合视图
/// @param sectionModel 分组
/// @param kind 类别
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSectionModel:(__kindof LUICollectionViewSectionModel *)sectionModel kind:(NSString *)kind;
@end

NS_ASSUME_NONNULL_END
