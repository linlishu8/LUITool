//
//  LUIDefine_EnumUtil.h
//  LUITool
//
//  Created by 六月 on 2023/8/14.
//

//添加enum类型与NSString转换的便捷宏###########################{
/*
 
LUIAS_EnumTypeCategories(UIViewAnimationCurve)
@@interface MyClass
@end
 
 
LUIDEF_EnumTypeCategories(UIViewAnimationCurve,(@{
    @(UIViewAnimationCurveEaseInOut):@"EaseInOut",
    @(UIViewAnimationCurveEaseIn):@"EaseIn",
    @(UIViewAnimationCurveEaseOut):@"EaseOut",
    @(UIViewAnimationCurveLinear):@"Linear",
}));
@implementation MyClass
+ (void)load {
    NSDictionary *json = @{@"key1":@"1",@"key2":@1,@"key3":@"EaseIn"};
    UIViewAnimationCurve mode = [json UIViewAnimationCurveAtPath:@"key1" otherwise:UIViewAnimationCurveEaseInOut];
}
@end
 */


//enum=>NSString
#define LUIAS_EnumValueToNSString(EnumType)\
+ (nonnull NSString *)stringWith##EnumType:(EnumType)value;
#define LUIDEF_EnumValueToNSString(EnumType,__staticMapDictionary)\
+ (NSString *)stringWith##EnumType:(EnumType)enumValue{\
    static NSDictionary<NSNumber*,NSString *> *staticMap;\
    if (!staticMap) {\
        NSDictionary *mapDictionary = (__staticMapDictionary);\
        NSMutableDictionary<NSNumber *,NSString *> *map = [[NSMutableDictionary alloc] initWithCapacity:mapDictionary.count];\
        for (id key in mapDictionary) {\
            id value = [mapDictionary objectForKey:key];\
            if ([key isKindOfClass:[NSNumber class]]) {\
                [map setObject:value forKey:key];\
            } else {\
                [map setObject:key forKey:value];\
            }\
        }\
        staticMap = (map);\
    }\
    NSString *str = staticMap[@(enumValue)];\
    if (!str) {\
        str = [@(enumValue) stringValue];\
    }\
    return str;\
}
//NSString=>enum
#define LUIAS_EnumValueFromNSString(EnumType)\
- (EnumType)EnumType;\
- (EnumType)EnumType##WithOtherwise:(EnumType)otherwise;
#define LUIDEF_EnumValueFromNSString(EnumType,__staticMapDictionary)\
- (EnumType)EnumType{\
    return [self EnumType##WithOtherwise:(EnumType)0];\
}\
- (EnumType)EnumType##WithOtherwise:(EnumType)otherwise{\
    static NSDictionary<NSString *,NSNumber *> *staticMap;\
    if (!staticMap) {\
        NSDictionary *mapDictionary = (__staticMapDictionary);\
        NSMutableDictionary<NSString *,NSNumber *> *map = [[NSMutableDictionary alloc] initWithCapacity:mapDictionary.count];\
        for (id key in mapDictionary) {\
            id value = [mapDictionary objectForKey:key];\
            if ([key isKindOfClass:[NSNumber class]]) {\
                [map setObject:key forKey:value];\
            } else {\
                [map setObject:value forKey:key];\
            }\
        }\
        staticMap = map;\
    }\
    NSNumber *number = nil;\
    NSScanner *scanner = [[NSScanner alloc] initWithString:self];\
    NSInteger value;\
    if ([scanner scanInteger:&value] && scanner.isAtEnd) {\
        number = @(value);\
    }\
    if (number != nil) {\
        return [number EnumType##WithOtherwise:otherwise];\
    }\
    number = [staticMap objectForKey:self];\
    if (number != nil) {\
        return (EnumType)[number integerValue];\
    }\
    return otherwise;\
}
//NSNumber=>enum
#define LUIAS_EnumValue_NSNumber(EnumType)\
- (EnumType)EnumType;\
- (EnumType)EnumType##WithOtherwise:(EnumType)otherwise;
#define LUIDEF_EnumValueFromNSNumber(EnumType,__staticMapDictionary)\
- (EnumType)EnumType{\
    return [self EnumType##WithOtherwise:(EnumType)0];\
}\
- (EnumType)EnumType##WithOtherwise:(EnumType)otherwise{\
    static NSDictionary<NSString *,NSNumber *> *staticMap;\
    if (!staticMap) {\
        NSDictionary *mapDictionary = (__staticMapDictionary);\
        NSMutableDictionary<NSString *,NSNumber *> *map = [[NSMutableDictionary alloc] initWithCapacity:mapDictionary.count];\
        for (id key in mapDictionary) {\
            id value = [mapDictionary objectForKey:key];\
            if ([key isKindOfClass:[NSNumber class]]) {\
                [map setObject:key forKey:value];\
            } else {\
                [map setObject:value forKey:key];\
            }\
        }\
        staticMap = map;\
    }\
    EnumType enumValue = otherwise;\
    if ([staticMap.allValues containsObject:self]) {\
        enumValue = (EnumType)[self integerValue];\
    }\
    return enumValue;\
}


//enum<=>NSString
#define LUIAS_EnumValue_NSString(EnumType)\
LUIAS_EnumValueToNSString(EnumType)\
LUIAS_EnumValueFromNSString(EnumType)
#define LUIDEF_EnumValue_NSString(EnumType,__staticMapDictionary)\
LUIDEF_EnumValueToNSString(EnumType,__staticMapDictionary)\
LUIDEF_EnumValueFromNSString(EnumType,__staticMapDictionary)

//定义NSString(enum)的类别
#define LUIAS_EnumTypeCategoryToNSString(EnumType)\
@interface NSString(EnumType)\
LUIAS_EnumValue_NSString(EnumType)\
@end
#define LUIDEF_EnumTypeCategoryToNSString(EnumType,__staticMapDictionary)\
@implementation NSString(EnumType)\
LUIDEF_EnumValue_NSString(EnumType,(__staticMapDictionary))\
@end

//定义NSNumber(enum)的类别
#define LUIAS_EnumTypeCategoryToNSNumber(EnumType)\
@interface NSNumber(EnumType)\
LUIAS_EnumValue_NSNumber(EnumType)\
@end
#define LUIDEF_EnumTypeCategoryToNSNumber(EnumType,__staticMapDictionary)\
@implementation NSNumber(EnumType)\
LUIDEF_EnumValueFromNSNumber(EnumType,(__staticMapDictionary))\
@end


//添加enum类型数据从NSDictionary中获取的便捷宏
//NSDictionary[path]=>enum
#define LUIAS_EnumValueFromNSDictionaryAtPath(EnumType)\
- (EnumType)EnumType##AtPath:(NSString *)path;\
- (EnumType)EnumType##AtPath:(NSString *)path otherwise:(EnumType)otherwise;
#define LUIDEF_EnumValueFromNSDictionaryAtPath(EnumType)\
- (EnumType)EnumType##AtPath:(NSString *)path {\
    return [self EnumType##AtPath:path otherwise:(EnumType)0];\
}\
- (EnumType)EnumType##AtPath:(NSString *)path otherwise:(EnumType)otherwise{\
    id obj = [self valueForKeyPath:path];\
    if (obj == [NSNull null]) {\
        obj = nil;\
    }\
    if (obj == nil) return otherwise;\
    if ([obj isKindOfClass:[NSNumber class]]) {\
        return [(NSNumber *)obj EnumType##WithOtherwise:otherwise];\
    }\
    if ([obj isKindOfClass:[NSString class]]) {\
        return [(NSString *)obj EnumType##WithOtherwise:otherwise];\
    }\
    return [[obj description] EnumType##WithOtherwise:otherwise];\
}

//NSDictionary[path]|otherwise=>enum,NSDictionary[path]=>enum
#define LUIAS_EnumValueFromNSDictionary(EnumType)\
LUIAS_EnumValueFromNSDictionaryAtPath(EnumType)
#define LUIDEF_EnumValueFromNSDictionary(EnumType)\
LUIDEF_EnumValueFromNSDictionaryAtPath(EnumType)

//定义NSDictionary(enum)的类别
#define LUIAS_EnumTypeCategoryToNSDictionary(EnumType)\
@interface NSDictionary(EnumType)\
LUIAS_EnumValueFromNSDictionary(EnumType)\
@end
#define LUIDEF_EnumTypeCategoryToNSDictionary(EnumType)\
@implementation NSDictionary(EnumType)\
LUIDEF_EnumValueFromNSDictionary(EnumType)\
@end

//给Enum添加NSString与NSDictionry的category
/*
 
__staticMapDictionary为NSDicionary<NSNumber *,NSString *>,key为enum取值的NSNumber,value为enum值对应的NSString,例如:
 
 LUIDEF_EnumTypeCategories(UIViewAnimationCurve,(@{
    @(UIViewAnimationCurveEaseInOut):@"EaseInOut",
    @(UIViewAnimationCurveEaseIn):@"EaseIn",
    @(UIViewAnimationCurveEaseOut):@"EaseOut",
    @(UIViewAnimationCurveLinear):@"Linear",
 }));
 
 */
#define LUIAS_EnumTypeCategories(EnumType)\
LUIAS_EnumTypeCategoryToNSString(EnumType)\
LUIAS_EnumTypeCategoryToNSNumber(EnumType)\
LUIAS_EnumTypeCategoryToNSDictionary(EnumType)
#define LUIDEF_EnumTypeCategories(EnumType,__staticMapDictionary)\
LUIDEF_EnumTypeCategoryToNSString(EnumType,__staticMapDictionary)\
LUIDEF_EnumTypeCategoryToNSNumber(EnumType,__staticMapDictionary)\
LUIDEF_EnumTypeCategoryToNSDictionary(EnumType)

//添加enum类型与NSString转换的便捷宏###########################}



//添加Mask类型与NSString转换的便捷宏###########################{
//OptionMask掩码值=>NSString
#define LUIAS_OptionValue_NSString(OptionType)\
+ (nullable NSString *)stringWithOPTIONS##OptionType:(OptionType)optionValue;

#define LUIDEF_OptionValue_NSString(OptionType,__staticMapDictionary)\
+ (NSString *)stringWithOPTIONS##OptionType:(OptionType)optionValue{\
    NSMutableArray<NSString *> *masks = [[NSMutableArray alloc] init];\
    static NSDictionary<NSNumber *,NSString *> *staticMap;\
    if (!staticMap) {\
        NSDictionary *mapDictionary = (__staticMapDictionary);\
        NSMutableDictionary<NSNumber *,NSString *> *map = [[NSMutableDictionary alloc] initWithCapacity:mapDictionary.count];\
        for (id key in mapDictionary) {\
            id value = [mapDictionary objectForKey:key];\
            if ([key isKindOfClass:[NSNumber class]]) {\
                [map setObject:value forKey:key];\
            } else {\
                [map setObject:key forKey:value];\
            }\
        }\
        staticMap = map;\
    }\
    for (NSNumber *num in staticMap) {\
        OptionType v = (OptionType)[num integerValue];\
        if ((optionValue&v) == v) {\
            NSString *s = staticMap[num];\
            [masks addObject:s];\
        }\
    }\
    NSString *str = [masks componentsJoinedByString:@"|"];\
    return str;\
}
//添加Mask类型与NSString转换的便捷宏###########################}
