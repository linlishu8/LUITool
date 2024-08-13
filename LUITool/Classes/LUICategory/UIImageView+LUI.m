//
//  UIImageView+LUI.m
//  LUITool
//
//  Created by 六月 on 2023/8/11.
//

#import "UIImageView+LUI.h"
#import "UIImage+LUI.h"
#import "LUICGRect.h"

@implementation UIImageView (LUI)

- (UIImage *)l_cropImageWithRect:(CGRect)clipRect {
    CGAffineTransform m = self.l_transformWithSelfContentMode;
    m = CGAffineTransformInvert(m);//进行矩阵反转,以便进行逆运算
    clipRect = CGRectApplyAffineTransform(clipRect, m);//由于图片进行了等比例缩放,因此要反算出UIView上的裁剪区域,对于于UIImage的区域
    UIImage *cuttedImage = [self.image l_cropImageWithRect:clipRect];
    return cuttedImage;
}

- (UIColor *)l_colorWithPoint:(CGPoint)point{
    //将point转换到UIImage的坐标系中去
    CGAffineTransform m = [self l_transformWithSelfContentMode];
    m = CGAffineTransformInvert(m);
    point = CGPointApplyAffineTransform(point, m);
    
    UIColor *color = [self.image l_colorWithPoint:point];
    return color;
}
- (CGAffineTransform)l_transformWithSelfContentMode{
    CGAffineTransform m = [self.image l_transformWithContentMode:self.contentMode toBounds:self.bounds];
    return m;
}
- (CGAffineTransform)l_transformWithContentMode:(UIViewContentMode)contentMode{
    CGAffineTransform m = [self.image l_transformWithContentMode:contentMode toBounds:self.bounds];
    return m;
}
- (CGRect)l_frameOfImageContent{
    if(!self.image) return self.bounds;
    CGSize size = self.image.size;
    size.width *= self.image.scale;
    size.height *= self.image.scale;
    CGRect f = CGRectZero;
    f.size = size;
    CGAffineTransform ctm = [self l_transformWithSelfContentMode];
    f = CGRectApplyAffineTransform(f, ctm);
    return f;
}
- (CGSize)l_sizeThatFitsFixedImageSize:(CGSize)size{
    if(size.width>0&size.height>0){
        return size;
    }
    UIImage *image = self.image;
    if(image==nil){
        if(size.width>0){
            return CGSizeMake(size.width, 0);
        }else if(size.height>0){
            return CGSizeMake(0, size.height);
        }else{
            return CGSizeZero;
        }
    }
    CGSize imageSize = self.image.size;
    if(size.width>0){
        imageSize.height = size.width*imageSize.height/imageSize.width;
        imageSize.width = size.width;
    }else if(size.height>0){
        imageSize.width = size.height*imageSize.width/imageSize.height;
        imageSize.height = size.height;
    }
    CGSize limitSize = size;
    if(limitSize.width<=0){
        limitSize.width = imageSize.width;
    }
    if(limitSize.height<=0){
        limitSize.height = imageSize.height;
    }
    CGRect r1 = CGRectMake(0, 0, imageSize.width, imageSize.height);
    CGAffineTransform m = [LUICGRect transformRect:r1 scaleTo:CGRectMake(0, 0, limitSize.width, limitSize.height) contentMode:self.contentMode];
    CGRect r2 = CGRectApplyAffineTransform(r1, m);
    CGSize sizeFits = r2.size;
    return sizeFits;
}
- (CGSize)l_sizeThatFits:(CGSize)size{
    UIImage *image = self.image;
    if(image==nil){
        return CGSizeZero;
    }
    CGSize imageSize = self.image.size;
    if(size.width<=0){
        size.width = imageSize.width;
    }
    if(size.height<=0){
        size.height = imageSize.height;
    }
    if(imageSize.width<=size.width&&imageSize.height<=size.height){
        return imageSize;
    }
    CGRect r1 = CGRectMake(0, 0, imageSize.width, imageSize.height);
    CGAffineTransform m = [LUICGRect transformRect:r1 scaleTo:CGRectMake(0, 0, size.width, size.height) contentMode:self.contentMode];
    CGRect r2 = CGRectApplyAffineTransform(r1, m);
    CGSize sizeFits = r2.size;
    CGSize s1 = [LUICGRect scaleSize:sizeFits aspectFitToMaxSize:size];
    return s1;
}
- (CGAffineTransform)l_transformFromImageCoordinateSpace{
    CGSize size = self.image.size;
    size.width *= self.image.scale;
    size.height *= self.image.scale;
    CGAffineTransform ctm = CGAffineTransformIdentity;
    ctm = CGAffineTransformConcat(ctm, CGAffineTransformMakeScale(1, -1));
    ctm = CGAffineTransformConcat(ctm, CGAffineTransformMakeTranslation(0, size.height));//进行y轴的翻转和平移
    ctm = CGAffineTransformConcat(ctm, self.l_transformWithSelfContentMode);//进行图片contentmode的缩放处理平移处理
    return ctm;
}
- (CGRect)l_convertRectFromImageCoordinateSpace:(CGRect)rect{
    CGAffineTransform ctm = [self l_transformFromImageCoordinateSpace];
    CGRect r = CGRectApplyAffineTransform(rect, ctm);
    return r;
}
- (CGPoint)l_convertPointFromFromImageCoordinateSpace:(CGPoint)point{
    CGAffineTransform ctm = [self l_transformFromImageCoordinateSpace];
    CGPoint p = CGPointApplyAffineTransform(point, ctm);
    return p;
}
@end
