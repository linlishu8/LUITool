//
//  CGGeometry+LUI.h
//  LUITool
//
//  Created by 六月 on 2021/8/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    LUICGAxisX, //X轴
    LUICGAxisY, //Y轴
} LUICGAxis;
UIKIT_STATIC_INLINE LUICGAxis LUICGAxisReverse(LUICGAxis axis) {
    return axis == LUICGAxisX ? LUICGAxisY : LUICGAxisX;
}
#pragma mark - CGPoint
UIKIT_STATIC_INLINE CGFloat LUICGPointGetValue(CGPoint point, LUICGAxis axis) {
    return axis == LUICGAxisX ? point.x : point.y;
}
UIKIT_STATIC_INLINE void LUICGPointSetValue(CGPoint *point, LUICGAxis axis, CGFloat value) {
    if (axis == LUICGAxisX) {(*point).x = value;} else {(*point).y = value;}
}
UIKIT_STATIC_INLINE void LUICGPointAddValue(CGPoint *point, LUICGAxis axis, CGFloat value) {
    LUICGPointSetValue(point, axis, LUICGPointGetValue(*point, axis) + value);
}

#pragma mark - CGVector
UIKIT_STATIC_INLINE CGFloat LUICGVectorGetValue(CGVector v, LUICGAxis axis) {
    return axis == LUICGAxisX ? v.dx : v.dy;
}
UIKIT_STATIC_INLINE void LUICGVectorSetValue(CGVector *v, LUICGAxis axis, CGFloat value) {
    if (axis == LUICGAxisX) {(*v).dx = value;} else {(*v).dy = value;}
}
UIKIT_STATIC_INLINE void LUICGVectorAddValue(CGVector *v, LUICGAxis axis, CGFloat value) {
    LUICGVectorSetValue(v, axis, LUICGVectorGetValue(*v, axis) + value);
}

#pragma mark - CGSize
UIKIT_STATIC_INLINE CGFloat LUICGSizeGetLength(CGSize size, LUICGAxis axis) {
    return axis == LUICGAxisX ? size.width : size.height;
}
UIKIT_STATIC_INLINE void LUICGSizeSetLength(CGSize *size, LUICGAxis axis, CGFloat value) {
    if (axis == LUICGAxisX) {(*size).width = value;} else {(*size).height = value;}
}
UIKIT_STATIC_INLINE void LUICGSizeAddLength(CGSize *size, LUICGAxis axis, CGFloat value) {
    LUICGSizeSetLength(size, axis, LUICGSizeGetLength(*size, axis) + value);
}

#pragma mark - CGRect
typedef enum : NSUInteger {
    LUICGRectAlignmentMin, //min最小值对齐
    LUICGRectAlignmentMid, //mid中值对齐
    LUICGRectAlignmentMax, //max最大值对齐
} LUICGRectAlignment;//对齐方向
UIKIT_STATIC_INLINE LUICGRectAlignment LUICGRectAlignmentReverse(LUICGRectAlignment align) {
    return align == LUICGRectAlignmentMin ? LUICGRectAlignmentMax : (align == LUICGRectAlignmentMax ? LUICGRectAlignmentMin : LUICGRectAlignmentMid);
}

