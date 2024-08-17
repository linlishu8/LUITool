//
//  UIImage+LUI.h
//  LUITool
//
//  Created by 六月 on 2023/8/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (LUI)
/**
 *  水平翻转图片
 *
 *  @return 新的图片
 */
- (UIImage *)l_horizontalInvertImage;
/**
 *  垂直翻转图片
 *
 *  @return 新的图片
 */
- (UIImage *)l_verticalInvertImage;
/**
 *  以图片中心为圆点,旋转图片
 *    如果radians为M_PI_2的整数倍时,将计算旋转后图片的capInsets值
 *  @param radians 旋转的弧度值,正值时逆时针旋转,负值顺时针旋转
 *
 *  @return 新的图片
 */
- (UIImage *)l_rotateImageWithRadians:(CGFloat)radians;

/**
 *  对图片进行仿射矩阵变换,得到新的图片
 *
 *  @param transform 要变换的矩阵
 *  @param newSize   进行矩阵变换后,图片尺寸可能会有变化(如旋转15度,尺寸变大了),此时要换入新的尺寸,如果是二倍大小,则该尺寸也要是二倍大小的值
 *
 *  @return 新的图片
 */
- (UIImage *)l_transformImageWithCTM:(CGAffineTransform)transform newSize:(CGSize)newSize;

/**
 *  对图片进行仿射矩阵变换,得到新的图片
 *
 *  @param transform 要变换的矩阵
 *  @param newSize   进行矩阵变换后,图片尺寸可能会有变化(如旋转15度,尺寸变大了),此时要换入新的尺寸,如果是二倍大小,则该尺寸也要是二倍大小的值
 *  @param orientation 变换后图片的朝向
 *
 *  @return 新的图片
 */
- (UIImage *)l_transformImageWithCTM:(CGAffineTransform)transform newSize:(CGSize)newSize newOrientation:(UIImageOrientation)orientation;

/**
 *  将图片朝向调整到指定的朝向
 *
 *  @param orientation 新的朝向
 *
 *  @return 如果朝向不变,返回self,否则返回调整后新的图片
 */
- (UIImage *)l_imageWithOrientation:(UIImageOrientation)orientation;

/**
 *  裁剪出指定rect的图片(限定在自己的size之内)
 *    内部已考虑到retina图片,rect不必为retina图片进行x2处理
 *  @param rect 指定的矩形区域,坐标系为图片坐标系,原点在图片的左上角
 *
 *  @return 新的图片
 */
- (UIImage *)l_cropImageWithRect:(CGRect)rect;

/**
 *  如果图片的长宽比例与aspectRatio不一致时,裁剪图片,使其比例与aspectRatio一致
 *    如果self是retina图片,则处理后的图片也是retina图片
 *
 *  @param aspectRatio height/width的比例值
 *
 *  @return 调整后的图片
 */
- (UIImage *)l_cropImageToFitAspectRatio:(CGFloat)aspectRatio;

/**
 *  如果图片的长宽比例与aspectRatioSize不一致时,裁剪图片,使其比例与aspectRatioSize一致
 *    如果self是retina图片,则处理后的图片也是retina图片
 *
 *  @param aspectRatioSize 用于指定长宽比的尺寸
 *
 *  @return 调整后的图片
 */
- (UIImage *)l_cropImageToFitAspectRatioSize:(CGSize)aspectRatioSize;

/**
 *  返回图片在内存里的像素点所占的内存大小,单位为字节
 *
 *  @return 字节大小
 */
- (NSUInteger)l_lengthOfRawData;

/**
 *  是否为png图片,判断依据是是否含有alpha通道
 *
 *  @return 是否是png图片
 */
- (BOOL)l_isPngImage;

/**
 *  获取图片压缩后的二进制数据,如果图片大小超过bytes时,会对图片进行等比例缩小尺寸处理
 *    会自动进行png检测,从而保持alpha通道
 *
 *  @param bytes              二进制数据的大小上限,0代表不限制
 *  @param compressionQuality 压缩后图片质量,取值为0...1,值越小,图片质量越差,压缩比越高,二进制大小越小
 *
 *  @return 二进制数据
 */
- (NSData *)l_imageDataThatFitBytes:(NSUInteger)bytes withCompressionQuality:(CGFloat)compressionQuality;

/**
 *  获取图片压缩后的二进制数据,如果图片大小超过bytes时,会对图片进行等比例缩小尺寸处理
 *    会自动进行png检测,从而保持alpha通道
 *    如果图片为jpg,默认的图片压缩质量为0.6
 *
 *  @param bytes              二进制数据的大小上限,0代表不限制
 *
 *  @return 二进制数据
 */
