//
//  UITableViewCell+LUI.h
//  LUITool
//
//  Created by 六月 on 2023/8/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern CGFloat const kLUIAccessoryTypeDefaultLeftMargin;//系统操作区域左边距默认值=10
extern CGFloat const kLUIAccessoryTypeDefaultRightMargin;//系统操作区域右边距默认值=15

@interface UITableViewCell (LUI)
//系统操作区域视图宽度
@property (nonatomic, readonly) CGFloat l_accessorySystemTypeViewWidth;
//系统操作区域视图与contentView的左边距
@property (nonatomic, readonly) CGFloat l_accessorySystemTypeViewLeftMargin;
//系统操作区域视图与UITableViewCell的右边距
@property (nonatomic, readonly) CGFloat l_accessorySystemTypeViewRightMargin;

//自定义操作区域视图与contentView的左边距
@property (nonatomic, readonly) CGFloat l_accessoryCustomViewLeftMargin;
//自定义操作区域视图与UITableViewCell的右边距
@property (nonatomic, readonly) CGFloat l_accessoryCustomViewRightMargin;

//自定义或系统操作区域视图与contentView的左边距
@property (nonatomic, readonly) CGFloat l_accessoryViewLeftMargin;
//自定义或系统操作区域视图与UITableViewCell的右边距
@property (nonatomic, readonly) CGFloat l_accessoryViewRightMargin;

/**
 计算cell在指定最大size的情况下,最合适的size值.使用calBlock时,不需要考虑safeAreaInsets,accessoryView,accessoryType,分割线等尺寸
 计算UITableViewCell的高度值,如果返回UITableViewAutomaticDimension,则系统会去调用Cell的sizeThatFits方法,将该返回的height值作为Cell的高度值.
 @param size 外层size值
 @param block 输入contentView的尺寸,计算出在该尺寸下,cell最合适的高度值.该高度值不需要考虑分割线值
 @return cell的最适合的高度值
 */
- (CGSize)l_sizeThatFits:(CGSize)size sizeFitsBlock:(CGSize(^ __nullable)(CGSize size))block;
@end

NS_ASSUME_NONNULL_END
