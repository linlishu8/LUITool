//
//  LUITableViewCellBase.h
//  LUITool
//
//  Created by 六月 on 2021/8/13.
//

#import <UIKit/UIKit.h>
#import "LUITableViewCellProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface LUITableViewCellBase : UITableViewCell<LUITableViewCellProtocol>
@property (nonatomic, readonly) BOOL isCellModelChanged;//cellModel是否有变化
@property (nonatomic, strong, nullable) __kindof LUITableViewCellModel *cellModel;
@property (nonatomic, readonly,class) BOOL useCachedFitedSize;//是否缓存sizeThatFits:的结果，默认为YES

- (void)customReloadCellModel;//cellModel变更时，更新视图内容。@override
- (void)customLayoutSubviews;//cellModel变更时，重新布局视图。@override
- (CGSize)customSizeThatFits:(CGSize)size;
//计算动态尺寸,该方法会在l_sizeThatFits:sizeFitsBlock:的block中执行。@override
@end

NS_ASSUME_NONNULL_END
