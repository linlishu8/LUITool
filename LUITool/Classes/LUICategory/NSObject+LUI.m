//
//  NSObject+LUI.m
//  LUITool
//
//  Created by 六月 on 2023/8/11.
//

#import "NSObject+LUI.h"
#import "NSString+LUI.h"

@implementation NSObject (LUI_ValueForKeyPath)

- (nullable id)l_valueForKeyPath:(NSString *)path {
    return [self l_valueForKeyPath:path otherwise:nil];
}
- (nullable id)l_valueForKeyPath:(NSString *)path otherwise:(nullable id)other {
    id obj = [self valueForKeyPath:path];
    id value = obj;
    if (!value) {
        value = other;
    }
    return value;
}
- (nullable NSArray *)l_arrayForKeyPath:(NSString *)path {
    return [self l_arrayForKeyPath:path otherwise:nil];
}
- (nullable NSArray *)l_arrayForKeyPath:(NSString *)path otherwise:(nullable NSArray *)other {
    id obj = [self l_valueForKeyPath:path otherwise:other];
    NSArray *value = nil;
    if ([obj isKindOfClass:[NSArray class]]) {
        value = obj;
    } else if ([obj isKindOfClass:[NSString class]]) {
        value = [(NSString *)obj l_jsonArray];
    }
    if (!value) {
        value = other;
    }
    return value;
}
- (nullable NSDictionary *)l_dictionaryForKeyPath:(NSString *)path {
    return [self l_dictionaryForKeyPath:path otherwise:nil];
}
- (nullable NSDictionary *)l_dictionaryForKeyPath:(NSString *)path otherwise:(nullable NSDictionary *)other {
    id obj = [self l_valueForKeyPath:path otherwise:other];
    NSDictionary *value = nil;
    if ([obj isKindOfClass:[NSDictionary class]]) {
        value = obj;
    } else if ([obj isKindOfClass:[NSString class]]) {
        value = [(NSString *)obj l_jsonDictionary];
    }
    if (!value) {
        value = other;
    }
    return value;
}

- (nullable NSString *)l_stringForKeyPath:(NSString *)path {
    return [self l_stringForKeyPath:path otherwise:nil];
}
- (nullable NSString *)l_stringForKeyPath:(NSString *)path otherwise:(nullable NSString *)other {
    id obj = [self l_valueForKeyPath:path otherwise:other];
    NSString *value = nil;
    if ([obj isKindOfClass:[NSString class]]) {
        value = obj;
    } else if ([obj isKindOfClass:[NSNumber class]]) {
        value = [(NSNumber *)obj stringValue];
    }
    if (!value) {
        value = other;
    }
    return value;
}

- (nullable NSNumber *)l_numberForKeyPath:(NSString *)path {
    return [self l_numberForKeyPath:path otherwise:nil];
}
- (nullable NSNumber *)l_numberForKeyPath:(NSString *)path otherwise:(nullable NSNumber *)other {
    id obj = [self l_valueForKeyPath:path otherwise:other];
    NSNumber *value = nil;
    if ([obj isKindOfClass:[NSNumber class]]) {
        value = obj;
    } else if ([obj isKindOfClass:[NSString class]]) {
        value = [(NSString *)obj l_numberValue];
    }
    if (value==nil) {
        value = other;
    }
    return value;
}

- (BOOL)l_boolForKeyPath:(NSString *)path {
    return [self l_boolForKeyPath:path otherwise:NO];
}
- (BOOL)l_boolForKeyPath:(NSString *)path otherwise:(BOOL)other {
    id obj = [self l_valueForKeyPath:path otherwise:nil];
    BOOL value = other;
    if ([obj isKindOfClass:[NSNumber class]]) {
        value = [(NSNumber *)obj boolValue];
    } else if ([obj isKindOfClass:[NSString class]]) {
        value = [(NSString *)obj boolValue];
    }
    return value;
}

- (NSInteger)l_integerForKeyPath:(NSString *)path {
    return [self l_integerForKeyPath:path otherwise:0];
}
- (NSInteger)l_integerForKeyPath:(NSString *)path otherwise:(NSInteger)other {
    NSNumber *obj = [self l_numberForKeyPath:path otherwise:nil];
    NSInteger value = other;
    if (obj!=nil) {
        value = [obj integerValue];
    }
    return value;
}

