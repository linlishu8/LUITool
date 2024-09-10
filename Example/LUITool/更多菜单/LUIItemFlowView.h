//
//  LUIItemFlowView.h
//  LUITool_Example
//
//  Created by 六月 on 2023/9/9.
//  Copyright © 2024 Your Name. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface LUIItemFlowView : UIView

@property (nonatomic, strong) LUILayoutButton *directionButton;//横向、竖向按钮
@property (nonatomic, strong) LUItemFlowCollectionView *itemFlowView;//tab菜单
@property (nonatomic, assign) BOOL directionVertical;//是否竖向


/// 返回高度
/// - Parameter directionVertical: 是否竖向
+ (CGFloat)sizeWithDirectionVertical:(BOOL)directionVertical;

@end

NS_ASSUME_NONNULL_END
