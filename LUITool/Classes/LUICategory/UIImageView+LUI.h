//
//  UIImageView+LUI.h
//  LUITool
//
//  Created by 六月 on 2024/8/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (LUI)

/// 裁剪图片视图上指定的区域,clipRect和self处于同一坐标系中
/// @param clipRect 裁剪的区域,当区域超出图片区域时,该区域不裁剪(不会以透明像素的形式出现)
- (UIImage *)l_cropImageWithRect:(CGRect)clipRect;

/// 获取某一点的颜色值,坐标系为UIImageView坐标系(原点在左上角)
/// @param point 点坐标
- (nullable UIColor *)l_colorWithPoint:(CGPoint)point;

/// 根据自身的ContentMode属性,获取图片的仿射矩阵,该矩阵的作用是将图片缩放到视图范围内.方法cropImageWithRect:使用它进行clipRect的逆转换.图片进行缩放时,坐标系为imageView的视图坐标系,图片从(0,0,self.image.size.width*image.scale,self.image.size.heigt*image.scale)变换到最终的显示效果
- (CGAffineTransform)l_transformWithSelfContentMode;

/// 根据ContentMode属性(=UIViewContentModeScaleAspectFit),获取图片的仿射矩阵,该矩阵的作用是将图片缩放到视图范围内
/// @param contentMode 变换属性
- (CGAffineTransform)l_transformWithContentMode:(UIViewContentMode)contentMode;

/// 获取图片经过contentMode缩放后的图片显示区域
- (CGRect)l_frameOfImageContent;

/// 返回从self.image的图片坐标系转(原点在图片左下角,y轴向上,x轴向右)换到UIView视图坐标系的转换变换矩阵
- (CGAffineTransform)l_transformFromImageCoordinateSpace;

/// 将rect从self.image所在的图片坐标系(原点在图片左下角,y轴向上,x轴向右)转换到UIImageView的视图坐标系
/// @param rect 图片坐标系的矩形区域
- (CGRect)l_convertRectFromImageCoordinateSpace:(CGRect)rect;

/// 将point从self.image所在的图片坐标系(原点在图片左下角,y轴向上,x轴向右)转换到UIView的视图坐标系
/// @param point 图片坐标系中的点
- (CGPoint)l_convertPointFromFromImageCoordinateSpace:(CGPoint)point;

/// 计算图片视图的合适尺寸,且不超过 size.某一边尺寸小于等于0，代表限定在图片尺寸内
/// @param size 限定的尺寸
- (CGSize)l_sizeThatFits:(CGSize)size;

/// 计算图片视图的合适尺寸。如果size不为(0,0)时，将直接返回size。如果size某一边值为0，该边将动态计算尺寸
/// @param size 指定图片的尺寸
- (CGSize)l_sizeThatFitsFixedImageSize:(CGSize)size;
@end

NS_ASSUME_NONNULL_END
