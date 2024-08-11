//
//  LUIModel.h
//  LUITool
//
//  Created by 六月 on 2024/8/11.
//

#import "LUIModelBase.h"
#import "LUICellModel.h"
#import "LUISectionModel.h"

NS_ASSUME_NONNULL_BEGIN

@class LUICellModel, LUISectionModel;

@interface LUIModel : LUIModelBase

@property (nonatomic, strong, nullable) NSArray<__kindof LUISectionModel *> *sectionModels;//分组
@property (nonatomic, readonly, nullable) NSArray<__kindof LUICellModel *> *allCellModels;//返回所有的单元格数据
@property (nonatomic, strong, nullable) id userInfo;//自定義的擴展對象
@property (nonatomic, readonly) NSInteger numberOfSections;//分组数量
@property (nonatomic, readonly) NSInteger numberOfCells;//所有单元格的数量

@property (nonatomic, assign) BOOL allowsSelection;//default YES
@property (nonatomic, assign) BOOL allowsMultipleSelection;//default NO
@property (nonatomic, assign) BOOL allowsFocus;//default YES

@property (nonatomic, readonly, nullable) NSIndexPath *indexPathOfLastCellModel;//返回最后一个单元格数据的位置
@property (nonatomic, readonly, nullable) NSMutableArray<__kindof LUISectionModel *> *mutableSectionModels;//可编辑的分组列表数据

/**
 *  产生一个空的分组
 *
 *  @return 分组对象
 */
- (__kindof LUISectionModel *)createEmptySectionModel;

/**
 *  快速加到单元格到最後一個分组中
 *
 *  @param cellModel 单元格数据
 */
- (void)addCellModel:(LUICellModel *)cellModel;

/**
 *  快速加到单元格到第一個分组的第一个位置上
 *
 *  @param cellModel 单元格数据
 */
- (void)addCellModelToFirst:(LUICellModel *)cellModel;

/**
 *  快速添加多个单元格到最后一个分组中,如果分组不存在,会创建分组
 *
 *  @param cellModels @[LUICellModel]
 */
- (void)addCellModels:(NSArray<LUICellModel *> *)cellModels;

/**
 *  插入某个单元格到指定的位置
 *
 *  @param cellModel 单元格
 *  @param indexPath 指定的位置
 */
- (void)insertCellModel:(LUICellModel *)cellModel atIndexPath:(NSIndexPath *)indexPath;
- (void)insertCellModels:(NSArray<LUICellModel *> *)cellModels afterIndexPath:(NSIndexPath *)indexPath;
- (void)insertCellModels:(NSArray<LUICellModel *> *)cellModels beforeIndexPath:(NSIndexPath *)indexPath;

- (void)insertCellModelsToBottom:(NSArray<LUICellModel *> *)cellModels;//添加单元格到底部
- (void)insertCellModelsToTop:(NSArray<LUICellModel *> *)cellModels;//添加单元格到顶部

/**
 *  將cell從所有的分组中移除
 *
 *  @param cellModel 单元格對象
 */
- (void)removeCellModel:(LUICellModel *)cellModel;

/**
 *  将多个cell从所有的分组中移除
 *
 *  @param cellModels @[LUICellModel]
 */
- (void)removeCellModels:(NSArray<LUICellModel *> *)cellModels;

/**
 *    将多个cell从所有的分组中移除
 *
 *  @param indexPaths @[NSIndexPath]
 */
- (void)removeCellModelsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;

/**
 *  移除指定位置上的单元格
 *
 *  @param indexPath 单元格位置
 */
- (void)removeCellModelAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  添加分组模型数据
 *
 *  @param sectionModel 分组模型数据
 */
- (void)addSectionModel:(LUISectionModel *)sectionModel;
- (void)insertSectionModel:(LUISectionModel *)sectionModel atIndex:(NSInteger)index;
- (void)addSectionModels:(NSArray<LUISectionModel *> *)sectionModels;

/**
 *  移除掉分组模型数据
 *
 *  @param sectionModel 分组模型数据
 */
- (void)removeSectionModel:(LUISectionModel *)sectionModel;

/**
 *  移除掉分组模型数据
 *
 *  @param index 分组索引
 */