- (NSData *)l_imageDataThatFitBytes:(NSUInteger)bytes;

/**
 *  获取图片png压缩后的二进制数据,如果图片大小超过bytes时,会对图片进行等比例缩小尺寸处理
 *
 *  @param bytes 二进制数据的大小上限,0代表不限制
 *
 *  @return 二进制数据
 */
- (NSData *)l_imageDataOfPngThatFitBytes:(NSUInteger)bytes;

/**
 *  获取图片jpg压缩后的二进制数据,如果图片大小超过bytes时,会对图片进行等比例缩小尺寸处理
 *
 *  @param bytes              二进制数据的大小上限,0代表不限制
 *  @param compressionQuality 压缩后图片质量,取值为0...1,值越小,图片质量越差,压缩比越高,二进制大小越小
 *
 *  @return 二进制数据
 */
- (NSData *)l_imageDataOfJpgThatFitBytes:(NSUInteger)bytes withCompressionQuality:(CGFloat)compressionQuality;

/**
 *  将图片等比例缩放到指定的尺寸,当比例不对时,图片会内缩,从而导致透明区域出现
 *    如果self是retina图片,则处理后的图片也是retina图片,其image.size=size
 *
 *  @param size 指定的尺寸
 *
 *  @return 拉伸后的图片
 */
- (UIImage *)l_scaleImageToAspectFitSize:(CGSize)size;

/**
 *  将图片等比例缩放到指定的尺寸,当比例不对时,图片会外扩,从而导致截断图片
 *    如果self是retina图片,则处理后的图片也是retina图片,其image.size=size
 *
 *  @param size 指定的尺寸
 *
 *  @return 拉伸后的图片
 */
- (UIImage *)l_scaleImageToAspectFillSize:(CGSize)size;

/**
 *  将图片缩放到指定的尺寸(比例不对时,图片会拉伸)
 *    如果self是retina图片,则处理后的图片也是retina图片,其image.size=size
 *
 *  @param size 指定的尺寸
 *
 *  @return 拉伸后的图片
 */
- (UIImage *)l_scaleImageToFillSize:(CGSize)size;

/**
 *  如果图片尺寸大于size,则等比例缩小图片,直到满足尺寸<=size;如果图片尺寸小于size,则返回自身
 *
 *  @param size 最大尺寸,此size不需要考虑retina
 *
 *  @return 图片
 */
- (UIImage *)l_reduceImageSizeToMaxSize:(CGSize)size;

/**
 *  如果图片的像素尺寸大于size*scale,则等比例缩小图片,直到满足尺寸<=size*scale;如果图片尺寸小于size*scale,则返回自身
 *
 *  @param size  最大尺寸
 *  @param scale size放大倍数
 *
 *  @return 图片
 */
- (UIImage *)l_reduceImageSizeToMaxSize:(CGSize)size scale:(CGFloat)scale;

/**
 *  返回转换成jpg格式的NSData的大小字符串
 *
 *  @return 文件大小字符串
 */
- (NSString *)l_filesizeString;
- (NSString *)l_filesizeStringWithCompressionQuality:(CGFloat)compressionQuality;

/// 绘制>的图片
/// @param size 图片大小
/// @param lineWidth 线宽，建议为2
/// @param color 图片颜色
+ (UIImage *)l_disclosureIndicatorImageWithSize:(CGSize)size lineWidth:(CGFloat)lineWidth color:(UIColor *)color;
+ (UIImage *)l_disclosureIndicatorImageWithColor:(UIColor *)color;//返回7x14，线宽为2的图片

/// 绘制打勾的图片
/// @param size 图片大小
/// @param lineWidth 线宽，建议为2
/// @param color 图片颜色
+ (UIImage *)l_checkmarkImageWithSize:(CGSize)size lineWidth:(CGFloat)lineWidth color:(UIColor *)color;
+ (UIImage *)l_checkmarkImageWithColor:(UIColor *)color;//返回17x17，线宽为2的图片
@end

@interface UIImage (UIViewTransform)//视图的仿照映射
/**
 *  根据ContentMode属性,获取图片的仿射矩阵,该矩阵的作用是将图片缩放到视图范围内.
    图片进行缩放时,坐标系为UIView的视图坐标系,图片从(0,0,self.size.width*self.scale,self.size.heigt*self.scale)变换到最终的显示效果
*
*  @param contentMode 视图的ContentMode属性
*  @param bounds      限定的矩阵区域
*
*  @return 矩阵
*/
- (CGAffineTransform)l_transformWithContentMode:(UIViewContentMode)contentMode toBounds:(CGRect)bounds;

