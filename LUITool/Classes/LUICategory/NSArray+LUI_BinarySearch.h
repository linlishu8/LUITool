//
//  NSArray+LUI_BinarySearch.h
//  LUITool
//
//  Created by 六月 on 2024/8/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface NSArray (LUI_BinarySearch)
/**
 要求数组为有序数组,该方法是查找出cmptr(arrayObj,idx)=NSOrderedSame的区域.cmptr闭包返回值定义如下:
    NSOrderedSame:idx在结果NSRange内
    NSOrderedAscending:idx在结果NSRange左侧
    NSOrderedDescending:idx在结果NSRange右侧
 
 例:数组[a1~a12]为有序数组,闭包cmptr(arrayObj,idx)的返回为:
    [a1~a4]返回NSOrderedAscending
    [a5~a7]返回NSOrderedSame
    [a8~a12]返回NSOrderedDescending
 该方法会使用二分查找,返回[a5~a7]的NSRange范围
 ----------
 有序数组:        [a1 a2 a3 a4 | a5 a6 a7 | a8 a9 a10 a11 a12]
 ----------
 cmptr返回:        |<-- asc -->||<- same ->||<----- desc ---->|
 
 @param cmptr 比较闭包,cmptr等效于[arrayObj compare:resultObj]
 @return cmptr函数值=NSOrderedSame的范围
 */
- (NSRange)l_rangeOfSortedObjectsWithComparator:(NS_NOESCAPE NSComparisonResult(^)(id arrayObj,NSInteger idx))cmptr;
- (nullable NSArray *)l_subarrayOfSortedObjectsWithComparator:(NS_NOESCAPE NSComparisonResult(^)(id arrayObj,NSInteger idx))cmptr;

/**
 要求数组为有序数组,该方法是查找出要插入新元素的索引值
 cmptr返回值说明:
 NSOrderedSame:插入元素在idx位置上
 NSOrderedAscending:插入元素在idx位置左侧
 NSOrderedDescending:插入元素在idx位置右侧
 
 ----------
 有序数组:        1，3，5，7，9，11
 ----------
 被插入数据为：0
 cmptr返回:      A，A，A，A，A，A
 ----------
 被插入数据为：4
 cmptr返回:      D，D，A，A，A，A
 ----------
 被插入数据为：5
 cmptr返回:      D，D，S，A，A，A
 ----------
 被插入数据为：12
 cmptr返回:      D，D，D，D，D，D
 cmptr 等效于 [resultObj compare:arrayObj]
 */
- (NSInteger)l_indexOfSortedObjectsWithComparator:(NS_NOESCAPE NSComparisonResult(^)(id arrayObj,NSInteger idx))cmptr;

@end

@interface NSMutableArray (LUI_BinarySearch)
/// 要求数组为有序数组，删除cmptr为NSOrderedSame的值
/// @param cmptr 比对block
- (void)l_removeSortedObjectsWithComparator:(NS_NOESCAPE NSComparisonResult(^)(id arrayObj,NSInteger idx))cmptr;
@end

@protocol MKComparatorProtocol <NSObject>
- (NSComparisonResult)l_compare:(__kindof id<MKComparatorProtocol>)other;
@end

@interface NSArray<ObjectType> (MKComparatorProtocol)
/// 要求数组为有序数组，查找与object进行比较时，返回same的对象索引范围
/// @param object 被搜索的元素
/// @param asc 数组是否从小到大排序
- (NSRange)l_rangeOfSortedObject:(ObjectType<MKComparatorProtocol>)object asc:(BOOL)asc;
- (nullable NSArray *)l_subarrayOfSortedObject:(ObjectType<MKComparatorProtocol>)object asc:(BOOL)asc;

/// 要求数组为有序数组，查找要插入object的位置（插入之后，继续保持数组有序）
/// @param object 将被插件入的元素
/// @param asc 数组是否从小到大排序
- (NSInteger)l_indexOfSortedObject:(ObjectType<MKComparatorProtocol>)object asc:(BOOL)asc;

- (NSArray<ObjectType> *)l_removeSortedObjectsInArray:(NSArray<ObjectType<MKComparatorProtocol>> *)otherArray asc:(BOOL)asc;
@end

@interface NSMutableArray<ObjectType> (MKComparatorProtocol)

/// 要求数组为有序数组，删除与object相等的元素（compare返回same的值）
/// @param object 被删除的元素
/// @param asc 数组是否从小到大排序
- (void)l_removeSortedObject:(ObjectType<MKComparatorProtocol>)object asc:(BOOL)asc;

/// 要求数组为有序数组，插入元素，同时继续保存数组有序
/// @param object 将被插件入的元素
/// @param asc 数组是否从小到大排序
- (void)l_insertSortdObject:(ObjectType<MKComparatorProtocol>)object asc:(BOOL)asc;
@end

@interface NSNumber (MKComparatorProtocol)
@end
@interface NSIndexPath (MKComparatorProtocol)
@end

NS_ASSUME_NONNULL_END