- (CGFloat)l_floatForKeyPath:(NSString *)path {
    return [self l_floatForKeyPath:path otherwise:0.0];
}
- (CGFloat)l_floatForKeyPath:(NSString *)path otherwise:(CGFloat)other {
    NSNumber *obj = [self l_numberForKeyPath:path otherwise:nil];
    CGFloat value = other;
    if (obj!=nil) {
        value = [obj floatValue];
    }
    return value;
}

- (CGFloat)l_CGFloatForKeyPath:(NSString *)path {
    return [self l_CGFloatForKeyPath:path otherwise:0.0];
}
- (CGFloat)l_CGFloatForKeyPath:(NSString *)path otherwise:(CGFloat)other {
    NSNumber *obj = [self l_numberForKeyPath:path otherwise:nil];
    CGFloat value = other;
    if (obj!=nil) {
        value = [obj floatValue];
    }
    return value;
}

- (double)l_doubleForKeyPath:(NSString *)path {
    return [self l_doubleForKeyPath:path otherwise:0.0f];
}
- (double)l_doubleForKeyPath:(NSString *)path otherwise:(CGFloat)other {
    NSNumber *obj = [self l_numberForKeyPath:path otherwise:nil];
    double value = other;
    if (obj!=nil) {
        value = [obj doubleValue];
    }
    return value;
}
- (nullable NSValue *)l_NSValueForKeyPath:(NSString *)path {
    return [self l_NSValueForKeyPath:path otherwise:nil];
}
- (nullable NSValue *)l_NSValueForKeyPath:(NSString *)path otherwise:(nullable NSValue *)other {
    id object = [self l_valueForKeyPath:path];
    if ([object isKindOfClass:[NSValue class]]) return object;
    return other;
}

- (NSTimeInterval)l_timeIntervalForKeyPath:(NSString *)path {
    return [self l_timeIntervalForKeyPath:path otherwise:0.0f];
}
- (NSTimeInterval)l_timeIntervalForKeyPath:(NSString *)path otherwise:(NSTimeInterval)other {
    NSNumber *obj = [self l_numberForKeyPath:path otherwise:nil];
    NSTimeInterval value = other;
    if (obj!=nil) {
        value = [obj doubleValue];
    }
    return value;
}
NSString *const kMKDateFormatNormal = @"yyyy-MM-dd HH:mm:ss";//"yyyy-MM-dd HH:mm:ss"
- (nullable NSDate *)l_dateSinceReferenceDateForKeyPath:(NSString *)path dateFormat:(nullable NSString *)dateFormat {
    return [self l_dateSinceReferenceDateForKeyPath:path dateFormat:dateFormat otherwise:nil];
}
- (nullable NSDate *)l_dateSinceReferenceDateForKeyPath:(NSString *)path dateFormat:(nullable NSString *)dateFormat otherwise:(nullable NSDate *)other {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = dateFormat;
    return [self l_dateSinceReferenceDateForKeyPath:path dateFormatter:dateFormatter otherwise:other];
}

