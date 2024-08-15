//
//  LUICollectionViewCellModel.h
//  LUITool
//
//  Created by 六月 on 2024/8/15.
//

#import <LUITool/LUITool.h>

NS_ASSUME_NONNULL_BEGIN

@class LUICollectionViewCellModel, LUICollectionViewSectionModel, LUICollectionViewModel;

typedef void(^LUICollectionViewCellModelBlockC)(__kindof LUICollectionViewCellModel *cellModel);
typedef void(^LUICollectionViewCellModelBlockS)(__kindof LUICollectionViewCellModel *cellModel, BOOL selected);
typedef BOOL(^LUICollectionViewCellModelBlockM)(__kindof LUICollectionViewCellModel *src,
                                          __kindof LUICollectionViewCellModel *dst);    //移动数据是触发的动作

typedef BOOL(^LUICollectionViewCellModelBlockD)(__kindof LUICollectionViewCellModel *cellModel);    //刪除数据时觸發的动作

@interface LUICollectionViewCellModel : LUICollectionCellModel

@property (nonatomic, assign) Class<LUICollectionViewCellProtocol> cellClass;
@property (nonatomic, strong) NSString *reuseIdentity;//用於列表重用单元格视图时的标志符,默认为NSStringFromCGClass(self.class)

@property (nonatomic, assign) BOOL canDelete;//是否可以被删除,默认为NO
@property (nonatomic, assign) BOOL canMove;//是否可以被移動,默认为 NO
@property (nonatomic, copy, nullable) LUICollectionViewCellModelBlockM whenMove;//移动位置时触发
@property (nonatomic, copy, nullable) LUICollectionViewCellModelBlockD whenDelete;//删除触发

@property (nonatomic, weak, nullable) __kindof UICollectionViewCell<LUICollectionViewCellProtocol> *collectionViewCell;//弱引用单元格视图
@property (nonatomic, readonly, nullable) UICollectionView *collectionView;
@property (nonatomic, copy, nullable) LUICollectionViewCellModelBlockC whenClick;//点击时被触发
@property (nonatomic, copy, nullable) LUICollectionViewCellModelBlockS whenSelected;//被触控事件选中时触发

@property(nonatomic) BOOL needReloadCell;//是否需要更新cell的视图内容

+ (instancetype)modelWithValue:(nullable id)modelValue cellClass:(Class)cellClass;
+ (instancetype)modelWithValue:(nullable id)modelValue cellClass:(Class)cellClass whenClick:(nullable LUICollectionViewCellModelBlockC)whenClick;

- (void)didClickSelf;
- (void)didSelectedSelf:(BOOL)selected;
- (BOOL)didDeleteSelf;

 - (nullable __kindof LUICollectionViewSectionModel *)sectionModel;
 - (nullable __kindof LUICollectionViewModel *)collectionModel;
/**
 *  根据模型显示视图
 *
 *  @param cell 视图对象
 */
- (void)displayCell:(UICollectionViewCell<LUICollectionViewCellProtocol> *)cell;

/**
 *  刷新视图
 */
- (void)refresh;

//移除单元格
- (void)removeCellModelWithAnimated:(BOOL)animated completion:(void (^ __nullable)(BOOL finished))completion;

@end

NS_ASSUME_NONNULL_END
