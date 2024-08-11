//
//  UIScrollView+LUI.h
//  LUITool
//
//  Created by 六月 on 2024/8/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    LUIScrollViewScrollDirectionVertical,//垂直滚动
    LUIScrollViewScrollDirectionHorizontal,//水平滚动
} LUIScrollViewScrollDirection;
typedef enum : NSUInteger {
    LUIScrollViewScrollPositionHead,//居上或居左
    LUIScrollViewScrollPositionMiddle,//居中
    LUIScrollViewScrollPositionFoot,//居下或居右
} LUIScrollViewScrollPosition;

@interface UIScrollView (LUI)
/**
 *  滚动到底部
 *
 *  @param animated 是否动画
 */
- (void)l_scrollToBottomWithAnimated:(BOOL)animated;
/**
 *  滚动到顶部
 *
 *  @param animated 是否动画
 */
- (void)l_scrollToTopWithAnimated:(BOOL)animated;
//设UIScrollView的contentSize左上角的坐标为(x,y),则contentOffset=(-x,-y)
@property (nonatomic, readonly) UIEdgeInsets l_contentOffsetOfRange;//计算contentOffset的x,y取值范围
@property (nonatomic, readonly) CGFloat l_contentOffsetOfMinY;//contentOffset.y的最小值
@property (nonatomic, readonly) CGFloat l_contentOffsetOfMaxY;//contentOffset.y的最大值
@property (nonatomic, readonly) CGFloat l_contentOffsetOfMinX;//contentOffset.x的最小值
@property (nonatomic, readonly) CGFloat l_contentOffsetOfMaxX;//contentOffset.x的最大值

/// 调整contentOffset值，使其在可滚动的范围内
/// - Parameter offset: offset
- (CGPoint)l_adjustContentOffsetInRange:(CGPoint)offset;

@property (nonatomic, readonly) CGRect l_contentDisplayRect;//当前显示内容的frame值,计算自zoomScale,contentOffset,frame值

@property (nonatomic, readonly) CGRect l_contentBounds;//self.bounds扣掉contentInsets值
@property (nonatomic, readonly) UIEdgeInsets l_adjustedContentInset;
@property (nonatomic, readonly) CGPoint l_centerPointOfContent;//返回scrollview显示内容的中心点，即self.bounds扣除掉adjustedContentInset之后区域的中心点

/**
 将scrollview缩放到指定的比例,同时保持point点坐标相对位置不变.
 使用场景如:双击scrollview,进行放大/缩小操作,point点为双击的点

 @param point 缩放时保持不动的点,坐标系为self
 @param scale 缩放比例
 @param animated 是否动画
 */
- (void)l_zoomToPoint:(CGPoint)point zoomScale:(CGFloat)scale animated:(BOOL)animated;

/**
 可以作为动画改变scrollview的zoom属性的手势响应方法

 @param gesture 引起zoom效果的手势
 */
- (void)l_toggleZoomScale:(UIGestureRecognizer *)gesture;

/// 响应UIKeyboardDidShowNotification事件，调整自己的contentInset和contentOffset
/// @param noti 键盘展示的通知
/// @param responderViewClass 响应控件的view类型
/// @param contentInsets  原始的contentInsets
/// @param window  scrollView所在的window对象
- (void)l_adjustContentWithUIKeyboardDidShowNotification:(NSNotification *)noti responderViewClass:(Class)responderViewClass contentInsets:(UIEdgeInsets)contentInsets window:(UIWindow *)window;


/// 计算将viewFrame滚动到指定位置的contentOffset值
/// @param viewFrame 指定的frame
/// @param direction 滚动方向，水平、垂直
/// @param position viewFrame位置，上中下或右中右
- (CGPoint)l_contentOffsetWithScrollTo:(CGRect)viewFrame direction:(LUIScrollViewScrollDirection)direction position:(LUIScrollViewScrollPosition)position;

- (void)l_autoBounces;
@end

NS_ASSUME_NONNULL_END
