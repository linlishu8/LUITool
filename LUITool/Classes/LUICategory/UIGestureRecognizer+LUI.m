//
//  UIGestureRecognizer+LUI.m
//  LUITool
//
//  Created by 六月 on 2023/8/11.
//

#import "UIGestureRecognizer+LUI.h"
#import "UIView+LUI.h"

@interface LUIGestureRecognizerMoveAction () {
    struct {
        CGPoint beginPoint;
        CGPoint prePoint;
        CGPoint endPoint;
    } __gestureState;
}
@property (nonatomic, assign) CGVector moveDistance;
@property (nonatomic, assign) CGVector moveVector;

@end
@implementation LUIGestureRecognizerMoveAction
- (void)setGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    if (_gestureRecognizer  ==  gestureRecognizer) return;
    [_gestureRecognizer removeTarget:self action:@selector(__moveGesture:)];
    _gestureRecognizer = gestureRecognizer;
    [_gestureRecognizer addTarget:self action:@selector(__moveGesture:)];
}
- (CGPoint)beginPoint {
    return __gestureState.beginPoint;
}
- (CGPoint)prePoint {
    return __gestureState.prePoint;
}
- (CGPoint)endPoint {
    return __gestureState.endPoint;
}
- (UIView *)__pointContainer:(UIPanGestureRecognizer *)gesture {
    UIWindow *window = [gesture.view l_firstSuperViewWithClass:UIWindow.class];
    return window?:gesture.view;
}
- (void)__moveGesture:(UIPanGestureRecognizer *)gesture {
    UIView *view = [self __pointContainer:gesture];
    CGPoint p = [gesture locationInView:view];
    switch (gesture.state) {
        case UIGestureRecognizerStatePossible:
            break;
        case UIGestureRecognizerStateBegan:
        {
            memset(&__gestureState, 0, sizeof(__gestureState));
            __gestureState.beginPoint = p;
            __gestureState.prePoint = p;
            __gestureState.endPoint = p;
            self.moveVector = CGVectorMake(0, 0);
            self.moveDistance = CGVectorMake(0, 0);
        }
            break;
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            CGPoint p1 = __gestureState.beginPoint;
            CGPoint p2 = p;
            __gestureState.endPoint = p;
            self.moveDistance = CGVectorMake(p2.x-p1.x, p2.y-p1.y);
        }
            break;
        default:
            break;
    }
    if (gesture.state  ==  UIGestureRecognizerStateChanged) {
        CGPoint pre = __gestureState.prePoint;
        self.moveVector = CGVectorMake(p.x-pre.x, p.y-pre.y);
    }
    if (self.whenAction) {
        self.whenAction(self);
    }
    if (gesture.state  ==  UIGestureRecognizerStateChanged) {
        CGPoint pre = __gestureState.prePoint;
        self.moveVector = CGVectorMake(p.x-pre.x, p.y-pre.y);
        __gestureState.prePoint = p;
    }
}

@end

#import <objc/runtime.h>

@implementation UIGestureRecognizer (LUI)

- (LUIGestureRecognizerMoveAction *)l_moveAction {
    const void * key = "l_moveAction";
    LUIGestureRecognizerMoveAction *obj = objc_getAssociatedObject(self, key);
    if (!obj) {
        obj = [[LUIGestureRecognizerMoveAction alloc] init];
        obj.gestureRecognizer = self;
        objc_setAssociatedObject(self, key, obj, OBJC_ASSOCIATION_RETAIN);
    }
    return obj;
}

@end
