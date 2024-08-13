//
//  UIScrollView+LUI.m
//  LUITool
//
//  Created by 六月 on 2023/8/11.
//

#import "UIScrollView+LUI.h"
#import "NSObject+LUI.h"
#import "UIView+LUI.h"
#import "CGGeometry+LUI.h"

@implementation UIScrollView (LUI)

- (void)l_scrollToBottomWithAnimated:(BOOL)animated{
    CGFloat offsetYMax = self.l_contentOffsetOfMaxY;
    CGFloat offsetYMin = self.l_contentOffsetOfMinY;
    if(offsetYMax<offsetYMin){
        offsetYMax = offsetYMin;
    }
    CGPoint contentOffset = self.contentOffset;
    contentOffset.y = offsetYMax;
    if(animated){
        [self setContentOffset:contentOffset animated:animated];
    }else{
        self.contentOffset = contentOffset;
    }
}
- (void)l_scrollToTopWithAnimated:(BOOL)animated{
    CGFloat offsetYMin = self.l_contentOffsetOfMinY;
    CGPoint contentOffset = self.contentOffset;
    contentOffset.y = offsetYMin;
    if(animated){
        [self setContentOffset:contentOffset animated:animated];
    }else{
        self.contentOffset = contentOffset;
    }
}
- (UIEdgeInsets)l_contentOffsetOfRange{
    CGRect bounds = self.bounds;
    CGSize contentSize = self.contentSize;
    UIEdgeInsets contentInset = self.l_adjustedContentInset;
    CGFloat minY = -contentInset.top;
    CGFloat maxY = MAX(minY,contentSize.height-bounds.size.height+contentInset.bottom);
    CGFloat minX = -contentInset.left;
    CGFloat maxX = MAX(minX,contentSize.width-bounds.size.width+contentInset.right);
    UIEdgeInsets range = UIEdgeInsetsMake(minY, minX, maxY, maxX);
    //    NSLog(@"bounds:%@,contentSize:%@,contentOffset:%@,contentInset:%@,offsetYMin:%@,offsetYMax:%@",NSStringFromCGRect(bounds),NSStringFromCGSize(contentSize),NSStringFromCGPoint(contentOffset),NSStringFromUIEdgeInsets(contentInset),@(offsetYMin),@(offsetYMax));
    return range;
}
- (CGPoint)l_adjustContentOffsetInRange:(CGPoint)offset{
    UIEdgeInsets range = self.l_contentOffsetOfRange;
    CGPoint offset1 = offset;
    offset1.x = MIN(offset1.x,range.right);
    offset1.x = MAX(offset1.x,range.left);
    offset1.y = MIN(offset1.y,range.bottom);
    offset1.y = MAX(offset1.y,range.top);
    return offset1;
}
- (CGFloat)l_contentOffsetOfMinX{
    CGFloat v = self.l_contentOffsetOfRange.left;
    return v;
}
- (CGFloat)l_contentOffsetOfMaxX{
    CGFloat v = self.l_contentOffsetOfRange.right;
    return v;
}
- (CGFloat)l_contentOffsetOfMinY{
    CGFloat v = self.l_contentOffsetOfRange.top;
    return v;
}
- (CGFloat)l_contentOffsetOfMaxY{
    CGFloat v = self.l_contentOffsetOfRange.bottom;
    return v;
}
- (CGRect)l_contentDisplayRect{
    CGRect displayRect = CGRectZero;
    CGFloat zoomScale = self.zoomScale;
    displayRect.origin = self.contentOffset;
    displayRect.size = self.frame.size;
    displayRect.origin.x /= zoomScale;
    displayRect.origin.y /= zoomScale;
    displayRect.size.width /= zoomScale;
    displayRect.size.height /= zoomScale;
    return displayRect;
}
- (CGRect)l_contentBounds{
    UIEdgeInsets insets = self.l_adjustedContentInset;
    CGRect bounds = self.bounds;
    bounds.origin = CGPointZero;
    CGRect b = UIEdgeInsetsInsetRect(bounds, insets);
    b.origin = CGPointZero;
    return b;
}
- (CGPoint)l_centerPointOfContent{
    CGRect bounds = self.bounds;
    UIEdgeInsets safeAreaInsets = [self l_adjustedContentInset];
    CGRect contentFrame = UIEdgeInsetsInsetRect(bounds, safeAreaInsets);
    CGPoint centerPoint = CGPointMake(CGRectGetMidX(contentFrame), CGRectGetMidY(contentFrame));
    return centerPoint;
}
- (UIEdgeInsets)l_adjustedContentInset{
    UIEdgeInsets insets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
         insets = self.adjustedContentInset;//adjustedContentInset=contentInset+safeAreaInsets
    } else {
        insets =  self.contentInset;
    }
    return insets;
}
- (void)l_zoomToPoint:(CGPoint)point zoomScale:(CGFloat)scale animated:(BOOL)animated{
    CGFloat zoomScale = self.zoomScale;
    CGFloat resultZoomScale = scale;
    CGPoint p = point;//由于scrollview的locationInView方法,会包含zoomScale值,因此要扣除掉zoomScale的影响
    p.x /= zoomScale;
    p.y /= zoomScale;
    CGRect displayRect = self.l_contentDisplayRect;
    CGAffineTransform m = CGAffineTransformIdentity;
    m = CGAffineTransformConcat(m, CGAffineTransformMakeTranslation(-CGRectGetMidX(displayRect), -CGRectGetMidY(displayRect)));
    m = CGAffineTransformConcat(m, CGAffineTransformMakeScale(zoomScale/resultZoomScale, zoomScale/resultZoomScale));//将displayRect移动到原点,然后进行缩放
    
    CGPoint zoomP = CGPointApplyAffineTransform(p, m);//计算p在缩放之后的坐标
    
    m = CGAffineTransformConcat(m, CGAffineTransformMakeTranslation(p.x-zoomP.x, p.y-zoomP.y));//将displayRect移动,使p相对位置不变
    CGRect zoomRect = CGRectApplyAffineTransform(displayRect, m);
    [self zoomToRect:zoomRect animated:YES];
}
- (void)l_toggleZoomScale:(UIGestureRecognizer *)gesture{
    CGFloat maxScale = self.maximumZoomScale;
    CGFloat zoomScale = self.zoomScale;
    CGFloat resultZoomScale = zoomScale==1?maxScale:1;
    CGPoint p = [gesture locationInView:self];//由于scrollview的locationInView方法,会包含zoomScale值,因此要扣除掉zoomScale的影响
    [self l_zoomToPoint:p zoomScale:resultZoomScale animated:YES];
}
- (void)l_adjustContentWithUIKeyboardDidShowNotification:(NSNotification *)noti responderViewClass:(Class)responderViewClass contentInsets:(UIEdgeInsets)contentInsets window:(UIWindow *)window{
    CGFloat duration = [noti.userInfo l_floatForKeyPath:UIKeyboardAnimationDurationUserInfoKey];
    CGRect keyboardFrame = [noti.userInfo l_NSValueForKeyPath:UIKeyboardFrameEndUserInfoKey].CGRectValue;
    CGRect windowRect = window.bounds;
    CGRect scrollViewFrame = [self.superview convertRect:self.frame toView:window];
    UIEdgeInsets insets = contentInsets;
    insets.bottom += keyboardFrame.size.height-(windowRect.size.height-CGRectGetMaxY(scrollViewFrame));
    self.contentInset = insets;
    
    UIView *responderView = self.l_firstResponder;
    if(responderViewClass!=nil){
        UIView *superView = [responderView l_firstSuperViewWithClass:responderViewClass];
        if(superView){
            responderView = superView;
        }
    }
    if(responderView){
        CGRect responderFrame = [responderView.superview convertRect:responderView.frame toView:self];
        CGPoint contentOffset = self.contentOffset;
        CGFloat offsetMinY = responderFrame.origin.y-self.frame.size.height+keyboardFrame.size.height-(windowRect.size.height-CGRectGetMaxY(scrollViewFrame))+responderFrame.size.height;
        if(contentOffset.y<offsetMinY){
            contentOffset.y = offsetMinY;
            [UIView animateWithDuration:duration animations:^{
                [self setContentOffset:contentOffset];
            }];
        }
    }
}
- (CGPoint)l_contentOffsetWithScrollTo:(CGRect)viewFrame direction:(LUIScrollViewScrollDirection)direction position:(LUIScrollViewScrollPosition)position {
    LUICGAxis Y = direction == LUIScrollViewScrollDirectionVertical ? LUICGAxisY : LUICGAxisX;
    CGPoint offset = self.contentOffset;
    CGRect bounds = self.bounds;
    UIEdgeInsets contentInset = self.l_adjustedContentInset;
    CGRect visiableBounds = UIEdgeInsetsInsetRect(bounds, contentInset);
    CGRect cellFrame2 = viewFrame;
    switch (position) {
        case LUIScrollViewScrollPositionHead:
            LUICGPointSetValue(&offset, Y, LUICGRectGetMin(cellFrame2, Y)-LUIEdgeInsetsGetEdge(contentInset, Y, LUIEdgeInsetsMin));
            break;
        case LUIScrollViewScrollPositionMiddle:
            LUICGPointSetValue(&offset, Y, LUICGRectGetMid(cellFrame2, Y)-LUIEdgeInsetsGetEdge(contentInset, Y, LUIEdgeInsetsMin)-LUICGRectGetLength(visiableBounds, Y)*0.5);
            break;
        case LUIScrollViewScrollPositionFoot:
            LUICGPointSetValue(&offset, Y, LUICGRectGetMax(cellFrame2, Y)-(LUICGRectGetLength(bounds, Y))+LUIEdgeInsetsGetEdge(contentInset, Y, LUIEdgeInsetsMax));
            break;
        default:
            break;
    }
    //限制offset范围
    offset = [self l_adjustContentOffsetInRange:offset];
    return offset;

}
- (void)l_autoBounces{
    CGSize contentSize = self.contentSize;
    UIEdgeInsets contentInset = self.l_adjustedContentInset;
    CGRect bounds = self.bounds;
    //存在浮点误差，因此添加一个容错值
    CGFloat delta = 0.0000001;
    BOOL bounces = contentSize.width+contentInset.left+contentInset.right>bounds.size.width+delta||contentSize.height+contentInset.top+contentInset.bottom>bounds.size.height+delta;
    self.bounces = bounces;
}

@end
