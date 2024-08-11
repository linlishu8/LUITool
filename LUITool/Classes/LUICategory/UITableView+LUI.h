//
//  UITableView+LUI.h
//  LUITool
//
//  Created by 六月 on 2024/8/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITableView (LUI)
/**
 *  如果tableview为group类型,且含有tablefootview,且自定了section的头部视图高度时,它的tablehead会有多余的空白,此方法用于去除该空白
 */
- (void)l_hiddenHeaderAreaBlank;
/**
 *  隐藏表尾区域上多余的单元格分隔线
 */
- (void)l_hiddenFooterAreaSeparators;
/**
 *  查找显示面积最大的单元格索引
 *
 *  @return 索引
 */
- (nullable NSIndexPath *)l_indexPathForMaxVisibleArea;

@property (nonatomic, readonly) CGFloat l_separatorHeight;//系统分割线的高度值
//ios10、11、12时，cell的contentView尺寸会被压缩，扣掉分隔线的调度
//ios13时，cell的高度会被系统自动添加上分隔线的高度
+ (BOOL)l_isAutoAddSeparatorHeightToCell;

/// 返回指定单元格类的可视单元格
/// @param cellClass 可视的单元格
- (NSArray<__kindof UITableViewCell *> *)l_visibleCellsWithClass:(Class)cellClass;
@end
@interface UITableView(l_SizeFits)

/// 计算tableview在指定宽度下，最合适的高度值
/// @param boundsWidth 宽度
- (CGFloat)l_heightThatFits:(CGFloat)boundsWidth;
@end

NS_ASSUME_NONNULL_END
