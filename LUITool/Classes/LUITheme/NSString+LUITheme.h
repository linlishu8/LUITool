//
//  NSString+LUITheme.h
//  LUITool
//
//  Created by 六月 on 2023/9/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (LUITheme)

- (NSString *)ltheme_uppercaseFirstLetterString;
+ (SEL)ltheme_setSelectorForProperty:(NSString *)propertyName;
+ (SEL)ltheme_setSelectorForStatedProperty:(NSString *)propertyName;

@end

NS_ASSUME_NONNULL_END
