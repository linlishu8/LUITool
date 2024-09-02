//
//  LUIThemeCenterElement.h
//  LUITool
//
//  Created by 六月 on 2023/9/2.
//

#import <Foundation/Foundation.h>
#import "LUIThemeElementProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface LUIThemeCenterElement : NSObject <LUIThemeElementProtocol>

@property (nonatomic, strong) NSString *key;

+ (instancetype)themeElementForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
