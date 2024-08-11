//
//  LUISectionMdel.h
//  LUITool
//
//  Created by 六月 on 2024/8/11.
//

#import "LUIModelBase.h"

NS_ASSUME_NONNULL_BEGIN

@class LUIModel, LUICellModel;

@interface LUISectionModel : LUIModelBase
@property(nonatomic,strong,nullable) NSArray<__kindof LUICellModel *> *cellModels;//含有的单元格
@property(nonatomic,strong,nullable) id userInfo;//自定義的擴展對象
@property(nonatomic,readonly) NSInteger numberOfCells;//单元格数量
@property(nonatomic,readonly) NSInteger indexInModel;
@property(nonatomic,readonly,nullable) NSMutableArray<__kindof LUICellModel *> * mutableCellModels;
//弱引用外層的数据
- (void)setCollectionModel:(nullable LUIModel *)collectionModel;
- (nullable __kindof LUIModel *)collectionModel;

/**
 *  加到单元格到分组中
 *
 *  @param cellModel 单元格数据
 */
- (void)addCellModel:(LUICellModel *)cellModel;
- (void)addCellModels:(NSArray<LUICellModel *> *)cellModels;
- (void)insertCellModel:(LUICellModel *)cellModel atIndex:(NSInteger)index;
- (void)insertCellModels:(NSArray<LUICellModel *> *)cellModels afterIndex:(NSInteger)index;
- (void)insertCellModels:(NSArray<LUICellModel *> *)cellModels beforeIndex:(NSInteger)index;
/**
 *  单元格添加后的配置,@overrdie
 *
 *  @param cellModel 单元格
 */
- (void)configCellModelAfterAdding:(LUICellModel *)cellModel;
- (void)configCellModelAfterRemoving:(LUICellModel *)cellModel;

- (void)insertCellModelsToTop:(NSArray<LUICellModel *> *)cellModels;//添加到顶部
- (void)insertCellModelsToBottom:(NSArray<LUICellModel *> *)cellModels;//添加到底部

/**
 *  將cell從所有的分组中移除
 *
 *  @param cellModel 单元格對象
 */
- (void)removeCellModel:(LUICellModel *)cellModel;

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
- (nullable __kindof LUICellModel *)cellModelAtIndex:(NSInteger)index;

/**
 *  返回指定单元格数据对应的索引
 *
 *  @param cellModel 单元格数据
 *
 *  @return 索引号
 */
- (NSInteger)indexOfCellModel:(LUICellModel *)cellModel;

- (nullable NSIndexPath *)indexPathForSelectedCellModel;
- (nullable __kindof LUICellModel *)cellModelForSelectedCellModel;
- (nullable NSArray<NSIndexPath *> *)indexPathsForSelectedCellModels;
- (nullable NSArray<__kindof LUICellModel *> *)cellModelsForSelectedCellModels;

- (NSComparisonResult)compare:(LUISectionModel *)otherObject;
@end

@interface LUISectionModel (Focused)

@property (nonatomic, readonly) NSInteger indexForFocusedCellModel;
@property (nonatomic, readonly, nullable) __kindof LUICellModel *cellModelForFocusedCellModel;

@end

NS_ASSUME_NONNULL_END
