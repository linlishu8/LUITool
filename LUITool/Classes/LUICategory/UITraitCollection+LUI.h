//
//  UITraitCollection+LUI.h
//  LUITool
//
//  Created by 六月 on 2024/8/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const kLUIUserInterfaceStyleChangeNotification;//系统黑暗模式变更通知

@interface UITraitCollection (LUI)

@property (class, nonatomic, readonly) BOOL l_isDarkStyle;//是否是处于黑暗模式

@end

NS_ASSUME_NONNULL_END