UIKIT_STATIC_INLINE void LUICGRectSetMinX(CGRect *rect, CGFloat value) {
    (*rect).origin.x = value;
}
UIKIT_STATIC_INLINE void LUICGRectSetMinY(CGRect *rect, CGFloat value) {
    (*rect).origin.y = value;
}
UIKIT_STATIC_INLINE void LUICGRectSetMidX(CGRect *rect, CGFloat value) {
    (*rect).origin.x = value - (*rect).size.width * 0.5;
}
UIKIT_STATIC_INLINE void LUICGRectSetMidY(CGRect *rect, CGFloat value) {
    (*rect).origin.y = value-(*rect).size.height * 0.5;
}
UIKIT_STATIC_INLINE void LUICGRectSetMaxX(CGRect *rect, CGFloat value) {
    (*rect).origin.x = value-(*rect).size.width;
}
UIKIT_STATIC_INLINE void LUICGRectSetMaxY(CGRect *rect, CGFloat value) {
    (*rect).origin.y = value-(*rect).size.height;
}
UIKIT_STATIC_INLINE void LUICGRectSetWidth(CGRect *rect, CGFloat value) {
    (*rect).size.width = value;
}
UIKIT_STATIC_INLINE void LUICGRectSetHeight(CGRect *rect, CGFloat value) {
    (*rect).size.height = value;
}
UIKIT_STATIC_INLINE CGPoint LUICGRectGetCenter(CGRect rect) {
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}
UIKIT_STATIC_INLINE void LUICGRectSetCenter(CGRect *rect, CGPoint center) {
    LUICGRectSetMidX(rect, center.x);
    LUICGRectSetMidY(rect, center.y);
}
UIKIT_STATIC_INLINE CGFloat LUICGRectGetPercentX(CGRect rect, CGFloat percent) {
    return CGRectGetMinX(rect) + percent * CGRectGetWidth(rect);
}
UIKIT_STATIC_INLINE CGFloat LUICGRectGetPercentY(CGRect rect, CGFloat percent) {
    return CGRectGetMinY(rect) + percent * CGRectGetHeight(rect);
}
UIKIT_STATIC_INLINE void LUICGRectSetMinXEdgeToRect(CGRect *rect, CGRect bounds, CGFloat edge) {
    LUICGRectSetMinX(rect, CGRectGetMinX(bounds) + edge);
}
UIKIT_STATIC_INLINE void LUICGRectSetMaxXEdgeToRect(CGRect *rect, CGRect bounds, CGFloat edge) {
    LUICGRectSetMaxX(rect, CGRectGetMaxX(bounds) - edge);
}
UIKIT_STATIC_INLINE void LUICGRectSetMinYEdgeToRect(CGRect *rect, CGRect bounds, CGFloat edge) {
    LUICGRectSetMinY(rect, CGRectGetMinY(bounds) + edge);
}
UIKIT_STATIC_INLINE void LUICGRectSetMaxYEdgeToRect(CGRect *rect, CGRect bounds, CGFloat edge) {
    LUICGRectSetMaxY(rect, CGRectGetMaxY(bounds) - edge);
}

#pragma mark - 与另一个rect进行对齐
UIKIT_STATIC_INLINE void LUICGRectAlignCenterToRect(CGRect *rect, CGRect bounds) {
    LUICGRectSetCenter(rect, LUICGRectGetCenter(bounds));
}
UIKIT_STATIC_INLINE void LUICGRectAlignMinXToRect(CGRect *rect, CGRect bounds) {
    LUICGRectSetMinX(rect, CGRectGetMinX(bounds));
}
UIKIT_STATIC_INLINE void LUICGRectAlignMidXToRect(CGRect *rect, CGRect bounds) {
    LUICGRectSetMidX(rect, CGRectGetMidX(bounds));
}
UIKIT_STATIC_INLINE void LUICGRectAlignMaxXToRect(CGRect *rect, CGRect bounds) {
    LUICGRectSetMaxX(rect, CGRectGetMaxX(bounds));
}
UIKIT_STATIC_INLINE void LUICGRectAlignMinYToRect(CGRect *rect, CGRect bounds) {
    LUICGRectSetMinY(rect, CGRectGetMinY(bounds));
}
UIKIT_STATIC_INLINE void LUICGRectAlignMidYToRect(CGRect *rect, CGRect bounds) {
    LUICGRectSetMidY(rect, CGRectGetMidY(bounds));
}
UIKIT_STATIC_INLINE void LUICGRectAlignMaxYToRect(CGRect *rect, CGRect bounds) {
    LUICGRectSetMaxY(rect, CGRectGetMaxY(bounds));
}

