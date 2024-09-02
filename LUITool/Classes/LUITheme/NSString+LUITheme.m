//
//  NSString+LUITheme.m
//  LUITool
//
//  Created by 六月 on 2023/9/2.
//

#import "NSString+LUITheme.h"

@implementation NSString (LUITheme)

- (NSString *)ltheme_uppercaseFirstLetterString{
    NSString *name = nil;
    if (self.length == 1) {
        name = self.uppercaseString;
    } else if (self.length > 1) {
        name = [NSString stringWithFormat:@"%@%@",[self substringToIndex:1].uppercaseString,[self substringFromIndex:1]];
    } else {
        name = self;
    }
    return name;
}
+ (SEL)ltheme_setSelectorForProperty:(NSString *)propertyName {
    NSString *selectorName = nil;
    selectorName = [NSString stringWithFormat:@"set%@:", propertyName.ltheme_uppercaseFirstLetterString];
    return NSSelectorFromString(selectorName);
}
+ (SEL)ltheme_setSelectorForStatedProperty:(NSString *)propertyName {
    NSString *selectorName = nil;
    selectorName = [NSString stringWithFormat:@"set%@:forState:", propertyName.ltheme_uppercaseFirstLetterString];
    return NSSelectorFromString(selectorName);
}

@end