- (nullable NSDate *)l_dateSinceReferenceDateForKeyPath:(NSString *)path dateFormatter:(nullable NSDateFormatter *)dateFormatter otherwise:(nullable NSDate *)other {
    
    id obj = [self l_valueForKeyPath:path otherwise:nil];
    NSDate *value = nil;
    if ([obj isKindOfClass:[NSDate class]]) {
        value = obj;
    } else if ([obj isKindOfClass:[NSString class]]) {
        //判断是否是字符串化的数字
        NSNumber *numberValue = [(NSString *)obj l_numberValue];
        if (numberValue!=nil) {
            value = [NSDate dateWithTimeIntervalSinceReferenceDate:[numberValue doubleValue]];
        } else if (dateFormatter) {
            value = [dateFormatter dateFromString:(NSString *)obj];
        }
    } else if ([obj isKindOfClass:[NSNumber class]]) {
        value = [NSDate dateWithTimeIntervalSinceReferenceDate:[(NSNumber *)obj doubleValue]];
    }
    if (!value) {
        value = other;
    }
    return value;
}
//时间起点为1970年
- (nullable NSDate *)l_dateSince1970ForKeyPath:(NSString *)path dateFormat:(nullable NSString *)dateFormat {
    return [self l_dateSince1970ForKeyPath:path dateFormat:dateFormat otherwise:nil];
}
- (nullable NSDate *)l_dateSince1970ForKeyPath:(NSString *)path dateFormat:(nullable NSString *)dateFormat otherwise:(nullable NSDate *)other {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = dateFormat;
    return [self l_dateSince1970ForKeyPath:path dateFormatter:dateFormatter otherwise:other];
}
- (nullable NSDate *)l_dateSince1970ForKeyPath:(NSString *)path dateFormatter:(nullable NSDateFormatter *)dateFormatter otherwise:(nullable NSDate *)other {
    id obj = [self l_valueForKeyPath:path otherwise:nil];
    NSDate *value = nil;
    if ([obj isKindOfClass:[NSDate class]]) {
        value = obj;
    } else if ([obj isKindOfClass:[NSString class]]) {
        //判断是否是字符串化的数字
        NSNumber *numberValue = [(NSString *)obj l_numberValue];
        if (numberValue!=nil) {
            value = [NSDate dateWithTimeIntervalSince1970:[numberValue doubleValue]];
        } else if (dateFormatter) {
            value = [dateFormatter dateFromString:(NSString *)obj];
        }
    } else if ([obj isKindOfClass:[NSNumber class]]) {
        value = [NSDate dateWithTimeIntervalSince1970:[(NSNumber *)obj doubleValue]];
    }
    if (!value) {
        value = other;
    }
    return value;
}
- (nullable NSDate *)l_dateSince1970MillisecondForKeyPath:(NSString *)path dateFormat:(nullable NSString *)dateFormat {
    return [self l_dateSince1970MillisecondForKeyPath:path dateFormat:dateFormat otherwise:nil];
}
//时间起点为1970年,时间戳单位为毫秒
- (nullable NSDate *)l_dateSince1970MillisecondForKeyPath:(NSString *)path dateFormat:(nullable NSString *)dateFormat otherwise:(nullable NSDate *)other {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = dateFormat;
    return [self l_dateSince1970MillisecondForKeyPath:path dateFormatter:dateFormatter otherwise:other];
}
- (nullable NSDate *)l_dateSince1970MillisecondForKeyPath:(NSString *)path dateFormatter:(nullable NSDateFormatter *)dateFormatter otherwise:(nullable NSDate *)other {
    
    id obj = [self l_valueForKeyPath:path otherwise:nil];
    NSDate *value = nil;
    if ([obj isKindOfClass:[NSDate class]]) {
        value = obj;
    } else if ([obj isKindOfClass:[NSString class]]) {
        //判断是否是字符串化的数字
        NSNumber *numberValue = [(NSString *)obj l_numberValue];
        if (numberValue!=nil) {
            value = [NSDate dateWithTimeIntervalSince1970:[numberValue doubleValue]/1000.0];
        } else if (dateFormatter) {
            value = [dateFormatter dateFromString:(NSString *)obj];
        }
    } else if ([obj isKindOfClass:[NSNumber class]]) {
        value = [NSDate dateWithTimeIntervalSince1970:[(NSNumber *)obj doubleValue]/1000.0];
    }
    if (!value) {
        value = other;
    }
    return value;
}
@end
@implementation NSDictionary(MKUI_ValueForKeyPathOtherwise)
- (nullable id)l_valueForKeyPath:(NSString *)path {
    return [self l_valueForKeyPath:path otherwise:nil];
}
- (nullable id)l_valueForKeyPath:(NSString *)path otherwise:(nullable id)other {
    id obj = [self valueForKeyPath:path];
    id value = obj;
    if (obj==[NSNull null]) {
        value = nil;
    }
    if (!value) {
        value = other;
    }
    return value;
}
@end

@implementation NSObject(MKUI_Address)
- (NSString *)l_objectAddress {
    return [NSString stringWithFormat:@"%@:%p",NSStringFromClass(self.class),self];
}
@end


