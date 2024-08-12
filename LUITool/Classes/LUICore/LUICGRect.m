//
//  LUICGRect.m
//  LUITool
//
//  Created by 六月 on 2023/8/11.
//

#import "LUICGRect.h"

@implementation LUICGRect
//+ (void)load{
//    CGRect fullBounds = [UIScreen mainScreen].bounds;
//    UIEdgeInsets insets = UIEdgeInsetsMake(44, 0, 20, 0);
//    CGRect bounds = UIEdgeInsetsInsetRect(fullBounds, insets);
//    UIView *v;
//    CGRect f1 = LUICGRect.rect(bounds).sizeTo([v sizeThatFits:bounds.size]).centerToRect(bounds).widthToValue(10).rect;
//    NSLog(@"f1:%@",NSStringFromCGRect(f1));
//}
- (id)initWithRect:(CGRect)rect {
    if (self = [self init]) {
        self.rect = rect;
    }
    return self;
}
+ (LUICGRect *)rect:(CGRect)rect {
    LUICGRect *r = [[LUICGRect alloc] init];
    r.rect = rect;
    return r;
}
- (CGPoint)center {
    return CGPointMake(self.midX, self.midY);
}
- (void)setCenter:(CGPoint)center {
    self.midX = center.x;
    self.midY = center.y;
}
- (CGFloat)minX {
    return CGRectGetMinX(self.rect);
}
- (void)setMinX:(CGFloat)value {
    CGRect r = self.rect;
    r.origin.x = value;
    self.rect = r;
}
- (CGFloat)midX {
    return CGRectGetMidX(self.rect);
}
- (void)setMidX:(CGFloat)value {
    CGRect r = self.rect;
    r.origin.x = value-r.size.width / 2;
    self.rect = r;
}
- (CGFloat)maxX {
    return CGRectGetMaxX(self.rect);
}
- (void)setMaxX:(CGFloat)value {
    CGRect r = self.rect;
    r.origin.x = value-r.size.width;
    self.rect = r;
}
- (CGFloat)minY {
    return CGRectGetMinY(self.rect);
}
- (void)setMinY:(CGFloat)value {
    CGRect r = self.rect;
    r.origin.y = value;
    self.rect = r;
}
- (CGFloat)midY {
    return CGRectGetMidY(self.rect);
}
- (void)setMidY:(CGFloat)value {
    CGRect r = self.rect;
    r.origin.y = value-r.size.height / 2;
    self.rect = r;
}
- (CGFloat)maxY {
    return CGRectGetMaxY(self.rect);
}
- (void)setMaxY:(CGFloat)value {
    CGRect r = self.rect;
    r.origin.y = value-r.size.height;
    self.rect = r;
}
- (CGPoint)origin {
    return self.rect.origin;
}
- (void)setOrigin:(CGPoint)origin {
    CGRect r = self.rect;
    r.origin = origin;
    self.rect = r;
}
- (CGFloat)x {
    return self.rect.origin.x;
}
- (void)setX:(CGFloat)x {
    CGRect r = self.rect;
    r.origin.x = x;
    self.rect = r;
}
- (CGFloat)y {
    return self.rect.origin.y;
}
- (void)setY:(CGFloat)y {
    CGRect r = self.rect;
    r.origin.y = y;
    self.rect = r;
}
- (CGSize)size {
    return self.rect.size;
}
- (void)setSize:(CGSize)size {
    CGRect r = self.rect;
    r.size = size;
    self.rect = r;
}
- (CGFloat)width {
    return self.rect.size.width;
}
- (void)setWidth:(CGFloat)width {
    CGRect r = self.rect;
    r.size.width = width;
    self.rect = r;
}
- (CGFloat)height {
    return self.rect.size.height;
}
- (void)setHeight:(CGFloat)height {
    CGRect r = self.rect;
    r.size.height = height;
    self.rect = r;
}
- (LUICGRectB)percentX {
    return [ ^CGFloat(CGFloat percent) {
        return self.minX + percent * self.rect.size.width;
    } copy];
}
- (LUICGRectB)percentY {
    return [^CGFloat(CGFloat percent) {
        return self.minY + percent * self.rect.size.height;
    } copy];
}

