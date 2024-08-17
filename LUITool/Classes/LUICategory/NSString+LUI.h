//
//  NSString+LUI.h
//  LUITool
//
//  Created by 六月 on 2023/8/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (LUI)

//如果字符串内容为数字时,返回数字对应的NSNumber对象
@property (nonatomic, readonly, nullable) NSNumber *l_numberValue;
@property (nonatomic, readonly, nullable) NSNumber *l_numberOfInteger;
@property (nonatomic, readonly, nullable) NSNumber *l_numberOfLongLong;
@property (nonatomic, readonly, nullable) NSNumber *l_numberOfCGFloat;
@property (nonatomic, readonly, nullable) NSNumber *l_numberOfFloat;
@property (nonatomic, readonly, nullable) NSNumber *l_numberOfDouble;

@property (nonatomic, readonly, nullable) id l_jsonValue;
@property (nonatomic, readonly, nullable) NSDictionary *l_jsonDictionary;
@property (nonatomic, readonly, nullable) NSArray *l_jsonArray;

@end

NS_ASSUME_NONNULL_END
