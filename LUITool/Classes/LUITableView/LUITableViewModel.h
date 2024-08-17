//
//  LUITableViewModel.h
//  LUITool
//
//  Created by 六月 on 2023/8/11.
//

#import <Foundation/Foundation.h>

#import "LUICollectionModel.h"
#import "LUICollectionCellModel.h"
#import "LUICollectionSectionModel.h"

#import "LUITableViewSectionModel.h"
#import "LUITableViewCellModel.h"
#import "LUITableViewSectionViewProtocol.h"
#import "LUITableViewCellProtocol.h"
#import "UITableViewCell+LUITableViewCell.h"

#define LUITableViewDefaultSectionIndexTitle @"#"

NS_ASSUME_NONNULL_BEGIN

@interface LUITableViewModel : LUICollectionModel<UITableViewDataSource,UITableViewDelegate>{
@protected
    LUITableViewSectionModel *_defaultIndexTitleSectionModel;    //存儲section的indexTitle沒有值的情況
}
@property(nonatomic,weak,nullable) id<UITableViewDataSource> forwardDataSource;//调用链传递
@property(nonatomic,weak,nullable) id<UITableViewDelegate> forwardDelegate;//调用链传递。ios10时，如果forwardDelegate实现了scrollViewDidScroll：方法，需要在forwardDelegate的dealloc方法中手动清空delegate，否则会闪退

@property(nonatomic,weak,nullable) UITableView *tableView;//弱引用
@property(nonatomic,assign) BOOL showSectionIndexTitle;//是否显示分组索引，默认为NO
@property(nonatomic,strong) NSString *defaultSectionIndexTitle;//当sectionModel.indexTitle沒有值时,采用此默认值，默认为#

@property(nonatomic,readwrite,getter=isEditing) BOOL editing;//独立的编辑中状态，并不与tableView的editting状态相关，可用于自定义的多选单元格功能

@property(nonatomic) BOOL reuseCell;;//是否重用cell，默认为YES
#pragma mark - empty
@property(nonatomic,assign,nullable) Class emptyBackgroundViewClass;//没有单元格数据时的背景视图类
@property(nonatomic,strong,nullable) UIView *emptyBackgroundView;//没有单元格数据时的背景视图
typedef void(^LUITableViewModelC)(LUITableViewModel *model);
@property(nonatomic,copy,nullable) LUITableViewModelC whenReloadBackgroundView;

//如果刷新cell、section时，出现滑动上下跳动问题，可以调用hideSectionHeadFootView，隐藏section的head、foot视图。
@property(nonatomic) BOOL hiddenSectionHeadView;//是否隐藏分组头部视图,默认为NO
@property(nonatomic) BOOL hiddenSectionFootView;//是否隐藏分组尾部视图,默认为NO
- (void)hideSectionHeadFootView;//隐藏分组的头部和尾部视图

- (void)reloadTableViewBackgroundView;//刷新tableview的backgroundView

/**
 *  使用tableview初始化,会设置tableview的datasource与delegate为self
 *
 *  @param tableView 列表对象
 *
 *  @return 列表的数据模型
 */
- (id)initWithTableView:(UITableView *)tableView;

- (nullable __kindof LUITableViewCellModel *)cellModelAtIndexPath:(NSIndexPath *)indexpath;
- (nullable __kindof LUITableViewSectionModel *)sectionModelAtIndex:(NSInteger)index;
- (nullable __kindof LUITableViewCellModel *)cellModelForSelectedCellModel;

- (nullable __kindof LUITableViewModel *)forwardDataSourceTo:(nullable id<UITableViewDataSource>)dataSource;
- (nullable __kindof LUITableViewModel *)forwardDelegateTo:(nullable id<UITableViewDelegate>)delegate;

/**
 *  将tableView的dataSource和delegate设置为self.如果forwardDelegate要监听scrollViewDidScroll:事件,则必须在设置collectionView的delegate之前设置forwardDelegate,因为scrollView是在设置delegate时,去获取delegate是否实现scrollViewDidScroll:方法,后续就不会再获取了.
 *
 *  @param tableView 视图
 */
- (void)setTableViewDataSourceAndDelegate:(nullable UITableView *)tableView;


/**
 *    添加上自動分组的单元格数据,分组的索引值为cellModel.indexTitle值,僅當showSectionIndexTitle为YES时才會出现右侧的分组索引条
 *    @return 返回被归进的分组中,其中分组默认设置为显示系統自帶的title,title值为分组的索引值,
 */
- (nullable __kindof LUITableViewSectionModel *)addAutoIndexedCellModel:(LUITableViewCellModel *)cellModel;

/**
 *    按照字符串順序對分组進行排序
 */
- (void)sort;

/**
 *  刷新列表视图,会保持列表视图的选中状态
 */
- (void)reloadTableViewData;
- (void)reloadTableViewDataWithAnimated:(BOOL)animated;
/**
 *  动画的方式添加/删除单元格
 *
 *  @param cellModel  单元格数据
 *  @param animated   是否动画
 */
- (void)addCellModel:(LUITableViewCellModel *)cellModel animated:(BOOL)animated;

- (void)insertCellModel:(LUITableViewCellModel *)cellModel atIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;
- (void)insertCellModel:(LUITableViewCellModel *)cellModel afterIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;
- (void)insertCellModel:(LUITableViewCellModel *)cellModel beforeIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;

- (void)insertCellModels:(NSArray<LUITableViewCellModel *> *)cellModels afterIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;
- (void)insertCellModels:(NSArray<LUITableViewCellModel *> *)cellModels beforeIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;

- (void)insertCellModelsToBottom:(NSArray<LUITableViewCellModel *> *)cellModels scrollToBottom:(BOOL)scrollToBottom;//动画添加单元格到底部,section不存在时,会创建默认的section.会动画将将的单元格从下往上推入
- (void)insertCellModelsToTop:(NSArray<LUITableViewCellModel *> *)cellModels keepContentOffset:(BOOL)keepContentOffset;//添加单元格到顶部,section不存在时,会创建默认的section.keepContentOffset标志是否会保持画面不动

- (void)removeCellModel:(LUITableViewCellModel *)cellModel animated:(BOOL)animated;
- (void)removeCellModels:(NSArray<LUITableViewCellModel *> *)cellModels animated:(BOOL)animated;
- (void)removeCellModelsAtIndexPaths:(NSArray<NSIndexPath *> *)indexpaths animated:(BOOL)animated;

- (void)insertSectionModel:(LUITableViewSectionModel *)sectionModel atIndex:(NSInteger)index animated:(BOOL)animated;//动画添加分组
- (void)removeSectionModel:(LUITableViewSectionModel *)sectionModel animated:(BOOL)animated;//动画移除分组

- (void)deselectCellModels:(NSArray<LUICollectionCellModel *> *)cellModels animated:(BOOL)animated;
- (void)deselectAllCellModelsWithAnimated:(BOOL)animated;

- (void)selectCellModels:(NSArray<LUITableViewCellModel *> *)cellModels animated:(BOOL)animated;
- (void)selectAllCellModelsWithAnimated:(BOOL)animated;

- (void)setCellModel:(LUITableViewCellModel *)cellModel selected:(BOOL)selected animated:(BOOL)animated;
@end

NS_ASSUME_NONNULL_END
