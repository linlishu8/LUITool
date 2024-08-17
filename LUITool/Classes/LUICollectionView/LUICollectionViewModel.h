//
//  LUICollectionViewModel.h
//  LUITool
//
//  Created by 六月 on 2024/8/15.
//

#import "LUICollectionModel.h"
#import "LUICollectionCellModel.h"
#import "LUICollectionSectionModel.h"

#import "LUICollectionViewSectionModel.h"
#import "LUICollectionViewCellModel.h"
#import "LUICollectionViewCellProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface LUICollectionViewModel : LUICollectionModel<UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic, weak, nullable) id<UICollectionViewDataSource> forwardDataSource;//调用链传递
@property (nonatomic, weak, nullable) id<UICollectionViewDelegate> forwardDelegate;//调用链传递。ios10时，如果forwardDelegate实现了scrollViewDidScroll：方法，需要在forwardDelegate的dealloc方法中手动清空delegate，否则会闪退
@property (nonatomic, readwrite,getter=isEditting) BOOL editting;//是否处在编辑状态中
@property (nonatomic, weak, nullable) UICollectionView *collectionView;//弱引用外部的collectionView

#pragma mark - empty
@property (nonatomic, assign, nullable) Class emptyBackgroundViewClass;//没有单元格数据时的背景视图类
@property (nonatomic, strong, nullable) __kindof UIView *emptyBackgroundView;//没有单元格数据时的背景视图
typedef void(^LUICollectionViewModelC)(__kindof LUICollectionViewModel *model);
@property (nonatomic, copy, nullable) LUICollectionViewModelC whenReloadBackgroundView;
@property (nonatomic) BOOL reuseCell;;//是否重用cell，默认为YES
- (void)reloadCollectionViewBackgroundView;//刷新collectionView的backgroundView

- (id)initWithCollectionView:(nullable UICollectionView *)collectionView;

- (nullable __kindof LUICollectionViewCellModel *)cellModelAtIndexPath:(NSIndexPath *)indexpath;
- (nullable __kindof LUICollectionViewSectionModel *)sectionModelAtIndex:(NSInteger)index;
- (nullable __kindof LUICollectionViewCellModel *)cellModelForSelectedCellModel;

/**
 *  将collectionView的dataSource和delegate设置为self.如果forwardDelegate要监听scrollViewDidScroll:事件,则必须在设置collectionView的delegate之前设置forwardDelegate,因为scrollView是在设置delegate时,去获取delegate是否实现scrollViewDidScroll:方法,后续就不会再获取了.
 *
 *  @param collectionView 集合视图
 */
- (void)setCollectionViewDataSourceAndDelegate:(nullable UICollectionView *)collectionView;

/**
 *  刷新集合视图,会保持集合视图的cell选中状态
 */
- (void)reloadCollectionViewData;

/**
 *  动画的方式添加/删除单元格
 *
 *  @param cellModel  单元格数据
 *  @param animated   是否动画
 *  @param completion 动画结束后的回调
 */
- (void)addCellModel:(LUICollectionViewCellModel *)cellModel animated:(BOOL)animated completion:(void (^ __nullable)(BOOL finished))completion;
- (void)insertCellModel:(LUICollectionViewCellModel *)cellModel atIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated completion:(void (^ __nullable)(BOOL finished))completion;
- (void)insertCellModels:(NSArray<LUICollectionViewCellModel *> *)cellModels afterIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated completion:(void (^ __nullable)(BOOL finished))completion;
- (void)insertCellModels:(NSArray<LUICollectionViewCellModel *> *)cellModels beforeIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated completion:(void (^ __nullable)(BOOL finished))completion;
- (void)removeCellModel:(LUICollectionViewCellModel *)cellModel animated:(BOOL)animated completion:(void (^ __nullable)(BOOL finished))completion;
- (void)removeCellModels:(NSArray<LUICollectionViewCellModel *> *)cellModels animated:(BOOL)animated completion:(void (^ __nullable)(BOOL finished))completion;

- (void)moveCellModelAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath inCollectionViewBatchUpdatesBlock:(BOOL)isBatchUpdates;

- (void)insertSectionModel:(LUICollectionViewSectionModel *)sectionModel atIndex:(NSInteger)index animated:(BOOL)animated completion:(void (^ __nullable)(BOOL finished))completion;//动画添加分组
- (void)removeSectionModel:(LUICollectionViewSectionModel *)sectionModel animated:(BOOL)animated completion:(void (^ __nullable)(BOOL finished))completion;//动画移除分组
@end

NS_ASSUME_NONNULL_END
