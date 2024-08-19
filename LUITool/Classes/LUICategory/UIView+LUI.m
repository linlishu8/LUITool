//
//  UIView+LUI.m
//  LUITool
//
//  Created by 六月 on 2023/8/11.
//

#import "UIView+LUI.h"
#import "UIImage+LUI.h"

@implementation UIView (LUI)

- (UIImage *)l_screenshotsImageWithSize:(CGSize)size scale:(CGFloat)scale {
    CGRect b = self.bounds;
    
    if (CGSizeEqualToSize(b.size, size)) {
        UIImage *image = [self l_screenshotsImageWithScale:scale];
        return image;
    }
    
    CGAffineTransform m1 = self.transform;
    UIView *superview = self.superview;
    CGPoint c = self.center;
    
    CGSize originSize = self.bounds.size;
    CGAffineTransform m = CGAffineTransformMakeScale(size.width/originSize.width, size.height/originSize.height);
    self.transform = m;
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    CGRect bounds = CGRectMake(0, 0, size.width, size.height);
    UIView *view = [[UIView alloc] initWithFrame:bounds];
    CGRect f1 = CGRectZero;
    f1.size = originSize;
    f1.origin.x = (bounds.size.width-f1.size.width)/2;
    f1.origin.y = (bounds.size.height-f1.size.height)/2;
    [self setL_frameSafety:f1];
    
    [view addSubview:self];
    [view layoutIfNeeded];
    
    UIImage *image = [view l_screenshotsImageWithScale:scale];
    
    if (superview) {
        [superview addSubview:self];
    }
    self.transform = m1;
    self.bounds = b;
    self.center = c;
    
    return image;
}
- (UIImage *)l_screenshotsImageWithScale:(CGFloat)scale {
    return [self l_screenshotsImageWithScale:scale opaque:NO];
}
- (UIImage *)l_screenshotsImageWithScale:(CGFloat)scale opaque:(BOOL)opaque {
    CGRect bounds = self.bounds;
    if (bounds.size.width<=0 || bounds.size.height<=0) return nil;
    UIGraphicsBeginImageContextWithOptions(bounds.size, opaque, scale);
    //    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
- (UIImage *)l_screenshotsImage {
    UIImage *image = [self l_screenshotsImageWithScale:0.0];
    return image;
}
- (void)setL_frameSafety:(CGRect)frame {
    CGAffineTransform m = self.transform;
    if (CGAffineTransformIsIdentity(m)) {
        self.frame = frame;
    } else {
        CGRect bounds = self.bounds;
        bounds.size = frame.size;
        CGPoint center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
        self.bounds = bounds;
        self.center = center;
    }
}
- (CGRect)l_frameSafety {
    CGRect f = self.bounds;
    f.origin.x = self.center.x-f.size.width/2;
    f.origin.y = self.center.y-f.size.height/2;
    return f;
}

- (void)setL_frameOfBoundsCenter:(CGRect)frame {
    self.bounds = CGRectMake(0, 0, frame.size.width, frame.size.height);
    CGPoint point = self.layer.anchorPoint;
    CGPoint center = CGPointZero;
    center.x = frame.origin.x+frame.size.width*point.x;
    center.y = frame.origin.y+frame.size.height*point.y;
    self.center = center;
}
- (CGRect)l_frameOfBoundsCenter {
    CGRect frame = self.bounds;
    CGPoint center = self.center;
    CGPoint point = self.layer.anchorPoint;
    frame.origin.x = center.x-frame.size.width*point.x;
    frame.origin.y = center.y-frame.size.height*point.y;
    return frame;
}
- (void)l_maskRectClear:(CGRect)clearRect {
    CGRect bounds = self.bounds;
    UIImage *maskImage = [UIImage l_imageMaskWithSize:bounds.size clearRect:clearRect];
    CALayer *maskLayer = [CALayer layer];
    maskLayer.contents = (__bridge id _Nullable)(maskImage.CGImage);
    maskLayer.frame = bounds;
    self.layer.mask = maskLayer;
}
- (void)l_sizeToFitWithMinSize:(CGSize)minSize {
    CGSize maxSize = CGSizeMake(99999999, 99999999);
    CGSize size = [self sizeThatFits:maxSize];
    size.width = MAX(minSize.width, size.width);
    size.height = MAX(minSize.height, size.height);
    CGRect f1 = self.bounds;
    f1.size = size;
    self.bounds = f1;
}
- (CGSize)l_sizeThatFits:(CGSize)size limitInSize:(CGSize)maxSize {
    CGSize size1 = size;
    if (maxSize.width  !=  0) {
        size1.width = MIN(maxSize.width, size1.width);
    }
    if (maxSize.height  !=  0) {
        size1.height = MIN(maxSize.height, size1.height);
    }
    CGSize sizeFits = [self sizeThatFits:size1];
    if (maxSize.width  !=  0) {
        sizeFits.width = MIN(maxSize.width, sizeFits.width);
    }
    if (maxSize.height  !=  0) {
        sizeFits.height = MIN(maxSize.height, sizeFits.height);
    }
    return sizeFits;
}
@end

@implementation UIWindow (LUI)
- (UIViewController *)l_rootViewControllerOfPresented {
    UIViewController *rootController = self.rootViewController;
    do {//查找出最外层的根控制器
        UIViewController *presentedViewController = rootController.presentedViewController;
        if (presentedViewController && presentedViewController  !=  rootController) {
            rootController = rootController.presentedViewController;
        } else {
            break;
        }
    } while (YES);
    return rootController;
}
@end

@implementation UIResponder (LUIResponder)
- (UIViewController *)l_viewControllerOfFirst {
    UIResponder *target = self;
    while (target) {
        target = target.nextResponder;
        if ([target isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)target;
        }
    }
    return nil;
}
- (UIViewController *)l_viewControllerOfFirstWithClass:(Class)viewControllerClass {
    UIResponder *target = self;
    while (target) {
        target = target.nextResponder;
        if ([target isKindOfClass:viewControllerClass]) {
            return (UIViewController *)target;
        } else if ([target isKindOfClass:[UIViewController class]]) {
            UIViewController *c = (UIViewController *)target;
            if ([c isKindOfClass:viewControllerClass]) {
                return c;
            }
        }
    }
    return nil;
}
- (UINavigationController *)l_navigationControllerOfFirst {
    UIResponder *target = self;
    while (target) {
        target = target.nextResponder;
        if ([target isKindOfClass:[UINavigationController class]]) {
            return (UINavigationController *)target;
        } else if ([target isKindOfClass:[UIViewController class]]) {
            UIViewController *c = (UIViewController *)target;
            if (c.navigationController) {
                return c.navigationController;
            }
        }
    }
    return nil;
}
@end

@implementation UIView (LUIResponder)
- (UITableView *)l_tableViewOfFirst {
    UITableView *tableView = (UITableView *)[self l_firstSuperViewWithClass:[UITableView class]];
    return tableView;
}
- (UICollectionView *)l_collectionViewOfFirst {
    UICollectionView *collectionView = (UICollectionView *)[self l_firstSuperViewWithClass:[UICollectionView class]];
    return collectionView;
}
- (UIView *)l_firstSuperViewWithClass:(Class)clazz {
    UIView *target = self.superview;
    while (target) {
        if ([target isKindOfClass:clazz]) {
            return target;
        }
        target = target.superview;
    }
    return nil;
}
- (NSArray *)l_subviewsWithClass:(Class)clazz {
    NSMutableArray *views = [[NSMutableArray alloc] init];
    for (UIView *v in self.subviews) {
        if ([v isKindOfClass:clazz]) {
            [views addObject:v];
        }
    }
    return views;
}
- (NSArray *)l_subviewsWithClass:(Class)clazz resursion:(BOOL)resursion {
    NSMutableArray *views = [[NSMutableArray alloc] init];
    for (UIView *v in self.subviews) {
        if ([v isKindOfClass:clazz]) {
            [views addObject:v];
        } else {
            if (resursion) {
                NSArray *subs = [v l_subviewsWithClass:clazz resursion:resursion];
                if (subs) {
                    [views addObjectsFromArray:subs];
                }
            }
        }
    }
    return views;
}
- (nullable UIView *)l_firstResponder {
    if (self.canBecomeFirstResponder && self.isFirstResponder) return self;
    for (UIView *subview in self.subviews) {
        UIView *r = subview.l_firstResponder;
        if (r) return r;
    }
    return nil;
}

@end
