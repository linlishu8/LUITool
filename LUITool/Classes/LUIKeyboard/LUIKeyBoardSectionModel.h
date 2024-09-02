//
//  LUIKeyBoardSectionModel.h
//  LUITool
//
//  Created by 六月 on 2023/8/20.
//

#import "LUICollectionViewSectionModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LUIKeyBoardSectionModel : LUICollectionViewSectionModel

@property (nonatomic) CGFloat l_otherLength;//特殊按钮占去的长度
@property (nonatomic) NSInteger l_numberOfOtherButtons;//不等长按钮的个数
@property (nonatomic) CGFloat l_maxHeight;//如果section里有设置了高度，获取最大值给section里的cell

@end

NS_ASSUME_NONNULL_END
