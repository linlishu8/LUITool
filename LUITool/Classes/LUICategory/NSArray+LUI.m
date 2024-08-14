//
//  NSArray+LUI.m
//  LUITool
//
//  Created by 六月 on 2023/8/11.
//

#import "NSArray+LUI.h"

@implementation NSArray (LUI)

- (NSArray *)l_removeObjectsInArray:(NSArray *)otherArray {
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:self.count];
    for (id obj in self) {
        if (![otherArray containsObject:obj]) {
            [result addObject:obj];
        }
    }
    return result;
}
- (NSArray *)l_map:(NS_NOESCAPE id _Nullable(^ _Nullable)(id obj))block {
    if (!block) {
        return @[];
    }
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:self.count];
    for (id obj in self) {
        id newObj = block(obj);
        if (newObj) {
            [result addObject:newObj];
        }
    }
    return result;
}
- (NSDictionary *)l_mapDictionary:(NS_NOESCAPE NSDictionary * _Nullable(^ _Nullable)(id obj))block {
    if (!block) {
        return @ {};
    }
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:self.count];
    for (id obj in self) {
        NSDictionary *dict = block(obj);
        if (dict) {
            [result addEntriesFromDictionary:dict];
        }
    }
    return result;
}
- (nullable id)l_reduce:(NS_NOESCAPE id _Nullable(^ _Nullable)(NSInteger index, id obj, id _Nullable result, BOOL *stop))block first:(nullable id)first {
    id result = first;
    __block BOOL stop = NO;
    if (block) {
        for (int i=0; i<self.count; i++) {
            id obj = self[i];
            block(i,obj,result,&stop);
            if (stop) {
                break;
            }
        }
    }
    return result;
}

@end
