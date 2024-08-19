//
//  NSArray+LUI_BinarySearch.m
//  LUITool
//
//  Created by 六月 on 2024/8/18.
//

#import "NSArray+LUI_BinarySearch.h"

@implementation NSArray (LUI_BinarySearch)
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
 
 @param cmptr 比较闭包
 @return cmptr函数值=NSOrderedSame的范围
 */
- (NSRange)l_rangeOfSortedObjectsWithComparator:(NS_NOESCAPE NSComparisonResult(^)(id arrayObj,NSInteger idx))cmptr{
    NSRange range = NSMakeRange(NSNotFound, 0);
    if(!cmptr){
        return range;
    }
    if(self.count==0){
        return range;
    }
    NSArray *sortedArray = self;
    //使用二分法查找到限定区域最左侧的元素
    NSInteger leftIndex = NSNotFound;
    NSInteger rightIndex = NSNotFound;
    {//查找区域左侧元素的索引
        NSInteger begin = 0;
        NSInteger end = sortedArray.count-1;
        while (YES) {
            NSInteger i = begin+(end-begin)/2.0;
            id value = sortedArray[i];
            NSComparisonResult r = cmptr(value,i);
            if(r==NSOrderedSame||r==NSOrderedDescending){//begin和end的中位数与区域相交
                if(end==begin){
                    leftIndex = end;
                    break;
                }else{
                    end = i;
                    continue;
                }
            }else{
                if(end==begin){
                    leftIndex = NSNotFound;
                    break;
                }else{
                    begin = i+1;
                    continue;
                }
            }
        }
    }
    if(leftIndex!=NSNotFound){//查找区域右侧元素的索引
        NSInteger begin = leftIndex;
        NSInteger end = sortedArray.count-1;
        while (YES) {
            NSInteger i = ceil(begin+(end-begin)/2.0);
            id value = sortedArray[i];
            NSComparisonResult r = cmptr(value,i);
            if(r==NSOrderedSame||r==NSOrderedAscending){//begin和end的中位数与区域相交
                if(end==begin){
                    rightIndex = begin;
                    break;
                }else{
                    begin = i;
                    continue;
                }
            }else{
                if(end==begin){
                    rightIndex = NSNotFound;
                    break;
                }else{
                    end = i-1;
                    continue;
                }
            }
        }
    }
    if(leftIndex!=NSNotFound&&rightIndex!=NSNotFound){
        range = NSMakeRange(leftIndex, rightIndex-leftIndex+1);
    }
    return range;
}
- (NSArray *)l_subarrayOfSortedObjectsWithComparator:(NS_NOESCAPE NSComparisonResult(^)(id arrayObj,NSInteger idx))cmptr{
    NSRange range = [self l_rangeOfSortedObjectsWithComparator:cmptr];
    if(range.length==0)return nil;
    return [self subarrayWithRange:range];
}
//#ifdef DEBUG
//+ (void)load{
//    {
//        NSArray<NSNumber *> *numbers = @[@(1),@(3),@(5),@(7),@(9)];
//        [self test_indexOfSortedObjects:numbers number:@(0)];
//        [self test_indexOfSortedObjects:numbers number:@(1)];
//        [self test_indexOfSortedObjects:numbers number:@(2)];
//        [self test_indexOfSortedObjects:numbers number:@(5)];
//        [self test_indexOfSortedObjects:numbers number:@(8)];
//        [self test_indexOfSortedObjects:numbers number:@(9)];
//        [self test_indexOfSortedObjects:numbers number:@(10)];
//        [self test_indexOfSortedObjects:@[] number:@(-1)];
//    }
//    {
//        NSArray<NSNumber *> *numbers = @[@(1),@(3),@(5),@(5),@(7),@(9)];
//        [self test_removeSortedObject:numbers number:@(0)];
//        [self test_removeSortedObject:numbers number:@(1)];
//        [self test_removeSortedObject:numbers number:@(5)];
//        [self test_removeSortedObject:numbers number:@(9)];
//        [self test_removeSortedObject:numbers number:@(10)];
//    }
//    [self test_perform];
//}
//+ (void)test_perform{
//    NSInteger count = 10000000;
//    NSMutableArray<NSNumber *> *list = [[NSMutableArray alloc] initWithCapacity:count];
//    for (int i=0; i<count; i++) {
//        [list addObject:@(i*2)];
//    }
//    {
//        NSNumber *obj = list[(NSInteger)(list.count*0.9)];
//        NSDate *date = [NSDate date];
//        NSInteger index = [list indexOfObject:obj];
//        NSTimeInterval t = [[NSDate date] timeIntervalSinceDate:date];
//        NSLog(@"indexOfObject:%f",t);
//    }
//    {
//        NSNumber *obj = list[(NSInteger)(list.count*0.9)];
//        NSDate *date = [NSDate date];
//        NSRange range = [list l_rangeOfSortedObject:obj asc:YES];
//        NSTimeInterval t = [[NSDate date] timeIntervalSinceDate:date];
//        NSLog(@"l_indexOfSortedObject:%f",t);
//    }
//
//    {
//        NSNumber *obj = @(list[(NSInteger)(list.count*0.9)].integerValue+1);
//        NSDate *date = [NSDate date];
//        NSInteger index = [list indexOfObject:obj];
//        NSTimeInterval t = [[NSDate date] timeIntervalSinceDate:date];
//        NSLog(@"indexOfObject:%f",t);
//    }
//    {
//        NSNumber *obj = @(list[(NSInteger)(list.count*0.9)].integerValue+1);
//        NSDate *date = [NSDate date];
//        NSRange range = [list l_rangeOfSortedObject:obj asc:YES];
//        NSTimeInterval t = [[NSDate date] timeIntervalSinceDate:date];
//        NSLog(@"l_indexOfSortedObject:%f",t);
//    }
//    {
//        NSNumber *obj = list[(NSInteger)(list.count*0.9)];
//        NSDate *date = [NSDate date];
//        NSInteger index = [list indexOfObject:obj];
//        [list insertObject:obj atIndex:index];
//        NSTimeInterval t = [[NSDate date] timeIntervalSinceDate:date];
//        NSLog(@"search and insertObject:%f",t);
//    }
//    {
//        NSNumber *obj = list[(NSInteger)(list.count*0.9)];
//        NSDate *date = [NSDate date];
//        [list l_insertSortdObject:obj asc:YES];
//        NSTimeInterval t = [[NSDate date] timeIntervalSinceDate:date];
//        NSLog(@"l_insertSortdObject:%f",t);
//    }
//}
//+ (void)test_removeSortedObject:(NSArray<NSNumber *> *)numbers number:(NSNumber *)number{
//    NSMutableArray<NSNumber *> *list1 = [[NSMutableArray alloc] initWithArray:numbers];
//    [list1 l_removeSortedObject:number asc:YES];
//
//    NSMutableArray<NSNumber *> *list2 = [[NSMutableArray alloc] initWithArray:numbers];
//    [list2 removeObject:number];
//
//    if(![list1 isEqualToArray:list2]){
//        NSLog(@"l_removeSortedObject error:%@,%@",list1,list2);
//    }
//}
//+ (void)test_indexOfSortedObjects:(NSArray<NSNumber *> *)numbers number:(NSNumber *)number{
//    NSInteger index = [numbers l_indexOfSortedObjectsWithComparator:^NSComparisonResult(NSNumber * _Nonnull arrayObj, NSInteger idx) {
//        return [number compare:arrayObj];
//    }];
//    NSInteger index2 = [numbers l_indexOfSortedObject:number asc:YES];
//    if(index!=index2){
//        NSLog(@"l_indexOfSortedObjectsWithComparator error:%@,%@",@(index2),@(index));
//    }
//    NSMutableArray<NSNumber *> *newNumbers = [[NSMutableArray alloc] initWithArray:numbers];
//    [newNumbers insertObject:number atIndex:index];
//
//    NSMutableArray<NSNumber *> *newNumbers2 = [[NSMutableArray alloc] initWithArray:numbers];
//    [newNumbers2 l_insertSortdObject:number asc:YES];
//
//    NSArray *sorted = [newNumbers sortedArrayUsingComparator:^NSComparisonResult(NSNumber * _Nonnull obj1, NSNumber * _Nonnull obj2) {
//        return [obj1 compare:obj2];
//    }];
//    if(![newNumbers isEqualToArray:sorted]){
//        NSLog(@"l_indexOfSortedObjectsWithComparator error:%@",newNumbers);
//    }
//    if(![newNumbers2 isEqualToArray:sorted]){
//        NSLog(@"l_indexOfSortedObjectsWithComparator error:%@",newNumbers2);
//    }
//}
//#endif
- (NSInteger)l_indexOfSortedObjectsWithComparator:(NS_NOESCAPE NSComparisonResult(^)(id arrayObj,NSInteger idx))cmptr{
    if(self.count==0){
        return 0;
    }
    /**
     设数组为[a0~an],被查找对象为x,查找出以下范围[ai,aj],其中:
     ai<=x
     aj>=x
     if i>0,a(i-1)<x
     if j<n,a(j+1)>x
     */
    NSRange range = [self l_rangeOfSortedObjectsWithComparator:^NSComparisonResult(id arrayObj, NSInteger idx) {
        NSComparisonResult r = cmptr(arrayObj,idx);
        NSComparisonResult result = r*-1;
        NSInteger count = self.count;
        if(r==NSOrderedAscending){//x,ai
            if(idx>0){
                id arrayObj2 = self[idx-1];
                NSComparisonResult r = cmptr(arrayObj2,idx-1);
                if(r==NSOrderedDescending){//a(i-1),x,ai,
                    result = NSOrderedSame;
                }
            }else{//插入0的位置
                result = NSOrderedSame;
            }
        }else if(r==NSOrderedDescending){//ai,x
            if(idx<count-1){
                id arrayObj2 = self[idx+1];
                NSComparisonResult r = cmptr(arrayObj2,idx+1);
                if(r==NSOrderedAscending){//ai,x,a(i+1)
                    result = NSOrderedSame;
                }
            }
        }
        return result;
    }];
    if(range.location!=NSNotFound){
        return range.location+range.length-1;
    }else{
        return self.count;
    }
}
@end