NS_ASSUME_NONNULL_BEGIN
typedef void(^__MKKVOProxyBlock)(NSString *keyPath,id object, NSDictionary<NSKeyValueChangeKey,id> *change,void * context);
@interface __MKKVOProxy : NSObject
@property(nonatomic,strong) NSString *objectKey;
@property(nonatomic,strong) NSString *keyPath;
@property(nonatomic,assign) NSKeyValueObservingOptions options;
@property(nonatomic,assign) void * context;
@property(nonatomic,strong) NSArray<__MKKVOProxyBlock> *blocks;
- (void)addObserveValueBlock:(__MKKVOProxyBlock)block;
- (void)setObserveValueBlock:(__MKKVOProxyBlock)block;
@end

typedef void(^__MKKVOGetProxyBlock)(__MKKVOProxy * _Nullable proxy);
typedef void(^__MKKVOGetProxysBlock)(NSArray<__MKKVOProxy *> * proxys);
@interface __MKKVOProxyManager : NSObject
@property(nonatomic,strong) NSRecursiveLock *lock;
+ (id)sharedInstance;
@property(nonatomic,strong) NSMutableDictionary<NSString *,NSMutableArray<__MKKVOProxy *> *> *objectProxyList;
- (void)getProxyForObject:(id)object keyPath:(NSString *)keyPath context:(nullable void *)context completion:(nullable __MKKVOGetProxyBlock)completion;
- (void)getProxysForObject:(id)object completion:(nullable __MKKVOGetProxysBlock)completion;
- (void)addProxy:(__MKKVOProxy *)proxy forObject:(NSObject *)object;
- (void)removeProxy:(__MKKVOProxy *)proxy;
@end
NS_ASSUME_NONNULL_END

@implementation __MKKVOProxyManager
+ (id)sharedInstance {
    static dispatch_once_t once;
    static id __singleton__;
    dispatch_once( &once, ^ { __singleton__ = [[self alloc] init]; } );
    return __singleton__;
}
- (id)init {
    if (self=[super init]) {
        self.lock = [[NSRecursiveLock alloc] init];
        self.objectProxyList = [[NSMutableDictionary alloc] init];
    }
    return self;
}
- (NSString *)__objectListKeyForObject:(id)object {
    return [NSString stringWithFormat:@"%p",object];
}
- (nullable __MKKVOProxy *)proxyForObject:(id)object keyPath:(NSString *)keyPath context:(nullable void *)context {
    __MKKVOProxy *proxy = nil;
    NSArray<__MKKVOProxy *> *proxyList = [self proxysForObject:object];
    for (__MKKVOProxy *p in proxyList) {
        if ([p.keyPath isEqualToString:keyPath] && p.context==context) {
            proxy = p;
            break;
        }
    }
    return proxy;
}
- (void)getProxyForObject:(id)object keyPath:(NSString *)keyPath context:(nullable void *)context completion:(nullable __MKKVOGetProxyBlock)completion {
    [self.lock lock];
    __MKKVOProxy *proxy = nil;
    NSArray<__MKKVOProxy *> *proxyList = [self proxysForObject:object];
    for (__MKKVOProxy *p in proxyList) {
        if ([p.keyPath isEqualToString:keyPath] && p.context==context) {
            proxy = p;
            break;
        }
    }
    if (completion) {
        completion(proxy);
    }
    [self.lock unlock];
}
- (NSArray<__MKKVOProxy *> *)proxysForObject:(id)object {
    NSArray *list = [self.objectProxyList[[self __objectListKeyForObject:object]] copy];
    return list;
}
- (void)getProxysForObject:(id)object completion:(nullable __MKKVOGetProxysBlock)completion {
    [self.lock lock];
    NSArray *list = [self.objectProxyList[[self __objectListKeyForObject:object]] copy];
    if (completion) {
        completion(list);
    }
    [self.lock unlock];
}
- (void)addProxy:(__MKKVOProxy *)proxy forObject:(NSObject *)object {
    [self.lock lock];
    NSString *k = [self __objectListKeyForObject:object];
    proxy.objectKey = k;
    NSMutableArray *list = self.objectProxyList[k];
    if (!list) {
        list = [[NSMutableArray alloc] init];
        self.objectProxyList[k] = list;
    }
    if (![list containsObject:proxy]) {
        [list addObject:proxy];
    }
    [self.lock unlock];
}
- (void)removeProxy:(__MKKVOProxy *)proxy {
    [self.lock lock];
    NSString *k = proxy.objectKey;
    NSMutableArray *list = self.objectProxyList[k];
    [list removeObject:proxy];
    if (list.count==0) {
        [self.objectProxyList removeObjectForKey:k];
    }
    [self.lock unlock];
}
@end
@implementation __MKKVOProxy
- (id)init {
    if (self=[super init]) {
    }
    return self;
}
#ifdef DEBUG
- (NSString *)description {
    return [NSString stringWithFormat:@"<__MKKVOProxy:%p,objectKey:%@,keyPath:%@,options:%@,context:%@,blocks:%@>",self,self.objectKey,self.keyPath,@(self.options),self.context,self.blocks];
}
#endif
- (void)dealloc {

}
- (void)addObserveValueBlock:(__MKKVOProxyBlock)block {
    NSMutableArray *blocks = [[NSMutableArray alloc] initWithArray:self.blocks];
    [blocks addObject:block];
    self.blocks = blocks;
}
- (void)setObserveValueBlock:(__MKKVOProxyBlock)block {
    self.blocks = @[block];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    for (__MKKVOProxyBlock block in self.blocks) {
        block(keyPath,object,change,context);
    }
}
@end
@implementation NSObject(l_KVO)
- (void)l_addObserverForKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context block:(void(^)(NSString *keyPath,id object, NSDictionary<NSKeyValueChangeKey,id> *change,void * context))block {
    [[__MKKVOProxyManager sharedInstance] getProxyForObject:self keyPath:keyPath context:context completion:^(__MKKVOProxy * _Nullable proxy) {
        if (proxy) {//已经注册过了，添加回调
            [proxy addObserveValueBlock:block];
        } else {
            proxy = [[__MKKVOProxy alloc] init];
            proxy.keyPath = keyPath;
            proxy.options = options;
            proxy.context = context;
            [proxy addObserveValueBlock:block];
            [[__MKKVOProxyManager sharedInstance] addProxy:proxy forObject:self];
            [self addObserver:proxy forKeyPath:keyPath options:options context:context];
        }
    }];
}

