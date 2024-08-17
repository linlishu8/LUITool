//
//  LUITableViewCellModel.h
//  LUITool
//
//  Created by 六月 on 2023/8/11.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LUICollectionModel.h"
#import "LUICollectionCellModel.h"
#import "LUICollectionSectionModel.h"
#import "LUITableViewCellSwipeAction.h"
NS_ASSUME_NONNULL_BEGIN

@class LUITableViewModel,LUITableViewSectionModel,LUITableViewCellModel;

@protocol LUITableViewCellProtocol;

typedef void(^LUITableViewCellModelBlockC)(__kindof LUITableViewCellModel *cellModel);    //点击该数据时触发的动作
typedef void(^LUITableViewCellModelBlockP)(__kindof LUITableViewCellModel *cellModel,BOOL selected);    //被触控事件选中是触发
typedef void(^LUITableViewCellModelBlockD)(__kindof LUITableViewCellModel *cellModel);    //刪除数据时触发
typedef void(^LUITableViewCellModelBlockM)(__kindof LUITableViewCellModel *src,
                                          __kindof LUITableViewCellModel *dst);    //移动数据时触发
typedef void(^LUITableViewCellModelBlockS)(__kindof LUITableViewCellModel *cellModel,
                                          __kindof UITableViewCell<LUITableViewCellProtocol> *cellView);    //繪製該数据时觸發的动作

@interface LUITableViewCellModel : LUICollectionCellModel {
@protected
    BOOL _selected;
    NSString *_reuseIdentity;
}
@property (nonatomic, assign) Class<LUITableViewCellProtocol> cellClass;            //对应的cell類,實例化时默认设置为UITableViewCell
@property (nonatomic, strong, nullable) NSString *indexTitle;//自動進行分组时,使用的索引值
@property (nonatomic, assign) BOOL canEdit;//是否可以被編輯
@property (nonatomic, assign) BOOL canMove;//是否可以被移動

@property (nonatomic, copy, nullable) LUITableViewCellModelBlockC whenClick;//点击触发
@property (nonatomic, copy, nullable) LUITableViewCellModelBlockP whenSelected;//被触控事件选中时触发
@property (nonatomic, copy, nullable) LUITableViewCellModelBlockC whenClickAccessory;//操作按鈕被點擊时的action
@property (nonatomic, copy, nullable) LUITableViewCellModelBlockD whenDelete;//删除触发.返回YES时，将会将model中删除自身,并动画删除cell
@property (nonatomic, copy, nullable) LUITableViewCellModelBlockM whenMove;//移動位置觸發

@property (nonatomic, copy, nullable) LUITableViewCellModelBlockS whenShow;//设置cell繪製的block,在cell被显示时進行自定義畫面的處理.一般是用於cellClass=UITableViewCell时,對UITableViewCell的內容進行定制.如需要更複雜的控制,請創建UITableViewCell的子類來实现.

//左滑显示更多按钮
@property (nonatomic, strong, nullable) NSArray<LUITableViewCellSwipeAction *> *swipeActions;
@property (nonatomic, assign) BOOL performsFirstActionWithFullSwipe;// default YES, set to NO to prevent a full swipe from performing the first action

@property (nonatomic, strong, nullable) NSArray<LUITableViewCellSwipeAction *> *leadingSwipeActions;//右滑显示的按钮

@property (nonatomic, readonly, nullable) NSArray<UITableViewRowAction *> *editActions;
- (nullable UISwipeActionsConfiguration *)swipeActionsConfigurationWithIndexPath:(NSIndexPath *)indexPath leading:(BOOL)leading API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(tvos);

@property (nonatomic, readonly, nullable) __kindof LUITableViewModel *tableViewModel;//弱引用外部的tableViewModel
@property (nonatomic, weak, nullable) __kindof UITableViewCell *tableViewCell;//弱引用对应的cell视图
@property (nonatomic, readonly, nullable) UITableView *tableView;//弱引用外部的tableview
@property (nonatomic, assign) UITableViewCellStyle cellStyle;//cell视图的style值,对应于cell.cellStyle
@property (nonatomic, strong) NSString *reuseIdentity;//用於列表重用单元格视图时的标志符,默认为NSStringFromCGClass(self.class)。如果cell的绘制很耗时，可以考虑将reuseIdentity设置为唯一值，防止tableView的重用，以减少重绘次数，提升滚动性能。
+ (instancetype)modelWithValue:(nullable id)modelValue cellClass:(Class)cellClass;
+ (instancetype)modelWithValue:(nullable id)modelValue cellClass:(Class)cellClass whenClick:(nullable LUITableViewCellModelBlockC)whenClick;

- (void)didClickSelf;
- (void)didClickAccessorySelf;
- (void)didSelectedSelf:(BOOL)selected;
- (void)didDeleteSelf;
- (nullable __kindof LUITableViewSectionModel *)sectionModel;

/**
 *    tableview在生成UITableViewCell时,手动绘制cell的內容,默认是调用whenShow的block
 */
- (void)displayCell:(UITableViewCell<LUITableViewCellProtocol> *)cell;

@property (nonatomic) BOOL needReloadCell;//是否需要更新cell的视图内容

/**
 *    刷新视图
 *  reload cell时，系统将会重新实例化一个cell。如果animated=YES时，新的cell将与旧的cell，进行一个fadein、fadeout动画效果。
 *  cell下方可视区域的单元格，也会被重新加载显示
 */
- (void)refresh;
- (void)refreshWithAnimated:(BOOL)animated;
/**
 取消选中某一个Cell
 */
- (void)deselectCellWithAnimated:(BOOL)animated;

- (void)selectCellWithAnimated:(BOOL)animated;
- (void)setSelected:(BOOL)selected animated:(BOOL)animated;

- (void)setFocused:(BOOL)focused refreshed:(BOOL)refreshed;

/// 从tableview中移除单元格
/// @param animated 是否展示动画效果
- (void)removeFromModelWithAnimated:(BOOL)animated;
@end

NS_ASSUME_NONNULL_END
