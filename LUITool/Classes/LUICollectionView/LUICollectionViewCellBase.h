//
//  LUICollectionViewCellBase.h
//  LUITool
//
//  Created by 六月 on 2024/8/16.
//

#import <UIKit/UIKit.h>
#import "LUICollectionViewCellProtocol.h"
#import "LUICollectionViewCellModel.h"
#import "LUIMacro.h"

NS_ASSUME_NONNULL_BEGIN

@interface LUICollectionViewCellBase : UICollectionViewCell <LUICollectionViewCellProtocol>

@property (nonatomic, strong, nullable) __kindof  LUICollectionViewCellModel *collectionCellModel;//数据模型
@property (nonatomic, readonly) BOOL isCellModelChanged;//cellmodel是否有变化

//是否缓存sizeThatFits:的结果，默认为YES
@property (nonatomic, readonly, class) BOOL useCachedFitedSize;
@property (nonatomic, readonly) BOOL isSharedInstance;
//单例，用于计算动态尺寸(实现使用LUIDEF_SINGLETON_SUBCLASS)
LUIAS_SINGLETON(LUICollectionViewCellBase)

- (void)customReloadCellModel;//cellModel变更时，更新视图内容。@override
- (void)customLayoutSubviews;//cellModel变更时，重新布局视图。@override

//计算动态尺寸,该方法会在dynamicSizeWithCollectionView的block中执行。@override
- (CGSize)customSizeThatFits:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
