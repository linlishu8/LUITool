//
//  LUITableViewSectionModel.h
//  LUITool
//
//  Created by 六月 on 2023/8/11.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "LUICollectionModel.h"
#import "LUICollectionCellModel.h"
#import "LUICollectionSectionModel.h"

NS_ASSUME_NONNULL_BEGIN

@class LUITableViewModel,LUITableViewCellModel,LUITableViewSectionModel;

@protocol LUITableViewSectionViewProtocol;

typedef void(^LUITableViewSectionModelS)(__kindof LUITableViewSectionModel *sectionModel,__kindof UIView *view);    //繪製該数据时觸發的动作

@interface LUITableViewSectionModel : LUICollectionSectionModel {
}
@property (nonatomic, strong, nullable) NSString *indexTitle;//本組的索引字符串
@property (nonatomic, assign, nullable) Class<LUITableViewSectionViewProtocol> headViewClass;//默认是UIView
@property (nonatomic, assign, nullable) Class<LUITableViewSectionViewProtocol> footViewClass;//默认是UIView

@property (nonatomic, assign) BOOL showHeadView;//是否显示頭部视图,默认为否
@property (nonatomic, assign) BOOL showFootView;//是否显示尾部视图,默认为否
@property (nonatomic, assign) BOOL showDefaultHeadView;//是否使用系統默认的頭部,默认为NO
@property (nonatomic, assign) BOOL showDefaultFootView;//是否使用系統默认的尾部,默认为NO
@property (nonatomic, assign) CGFloat headViewHeight;//使用系統默认的视图时,head视图高度
@property (nonatomic, assign) CGFloat footViewHeight;//使用系統默认的视图时,foot视图高度
@property (nonatomic, strong, nullable) NSString *headTitle;//head區域的字符串
@property (nonatomic, strong, nullable) NSString *footTitle;//foot區域的字符串

@property (nonatomic, readonly, nullable) UITableView *tableView;//弱引用外部的tableview
@property (nonatomic, weak, nullable) __kindof LUITableViewModel *tableViewModel;

@property (nonatomic, copy, nullable) LUITableViewSectionModelS whenShowHeadView;//显示自定義head视图的繪製block
@property (nonatomic, copy, nullable) LUITableViewSectionModelS whenShowFootView;//显示自定義foot视图的繪製block

- (nullable __kindof LUITableViewCellModel *)cellModelAtIndex:(NSInteger)index;

/**
 *  初始化一个显示空白头部的分组
 *
 *  @param height 头部的高度
 *
 *  @return 分组
 */
- (id)initWithBlankHeadView:(CGFloat)height;

/**
 *  初始化一个显示空白尾部的分组
 *
 *  @param height 尾部的高度
 *
 *  @return 分组
 */
- (id)initWithBlankFootView:(CGFloat)height;

/**
 *  初始化一个显示空白头部/尾部的分组
 *
 *  @param headViewHeight 头部高度
 *  @param footViewHeight 尾部高度
 *
 *  @return 分组
 */
- (id)initWithBlankHeadView:(CGFloat)headViewHeight footView:(CGFloat)footViewHeight;

/**
 *  设置显示系统默认的头部视图
 *
 *  @param height 视图高度
 */
- (void)showDefaultHeadViewWithHeight:(CGFloat)height;
/**
 *  设置显示系统默认的尾部视图
 *
 *  @param height 视图高度
 */
- (void)showDefaultFootViewWithHeight:(CGFloat)height;

- (void)displayHeadView:(UIView<LUITableViewSectionViewProtocol> *)view;
- (void)displayFootView:(UIView<LUITableViewSectionViewProtocol> *)view;

- (void)refresh;//刷新整個section
- (void)refreshWithAnimated:(BOOL)animated;
@end

NS_ASSUME_NONNULL_END
