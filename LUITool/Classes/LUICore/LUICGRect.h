//
//  LUICGRect.h
//  LUITool
//
//  Created by 六月 on 2024/8/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LUICGRect : NSObject

@property (nonatomic, assign) CGRect rect;

- (id)initWithRect:(CGRect)rect;
+ (LUICGRect *)rect:(CGRect)rect;

@property (nonatomic, assign) CGPoint center;

@property (nonatomic, assign) CGFloat minX;
@property (nonatomic, assign) CGFloat midX;
@property (nonatomic, assign) CGFloat maxX;

@property (nonatomic, assign) CGFloat minY;
@property (nonatomic, assign) CGFloat midY;
@property (nonatomic, assign) CGFloat maxY;

@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

typedef CGFloat(^LUICGRectB)(CGFloat);
@property (nonatomic, readonly) LUICGRectB percentX;
@property (nonatomic, readonly) LUICGRectB percentY;

#pragma mark - 链式调用

+ (LUICGRect *(^)(CGRect rect))rect;
+ (LUICGRect *(^)(CGFloat x,CGFloat y,CGFloat width,CGFloat height))make;

typedef LUICGRect * __nonnull (^LUICGRectR)(CGRect);
@property (nonatomic, readonly) LUICGRectR centerToRect;

@property (nonatomic, readonly) LUICGRectR minXToRect;
@property (nonatomic, readonly) LUICGRectR midXToRect;
@property (nonatomic, readonly) LUICGRectR maxXToRect;
@property (nonatomic, readonly) LUICGRectR minYToRect;
@property (nonatomic, readonly) LUICGRectR midYToRect;
@property (nonatomic, readonly) LUICGRectR maxYToRect;
@property (nonatomic, readonly) LUICGRectR rectToRect;

typedef LUICGRect * __nonnull (^LUICGRectF)(CGFloat);
@property (nonatomic, readonly) LUICGRectF minXToValue;
@property (nonatomic, readonly) LUICGRectF midXToValue;
@property (nonatomic, readonly) LUICGRectF maxXToValue;
@property (nonatomic, readonly) LUICGRectF minYToValue;
@property (nonatomic, readonly) LUICGRectF midYToValue;
@property (nonatomic, readonly) LUICGRectF maxYToValue;

@property (nonatomic, readonly) LUICGRectF xToValue;
@property (nonatomic, readonly) LUICGRectF yToValue;
@property (nonatomic, readonly) LUICGRectF widthToValue;
@property (nonatomic, readonly) LUICGRectF heightToValue;

typedef LUICGRect * __nonnull (^LUICGRectS)(CGSize);
@property (nonatomic, readonly) LUICGRectS sizeToValue;

typedef LUICGRect * __nonnull (^LUICGRectE)(CGRect,CGFloat);//边与rect的padding值
@property (nonatomic, readonly) LUICGRectE minXToEdge;//left-padding
@property (nonatomic, readonly) LUICGRectE maxXToEdge;//right-padding
@property (nonatomic, readonly) LUICGRectE minYToEdge;//top-padding
@property (nonatomic, readonly) LUICGRectE maxYToEdge;//bottom-padding

@end

NS_ASSUME_NONNULL_END
