//
//  LUICollectionViewSupplementaryView.h
//  LUITool
//
//  Created by 六月 on 2024/8/16.
//

#import <UIKit/UIKit.h>
#import "LUICollectionViewSupplementaryElementProtocol.h"
#import "LUICollectionViewSectionModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LUICollectionViewSupplementaryView : UICollectionReusableView <LUICollectionViewSupplementaryElementProtocol>

@property (nonatomic, strong, nullable) UIView *contentView;
@property (nonatomic, strong, nullable) __kindof LUICollectionViewSectionModel *sectionModel;
@property (nonatomic, strong, nullable) NSString *kind;

@end

NS_ASSUME_NONNULL_END