#pragma mark - 链式调用
+ (LUICGRect *(^)(CGRect rect))rect{
    return [^LUICGRect *(CGRect rect){
        return [self rect:rect];
    } copy];
}
+ (LUICGRect *(^)(CGFloat x,CGFloat y,CGFloat width,CGFloat height))make{
    return [^LUICGRect *(CGFloat x,CGFloat y,CGFloat width,CGFloat height){
        return [self rect:CGRectMake(x, y, width, height)];
    } copy];
}
#define LUICGRectXXXToRect(position) \
- (LUICGRectR)position##ToRect{\
    return [^LUICGRect *(CGRect bounds){\
        self.position = LUICGRect.rect(bounds).position;\
        return self;\
    } copy];\
}
LUICGRectXXXToRect(center)
LUICGRectXXXToRect(minX)
LUICGRectXXXToRect(midX)
LUICGRectXXXToRect(maxX)
LUICGRectXXXToRect(minY)
LUICGRectXXXToRect(midY)
LUICGRectXXXToRect(maxY)
LUICGRectXXXToRect(rect)

#define LUICGRectXXXToValue(position) \
- (LUICGRectF)position##ToValue{\
    return [^LUICGRect *(CGFloat value){\
        self.position = value;\
        return self;\
    } copy];\
}
LUICGRectXXXToValue(minX)
LUICGRectXXXToValue(midX)
LUICGRectXXXToValue(maxX)
LUICGRectXXXToValue(minY)
LUICGRectXXXToValue(midY)
LUICGRectXXXToValue(maxY)
LUICGRectXXXToValue(x)
LUICGRectXXXToValue(y)
LUICGRectXXXToValue(width)
LUICGRectXXXToValue(height)

- (LUICGRectS)sizeToValue{
    return [^LUICGRect *(CGSize size){
        self.size = size;
        return self;
    } copy];
}

- (LUICGRect *(^)(CGRect bounds,CGFloat edge))minXToEdge{
    return [^LUICGRect *(CGRect bounds,CGFloat edge){
        self.minXToValue(CGRectGetMinX(bounds)+edge);
        return self;
    } copy];
}
- (LUICGRect *(^)(CGRect bounds,CGFloat edge))maxXToEdge{
    return [^LUICGRect *(CGRect bounds,CGFloat edge){
        self.maxXToValue(CGRectGetMaxX(bounds)-edge);
        return self;
    } copy];
}
- (LUICGRect *(^)(CGRect bounds,CGFloat edge))minYToEdge{
    return [^LUICGRect *(CGRect bounds,CGFloat edge){
        self.minYToValue(CGRectGetMinY(bounds)+edge);
        return self;
    } copy];
}
- (LUICGRect *(^)(CGRect bounds,CGFloat edge))maxYToEdge{
    return [^LUICGRect *(CGRect bounds,CGFloat edge){
        self.maxYToValue(CGRectGetMaxY(bounds)-edge);
        return self;
    } copy];
}
@end

@implementation LUICGRect(Scale)

+ (CGSize)scaleSize:(CGSize)originSize aspectFitToMaxSize:(CGSize)maxSize{//如果s的尺寸超过size，则等比例缩放s直到宽高都不超过size
    CGSize size = maxSize;
    CGSize s = originSize;
    if(s.width<=size.width&&s.height<=size.height){
    }else if(s.width<=size.width&&s.height>size.height){
        CGFloat h = size.height;
        CGFloat w = h*s.width/s.height;
        s.width = w;
        s.height = h;
    }else if(s.width>size.width&&s.height<=size.height){
        CGFloat w = size.width;
        CGFloat h = w*s.height/s.width;
        s.width = w;
        s.height = h;
    }else if(s.width>size.width&&s.height>size.height){
        CGFloat w = size.width;
        CGFloat h = w*s.height/s.width;
        if(h>size.height){
            h = size.height;
            w = h*s.width/s.height;
        }
        s.width = w;
        s.height = h;
    }
    return s;
}

+ (CGSize)scaleSize:(CGSize)originSize aspectFitToSize:(CGSize)maxSize{//等比例缩放s直到宽高都不超过size
    CGSize size = maxSize;
    CGSize s = originSize;
    CGFloat w = size.width;
    CGFloat h = w*s.height/s.width;
    if(h>size.height){
        h = size.height;
        w = h*s.width/s.height;
    }
    s.width = w;
    s.height = h;
    return s;
}


