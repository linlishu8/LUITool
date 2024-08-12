//
//  LUIModelBase.h
//  LUITool
//
//  Created by 六月 on 2023/8/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LUICollectionModelObjectBase : NSObject<NSCopying>

@property(nonatomic,strong,nullable) id modelValue;

+ (instancetype)modelWithValue:(nullable id)modelVaule;
//id value = model[@"key"];
//model[@"key"] = nil;
//model[@"key"] = @(YES);
@property(nonatomic,readonly) NSMutableDictionary *dynamicProperties;

- (void)setObject:(nullable id)obj forKeyedSubscript:(id<NSCopying>)key;

- (nullable id)objectForKeyedSubscript:(id<NSCopying>)key;

@end

@interface LUICollectionModelObjectBase(LUI_ValueForKeyPath)

- (nullable id)l_valueForKeyPath:(NSString *)path otherwise:(nullable id)other;

@end

NS_ASSUME_NONNULL_END
