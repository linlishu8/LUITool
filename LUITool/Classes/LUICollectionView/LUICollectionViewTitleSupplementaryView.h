//
//  LUICollectionViewTitleSupplementaryView.h
//  LUITool
//
//  Created by 六月 on 2024/8/16.
//

#import <UIKit/UIKit.h>
#import "LUICollectionViewTitleSupplementarySectionModel.h"
#import "LUIMacro.h"
#import "LUICollectionViewSupplementaryView.h"

NS_ASSUME_NONNULL_BEGIN

@interface LUICollectionViewTitleSupplementaryView : LUICollectionViewSupplementaryView

LUIAS_SINGLETON(LUICollectionViewTitleSupplementaryView);//此单例用于动态高度的计算
@property (nonatomic, strong, nullable) LUICollectionViewTitleSupplementarySectionModel *titleSectionModel;
@property (nonatomic, strong) UILabel *textLabel;
+ (UIEdgeInsets)contentInsets;

@end

NS_ASSUME_NONNULL_END
