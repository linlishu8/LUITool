//
//  LUIModelBase.m
//  LUITool
//
//  Created by 六月 on 2023/8/11.
//

#import "LUICollectionModelObjectBase.h"

@interface LUICollectionModelObjectBase() {
    NSMutableDictionary *_dynamicProperties;
}
@end
@implementation LUICollectionModelObjectBase
- (id)init {
    if (self = [super init]) {
        _dynamicProperties = [[NSMutableDictionary alloc] init];
    }
    return self;
}
- (id)copyWithZone:(NSZone *)zone {
    LUICollectionModelObjectBase *obj = [self.class allocWithZone:zone];
    obj->_dynamicProperties = [_dynamicProperties mutableCopy];
    obj.modelValue = self.modelValue;
    return obj;
}
+ (LUICollectionModelObjectBase *)modelWithValue:(nullable id)modelVaule {
    LUICollectionModelObjectBase *m = [[self alloc] init];
    m.modelValue = modelVaule;
    return m;
}
- (NSMutableDictionary *)dynamicProperties{
    return _dynamicProperties;
}
- (void)setObject:(nullable id)obj forKeyedSubscript:(id<NSCopying>)key {
    if (obj == nil) {
        [_dynamicProperties removeObjectForKey:key];
    } else {
        _dynamicProperties[key] = obj;
    }
}
- (nullable id)objectForKeyedSubscript:(id<NSCopying>)key {
    id value = _dynamicProperties[key];
    return value;
}
@end
#import "NSObject+LUI.h"
@implementation LUICollectionModelObjectBase(LUI_ValueForKeyPathOtherwise)
- (nullable id)l_valueForKeyPath:(NSString *)path otherwise:(nullable id)other {
    return [_dynamicProperties l_valueForKeyPath:path otherwise:other];
}
@end