#pragma mark - Axis operation
UIKIT_STATIC_INLINE CGFloat LUICGRectGetMin(CGRect rect, LUICGAxis axis) {
    return axis == LUICGAxisX ? CGRectGetMinX(rect):CGRectGetMinY(rect);
}
UIKIT_STATIC_INLINE void LUICGRectSetMin(CGRect *rect, LUICGAxis axis, CGFloat value) {
    if (axis == LUICGAxisX) {LUICGRectSetMinX(rect, value);} else {LUICGRectSetMinY(rect, value);}
}
UIKIT_STATIC_INLINE void LUICGRectAddMin(CGRect *rect, LUICGAxis axis, CGFloat value) {
    LUICGRectSetMin(rect, axis, LUICGRectGetMin(*rect, axis)+value);
}
UIKIT_STATIC_INLINE CGFloat LUICGRectGetMid(CGRect rect, LUICGAxis axis) {
    return axis == LUICGAxisX ? CGRectGetMidX(rect) : CGRectGetMidY(rect);
}
UIKIT_STATIC_INLINE void LUICGRectSetMid(CGRect *rect, LUICGAxis axis, CGFloat value) {
    if (axis == LUICGAxisX) {LUICGRectSetMidX(rect, value);} else {LUICGRectSetMidY(rect, value);}
}
UIKIT_STATIC_INLINE void LUICGRectAddMid(CGRect *rect, LUICGAxis axis, CGFloat value) {
    LUICGRectSetMid(rect, axis, LUICGRectGetMid(*rect, axis)+value);
}
UIKIT_STATIC_INLINE CGFloat LUICGRectGetMax(CGRect rect, LUICGAxis axis) {
    return axis == LUICGAxisX ? CGRectGetMaxX(rect) : CGRectGetMaxY(rect);
}
UIKIT_STATIC_INLINE void LUICGRectSetMax(CGRect *rect, LUICGAxis axis, CGFloat value) {
    if (axis == LUICGAxisX) {LUICGRectSetMaxX(rect, value);} else {LUICGRectSetMaxY(rect, value);}
}
UIKIT_STATIC_INLINE void LUICGRectAddMax(CGRect *rect, LUICGAxis axis, CGFloat value) {
    LUICGRectSetMax(rect, axis, LUICGRectGetMax(*rect, axis) + value);
}
UIKIT_STATIC_INLINE void LUICGRectSetMinEdgeToRect(CGRect *rect, LUICGAxis axis, CGRect bounds, CGFloat edge) {
    if (axis == LUICGAxisX) {LUICGRectSetMinXEdgeToRect(rect, bounds, edge);} else {LUICGRectSetMinYEdgeToRect(rect, bounds, edge);}
}
UIKIT_STATIC_INLINE void LUICGRectSetMaxEdgeToRect(CGRect *rect, LUICGAxis axis, CGRect bounds, CGFloat edge) {
    if (axis == LUICGAxisX) {LUICGRectSetMaxXEdgeToRect(rect, bounds, edge);} else {LUICGRectSetMaxYEdgeToRect(rect, bounds, edge);}
}
UIKIT_STATIC_INLINE CGFloat LUICGRectGetLength(CGRect rect, LUICGAxis axis) {
    return axis == LUICGAxisX ? CGRectGetWidth(rect) : CGRectGetHeight(rect);
}
UIKIT_STATIC_INLINE void LUICGRectSetLength(CGRect *rect, LUICGAxis axis, CGFloat value) {
    if (axis == LUICGAxisX) {LUICGRectSetWidth(rect, value);} else {LUICGRectSetHeight(rect, value);}
}
UIKIT_STATIC_INLINE void LUICGRectAddLength(CGRect *rect, LUICGAxis axis, CGFloat value) {
    LUICGRectSetLength(rect, axis, LUICGRectGetLength(*rect, axis)+value);
}
UIKIT_STATIC_INLINE void LUICGRectAlignMinToRect(CGRect *rect, LUICGAxis axis, CGRect bounds) {
    if (axis == LUICGAxisX) {LUICGRectAlignMinXToRect(rect, bounds);} else {LUICGRectAlignMinYToRect(rect, bounds);}
}
UIKIT_STATIC_INLINE void LUICGRectAlignMidToRect(CGRect *rect, LUICGAxis axis, CGRect bounds) {
    if (axis == LUICGAxisX) {LUICGRectAlignMidXToRect(rect, bounds);} else {LUICGRectAlignMidYToRect(rect, bounds);}
}
UIKIT_STATIC_INLINE void LUICGRectAlignMaxToRect(CGRect *rect, LUICGAxis axis, CGRect bounds) {
    if (axis == LUICGAxisX) {LUICGRectAlignMaxXToRect(rect, bounds);} else {LUICGRectAlignMaxYToRect(rect, bounds);}
}
UIKIT_STATIC_INLINE void LUICGRectAlignToRect(CGRect *rect, LUICGAxis axis, LUICGRectAlignment alignment, CGRect bounds) {
    switch (alignment) {
        case LUICGRectAlignmentMin:
            LUICGRectAlignMinToRect(rect, axis, bounds);
            break;
        case LUICGRectAlignmentMid:
            LUICGRectAlignMidToRect(rect, axis, bounds);
            break;
        case LUICGRectAlignmentMax:
            LUICGRectAlignMaxToRect(rect, axis, bounds);
            break;
    }
}
UIKIT_STATIC_INLINE void LUICGRectAlignMidCenterToRect(CGRect *rect, CGRect bounds) {
    LUICGRectAlignMidToRect(rect, LUICGAxisX, bounds);
    LUICGRectAlignMidToRect(rect, LUICGAxisY, bounds);
}

