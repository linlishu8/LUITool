//
//  LUICollectionViewFlowLayout.h
//  LUITool
//
//  Created by 六月 on 2024/8/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LUICollectionViewDelegateFlowLayout <UICollectionViewDelegate>
@optional
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout maximumInteritemSpacingForSectionAtIndex:(NSInteger)section;
@end

extern const NSInteger kLUICollectionViewFlowLayoutNoMaximumInteritemSpacing;//不限制最大间隔

@interface LUICollectionViewFlowLayout : UICollectionViewFlowLayout
//InteritemSpacing为两个cell之间，在滚动方向的间隔。当垂直滚动时，为两个cell的上下间隔；当水平滚动时，为两个cell的左右间隔。

//cell沿滚动方向上的间隔spacing,满足条件：minimumInteritemSpacing <= spacing <= maximumInteritemSpacing
@property (nonatomic) CGFloat maximumInteritemSpacing;//默认为不限最大值kLUICollectionViewFlowLayoutNoMaximumInteritemSpacing
@end

@interface LUICollectionViewFlowLayout (LUICollectionViewDelegateFlowLayout)
@property(nonatomic,readonly,nullable)
id<LUICollectionViewDelegateFlowLayout> l_LUIFlowLayoutDelegate;
- (CGFloat)l_maximumInteritemSpacingForSectionAtIndex:(NSInteger)index;
@end


//元素间距固定为minimumInteritemSpacing
@interface LUICollectionViewFixInteritemSpacingFlowLayout : LUICollectionViewFlowLayout//元素间隔固定为minimumInteritemSpacing
@end

NS_ASSUME_NONNULL_END
