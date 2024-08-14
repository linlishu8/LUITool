//
//  NSString+LUI.m
//  LUITool
//
//  Created by 六月 on 2023/8/11.
//

#import "NSString+LUI.h"

@implementation NSString (LUI)

- (NSNumber *)l_numberValue {
    NSNumber *number;
    number = [self l_numberOfInteger];
    if (number == nil) {
        number = [self l_numberOfLongLong];
    }
    if (number == nil) {
        number = [self l_numberOfCGFloat];
    }
    return number;
}
- (NSNumber *)l_numberOfInteger {
    NSScanner *scanner = [[NSScanner alloc] initWithString:self];
    NSInteger value;
    if ([scanner scanInteger:&value]&&scanner.isAtEnd) {
        return @(value);
    }
    return nil;
}
- (NSNumber *)l_numberOfLongLong {
    NSScanner *scanner = [[NSScanner alloc] initWithString:self];
    long long value;
    if ([scanner scanLongLong:&value]&&scanner.isAtEnd) {
        return @(value);
    }
    return nil;
}
- (NSNumber *)l_numberOfCGFloat {
#if defined(__LP64__) && __LP64__
    return [self l_numberOfDouble];
#else
    return [self l_numberOfFloat];
#endif
}
- (NSNumber *)l_numberOfFloat {
    NSScanner *scanner = [[NSScanner alloc] initWithString:self];
    float value;
    if ([scanner scanFloat:&value]&&scanner.isAtEnd) {
        return @(value);
    }
    return nil;
}
- (NSNumber *)l_numberOfDouble {
    NSScanner *scanner = [[NSScanner alloc] initWithString:self];
    double value;
    if ([scanner scanDouble:&value]&&scanner.isAtEnd) {
        return @(value);
    }
    return nil;
}

- (id)l_jsonValue {
    if (self.length==0)return nil;
    NSError *error = nil;
    id obj =[NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    if (obj==nil && error!=nil)  {
#ifdef DEBUG
        NSLog(@"jsonValue:%@ error:%@",self,error);
#endif
    }
    return obj;
}
- (NSDictionary *)l_jsonDictionary {
    id obj = [self l_jsonValue];
    if ([obj isKindOfClass:[NSDictionary class]])  {
        return obj;
    } else {
        return nil;
    }
}
- (NSArray *)l_jsonArray {
    id obj = [self l_jsonValue];
    if ([obj isKindOfClass:[NSArray class]])  {
        return obj;
    } else {
        return nil;
    }
}

@end
