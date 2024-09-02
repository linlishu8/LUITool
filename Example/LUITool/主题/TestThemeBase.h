//
//  TestThemeBase.h
//  LUITool_Example
//
//  Created by 六月 on 2024/9/2.
//  Copyright © 2024 Your Name. All rights reserved.
//

#import "TestThemeProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface TestThemeBase : LUITheme <TestThemeProtocol>

@property (nonatomic, readonly) BOOL dark;

@end

NS_ASSUME_NONNULL_END
