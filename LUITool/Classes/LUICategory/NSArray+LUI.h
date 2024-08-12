//
//  NSArray+LUI.h
//  LUITool
//
//  Created by 六月 on 2023/8/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (LUI)

/// 扣除otherArray中的所有元素，返回新的数组:result=self-otherArray
/// @param otherArray 被扣除元素的数组
- (NSArray *)l_removeObjectsInArray:(NSArray *)otherArray;

/// 对数组中的每个元素进行映射变换，返回新的数组
/// @param block 变换block，当返回nil时，代表不添加
- (NSArray *)l_map:(NS_NOESCAPE id _Nullable(^ _Nullable)(id obj))block;

/// 对数组中的每个元素进行变换，变换block返回dict，然后将所有的dict合并返回
/// @param block 变换block，返回dict
- (NSDictionary *)l_mapDictionary:(NS_NOESCAPE NSDictionary * _Nullable(^ _Nullable)(id obj))block;

- (nullable id)l_reduce:(NS_NOESCAPE id _Nullable(^ _Nullable)(NSInteger index,id obj,id _Nullable result,BOOL *stop))block first:(nullable id)first;

@end

NS_ASSUME_NONNULL_END
