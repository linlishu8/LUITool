//
//  LUIThemeElementProtocol.h
//  LUITool
//  返回主题对象的封装
//  Created by 六月 on 2021/8/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LUIThemeElementProtocol <NSObject>

@property (nonatomic, readonly, nullable) id<NSObject> themeElement;//返回主题对象

@end

NS_ASSUME_NONNULL_END