@implementation NSMutableArray (MKUI_BinarySearch)

/// 要求数组为有序数组，删除cmptr为NSOrderedSame的值
/// @param cmptr 比对block
- (void)l_removeSortedObjectsWithComparator:(NS_NOESCAPE NSComparisonResult(^)(id arrayObj,NSInteger idx))cmptr{
    NSRange range = [self l_rangeOfSortedObjectsWithComparator:cmptr];
    if(range.location!=NSNotFound){
        [self removeObjectsInRange:range];
    }
}
@end

@implementation NSArray (MKComparatorProtocol)
- (NSRange)l_rangeOfSortedObject:(id<MKComparatorProtocol>)object asc:(BOOL)asc{
    return [self l_rangeOfSortedObjectsWithComparator:^NSComparisonResult(id<MKComparatorProtocol>  _Nonnull arrayObj, NSInteger idx) {
        NSComparisonResult r = [arrayObj l_compare:object];
        if(!asc){
            r = -r;
        }
        return r;
    }];
}
- (NSArray *)l_subarrayOfSortedObject:(id<MKComparatorProtocol>)object asc:(BOOL)asc{
    NSRange range = [self l_rangeOfSortedObject:object asc:asc];
    if(range.length==0)return nil;
    return [self subarrayWithRange:range];
}
- (NSInteger)l_indexOfSortedObject:(id<MKComparatorProtocol>)object asc:(BOOL)asc{
    return [self l_indexOfSortedObjectsWithComparator:^NSComparisonResult(id<MKComparatorProtocol>  _Nonnull arrayObj, NSInteger idx) {
        NSComparisonResult r = [object l_compare:arrayObj];
        if(!asc){
            r = -r;
        }
        return r;
    }];
}
- (NSArray *)l_removeSortedObjectsInArray:(NSArray<id<MKComparatorProtocol>> *)otherArray asc:(BOOL)asc{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (id obj in self) {
        NSRange range = [otherArray l_rangeOfSortedObject:obj asc:asc];
        if(range.length==0){
            [result addObject:obj];
        }
    }
    return result;
}
@end

@implementation NSMutableArray (MKComparatorProtocol)
- (void)l_removeSortedObject:(id<MKComparatorProtocol>)object asc:(BOOL)asc{
    [self l_removeSortedObjectsWithComparator:^NSComparisonResult(id<MKComparatorProtocol>  _Nonnull arrayObj, NSInteger idx) {
        NSComparisonResult r = [arrayObj l_compare:object];
        if(!asc){
            r = -r;
        }
        return r;
    }];
}
- (void)l_insertSortdObject:(id<MKComparatorProtocol>)object asc:(BOOL)asc{
    NSInteger index = [self l_indexOfSortedObject:object asc:asc];
    if(index!=NSNotFound){
        [self insertObject:object atIndex:index];
    }
}
@end

@implementation NSNumber (MKComparatorProtocol)
- (NSComparisonResult)l_compare:(__kindof id<MKComparatorProtocol>)other{
    return [self compare:other];
}
@end
@implementation NSIndexPath (MKComparatorProtocol)
- (NSComparisonResult)l_compare:(__kindof id<MKComparatorProtocol>)other{
    return [self compare:other];
}
@end
