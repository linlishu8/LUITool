//
//  LUICollectionViewSectionModel.h
//  LUITool
//
//  Created by 六月 on 2024/8/15.
//

#import "LUICollectionSectionModel.h"
#import "LUICollectionViewSupplementaryElementProtocol.h"

@class LUICollectionViewModel,LUICollectionViewCellModel;

NS_ASSUME_NONNULL_BEGIN

@interface LUICollectionViewSectionModel : LUICollectionSectionModel {
    @protected
    NSMutableDictionary *_supplementaryElementCellClasses;
}
@property (nonatomic, readonly, nullable) __kindof UICollectionView *collectionView;//弱引用集合视图
- (nullable __kindof LUICollectionViewModel *)collectionModel;
- (nullable __kindof LUICollectionViewCellModel *)cellModelAtIndex:(NSInteger)index;

/**
 *  刷新分组视图
 */
- (void)refresh;

/**
 *  设置集合分组的补充元素显示视图
 *
 *  @param aClass 视图类,必须为UICollectionReusableView的子类
 *  @param kind   补充元素对应的类型,用于区分不同的补充元素
 */
- (void)setSupplementaryElementViewClass:(Class<LUICollectionViewSupplementaryElementProtocol>)aClass forKind:(NSString *)kind;

/**
 *  移除指定类型的补充元素的显示视图类.被移走后,将不会显示视图
 *
 *  @param kind 补充元素对应的类型
 */
- (void)removeSupplementaryElementViewClassForKind:(NSString *)kind;

/**
 *  获取指定类型的补充元素的显示视图类
 *
 *  @param kind 补充元素对应的类型
 *
 *  @return UICollectionReusableView子类
 */
- (Class<LUICollectionViewSupplementaryElementProtocol>)supplementaryElementViewClassForKind:(NSString *)kind;

/**
 *  显示分组的补充元素视图
 *
 *  @param view 补充元素视图
 *  @param kind 补充元素对应的类型
 */
- (void)displaySupplementaryElementView:(UICollectionReusableView<LUICollectionViewSupplementaryElementProtocol> *)view forKind:(NSString *)kind;
@end

NS_ASSUME_NONNULL_END
