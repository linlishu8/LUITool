//
//  NSObject+LUI.h
//  LUITool
//
//  Created by 六月 on 2023/8/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (LUI_ValueForKeyPath)

- (nullable id)l_valueForKeyPath:(NSString *)path;
- (nullable id)l_valueForKeyPath:(NSString *)path otherwise:(nullable id)other;

- (nullable NSArray *)l_arrayForKeyPath:(NSString *)path;
- (nullable NSArray *)l_arrayForKeyPath:(NSString *)path otherwise:(nullable NSArray *)other;

- (nullable NSDictionary *)l_dictionaryForKeyPath:(NSString *)path;
- (nullable NSDictionary *)l_dictionaryForKeyPath:(NSString *)path otherwise:(nullable NSDictionary *)other;

- (nullable NSString *)l_stringForKeyPath:(NSString *)path;
- (nullable NSString *)l_stringForKeyPath:(NSString *)path otherwise:(nullable NSString *)other;

- (nullable NSNumber *)l_numberForKeyPath:(NSString *)path otherwise:(nullable NSNumber *)other;

- (BOOL)l_boolForKeyPath:(NSString *)path;
- (BOOL)l_boolForKeyPath:(NSString *)path otherwise:(BOOL)other;

- (NSInteger)l_integerForKeyPath:(NSString *)path;
- (NSInteger)l_integerForKeyPath:(NSString *)path otherwise:(NSInteger)other;

- (CGFloat)l_floatForKeyPath:(NSString *)path;
- (CGFloat)l_floatForKeyPath:(NSString *)path otherwise:(CGFloat)other;

- (CGFloat)l_CGFloatForKeyPath:(NSString *)path;
- (CGFloat)l_CGFloatForKeyPath:(NSString *)path otherwise:(CGFloat)other;

- (double)l_doubleForKeyPath:(NSString *)path;
- (double)l_doubleForKeyPath:(NSString *)path otherwise:(CGFloat)other;

- (nullable NSValue *)l_NSValueForKeyPath:(NSString *)path;
- (nullable NSValue *)l_NSValueForKeyPath:(NSString *)path otherwise:(nullable NSValue *)other;

- (NSTimeInterval)l_timeIntervalForKeyPath:(NSString *)path;
- (NSTimeInterval)l_timeIntervalForKeyPath:(NSString *)path otherwise:(NSTimeInterval)other;

extern NSString *const kLUIDateFormatNormal;//"yyyy-MM-dd HH:mm:ss"
//时间起点为ReferenceDate
- (nullable NSDate *)l_dateSinceReferenceDateForKeyPath:(NSString *)path dateFormat:(nullable NSString *)dateFormat;
- (nullable NSDate *)l_dateSinceReferenceDateForKeyPath:(NSString *)path dateFormat:(nullable NSString *)dateFormat otherwise:(nullable NSDate *)other;
- (nullable NSDate *)l_dateSinceReferenceDateForKeyPath:(NSString *)path dateFormatter:(nullable NSDateFormatter *)dateFormatter otherwise:(nullable NSDate *)other;
//时间起点为1970年
- (nullable NSDate *)l_dateSince1970ForKeyPath:(NSString *)path dateFormat:(nullable NSString *)dateFormat;
- (nullable NSDate *)l_dateSince1970ForKeyPath:(NSString *)path dateFormat:(nullable NSString *)dateFormat otherwise:(nullable NSDate *)other;
- (nullable NSDate *)l_dateSince1970ForKeyPath:(NSString *)path dateFormatter:(nullable NSDateFormatter *)dateFormatter otherwise:(nullable NSDate *)other;
 
//时间起点为1970年,时间戳单位为毫秒
- (nullable NSDate *)l_dateSince1970MillisecondForKeyPath:(NSString *)path dateFormat:(nullable NSString *)dateFormat;
- (nullable NSDate *)l_dateSince1970MillisecondForKeyPath:(NSString *)path dateFormat:(nullable NSString *)dateFormat otherwise:(nullable NSDate *)other;
- (nullable NSDate *)l_dateSince1970MillisecondForKeyPath:(NSString *)path dateFormatter:(nullable NSDateFormatter *)dateFormatter otherwise:(nullable NSDate *)other;

@end

NS_ASSUME_NONNULL_END

NS_ASSUME_NONNULL_BEGIN
@interface NSDictionary(LUI_ValueForKeyPath)

- (nullable id)l_valueForKeyPath:(NSString *)path;
- (nullable id)l_valueForKeyPath:(NSString *)path otherwise:(nullable id)other;

@end
NS_ASSUME_NONNULL_END

NS_ASSUME_NONNULL_BEGIN
@interface NSObject(LUI_KVO)
/// 监听KVO，回调使用block。可重复调用。事件发生时，所有的回调block都会被执行。（注：keypath，context相同的重复调用，options只使用第一次的值。）
/// 监听完后，需要手动调用l_removeObserver等取消监听的方法，否则会有内存泄漏问题，以及在ios10及以下版本，应用会闪退（原因：ios10及以下版本，dealloc时，不会自动取消KVO的监听，从而闪退：An instance 0xxxx of class xxxx was deallocated while key value observers were still registered with it. Current observation info: xxxxx）。建议是在dealloc时，调用[self l_removeObserver]方法取消KVO监听。
/// @param keyPath keypath
/// @param options 选项
/// @param context 上下文
/// @param block 回调
- (void)l_addObserverForKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context block:(void(^)(NSString *keyPath,id object, NSDictionary<NSKeyValueChangeKey,id> *change,void * context))block;

/// 监听KVO，回调使用block。可重复调用,最后的调用会覆盖之前的block
/// 监听完后，需要手动调用l_removeObserver等取消监听的方法，否则会有内存泄漏问题，以及在ios10及以下版本，应用会闪退（原因：ios10及以下版本，dealloc时，不会自动取消KVO的监听，从而闪退：An instance 0xxxx of class xxxx was deallocated while key value observers were still registered with it. Current observation info: xxxxx）。建议是在dealloc时，调用[self l_removeObserver]方法取消KVO监听。
/// @param keyPath keypath
/// @param options 选项
/// @param context 上下文
/// @param block 回调
- (void)l_setObserverForKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context block:(void(^)(NSString *keyPath,id object, NSDictionary<NSKeyValueChangeKey,id> *change,void * context))block;

/// 取消KVO的监听。该方法可以重复调用，即使没有监听KVO，也可以调用，不会闪退。
/// @param keyPath keypath
/// @param context 上下文
- (void)l_removeObserverForKeyPath:(NSString *)keyPath context:(nullable void *)context;

/// 取消KVO的监听。该方法可以重复调用，即使没有监听KVO，也可以调用，不会闪退。
/// @param keyPath keypath
- (void)l_removeObserverForKeyPath:(NSString *)keyPath;

/// 取消KVO的监听。该方法可以重复调用，即使没有监听KVO，也可以调用，不会闪退。
- (void)l_removeObserver;
@end
NS_ASSUME_NONNULL_END
