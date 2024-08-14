//
//  LUITableViewSectionAdjustsView.h
//  LUITool
//
//  Created by 六月 on 2021/8/13.
//

#import "LUITableViewSectionView.h"

NS_ASSUME_NONNULL_BEGIN

@interface LUITableViewSectionAdjustsView : LUITableViewSectionView

+ (UIEdgeInsets)contentMargin;//返回UIEdgeInsetsMake(8, 16, 8, 16)
/**
 *  只显示头部,分组高度自适应
 *
 *  @param title 标题
 *
 *  @return 分组
 */
+ (LUITableViewSectionModel *)sectionModelWithHeadTitle:(nullable NSString *)title;
/**
 *  只显示尾部,分组高度自适应
 *
 *  @param title 标题
 *
 *  @return 分组
 */
+ (LUITableViewSectionModel *)sectionModelWithFootTitle:(nullable NSString *)title;

/**
 *  分组高度自适应
 *
 *  @param headTitle 头部标题
 *  @param footTitle 尾部标题
 *
 *  @return 分组
 */
+ (LUITableViewSectionModel *)sectionModelWithHeadTitle:(nullable NSString *)headTitle footTitle:(nullable NSString *)footTitle;
@end

NS_ASSUME_NONNULL_END
