//
//  LUITableViewSectionView.h
//  LUITool
//
//  Created by 六月 on 2024/8/13.
//

#import <UIKit/UIKit.h>
#import "LUITableViewSectionViewProtocol.h"
#define kMKUITableViewSectionViewDefaultHeight 22
NS_ASSUME_NONNULL_BEGIN

@interface LUITableViewSectionView : UIView <LUITableViewSectionViewProtocol>

@property (nonatomic, strong) __kindof LUITableViewSectionModel *sectionModel;
@property (nonatomic, assign) LUITableViewSectionViewKind kind;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *textLabel;

@end

NS_ASSUME_NONNULL_END
