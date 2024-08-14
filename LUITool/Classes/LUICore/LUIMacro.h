//
//  LUIMacro.h
//  LUITool
//
//  Created by 六月 on 2024/8/12.
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

#undef lui_weakify
#define lui_weakify( x )     __weak __typeof__(x) __weak_##x##__ = x;

#undef    lui_strongify
#define lui_strongify( x )     __strong __typeof__(x) x = __weak_##x##__;