+ (CGAffineTransform)transformRect:(CGRect)fromRect scaleTo:(CGRect)toRect contentMode:(UIViewContentMode)contentMode{
    CGAffineTransform m = CGAffineTransformIdentity;
    switch (contentMode) {
        case UIViewContentModeScaleAspectFit:{
            CGFloat scaleWidth = toRect.size.width/fromRect.size.width;
            CGFloat scaleHeight = toRect.size.height/fromRect.size.height;
            CGFloat scale = MIN(scaleWidth,scaleHeight);
            m = CGAffineTransformConcat(m, CGAffineTransformMakeTranslation(-CGRectGetMidX(fromRect), -CGRectGetMidY(fromRect)));
            m = CGAffineTransformConcat(m, CGAffineTransformMakeScale(scale, scale));//缩放
            m = CGAffineTransformConcat(m, CGAffineTransformMakeTranslation(CGRectGetMidX(toRect), CGRectGetMidY(toRect)));
        }
            break;
        case UIViewContentModeScaleAspectFill:{
            CGFloat scaleWidth = toRect.size.width/fromRect.size.width;
            CGFloat scaleHeight = toRect.size.height/fromRect.size.height;
            CGFloat scale = MAX(scaleWidth,scaleHeight);
            m = CGAffineTransformConcat(m, CGAffineTransformMakeTranslation(-CGRectGetMidX(fromRect), -CGRectGetMidY(fromRect)));
            m = CGAffineTransformConcat(m, CGAffineTransformMakeScale(scale, scale));//缩放
            m = CGAffineTransformConcat(m, CGAffineTransformMakeTranslation(CGRectGetMidX(toRect), CGRectGetMidY(toRect)));
        }
            break;
        case UIViewContentModeScaleToFill:{
            CGFloat scaleWidth = toRect.size.width/fromRect.size.width;
            CGFloat scaleHeight = toRect.size.height/fromRect.size.height;
            m = CGAffineTransformConcat(m, CGAffineTransformMakeTranslation(-CGRectGetMidX(fromRect), -CGRectGetMidY(fromRect)));
            m = CGAffineTransformConcat(m, CGAffineTransformMakeScale(scaleWidth, scaleHeight));//缩放
            m = CGAffineTransformConcat(m, CGAffineTransformMakeTranslation(CGRectGetMidX(toRect), CGRectGetMidY(toRect)));
        }
            break;
        case UIViewContentModeCenter:
            m = [self transformRect:fromRect moveTo:toRect alignPoint:CGPointMake(0.5, 0.5)];
            break;
        case UIViewContentModeLeft:
            m = [self transformRect:fromRect moveTo:toRect alignPoint:CGPointMake(0, 0.5)];
            break;
        case UIViewContentModeRight:
            m = [self transformRect:fromRect moveTo:toRect alignPoint:CGPointMake(1, 0.5)];
            break;
        case UIViewContentModeTop:
            m = [self transformRect:fromRect moveTo:toRect alignPoint:CGPointMake(0.5, 0)];
            break;
        case UIViewContentModeBottom:
            m = [self transformRect:fromRect moveTo:toRect alignPoint:CGPointMake(0.5, 1)];
            break;
        case UIViewContentModeTopLeft:
            m = [self transformRect:fromRect moveTo:toRect alignPoint:CGPointMake(0, 0)];
            break;
        case UIViewContentModeTopRight:
            m = [self transformRect:fromRect moveTo:toRect alignPoint:CGPointMake(1, 0)];
            break;
        case UIViewContentModeBottomLeft:
            m = [self transformRect:fromRect moveTo:toRect alignPoint:CGPointMake(0, 1)];
            break;
        case UIViewContentModeBottomRight:
            m = [self transformRect:fromRect moveTo:toRect alignPoint:CGPointMake(1, 1)];
            break;
        default:
            break;
    }
    return m;
}
+ (CGAffineTransform)transformRect:(CGRect)fromRect moveTo:(CGRect)toRect alignPoint:(CGPoint)point{
    CGAffineTransform m = CGAffineTransformIdentity;
    CGPoint p1 = CGPointMake(fromRect.origin.x+fromRect.size.width*point.x, fromRect.origin.y+fromRect.size.height*point.y);
    CGPoint p2 = CGPointMake(toRect.origin.x+toRect.size.width*point.x, toRect.origin.y+toRect.size.height*point.y);
    m = CGAffineTransformMakeTranslation(p2.x-p1.x, p2.y-p1.y);
    return m;
}
@end
