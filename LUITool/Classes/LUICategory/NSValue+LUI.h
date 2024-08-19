//
//  NSValue+LUI.h
//  LUITool
//
//  Created by 六月 on 2024/8/19.
//

#import <Foundation/Foundation.h>
#import "CGGeometry+LUI.h"
NS_ASSUME_NONNULL_BEGIN

@interface NSValue (LUICGRange)
+ (NSValue *)valueWithLUICGRange:(LUICGRange)r;
@property (nonatomic, readonly) LUICGRange LUICGRangeValue;
@end

NS_ASSUME_NONNULL_END