#pragma mark - UIRectEdge

typedef enum : NSUInteger {
    LUIEdgeInsetsMin, //对应于top, left
    LUIEdgeInsetsMax, //对应于bottom, right
} LUIEdgeInsetsEdge;

UIKIT_STATIC_INLINE CGFloat LUIEdgeInsetsGetEdge(UIEdgeInsets insets, LUICGAxis axis, LUIEdgeInsetsEdge edge) {
    return axis == LUICGAxisX ? (edge == LUIEdgeInsetsMin?insets.left:insets.right):(edge == LUIEdgeInsetsMin?insets.top:insets.bottom);
}
UIKIT_STATIC_INLINE CGFloat LUIEdgeInsetsGetEdgeSum(UIEdgeInsets insets, LUICGAxis axis) {
    return axis == LUICGAxisX ? (insets.left+insets.right):(insets.top+insets.bottom);
}
UIKIT_STATIC_INLINE void LUIEdgeInsetsSetEdge(UIEdgeInsets *insets, LUICGAxis axis, LUIEdgeInsetsEdge edge, CGFloat value) {
    if (axis == LUICGAxisX) {if (edge == LUIEdgeInsetsMin) {(*insets).left=value;} else {(*insets).right=value;}} else {if (edge == LUIEdgeInsetsMin) {(*insets).top=value;} else {(*insets).bottom=value;}}
}
UIKIT_STATIC_INLINE void LUIEdgeInsetsAddEdge(UIEdgeInsets *insets, LUICGAxis axis, LUIEdgeInsetsEdge edge, CGFloat value) {
    LUIEdgeInsetsSetEdge(insets, axis, edge, LUIEdgeInsetsGetEdge(*insets, axis, edge)+value);
}

#pragma mark - CGAffineTransform
UIKIT_STATIC_INLINE CGAffineTransform LUICGAffineTransformMakeTranslation(LUICGAxis X, CGFloat tx) {
    return X == LUICGAxisX?CGAffineTransformMakeTranslation(tx, 0):CGAffineTransformMakeTranslation(0, tx);
}
#pragma mark - CATransform3D
UIKIT_STATIC_INLINE CATransform3D LUICATransform3DMakeTranslation(LUICGAxis X, CGFloat tx) {
    return X == LUICGAxisX?CATransform3DMakeTranslation(tx, 0, 0):CATransform3DMakeTranslation(0, tx, 0);
}
UIKIT_STATIC_INLINE CATransform3D LUICATransform3DMakeRotation(LUICGAxis X, CGFloat angle) {
    return X == LUICGAxisX?CATransform3DMakeRotation(angle, 1, 0, 0):CATransform3DMakeRotation(angle, 0, 1, 0);
}
UIKIT_STATIC_INLINE CATransform3D LUICATransform3DMakeScale(LUICGAxis X , CGFloat sx) {
    return X == LUICGAxisX?CATransform3DMakeScale(sx, 1, 1):CATransform3DMakeScale(1, sx, 1);
}

//闭区间
struct LUICGRange {
    CGFloat begin;
    CGFloat end;
};
typedef struct CG_BOXABLE LUICGRange LUICGRange;