- (void)l_setObserverForKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context block:(void(^)(NSString *keyPath,id object, NSDictionary<NSKeyValueChangeKey,id> *change,void * context))block {
    [[__MKKVOProxyManager sharedInstance] getProxyForObject:self keyPath:keyPath context:context completion:^(__MKKVOProxy * _Nullable proxy) {
        if (proxy) {//已经注册过了，修改回调
            [proxy setObserveValueBlock:block];
        } else {
            proxy = [[__MKKVOProxy alloc] init];
            proxy.keyPath = keyPath;
            proxy.options = options;
            proxy.context = context;
            [proxy addObserveValueBlock:block];
            [[__MKKVOProxyManager sharedInstance] addProxy:proxy forObject:self];
            [self addObserver:proxy forKeyPath:keyPath options:options context:context];
        }
    }];
}
- (void)l_removeObserverForKeyPath:(NSString *)keyPath context:(nullable void *)context {
    [[__MKKVOProxyManager sharedInstance] getProxysForObject:self completion:^(NSArray<__MKKVOProxy *> * _Nonnull proxys) {
        for (__MKKVOProxy *proxy in proxys) {
            if ([proxy.keyPath isEqualToString:keyPath] && (proxy.context==context)) {
                [self removeObserver:proxy forKeyPath:keyPath context:context];
                [[__MKKVOProxyManager sharedInstance] removeProxy:proxy];
            }
        }
    }];
}
- (void)l_removeObserverForKeyPath:(NSString *)keyPath {
    [[__MKKVOProxyManager sharedInstance] getProxysForObject:self completion:^(NSArray<__MKKVOProxy *> * _Nonnull proxys) {
        for (__MKKVOProxy *proxy in proxys) {
            if ([proxy.keyPath isEqualToString:keyPath]) {
                [self removeObserver:proxy forKeyPath:keyPath];
                [[__MKKVOProxyManager sharedInstance] removeProxy:proxy];
            }
        }
    }];
}
- (void)l_removeObserver {
    [[__MKKVOProxyManager sharedInstance] getProxysForObject:self completion:^(NSArray<__MKKVOProxy *> * _Nonnull proxys) {
        for (__MKKVOProxy *proxy in proxys) {
            [self removeObserver:proxy forKeyPath:proxy.keyPath];
            [[__MKKVOProxyManager sharedInstance] removeProxy:proxy];
        }
    }];
}

@end
