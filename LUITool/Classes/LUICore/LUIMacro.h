//
//  LUIMacro.h
//  LUITool
//
//  Created by 六月 on 2022/5/14.
//

#undef    LUIAS_SINGLETON
#define LUIAS_SINGLETON( ... ) \
- (nonnull instancetype)sharedInstance; \
+ (nonnull instancetype)sharedInstance;

#undef    LUIDEF_SINGLETON
#define LUIDEF_SINGLETON( ... ) \
- (instancetype)sharedInstance{ \
    return [[self class] sharedInstance]; \
} \
+ (instancetype)sharedInstance{ \
    static dispatch_once_t once; \
    static id __singleton__; \
    dispatch_once( &once, ^{ __singleton__ = [[self alloc] init]; } ); \
    return __singleton__; \
}

#undef    LUIDEF_SINGLETON_SUBCLASS
#define LUIDEF_SINGLETON_SUBCLASS \
- (instancetype)sharedInstance{ \
    return [[self class] sharedInstance]; \
} \
+ (instancetype)sharedInstance{ \
    static dispatch_once_t once;\
    static NSMutableDictionary * __singleton__;\
    dispatch_once( &once, ^{ __singleton__ = [[NSMutableDictionary alloc] init]; } );\
    id shareObject;\
    @synchronized (__singleton__) {\
       shareObject = __singleton__[NSStringFromClass(self)];\
        if (!shareObject) {\
            shareObject = [[self alloc] init];\
            __singleton__[NSStringFromClass(self)] = shareObject;\
        }\
    }\
    return shareObject;\
}

/**
 *  对于block外部与内部间的变量传递,定义block外的weak弱引用与block内的strong强引用,防止因block而引起的循环引用内存泄露
 *    范例:
 - (void)test{
    NSObject *obj;
    @LUI_WEAKIFY(self);
    @LUI_WEAKIFY(obj);
    void(^testBlock)() = ^() {
        @LUI_NORMALIZE(self);
        @LUI_NORMALIZE(obj);
        ...
    };
 }
 *  @param objc_arc 对象
 *
 */
//由于以前的weakify,normalize,normalizeAndNoNil会有命名冲突问题,因此修改这些宏,添加LUI前缀,并大写化
#undef LUI_WEAKIFY
#define LUI_WEAKIFY( x )    autoreleasepool{} __weak __typeof__(x) __weak_##x##__ = x;

#undef    LUI_NORMALIZE
#define LUI_NORMALIZE( x )    try{} @finally{} __typeof__(x) x = __weak_##x##__;
#undef    LUI_NORMALIZEANDNOTNIL
#define LUI_NORMALIZEANDNOTNIL( x )    try{} @finally{} __typeof__(x) x = __weak_##x##__;if (x == nil) return;