UIKIT_STATIC_INLINE LUICGRange LUICGRangeMake(CGFloat begin, CGFloat end) {
    return (LUICGRange) {begin, end};
}
UIKIT_STATIC_INLINE CGFloat LUICGRangeInterpolate(LUICGRange range, CGFloat progress) {//插值
    return range.begin * (1.0 - progress) + range.end * progress;
}
UIKIT_STATIC_INLINE BOOL LUICGRangeContainsValue(LUICGRange range, CGFloat v) {//是否包含指定值
    return v>=range.begin && v<=range.end;
}
UIKIT_STATIC_INLINE BOOL LUICGRangeIsNull(LUICGRange r) {//是否是无效的区域
    return r.end<r.begin;
}
UIKIT_STATIC_INLINE BOOL LUICGRangeIsEmpty(LUICGRange r) {//是否是空区间
    return r.end == r.begin;
}
UIKIT_STATIC_INLINE BOOL LUICGRangeIntersectsRange(LUICGRange r1, LUICGRange r2) {//两个区间是否相交
    return LUICGRangeContainsValue(r1, r2.end)  ||  LUICGRangeContainsValue(r1, r2.begin)
     || LUICGRangeContainsValue(r2, r1.end)  ||  LUICGRangeContainsValue(r2, r1.begin)
    ;
}
UIKIT_STATIC_INLINE LUICGRange LUICGRangeUnion(LUICGRange r1, LUICGRange r2) {//返回两个区间的并
    return LUICGRangeMake(MIN(r1.begin, r2.begin), MAX(r1.end, r2.end));
}
UIKIT_STATIC_INLINE LUICGRange LUICGRangeIntersection(LUICGRange r1, LUICGRange r2) {//返回两个区间的交，没有交集时，返回无效区间
    return LUICGRangeMake(MAX(r1.begin, r2.begin), MIN(r1.end, r2.end));
}
UIKIT_STATIC_INLINE LUICGRange LUICGRectGetRange(CGRect rect, LUICGAxis axis) {
    return LUICGRangeMake(LUICGRectGetMin(rect, axis), LUICGRectGetMax(rect, axis));
}
UIKIT_STATIC_INLINE CGFloat LUICGRangeGetMin(LUICGRange r) {
    return r.begin;
}
UIKIT_STATIC_INLINE CGFloat LUICGRangeGetMax(LUICGRange r) {
    return r.end;
}
UIKIT_STATIC_INLINE CGFloat LUICGRangeGetMid(LUICGRange r) {
    return r.begin + (r.end - r.begin) * 0.5;
}
UIKIT_STATIC_INLINE CGFloat LUICGRangeGetLength(LUICGRange r) {
    return r.end - r.begin;
}

UIKIT_STATIC_INLINE NSComparisonResult LUICGRangeCompareWithValue(LUICGRange r, CGFloat value) {
    return LUICGRangeContainsValue(r, value) ? NSOrderedSame : (r.end < value ? NSOrderedAscending:NSOrderedDescending);
}
UIKIT_STATIC_INLINE NSComparisonResult LUICGRangeCompareWithRange(LUICGRange r1, LUICGRange r2) {
    return LUICGRangeIntersectsRange(r1, r2)?NSOrderedSame:(r1.end<r2.begin?NSOrderedAscending:NSOrderedDescending);
//    return LUICGRangeContainsValue(r, value)?NSOrderedSame:(r.end<value?NSOrderedAscending:NSOrderedDescending);
}

UIKIT_STATIC_INLINE NSComparisonResult LUICGRectCompareWithPoint(CGRect rect, CGPoint point, LUICGAxis axis) {
    return LUICGRangeCompareWithValue(LUICGRectGetRange(rect, axis), LUICGPointGetValue(point, axis));
}
UIKIT_STATIC_INLINE NSComparisonResult LUICGRectCompareWithCGRect(CGRect r1, CGRect r2, LUICGAxis axis) {
    return LUICGRangeCompareWithRange(LUICGRectGetRange(r1, axis), LUICGRectGetRange(r2, axis));
}


UIKIT_STATIC_INLINE UIEdgeInsets LUIEdgeInsetsMakeSameEdge(CGFloat edge) {
    return UIEdgeInsetsMake(edge, edge, edge, edge);
}

NS_ASSUME_NONNULL_END



