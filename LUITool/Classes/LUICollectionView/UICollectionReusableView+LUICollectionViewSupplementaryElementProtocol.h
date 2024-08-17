//
//  UICollectionReusableView+LUICollectionViewSupplementaryElementProtocol.h
//  LUITool
//
//  Created by 六月 on 2024/8/16.
//

#import <UIKit/UIKit.h>
#import "LUICollectionViewSupplementaryElementProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface UICollectionReusableView (LUICollectionViewSupplementaryElementProtocol)

/**
 *  动态计算sectionview的尺寸,一般是使用单例进行动态尺寸计算.block中只需要计算尺寸,不需要再配置单例view的bounds,sectionModel,kind等属性
 *
 *  @param collectionView      集合视图
 *  @param sectionModel           分组数据
 *  @param kind                   分组数据类别
 *  @param view                单例视图，,其bounds在block中，已经被设置为一个很大的值
 *  @param block               计算block
 *
 *  @return 动态尺寸
 */
+ (CGSize)dynamicReferenceSizeWithCollectionView:(UICollectionView *)collectionView collectionSectionModel:(LUICollectionViewSectionModel *)sectionModel forKind:(NSString *)kind viewShareInstance:(UICollectionReusableView<LUICollectionViewSupplementaryElementProtocol> *)view calBlock:(CGSize(^)(UICollectionView *collectionView,LUICollectionViewSectionModel *sectionModel,NSString *kind,id view))block;

@end

NS_ASSUME_NONNULL_END
