//
//  LUISectionMdel.h
//  LUITool
//
//  Created by 六月 on 2023/8/11.
//

#import "LUICollectionModelObjectBase.h"

NS_ASSUME_NONNULL_BEGIN

@class LUICollectionModel, LUICollectionCellModel;

@interface LUICollectionSectionModel : LUICollectionModelObjectBase
@property(nonatomic,strong,nullable) NSArray<__kindof LUICollectionCellModel *> *cellModels;//含有的单元格
@property(nonatomic,strong,nullable) id userInfo;//自定義的擴展對象
@property(nonatomic,readonly) NSInteger numberOfCells;//单元格数量
@property(nonatomic,readonly) NSInteger indexInModel;
@property(nonatomic,readonly,nullable) NSMutableArray<__kindof LUICollectionCellModel *> * mutableCellModels;
//弱引用外層的数据
- (void)setCollectionModel:(nullable LUICollectionModel *)collectionModel;
- (nullable __kindof LUICollectionModel *)collectionModel;

/**
 *  加到单元格到分组中
 *
 *  @param cellModel 单元格数据
 */
- (void)addCellModel:(LUICollectionCellModel *)cellModel;
- (void)addCellModels:(NSArray<LUICollectionCellModel *> *)cellModels;
- (void)insertCellModel:(LUICollectionCellModel *)cellModel atIndex:(NSInteger)index;
- (void)insertCellModels:(NSArray<LUICollectionCellModel *> *)cellModels afterIndex:(NSInteger)index;
- (void)insertCellModels:(NSArray<LUICollectionCellModel *> *)cellModels beforeIndex:(NSInteger)index;
/**
 *  单元格添加后的配置,@overrdie
 *
 *  @param cellModel 单元格
 */
- (void)configCellModelAfterAdding:(LUICollectionCellModel *)cellModel;
- (void)configCellModelAfterRemoving:(LUICollectionCellModel *)cellModel;

- (void)insertCellModelsToTop:(NSArray<LUICollectionCellModel *> *)cellModels;//添加到顶部
- (void)insertCellModelsToBottom:(NSArray<LUICollectionCellModel *> *)cellModels;//添加到底部

/**
 *  將cell從所有的分组中移除
 *
 *  @param cellModel 单元格對象
 */
- (void)removeCellModel:(LUICollectionCellModel *)cellModel;

/**
 *  移除index位置的单元格
 *
 *  @param index 索引位置
 */
- (void)removeCellModelAtIndex:(NSInteger)index;

/**
 *  移除多个单元格
 *
 *  @param indexes 索引位置集合
 */
- (void)removeCellModelsAtIndexes:(NSIndexSet *)indexes;

/**
 *    清空所有数据
 */
- (void)removeAllCellModels;

/**
 *  返回指定索引下的单元格数据
 *
 *  @param index 索引
 *
 *  @return 单元格数据
 */
- (nullable __kindof LUICollectionCellModel *)cellModelAtIndex:(NSInteger)index;

/**
 *  返回指定单元格数据对应的索引
 *
 *  @param cellModel 单元格数据
 *
 *  @return 索引号
 */
- (NSInteger)indexOfCellModel:(LUICollectionCellModel *)cellModel;

- (nullable NSIndexPath *)indexPathForSelectedCellModel;
- (nullable __kindof LUICollectionCellModel *)cellModelForSelectedCellModel;
- (nullable NSArray<NSIndexPath *> *)indexPathsForSelectedCellModels;
- (nullable NSArray<__kindof LUICollectionCellModel *> *)cellModelsForSelectedCellModels;

- (NSComparisonResult)compare:(LUICollectionSectionModel *)otherObject;
@end

@interface LUICollectionSectionModel (Focused)

@property (nonatomic, readonly) NSInteger indexForFocusedCellModel;
@property (nonatomic, readonly, nullable) __kindof LUICollectionCellModel *cellModelForFocusedCellModel;

@end

NS_ASSUME_NONNULL_END
