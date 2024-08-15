//
//  LUICollectionView.h
//  LUITool
//
//  Created by 六月 on 2024/8/15.
//

#import <UIKit/UIKit.h>
#import "LUICollectionViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LUICollectionView : UICollectionView

@property (nonatomic, strong, nullable) LUICollectionViewModel *model;

@end

NS_ASSUME_NONNULL_END