NS_ASSUME_NONNULL_BEGIN
//插值
UIKIT_STATIC_INLINE CGFloat LUICGFloatInterpolate(CGFloat v1, CGFloat v2, CGFloat progress) {
    return v1 * (1.0 - progress) + v2 * progress;
}
UIKIT_STATIC_INLINE CGPoint LUICGPointInterpolate(CGPoint v1, CGPoint v2, CGFloat progress) {
    return CGPointMake(LUICGFloatInterpolate(v1.x, v2.x, progress), LUICGFloatInterpolate(v1.y, v2.y, progress));
}
UIKIT_STATIC_INLINE CGVector LUICGVectorInterpolate(CGVector v1, CGVector v2, CGFloat progress) {
    return CGVectorMake(LUICGFloatInterpolate(v1.dx, v2.dx, progress), LUICGFloatInterpolate(v1.dy, v2.dy, progress));
}
UIKIT_STATIC_INLINE CGSize LUICGSizeInterpolate(CGSize v1, CGSize v2, CGFloat progress) {
    return CGSizeMake(LUICGFloatInterpolate(v1.width, v2.width, progress), LUICGFloatInterpolate(v1.height, v2.height, progress));
}
UIKIT_STATIC_INLINE CGRect LUICGRectInterpolate(CGRect v1, CGRect v2, CGFloat progress) {
    return CGRectMake(
        LUICGFloatInterpolate(v1.origin.x, v2.origin.x, progress), 
        LUICGFloatInterpolate(v1.origin.y, v2.origin.y, progress), 
        LUICGFloatInterpolate(v1.size.width, v2.size.width, progress), 
        LUICGFloatInterpolate(v1.size.height, v2.size.height, progress)
    );
}
UIKIT_STATIC_INLINE CGAffineTransform LUICGAffineTransformInterpolate(CGAffineTransform v1, CGAffineTransform v2, CGFloat progress) {
    return CGAffineTransformMake(
        LUICGFloatInterpolate(v1.a, v2.a, progress), 
        LUICGFloatInterpolate(v1.b, v2.b, progress), 
        LUICGFloatInterpolate(v1.c, v2.c, progress), 
        LUICGFloatInterpolate(v1.d, v2.d, progress), 
        LUICGFloatInterpolate(v1.tx, v2.tx, progress), 
        LUICGFloatInterpolate(v1.ty, v2.ty, progress)
    );
}
UIKIT_STATIC_INLINE CATransform3D LUICATransform3DInterpolate(CATransform3D v1, CATransform3D v2, CGFloat progress) {
    CATransform3D v = CATransform3DIdentity;
    v.m11 = LUICGFloatInterpolate(v1.m11, v2.m11, progress);
    v.m12 = LUICGFloatInterpolate(v1.m12, v2.m12, progress);
    v.m13 = LUICGFloatInterpolate(v1.m13, v2.m13, progress);
    v.m14 = LUICGFloatInterpolate(v1.m14, v2.m14, progress);
    v.m21 = LUICGFloatInterpolate(v1.m21, v2.m21, progress);
    v.m22 = LUICGFloatInterpolate(v1.m22, v2.m22, progress);
    v.m23 = LUICGFloatInterpolate(v1.m23, v2.m23, progress);
    v.m24 = LUICGFloatInterpolate(v1.m24, v2.m24, progress);
    v.m31 = LUICGFloatInterpolate(v1.m31, v2.m31, progress);
    v.m32 = LUICGFloatInterpolate(v1.m32, v2.m32, progress);
    v.m33 = LUICGFloatInterpolate(v1.m33, v2.m33, progress);
    v.m34 = LUICGFloatInterpolate(v1.m34, v2.m34, progress);
    v.m41 = LUICGFloatInterpolate(v1.m41, v2.m41, progress);
    v.m42 = LUICGFloatInterpolate(v1.m42, v2.m42, progress);
    v.m43 = LUICGFloatInterpolate(v1.m43, v2.m43, progress);
    v.m44 = LUICGFloatInterpolate(v1.m44, v2.m44, progress);
    return v;
}

UIKIT_STATIC_INLINE UIColor *__LUIColorInterpolate(UIColor *v1, UIColor *v2, CGFloat progress) {//插值
    CGFloat r1, g1, b1, a1;[v1 getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
    CGFloat r2, g2, b2, a2;[v2 getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
    CGFloat r = LUICGFloatInterpolate(r1, r2, progress);
    CGFloat g = LUICGFloatInterpolate(g1, g2, progress);
    CGFloat b = LUICGFloatInterpolate(b1, b2, progress);
    CGFloat a = LUICGFloatInterpolate(a1, a2, progress);
    UIColor *v = [UIColor colorWithRed:r green:g blue:b alpha:a];
    return v;
}

UIKIT_STATIC_INLINE UIColor *LUIColorInterpolate(UIColor *v1, UIColor *v2, CGFloat progress) {//插值
    UIColor *v;
    if (@available(iOS 13.0, *)) {
        v = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            UIColor *c1 = [v1 resolvedColorWithTraitCollection:traitCollection];
            UIColor *c2 = [v2 resolvedColorWithTraitCollection:traitCollection];
            return __LUIColorInterpolate(c1, c2, progress);
        }];
    } else {
        v = __LUIColorInterpolate(v1, v2, progress);
    }
    return v;
}

NS_ASSUME_NONNULL_END
