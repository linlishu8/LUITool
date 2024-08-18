//
//  LUIEdgeInsetsUILabel.h
//  LUITool
//
//  Created by 六月 on 2024/8/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LUIEdgeInsetsUILabel : UILabel
@property (nonatomic, assign) BOOL fillContainerWidth;//sizeThatFit时，是否填充整个容器的宽度，默认为NO
@property (nonatomic) UIEdgeInsets contentInset;
@end

NS_ASSUME_NONNULL_END
