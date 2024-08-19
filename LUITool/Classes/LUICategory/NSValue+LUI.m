//
//  NSValue+LUI.m
//  LUITool
//
//  Created by 六月 on 2024/8/19.
//

#import "NSValue+LUI.h"

@implementation NSValue (LUICGRange)
+ (NSValue *)valueWithLUICGRange:(LUICGRange)r {
    NSValue *value = [NSValue value:&r withObjCType:@encode(LUICGRange)];
    return value;
}
- (LUICGRange)LUICGRangeValue {
    LUICGRange range;
    [self getValue:&range];
    return range;
}
@end