- (void)removeSectionModelAtIndex:(NSInteger)index;
- (void)removeSectionModelsInRange:(NSRange)range;
/**
 *    清空所有数据
 */
- (void)removeAllSectionModels;

/**
 *  遍历所有的单元格
 *
 *  @param block 单元格访问block
 */
- (void)enumerateCellModelsUsingBlock:(void(^)(id cellModel,NSIndexPath *indexpath,BOOL *stop))block;

/**
 *  查找指定的单元格
 *
 *  @param block 测试单元格是否满足条件的block
 *
 *  @return 指定单元格的indexpath
 */
- (nullable NSIndexPath *)indexPathOfCellModelPassingTest:(BOOL(^ __nullable)(id cellModel,NSIndexPath *indexpath,BOOL *stop))block;

/**
 *  查找指定的单元格
 *
 *  @param block 测试单元格是否满足条件的block
 *
 *  @return 符合条件的单元格indexpath列表
 */
- (nullable NSArray<NSIndexPath *> *)indexPathsOfCellModelPassingTest:(BOOL(^ __nullable)(id cellModel,NSIndexPath *indexpath,BOOL *stop))block;

/**
 *  獲取指定单元格的位置
 *
 *  @param cellModel 单元格数据
 *
 *  @return indexpath對象
 */
- (nullable NSIndexPath *)indexPathOfCellModel:(LUICellModel *)cellModel;

/**
 *  获取多个指定单元格的位置
 *
 *  @param cellModels @[LUICellModel]
 *
 *  @return @[NSIndexPath]
 */
- (nullable NSArray<NSIndexPath *> *)indexPathsOfCellModels:(NSArray<LUICellModel *> *)cellModels;

/**
 *  获取指定分组的索引值
 *
 *  @param sectionModel 分组
 *
 *  @return 索引
 */
- (NSInteger)indexOfSectionModel:(LUISectionModel *)sectionModel;
- (nullable NSIndexSet *)indexSetOfSectionModel:(LUISectionModel *)sectionModel;

/**
 *  返回indexpath指定的单元格数据
 *
 *  @param indexpath NSIndexPath對象
 *
 *  @return LUICellModel数据
 */
- (nullable __kindof LUICellModel *)cellModelAtIndexPath:(NSIndexPath *)indexpath;
- (nullable NSArray<__kindof LUICellModel *> *)cellModelsAtIndexPaths:(NSArray<NSIndexPath *> *)indexpaths;
/**
 *  返回index指定的分组
 *
 *  @param index 索引
 *
 *  @return 分组数据
 */
- (nullable __kindof LUISectionModel *)sectionModelAtIndex:(NSInteger)index;

/**
 *  移除掉没有单元格的空分组
 */
- (void)removeEmptySectionModels;

/**
 *  获取没有含有cell的空分组
 *
 *  @return @[LUISectionMdel]
 */
- (nullable NSArray<__kindof LUISectionModel *> *)emptySectionModels;

/**
 *  移动单元格
 *
 *  @param sourceIndexPath      源
 *  @param destinationIndexPath 目的
 */
- (void)moveCellModelAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;


#pragma mark - selection
- (void)selectCellModelAtIndexPath:(nullable NSIndexPath *)indexPath;
- (void)selectCellModelsAtIndexPaths:(nullable NSArray<NSIndexPath *> *)indexPaths;
- (void)selectCellModel:(nullable LUICellModel *)cellModel;
- (void)selectCellModels:(nullable NSArray<LUICellModel *> *)cellModels;
- (void)selectAllCellModels;

- (void)deselectCellModelAtIndexPath:(nullable NSIndexPath *)indexPath;
- (void)deselectCellModel:(nullable LUICellModel *)cellModel;
- (void)deselectCellModels:(nullable NSArray<LUICellModel *> *)cellModels;
- (void)deselectAllCellModels;

- (nullable NSIndexPath *)indexPathForSelectedCellModel;
- (nullable __kindof LUICellModel *)cellModelForSelectedCellModel;
- (nullable NSArray<NSIndexPath *> *)indexPathsForSelectedCellModels;
- (nullable NSArray<__kindof LUICellModel *> *)cellModelsForSelectedCellModels;

@end

NS_ASSUME_NONNULL_END
