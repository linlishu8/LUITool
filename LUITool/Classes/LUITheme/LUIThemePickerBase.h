//
//  LUIThemePickerBase.h
//  LUITool
//
//  Created by 六月 on 2023/9/2.
//

#import <Foundation/Foundation.h>
#import "LUIThemePickerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface LUIThemePickerBase : NSObject <LUIThemePickerProtocol>
@property (nonatomic, strong, nullable) NSArray<id<LUIThemeElementProtocol>> * elements;//主题元素
@property (nonatomic, assign) SEL objSelector;
- (instancetype)initWithObjSelector:(SEL)objSelector;
@end

NS_ASSUME_NONNULL_END

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LUIThemePickerBase (Element)
+ (nullable UIColor *)themeUIColorWithElement:(id<LUIThemeElementProtocol>)element;
+ (nullable UIImage *)themeUIImageWithElement:(id<LUIThemeElementProtocol>)element;
+ (CGColorRef)themeCGColorRefWithElement:(id<LUIThemeElementProtocol>)element;
+ (NSInteger)themeNSIntegerWithElement:(id<LUIThemeElementProtocol>)element;
+ (CGFloat)themeCGFloatWithElement:(id<LUIThemeElementProtocol>)element;
+ (CGSize)themeCGSizeWithElement:(id<LUIThemeElementProtocol>)element;
@end

NS_ASSUME_NONNULL_END