/**
 根据contentMode属性,计算从fromBounds坐标系变换到bounds坐标系的仿射矩阵

 @param contentMode 视图的ContentMode属性
 @param fromBounds 起始坐标系
 @param bounds 终止坐标系
 @param imageScale bounds坐标系的缩放参数.对应于UIImage的scale属性值.没有缩放时,传1
 @return 矩阵
 */
+ (CGAffineTransform)l_transformWithContentMode:(UIViewContentMode)contentMode fromBounds:(CGRect)fromBounds toBounds:(CGRect)bounds scale:(CGFloat)imageScale;
@end

@interface UIImage (l_UIColor)
/**
 *  使用blend来改变图片的颜色.如一张蓝色的星星图,使用白色的tintColor之后,会变成白色的星星图
 *
 *  @param tintColor 混合的颜色
 *
 *  @return 新的图片
 */
- (UIImage *)l_imageWithTintColor:(UIColor *)tintColor;

/// 以RGBA格式，遍历图片中所有像素点
/// @param block 遍历block，x，y为坐标值
- (void)l_enumRGBAPixcelsWithBlock:(void(^)(int x,int y,int r,int g,int b,int a))block;

/// 对图片中的像素（RGBA格式）进行转换操作，然后生成新的RGBA图片（如灰度图）
/// @param block 转换block，x，y为坐标值
- (UIImage *)l_convertRGBAImageWithBlock:(void(^)(int x,int y,int *r,int *g,int *b,int *a))block;

/// 返回灰度图片。
///
@property (nonatomic, readonly) UIImage *l_grayImage;

/**
 *  根据color,获取1x1尺寸的图片.可用于UIButton的backgroundImage属性设置
 *
 *  @param color 颜色
 *
 *  @return 图片
 */
+ (UIImage *)l_imageWithUIColor:(UIColor *)color;

/**
 *  根据color,获取指定尺寸的图片.可用于UIButton的backgroundImage属性设置
 *
 *  @param color 颜色
 *  @param size  图片尺寸
 *
 *  @return 图片
 */
+ (UIImage *)l_imageWithUIColor:(UIColor *)color size:(CGSize)size;

/**
 *  创建一个遮罩图片,该图片可以作为layer.mask遮罩图片的内容
 *    遮罩图片的底色为蓝色,然后清除掉clearRect(UIView坐标系)指定的区域
 *  @param imageSize 图片大小
 *  @param clearRect 要清除颜色以及alpha值的区域.坐标系为UIView
 *
 *  @return 遮罩图片
 */
+ (UIImage *)l_imageMaskWithSize:(CGSize)imageSize clearRect:(CGRect)clearRect;

/**
 *  获取图片的主色调
 *
 *  @return 主色调
 */
- (UIColor *)l_mostColor;

/**
 *  获取某一点的颜色值,坐标系为UIView坐标系(原点在左上角)
 *
 *  @param point 点坐标
 *
 *  @return 颜色对象
 */
- (nullable UIColor *)l_colorWithPoint:(CGPoint)point;

/// 产生线性渐变的图片
/// @param size 图片尺寸
/// @param startColor 起始颜色
/// @param startPoint 起始位置，图片左上角为(0,0)，图片右下角为(1,1)
/// @param endColor 结束颜色
/// @param endPoint 结束位置，图片左上角为(0,0)，图片右下角为(1,1)
+ (UIImage *)l_linearGradientImageWithSize:(CGSize)size startColor:(UIColor *)startColor startPoint:(CGPoint)startPoint endColor:(UIColor *)endColor endPoint:(CGPoint)endPoint;

/// 产生辐射渐变的图片
/// @param size 图片尺寸
/// @param startColor 起始颜色
/// @param startCenter 起始中心圆位置，图片左上角为(0,0)，图片右下角为(1,1)
/// @param startRadius 起始中心圆半径
/// @param endColor 结束颜色
/// @param endCenter 结束中心圆位置，图片左上角为(0,0)，图片右下角为(1,1)
/// @param endRadius 结束中心圆半径
+ (UIImage *)l_radialGradientImageWithSize:(CGSize)size startColor:(UIColor *)startColor startCenter:(CGPoint)startCenter startRadius:(CGFloat)startRadius endColor:(UIColor *)endColor endCenter:(CGPoint)endCenter endRadius:(CGFloat)endRadius;
@end
NS_ASSUME_NONNULL_END
