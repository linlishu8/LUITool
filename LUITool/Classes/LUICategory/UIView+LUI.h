//
//  UIView+LUI.h
//  LUITool
//
//  Created by 六月 on 2023/8/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (LUI)
/**
 *  返回视图的截屏图片,图片的 size=视图的 size,图片的 scale=屏幕 scale
 *
 *  @return 图片
 */
- (UIImage *)l_screenshotsImage;

/**
 *  返回视图的截屏图片
 *
 *  @param scale 图片的 scale 值,0代表屏幕 scale
 *
 *  @return 图片
 */
- (UIImage *)l_screenshotsImageWithScale:(CGFloat)scale;

- (UIImage *)l_screenshotsImageWithScale:(CGFloat)scale opaque:(BOOL)opaque;
/**
 *  返回视图的截屏图片,如果视图的尺寸与 size 不合,此时会对视图进行transform变换
 *
 *  @param size  目标图片尺寸
 *  @param scale 目标图片的 scale,0代表使用屏幕scale
 *
 *  @return 图片
 */
- (UIImage *)l_screenshotsImageWithSize:(CGSize)size scale:(CGFloat)scale;

/**
 *  如果设置了self.transform,此时直接设置self.frame无效.这种情况改为设置bounds与center值
 *    注:该方法仅针对layer.anchorPoint=(0.5,0.5),其余情况不适用
 */
@property (nonatomic, assign) CGRect l_frameSafety;

@property (nonatomic, assign) CGRect l_frameOfBoundsCenter;//考虑了self.transform,layer.anchorPoint值的情况,由bounds和center计算而得
/**
 *  使指定的区域,变透明
 *    原理是根据self.bounds与clearRect生成遮罩图片以及遮罩CALayer,然后设置self.layer.mask属性
 *  @param clearRect 指定的区域,坐标系为self
 */
- (void)l_maskRectClear:(CGRect)clearRect;

/**
 *  自动调整自己的尺寸,同时要求尺寸不能小于minSize.
    一般用于导航条的按钮,sizeToFit出来的尺寸太小了,不适应触控.此时要规定它的最小尺寸
 *
 *  @param minSize 最小尺寸
 */
- (void)l_sizeToFitWithMinSize:(CGSize)minSize;

/**
 计算合适的尺寸.maxSize限定结果尺寸的最大值,某一边的值=0,代表这边的值不限定最大值

 @param size 容器尺寸
 @param maxSize 最大尺寸
 @return 最合适的尺寸
 */
- (CGSize)l_sizeThatFits:(CGSize)size limitInSize:(CGSize)maxSize;
@end

@interface UIWindow (LUI)
@property (nonatomic, readonly, nullable) UIViewController *l_rootViewControllerOfPresented;//找出最外层的根控制器,包含被弹出的控制器
@end
NS_ASSUME_NONNULL_END



NS_ASSUME_NONNULL_BEGIN
@interface UIResponder (LUI)
/**
 *  根据UIView.nextResponder,来递归地查找出离view最近的UIViewController
 *
 *  @return UIViewController对象
 */
- (nullable __kindof UIViewController *)l_viewControllerOfFirst;
- (nullable __kindof UIViewController *)l_viewControllerOfFirstWithClass:(Class)viewControllerClass;

/**
 *  根据UIView.nextResponder,来递归地查找出离view最近的UINavigationController
 *
 *  @return UINavigationController对象
 */
- (nullable UINavigationController *)l_navigationControllerOfFirst;

@end

@interface UIView (LUI)
/**
 *  根据super.view,递归查找出第一个UITableView
 *
 *  @return 外层的列表对象
 */
- (nullable UITableView *)l_tableViewOfFirst;

/**
 *  根据super.view,递归查找出第一个UICollectionView
 *
 *  @return 外层的集合对象
 */
- (nullable UICollectionView *)l_collectionViewOfFirst;
/**
 *  根据super.view,递归查找出clazz类型的view视图
 *
 *  @param clazz UIView的子类
 *
 *  @return 最接近self的外层视图
 */
- (nullable __kindof UIView *)l_firstSuperViewWithClass:(Class)clazz;

/**
 *  从self.subviews中查找出指定class的子视图
 *
 *  @param clazz 子视图的类型
 *
 *  @return 符合条件的子视图
 */
- (nullable NSArray<__kindof UIView *> *)l_subviewsWithClass:(Class)clazz;

/// 递归查找指定的子类
/// @param clazz 子视图类型
/// @param resursion 是否递归
- (nullable NSArray<__kindof UIView *> *)l_subviewsWithClass:(Class)clazz resursion:(BOOL)resursion;

/// 递归查找isFirstResponder的控件
- (nullable __kindof UIView *)l_firstResponder;
@end

NS_ASSUME_NONNULL_END
