//
//  UIImage+LUI.m
//  LUITool
//
//  Created by 六月 on 2023/8/11.
//

#import "UIImage+LUI.h"
#import "LUICGRect.h"
#import "CGGeometry+LUI.h"

@implementation UIImage (LUI)
- (UIImage *)l_transformImageWithCTM:(CGAffineTransform)transform newSize:(CGSize)newSize {
    UIImage *img = [self l_transformImageWithCTM:transform newSize:newSize newOrientation:self.imageOrientation];
    return img;
}
- (UIImage *)l_transformImageWithCTM:(CGAffineTransform)transform newSize:(CGSize)newSize newOrientation:(UIImageOrientation)orientation {
    CGFloat width = floor(newSize.width);//向下取整
    CGFloat height = floor(newSize.height);//向下取整
    UIImage *aImage = self;
    CGFloat scale = aImage.scale;
    size_t bitsPerComponent = CGImageGetBitsPerComponent(aImage.CGImage);
    size_t bytesPerRow = width*4;
    CGColorSpaceRef space = CGImageGetColorSpace(aImage.CGImage);
    //    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(aImage.CGImage);//当图片的bitmapinfo为kCGImageAlphaLast时,创建context失败,失败是不支持colorspace与该bitmapinfo的组合
    CGBitmapInfo bitmapInfo = (CGBitmapInfo)kCGImageAlphaPremultipliedLast;
    CGContextRef ctx = CGBitmapContextCreate(NULL,//由系统自动创建和管理位图内存
                                             width,//画布的宽度(要求整数值)
                                             height,//画布的高度(要求整数值)
                                             bitsPerComponent,//每个像素点颜色分量(如R通道)所点的比特数
                                             bytesPerRow,//每一行所占的字节数
                                             space,//画面使用的颜色空间
                                             bitmapInfo//每个像素点内存空间的使用信息,如是否使用alpha通道,内存高低位读取方式等
                                             );
    CGContextConcatCTM(ctx, transform);//对画面里的每个像素点,应用变换矩阵.即最终要显示的像素点的值f([x,y,1])=f([x,y,1]*[矩阵:transform])
    CGContextDrawImage(ctx, CGRectMake(0, 0, CGImageGetWidth(aImage.CGImage), CGImageGetHeight(aImage.CGImage)), aImage.CGImage);//在画布上下文的原来图片所占的矩形区域绘制位图,绘制后,画面上下文会再对该区域里的每一个像素点应用转置矩阵
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg scale:scale orientation:orientation];
    CGImageRelease(cgimg);
    CGContextRelease(ctx);
    return img;
}
- (UIImage *)l_horizontalInvertImage {
    //该方法已经考虑到了"@2x"图片的情况
    CGSize imageSize = CGSizeMake(CGImageGetWidth(self.CGImage), CGImageGetHeight(self.CGImage));
    CGAffineTransform m = CGAffineTransformIdentity;
    m = CGAffineTransformConcat(m, CGAffineTransformMakeScale(-1, 1));
    m = CGAffineTransformConcat(m, CGAffineTransformMakeTranslation(imageSize.width, 0));
    UIImage *img = [self l_transformImageWithCTM:m newSize:imageSize];
    
    //对capInsets也进行翻转
    UIEdgeInsets capInsets = self.capInsets;
    BOOL isCapInsetsEq = capInsets.top == capInsets.bottom
     && capInsets.left == capInsets.right
     && capInsets.top == capInsets.left;
    if (!isCapInsetsEq) {
        UIEdgeInsets capInsets2 = capInsets;
        capInsets2.left = capInsets.right;
        capInsets2.right = capInsets.left;
        img = [img resizableImageWithCapInsets:capInsets2 resizingMode:self.resizingMode];
    }
    return img;
}
- (UIImage *)l_verticalInvertImage{
    CGSize imageSize = CGSizeMake(CGImageGetWidth(self.CGImage), CGImageGetHeight(self.CGImage));
    CGAffineTransform m = CGAffineTransformIdentity;
    m = CGAffineTransformConcat(m, CGAffineTransformMakeScale(1, -1));
    m = CGAffineTransformConcat(m, CGAffineTransformMakeTranslation(0, imageSize.height));
    UIImage *img = [self l_transformImageWithCTM:m newSize:imageSize];
    
    //对capInsets也进行翻转
    UIEdgeInsets capInsets = self.capInsets;
    BOOL isCapInsetsEq = capInsets.top == capInsets.bottom
     && capInsets.left == capInsets.right
     && capInsets.top == capInsets.left;
    if (!isCapInsetsEq) {
        UIEdgeInsets capInsets2 = capInsets;
        capInsets2.top = capInsets.bottom;
        capInsets2.bottom = capInsets.top;
        img = [img resizableImageWithCapInsets:capInsets2 resizingMode:self.resizingMode];
    }
    return img;
}
- (UIImage *)l_rotateImageWithRadians:(CGFloat)radians{
    CGSize imageSize = CGSizeMake(CGImageGetWidth(self.CGImage), CGImageGetHeight(self.CGImage));
    CGAffineTransform m = CGAffineTransformIdentity;
    //将图片的中心移动到原点
    m = CGAffineTransformConcat(m, CGAffineTransformMakeTranslation(-imageSize.width*0.5, -imageSize.height*0.5));
    m = CGAffineTransformConcat(m, CGAffineTransformMakeRotation(radians));//旋转
    //旋转后,图片的矩形大小会变发变化,因此要重新计算矩形大小
    CGRect f = (CGRect) {CGPointZero,imageSize};
    CGRect bounds = CGRectApplyAffineTransform(f,m);
    
    m = CGAffineTransformConcat(m, CGAffineTransformMakeTranslation(bounds.size.width*0.5, bounds.size.height*0.5));//将矩形的左下角移动到原点
    CGSize newSize = bounds.size;
    UIImage *img = [self l_transformImageWithCTM:m newSize:newSize];
    
    //判断是否是旋转90度的整数倍
    UIEdgeInsets capInsets = self.capInsets;
    BOOL isCapInsetsEq = capInsets.top == capInsets.bottom
     && capInsets.left == capInsets.right
     && capInsets.top == capInsets.left;
    if (!isCapInsetsEq) {
        NSInteger unitOf90 = (NSInteger)(radians/M_PI_2);
        if (ABS(unitOf90*M_PI_2-radians)<0.0000000000000001) {
            NSInteger direction = unitOf90%4;
            if (direction<0) {
                direction += 4;
            }
            UIEdgeInsets capInsets2 = UIEdgeInsetsZero;
            switch (direction) {
                case 0://不变
                    capInsets2 = capInsets;
                    break;
                case 1://逆时针旋转90度
                    capInsets2.top = capInsets.right;
                    capInsets2.left = capInsets.top;
                    capInsets2.bottom = capInsets.left;
                    capInsets2.right = capInsets.bottom;
                    break;
                case 2://旋转180度
                    capInsets2.top = capInsets.bottom;
                    capInsets2.bottom = capInsets.top;
                    capInsets2.left = capInsets.right;
                    capInsets2.right = capInsets.left;
                    break;
                case 3://顺时针旋转90度
                    capInsets2.top = capInsets.left;
                    capInsets2.left = capInsets.bottom;
                    capInsets2.bottom = capInsets.right;
                    capInsets2.right = capInsets.top;
                    break;
                default:
                    break;
            }
            img = [img resizableImageWithCapInsets:capInsets2 resizingMode:self.resizingMode];
        }
    }
    return img;
}
- (UIImage *)l_imageWithOrientation:(UIImageOrientation)orientation{
    UIImageOrientation oldOrientation = self.imageOrientation;
    if (self.imageOrientation == orientation) {
        return self;
    }
    CGSize imageSize = CGSizeMake(CGImageGetWidth(self.CGImage), CGImageGetHeight(self.CGImage));//该方法已经考虑到了@2x图片的情况和图片的朝向
    CGSize newSize = imageSize;
    
    CGAffineTransform m = CGAffineTransformIdentity;
    BOOL mirrored = NO;
    CGFloat radians = 0;
    //oldOrientation=>UIImageOrientationUp
    switch (oldOrientation) {
        case UIImageOrientationUp:
            break;
        case UIImageOrientationDown:
            radians = M_PI;
            break;
        case UIImageOrientationLeft:
            radians = M_PI_2;
            break;
        case UIImageOrientationRight:
            radians = -M_PI_2;
            break;
        case UIImageOrientationUpMirrored:
            mirrored = YES;
            break;
        case UIImageOrientationDownMirrored:
            mirrored = YES;
            radians = M_PI;
            break;
        case UIImageOrientationLeftMirrored:
            radians = -M_PI_2;
            mirrored = YES;
            break;
        case UIImageOrientationRightMirrored:
            radians = M_PI_2;
            mirrored = YES;
            break;
        default:
            break;
    }
    
    if (radians || mirrored) {
        //将图片的中心移动到原点
        m = CGAffineTransformConcat(m, CGAffineTransformMakeTranslation(-newSize.width*0.5, -newSize.height*0.5));
        m = CGAffineTransformConcat(m, CGAffineTransformMakeRotation(radians));//旋转
        if (mirrored) {
            m = CGAffineTransformConcat(m, CGAffineTransformMakeScale(-1, 1));
        }
        //旋转后,图片的矩形大小会变发变化,因此要重新计算矩形大小
        CGRect f = (CGRect) {CGPointZero,imageSize};
        CGRect bounds = CGRectApplyAffineTransform(f,m);
        
        m = CGAffineTransformConcat(m, CGAffineTransformMakeTranslation(bounds.size.width*0.5, bounds.size.height*0.5));//将矩形的左下角移动到原点
        newSize = bounds.size;
    }
    //UIImageOrientationUp=>orientation
    mirrored = NO;
    radians = 0;
    switch (orientation) {
        case UIImageOrientationUp:
            break;
        case UIImageOrientationDown:
            radians = M_PI;
            break;
        case UIImageOrientationLeft:
            radians = -M_PI_2;
            break;
        case UIImageOrientationRight:
            radians = M_PI_2;
            break;
        case UIImageOrientationUpMirrored:
            mirrored = YES;
            break;
        case UIImageOrientationDownMirrored:
            mirrored = YES;
            radians = M_PI;
            break;
        case UIImageOrientationLeftMirrored:
            radians = -M_PI_2;
            mirrored = YES;
            break;
        case UIImageOrientationRightMirrored:
            radians = M_PI_2;
            mirrored = YES;
            break;
        default:
            break;
    }
    if (radians || mirrored) {
        //将图片的中心移动到原点
        m = CGAffineTransformConcat(m, CGAffineTransformMakeTranslation(-newSize.width*0.5, -newSize.height*0.5));
        m = CGAffineTransformConcat(m, CGAffineTransformMakeRotation(radians));//旋转
        if (mirrored) {
            m = CGAffineTransformConcat(m, CGAffineTransformMakeScale(-1, 1));
        }
        //旋转后,图片的矩形大小会变发变化,因此要重新计算矩形大小
        CGRect f = (CGRect) {CGPointZero,imageSize};
        CGRect bounds = CGRectApplyAffineTransform(f,m);
        
        m = CGAffineTransformConcat(m, CGAffineTransformMakeTranslation(bounds.size.width*0.5, bounds.size.height*0.5));//将矩形的左下角移动到原点
        newSize = bounds.size;
    }
    
    UIImage *img = [self l_transformImageWithCTM:m newSize:newSize newOrientation:orientation];
    return img;
}
- (UIImage *)l_cropImageWithRect:(CGRect)cropRect{
    CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
    cropRect = CGRectIntersection(bounds, cropRect);//限制在自己的尺寸里面
    CGRect drawRect = CGRectMake(-cropRect.origin.x , -cropRect.origin.y, self.size.width * self.scale, self.size.height * self.scale);
    UIGraphicsBeginImageContext(cropRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, CGRectMake(0, 0, cropRect.size.width, cropRect.size.height));
    [self drawInRect:drawRect];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
- (UIImage *)l_cropImageToFitAspectRatioSize:(CGSize)aspectRatioSize{
    return [self l_cropImageToFitAspectRatio:aspectRatioSize.height/aspectRatioSize.width];
}
- (UIImage *)l_cropImageToFitAspectRatio:(CGFloat)aspectRatio{//aspectRatio=height/width
    CGSize imageSize = self.size;
    if (imageSize.width == 0) {
        return self;
    }
    UIImage *resultImage = self;
    CGFloat myAspectRatio = imageSize.height/imageSize.width;
    if (ABS(myAspectRatio-aspectRatio)>0.0000001) {//比例不相同
        CGRect r = CGRectZero;
        if (myAspectRatio>aspectRatio) {//height太大了
            r.size.width = imageSize.width;
            r.size.height = imageSize.width*aspectRatio;
        } else {//width太大了
            r.size.height = imageSize.height;
            r.size.width = imageSize.height/aspectRatio;
        }
        r.origin.x = (imageSize.width-r.size.width)/2;
        r.origin.y = (imageSize.height-r.size.height)/2;
        resultImage = [self l_cropImageWithRect:r];
    }
    return resultImage;
}
- (NSUInteger)l_lengthOfRawData{
    CGDataProviderRef providerRef = CGImageGetDataProvider(self.CGImage);
    CFDataRef dataRef = CGDataProviderCopyData(providerRef);
    CFIndex len = CFDataGetLength(dataRef);
    CFRelease(dataRef);
    return (NSUInteger)len;
}
- (BOOL)l_isPngImage{
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(self.CGImage);
    BOOL isPng = !(alphaInfo == kCGImageAlphaNone || alphaInfo == kCGImageAlphaNoneSkipLast || alphaInfo == kCGImageAlphaNoneSkipFirst);
    return isPng;
}
- (NSData *)l_imageDataThatFitBytes:(NSUInteger)bytes withCompressionQuality:(CGFloat)compressionQuality{
    BOOL isPng = self.l_isPngImage;
    NSData *data;
    if (isPng) {
        data = [self l_imageDataOfPngThatFitBytes:bytes];
    } else {
        data = [self l_imageDataOfJpgThatFitBytes:bytes withCompressionQuality:compressionQuality];
    }
    return data;
}
- (NSData *)l_imageDataThatFitBytes:(NSUInteger)bytes{
    NSData *data = [self l_imageDataThatFitBytes:bytes withCompressionQuality:0.6];
    return data;
}
- (NSData *)l_imageDataOfPngThatFitBytes:(NSUInteger)bytes{
    NSData *data = UIImagePNGRepresentation(self);
    NSUInteger len = data.length;
    if (bytes != 0 && len>bytes) {//可以简单认为压缩后的大小与像素点数量成正比
        CGFloat factor = 0.9*sqrt(1.0*bytes/len);//由于只是近似计算,因此再乘上0.9系数,让压缩后的值再小点
        CGSize size = self.size;
        size.width *= factor;
        size.height *= factor;
        UIImage *image = [self l_scaleImageToAspectFitSize:size];
        data = [image l_imageDataOfPngThatFitBytes:bytes];
    }
    return data;
}
- (NSData *)l_imageDataOfJpgThatFitBytes:(NSUInteger)bytes withCompressionQuality:(CGFloat)compressionQuality{
    NSData *data = UIImageJPEGRepresentation(self, compressionQuality);
    NSUInteger len = data.length;
    if (bytes != 0 && len>bytes) {//可以简单认为压缩后的大小与像素点数量成正比
        CGFloat factor = 0.9*sqrt(1.0*bytes/len);//由于只是近似计算,因此再乘上0.9系数,让压缩后的值再小点
        CGSize size = self.size;
        size.width *= factor;
        size.height *= factor;
        UIImage *image = [self l_scaleImageToAspectFitSize:size];
        data = [image l_imageDataOfJpgThatFitBytes:bytes withCompressionQuality:compressionQuality];
    }
    return data;
}
- (UIImage *)l_scaleImageToAspectFitSize:(CGSize)size{
    return [self scaleImageToSize:size withContentMode:UIViewContentModeScaleAspectFit];
}
- (UIImage *)l_scaleImageToAspectFillSize:(CGSize)size{
    return [self scaleImageToSize:size withContentMode:UIViewContentModeScaleAspectFill];
}
- (UIImage *)l_scaleImageToFillSize:(CGSize)size{
    return [self scaleImageToSize:size withContentMode:UIViewContentModeScaleToFill];
}
- (UIImage *)l_reduceImageSizeToMaxSize:(CGSize)size{
    UIImage *img;
    CGSize imageSize = self.size;
    if (imageSize.width<=size.width && imageSize.height<=size.height) {
        img = self;
    } else {
        //按image的比例,重新计算size的大小
        CGFloat width = (self.size.width/self.size.height)*size.height;
        if (width>size.width) {
            size.height = (self.size.height/self.size.width)*size.width;
        } else {
            size.width = width;
        }
        img = [self l_scaleImageToFillSize:size];
    }
    return img;
}
- (UIImage *)l_reduceImageSizeToMaxSize:(CGSize)size scale:(CGFloat)scale{
    CGFloat f = scale/self.scale;
    CGSize imageSizeScaled = CGSizeMake(size.width*f, size.height*f);
    UIImage *image = [self l_reduceImageSizeToMaxSize:imageSizeScaled];
    return image;
}
//缩放图片到指定尺寸,比例不对时,按照mode进行处理
- (UIImage *)scaleImageToSize:(CGSize)size withContentMode:(UIViewContentMode)mode{
    if (CGSizeEqualToSize(size, self.size)) {
        return self;
    }
    CGFloat scale = self.scale;
    CGSize retinaSize = self.size;
    retinaSize.width *= scale;
    retinaSize.height *= scale;
    
    CGSize canvasSize = size;
    canvasSize.width *= scale;
    canvasSize.height *= scale;
    
    CGRect imageRect;
    imageRect.origin = CGPointZero;
    imageRect.size = canvasSize;
    
    switch (mode) {
        case UIViewContentModeScaleAspectFit://缩放时,比例不对会出现透明边
        {
            //缩放
            CGFloat widthOfNew = (retinaSize.width/retinaSize.height)*canvasSize.height;
            if (widthOfNew<=canvasSize.width) {
                imageRect.size.width = widthOfNew;
            } else {
                imageRect.size.height = (retinaSize.height/retinaSize.width)*canvasSize.width;
            }
            //居中
            imageRect.origin.x = (canvasSize.width-imageRect.size.width)*0.5;
            imageRect.origin.y = (canvasSize.height-imageRect.size.height)*0.5;
        }
            break;
        case UIViewContentModeScaleAspectFill://缩放时,比例不对会出现裁切
        {
            //缩放
            CGFloat widthOfNew = (retinaSize.width/retinaSize.height)*canvasSize.height;
            if (widthOfNew>=canvasSize.width) {
                imageRect.size.width = widthOfNew;
            } else {
                imageRect.size.height = (retinaSize.height/retinaSize.width)*canvasSize.width;
            }
            //居中
            imageRect.origin.x = (canvasSize.width-imageRect.size.width)*0.5;
            imageRect.origin.y = (canvasSize.height-imageRect.size.height)*0.5;
        }
        case UIViewContentModeScaleToFill://缩放时,比例不对时,比例会失真
        default:
            break;
    }
    
//    UIImage *aImage = self;
//    CGImageRef imageRef = aImage.CGImage;
//    CGFloat width = canvasSize.width;//向下取整
//    CGFloat height = canvasSize.height;//向下取整
//    size_t bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
//    size_t bytesPerRow = floor(width)*4;
//    CGColorSpaceRef space = CGImageGetColorSpace(imageRef);
//
//    //    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(aImage.CGImage);//当图片的bitmapinfo为kCGImageAlphaLast时,创建context失败,失败是不支持colorspace与该bitmapinfo的组合
//    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
//    bitmapInfo = (CGBitmapInfo)kCGImageAlphaPremultipliedLast;
////    if (kCGImageAlphaLast == bitmapInfo) {
////        bitmapInfo = (CGBitmapInfo)kCGImageAlphaPremultipliedLast;
////    }
//    CGContextRef ctx = CGBitmapContextCreate(NULL,//由系统自动创建和管理位图内存
//                                             width,//画布的宽度(要求整数值)
//                                             height,//画布的高度(要求整数值)
//                                             bitsPerComponent,//每个像素点颜色分量(如R通道)所点的比特数
//                                             bytesPerRow,//每一行所占的字节数
//                                             space,//画面使用的颜色空间
//                                             bitmapInfo//每个像素点内存空间的使用信息,如是否使用alpha通道,内存高低位读取方式等
//                                             );
//    CGContextDrawImage(ctx, imageRect, aImage.CGImage);
//    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
//    UIImage *img = [UIImage imageWithCGImage:cgimg scale:scale orientation:UIImageOrientationUp];
//    CGImageRelease(cgimg);
//    CGContextRelease(ctx);

    if (canvasSize.width<=0 || canvasSize.height<=0) return nil;
    UIGraphicsBeginImageContextWithOptions(canvasSize, !self.l_isPngImage, 1);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self drawInRect:imageRect];
    CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);
    UIGraphicsEndImageContext();
    return img;

}
- (NSString *)l_filesizeString{
    NSString *str = [self l_filesizeStringWithCompressionQuality:1];
    return str;
}
- (NSString *)l_filesizeStringWithCompressionQuality:(CGFloat)compressionQuality{
    NSData *data = UIImageJPEGRepresentation(self, compressionQuality);
    NSUInteger filesize = data.length;
    NSString *str = [self __transFileSize:filesize];
    return str;
}
- (NSString *)__transFileSize:(NSUInteger)fileSize{//输出方便阅读的文件大小字符串
    NSDictionary *map =
    @{
        @(1024*1024*1024):@"GB",
        @(1024*1024):@"MB",
        @(1024):@"KB",
        @(1):@"B",
    };
    NSString *str = nil;
    for (NSString *unit in map) {
        NSUInteger n = [[map objectForKey:unit] integerValue];
        double v = fileSize*1.0/n;
        if (v>=1 || n == 1) {
            str = [NSString stringWithFormat:@"%.1f%@",v,unit];
        }
    }
    return str;
}
+ (UIImage *)l_disclosureIndicatorImageWithSize:(CGSize)size lineWidth:(CGFloat)lineWidth color:(UIColor *)color{
    if (size.width<=0 || size.height<=0) return nil;
    CGFloat scale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [color setStroke];
    CGContextSetLineWidth(ctx, lineWidth);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    CGRect bounds = CGRectMake(0, 0, size.width, size.height);
    CGRect r = CGRectMake(0, 0, size.width-lineWidth, size.height-lineWidth);
    LUICGRectAlignMidXToRect(&r, bounds);
    LUICGRectAlignMidYToRect(&r, bounds);
    CGContextSetLineWidth(ctx, lineWidth);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    CGPoint p1 = r.origin;
    CGPoint p2 = CGPointMake(CGRectGetMaxX(r), CGRectGetMidY(r));
    CGPoint p3 = CGPointMake(CGRectGetMinX(r), CGRectGetMaxY(r));
    CGPoint points[3] = {p1,p2,p3};
    CGContextAddLines(ctx, points, 3);
    CGContextDrawPath(ctx, kCGPathStroke);
    CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);
    UIGraphicsEndImageContext();
    return img;
}
+ (UIImage *)l_disclosureIndicatorImageWithColor:(UIColor *)color{
    return [UIImage l_disclosureIndicatorImageWithSize:CGSizeMake(7, 14) lineWidth:2 color:color];
}
+ (UIImage *)l_checkmarkImageWithSize:(CGSize)size lineWidth:(CGFloat)lineWidth color:(UIColor *)color{
    if (size.width<=0 || size.height<=0) return nil;
    CGFloat scale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [color setStroke];
    CGContextSetLineWidth(ctx, lineWidth);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    CGRect bounds = CGRectMake(0, 0, size.width, size.height);
    CGFloat length = MIN(size.width,size.height);
    CGRect r = CGRectMake(0, 0, length-lineWidth, length-lineWidth);
    LUICGRectAlignMidXToRect(&r, bounds);
    LUICGRectAlignMidYToRect(&r, bounds);
    CGPoint p1 = CGPointMake(r.origin.x, CGRectGetMinY(r)+r.size.height*0.6);
    CGPoint p2 = CGPointMake(CGRectGetMinX(r)+r.size.width*0.4, CGRectGetMaxY(r));
    CGPoint p3 = CGPointMake(CGRectGetMaxX(r), CGRectGetMinY(r));
    CGPoint points[3] = {p1,p2,p3};
    CGContextAddLines(ctx, points, 3);
    CGContextDrawPath(ctx, kCGPathStroke);
    CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);
    UIGraphicsEndImageContext();
    return img;
}
+ (UIImage *)l_checkmarkImageWithColor:(UIColor *)color{
    return [UIImage l_checkmarkImageWithSize:CGSizeMake(17, 17) lineWidth:2 color:color];
}
@end

@implementation UIImage (UIViewTransform)
- (CGAffineTransform)l_transformWithContentMode:(UIViewContentMode)contentMode toBounds:(CGRect)bounds {
    CGRect fromBounds = CGRectZero;
    CGSize imageSize = self.size;
    CGFloat imageScale = self.scale;
    imageSize.width *= imageScale;
    imageSize.height *= imageScale;
    fromBounds.size = imageSize;
    return [self.class l_transformWithContentMode:contentMode fromBounds:fromBounds toBounds:bounds scale:imageScale];
}
+ (CGAffineTransform)l_transformWithContentMode:(UIViewContentMode)contentMode fromBounds:(CGRect)fromBounds toBounds:(CGRect)bounds scale:(CGFloat)imageScale {
    CGAffineTransform m = CGAffineTransformIdentity;
    CGSize imageSize = fromBounds.size;
    CGSize viewSize = bounds.size;
    switch (contentMode) {
        case UIViewContentModeScaleAspectFit:{
            CGFloat scale = viewSize.width/imageSize.width;//视图/图片的比例值
            CGFloat h_view = imageSize.height*scale;
            if (h_view<=viewSize.height) {//正解:按宽度等比例缩放
            } else {//按高度等比例缩放
                scale = viewSize.height/imageSize.height;
            }
            m = CGAffineTransformConcat(m, CGAffineTransformMakeScale(scale, scale));//缩放
            CGPoint imageCenter = CGPointMake(imageSize.width*0.5,imageSize.height*0.5);
            CGPoint imageCenterAfterScale = CGPointApplyAffineTransform(imageCenter, m);
            CGPoint viewCenter = CGPointMake(viewSize.width*0.5, viewSize.height*0.5);
            m = CGAffineTransformConcat(m, CGAffineTransformMakeTranslation(viewCenter.x-imageCenterAfterScale.x, viewCenter.y-imageCenterAfterScale.y));//平移中心点
        }
            break;
        case UIViewContentModeScaleAspectFill:{
            CGFloat scale = viewSize.width/imageSize.width;//视图/图片的比例值
            CGFloat h_view = imageSize.height*scale;
            if (h_view>=viewSize.height) {//正解:按宽度等比例缩放
            } else {//按高度等比例缩放
                scale = viewSize.height/imageSize.height;
            }
            m = CGAffineTransformConcat(m, CGAffineTransformMakeScale(scale, scale));//缩放
            CGPoint imageCenter = CGPointMake(imageSize.width*0.5,imageSize.height*0.5);
            CGPoint imageCenterAfterScale = CGPointApplyAffineTransform(imageCenter, m);
            CGPoint viewCenter = CGPointMake(viewSize.width*0.5, viewSize.height*0.5);
            m = CGAffineTransformConcat(m, CGAffineTransformMakeTranslation(viewCenter.x-imageCenterAfterScale.x, viewCenter.y-imageCenterAfterScale.y));//平移中心点
        }
            break;
        case UIViewContentModeScaleToFill:{
            CGFloat scaleX = viewSize.width/imageSize.width;
            CGFloat scaleY = viewSize.height/imageSize.height;
            
            m = CGAffineTransformConcat(m, CGAffineTransformMakeScale(scaleX, scaleY));//缩放
        }
            break;
        case UIViewContentModeCenter:
            m = [self transformWithTranslationModePosition:CGPointMake(0.5, 0.5) fromBounds:fromBounds toBounds:bounds scale:imageScale];
            break;
        case UIViewContentModeLeft:
            m = [self transformWithTranslationModePosition:CGPointMake(0, 0.5) fromBounds:fromBounds toBounds:bounds scale:imageScale];
            break;
        case UIViewContentModeRight:
            m = [self transformWithTranslationModePosition:CGPointMake(1, 0.5) fromBounds:fromBounds toBounds:bounds scale:imageScale];
            break;
        case UIViewContentModeTop:
            m = [self transformWithTranslationModePosition:CGPointMake(0.5, 0) fromBounds:fromBounds toBounds:bounds scale:imageScale];
            break;
        case UIViewContentModeBottom:
            m = [self transformWithTranslationModePosition:CGPointMake(0.5, 1) fromBounds:fromBounds toBounds:bounds scale:imageScale];
            break;
        case UIViewContentModeTopLeft:
            m = [self transformWithTranslationModePosition:CGPointMake(0, 0) fromBounds:fromBounds toBounds:bounds scale:imageScale];
            break;
        case UIViewContentModeTopRight:
            m = [self transformWithTranslationModePosition:CGPointMake(1, 0) fromBounds:fromBounds toBounds:bounds scale:imageScale];
            break;
        case UIViewContentModeBottomLeft:
            m = [self transformWithTranslationModePosition:CGPointMake(0, 1) fromBounds:fromBounds toBounds:bounds scale:imageScale];
            break;
        case UIViewContentModeBottomRight:
            m = [self transformWithTranslationModePosition:CGPointMake(1, 1) fromBounds:fromBounds toBounds:bounds scale:imageScale];
            break;
        default:
            break;
    }
    return m;
}
+ (CGAffineTransform)transformWithTranslationModePosition:(CGPoint)point fromBounds:(CGRect)fromBounds toBounds:(CGRect)bounds scale:(CGFloat)imageScale{
    CGSize imageSize = fromBounds.size;
    CGSize viewSize = bounds.size;
    
    CGAffineTransform m = CGAffineTransformIdentity;
    CGFloat scale = 1/imageScale;
    m = CGAffineTransformConcat(m, CGAffineTransformMakeScale(scale, scale));//缩放
    CGPoint imageCenter = CGPointMake(imageSize.width*point.x,imageSize.height*point.y);
    CGPoint imageCenterAfterScale = CGPointApplyAffineTransform(imageCenter, m);
    CGPoint viewCenter = CGPointMake(viewSize.width*point.x, viewSize.height*point.y);
    m = CGAffineTransformConcat(m, CGAffineTransformMakeTranslation(viewCenter.x-imageCenterAfterScale.x, viewCenter.y-imageCenterAfterScale.y));//平移中心点
    return m;
}
@end

@implementation UIImage (l_UIColor)
- (UIImage *)l_imageWithTintColor:(UIColor *)tintColor{
    if (!tintColor) {
        return self;
    }
    if (self.size.width<=0 || self.size.height<=0) return nil;
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
    UIRectFill(bounds);
    
    //Draw the tinted image in context
    [self drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIEdgeInsets capInsets = self.capInsets;
    UIImageResizingMode resizingMode = self.resizingMode;
    if (!UIEdgeInsetsEqualToEdgeInsets(capInsets, UIEdgeInsetsZero)) {
        tintedImage = [tintedImage resizableImageWithCapInsets:capInsets resizingMode:resizingMode];
    }
    return tintedImage;
}
- (void)l_enumRGBAPixcelsWithBlock:(void(^)(int x,int y,int r,int g,int b,int a))block{
    if (!block) {
        return;
    }
    UIImage *aImage = self;
    CGImageRef imageRef = aImage.CGImage;
    size_t width = CGImageGetWidth(imageRef);//向下取整
    size_t height = CGImageGetHeight(imageRef);//向下取整
    
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(NULL,//由系统自动创建和管理位图内存
                                             width,//画布的宽度(要求整数值)
                                             height,//画布的高度(要求整数值)
                                             8,//每个像素点颜色分量(如R通道)所点的比特数
                                             width*4,//每一行所占的字节数
                                             space,//画面使用的颜色空间
                                             (CGBitmapInfo)kCGBitmapByteOrder32Little|kCGImageAlphaPremultipliedLast//每个像素点内存空间的使用信息,如是否使用alpha通道,内存高低位读取方式等
                                             );
    CGContextDrawImage(ctx,CGRectMake(0,0, width, height), imageRef);
    //第二步 取每个点的像素值
    unsigned char* data = CGBitmapContextGetData(ctx);
    if (data  !=  NULL) {
        int index = 0;
        int r,g,b,a;
        for (int y=0; y<height; y++) {
            for (int x=0; x<width; x++) {
                r = data[index+3];
                g = data[index+2];
                b = data[index+1];
                a = data[index+0];
                if (block) {
                    block(x,y,r,g,b,a);
                }
                index+=4;
            }
        }
    }
    
    CGContextRelease(ctx);
    CGColorSpaceRelease(space);
}
- (UIImage *)l_convertRGBAImageWithBlock:(void(^)(int x,int y,int *r,int *g,int *b,int *a))block{
    if (!block) {
        return self;
    }
    UIImage *aImage = self;
    CGImageRef imageRef = aImage.CGImage;
    CGFloat scale = aImage.scale;
    UIImageOrientation imageOrientation = aImage.imageOrientation;
    size_t width = CGImageGetWidth(imageRef);//向下取整
    size_t height = CGImageGetHeight(imageRef);//向下取整
    
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    uint8_t* rgbaPixel = (uint8_t*)malloc(width * height * 4);

    [self l_enumRGBAPixcelsWithBlock:^void(int x, int y, int r, int g, int b, int a) {
        if (block) {
            block(x,y,&r,&g,&b,&a);
        }
        NSInteger index = y*width*4+x*4;
        rgbaPixel[index+3] = (uint8_t)r;//r
        rgbaPixel[index+2] = (uint8_t)g;//g
        rgbaPixel[index+1] = (uint8_t)b;//b
        rgbaPixel[index+0] = (uint8_t)a;//a
    }];
    CGContextRef ctx = CGBitmapContextCreate(rgbaPixel,
                                             width,//画布的宽度(要求整数值)
                                             height,//画布的高度(要求整数值)
                                             8,//每个像素点颜色分量(如R通道)所点的比特数
                                             width*4,//每一行所占的字节数
                                             space,//画面使用的颜色空间
                                             (CGBitmapInfo)kCGBitmapByteOrder32Little|kCGImageAlphaPremultipliedLast//每个像素点内存空间的使用信息,如是否使用alpha通道,内存高低位读取方式等
                                             );
    
    CGImageRef resultImageRef = CGBitmapContextCreateImage(ctx);
    CGContextRelease(ctx);
    CGColorSpaceRelease(space);
    free(rgbaPixel);
    
    UIImage *resultUIImage = [UIImage imageWithCGImage:resultImageRef scale:scale orientation:imageOrientation];
    CGImageRelease(resultImageRef);
    return resultUIImage;
}
- (UIImage *)l_grayImage{
    UIImage *resultImage = [self l_convertRGBAImageWithBlock:^(int x, int y, int *r, int *g, int *b, int *a) {
        //参见https://blog.csdn.net/u012308586/article/details/94619769/
        //对于彩色转灰度，有一个很著名的心理学公式：Gray = R*0.299 + G*0.587 + B*0.114
        //Gray = (R*38 + G*75 + B*15) >> 7
        int gray = (*r*38 + *g*75 + *b*15) >> 7;
        *r = gray;
        *g = gray;
        *b = gray;
    }];
    return resultImage;
}
+ (UIImage *)l_imageWithUIColor:(UIColor *)color{
    UIImage *img = [self l_imageWithUIColor:color size:CGSizeMake(1, 1)];
    return img;
}
+ (UIImage *)l_imageWithUIColor:(UIColor *)color size:(CGSize)size{
    if (size.width<=0 || size.height<=0) return nil;
    if (!color) return nil;
    CGRect rect = CGRectZero;
    rect.size = size;
    CGFloat scale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(rect.size,NO,scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, color.CGColor);
    CGContextFillRect(ctx, rect);
    CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);
    UIGraphicsEndImageContext();
    return img;
}
+ (UIImage *)l_imageMaskWithSize:(CGSize)imageSize clearRect:(CGRect)clearRect{
    CGRect rect = CGRectZero;
    rect.size = imageSize;
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIColor *backgrondColor = [UIColor blueColor];
    CGContextSetFillColorWithColor(ctx, backgrondColor.CGColor);
    CGContextFillRect(ctx, rect);
    CGContextClearRect(ctx, clearRect);
    CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    UIGraphicsEndImageContext();
    return img;
}
- (UIColor *)l_mostColor{

    int bitmapInfo = (CGBitmapInfo)kCGBitmapByteOrder32Little|kCGImageAlphaPremultipliedLast;
    
    //绘制图片,缩小到60x60,以加快速度
    CGSize imageSize = self.size;
    imageSize.width *= self.scale;
    imageSize.height *= self.scale;
    imageSize.width = MAX(60, imageSize.width);
    imageSize.height = MAX(60, imageSize.height);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 imageSize.width,
                                                 imageSize.height,
                                                 8,//bits per component
                                                 imageSize.width*4,
                                                 colorSpace,
                                                 bitmapInfo);
    CGRect drawRect = CGRectMake(0, 0, imageSize.width, imageSize.height);
    CGContextDrawImage(context, drawRect, self.CGImage);
    CGColorSpaceRelease(colorSpace);
    
    //第二步 取每个点的像素值
    unsigned char* data = CGBitmapContextGetData (context);
//    if (data  ==  NULL) {
//        CGContextRelease(context);
//        return nil;
//    }
    
    NSCountedSet *cls=[NSCountedSet setWithCapacity:imageSize.width*imageSize.height];
    int index = 0;
    int r,g,b,a;
    for (int y=0; y<imageSize.height; y++) {
        for (int x=0; x<imageSize.width; x++) {
            r = data[index+3];
            g = data[index+2];
            b = data[index+1];
            a = data[index+0];
            
            NSArray *clr=@[@(r),@(g),@(b),@(a)];
            [cls addObject:clr];
            index+=4;
        }
    }
    CGContextRelease(context);
    
    //第三步 找到出现次数最多的那个颜色
    NSArray *MaxColor=nil;
    NSUInteger MaxCount=0;
    for (NSArray *curColor in cls) {
        NSUInteger tmpCount = [cls countForObject:curColor];
        if ( tmpCount < MaxCount ) continue;
        MaxCount=tmpCount;
        MaxColor=curColor;
    }
    UIColor *color = [UIColor colorWithRed:([MaxColor[0] intValue]/255.0f) green:([MaxColor[1] intValue]/255.0f) blue:([MaxColor[2] intValue]/255.0f) alpha:([MaxColor[3] intValue]/255.0f)];
    return color;
}
- (UIColor *)l_colorWithPoint:(CGPoint)point{
    UIColor *color;
    CGImageRef imageRef = self.CGImage;
    CGRect rect = CGRectZero;
    rect.size.width = CGImageGetWidth(imageRef);
    rect.size.height= CGImageGetHeight(imageRef);
    if (point.x<0 || point.x>rect.size.width || point.y<0 || point.y>rect.size.height) {//越界了,返回nil
        return nil;
    }
    UIImage *aImage = self;
    CGFloat width = CGImageGetWidth(imageRef);//向下取整
    CGFloat height = CGImageGetHeight(imageRef);//向下取整
    size_t bitsPerComponent = CGImageGetBitsPerComponent(aImage.CGImage);
    size_t bytesPerRow = width*4;
    CGColorSpaceRef space = CGImageGetColorSpace(aImage.CGImage);
    //    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(aImage.CGImage);//当图片的bitmapinfo为kCGImageAlphaLast时,创建context失败,失败是不支持colorspace与该bitmapinfo的组合
    CGBitmapInfo bitmapInfo = (CGBitmapInfo)kCGImageAlphaPremultipliedLast;
    CGContextRef ctx = CGBitmapContextCreate(NULL,//由系统自动创建和管理位图内存
                                             width,//画布的宽度(要求整数值)
                                             height,//画布的高度(要求整数值)
                                             bitsPerComponent,//每个像素点颜色分量(如R通道)所点的比特数
                                             bytesPerRow,//每一行所占的字节数
                                             space,//画面使用的颜色空间
                                             bitmapInfo//每个像素点内存空间的使用信息,如是否使用alpha通道,内存高低位读取方式等
                                             );
    
    
    CGContextDrawImage(ctx, rect, imageRef);
    unsigned char* data = CGBitmapContextGetData(ctx);
    int offset = 4*(rect.size.width*round(point.y)+round(point.x));
    int R = data[offset];
    int G = data[offset+1];
    int B = data[offset+2];
    int A = data[offset+3];
    color = [UIColor colorWithRed:R/255. green:G/255. blue:B/255. alpha:A/255.];
    CGContextRelease(ctx);
    return color;
}
+ (UIImage *)l_linearGradientImageWithSize:(CGSize)size startColor:(UIColor *)startColor startPoint:(CGPoint)startPoint endColor:(UIColor *)endColor endPoint:(CGPoint)endPoint{
    if (size.width<=0 || size.height<=0) return nil;
    CGRect rect = CGRectZero;
    rect.size = size;
    CGFloat scale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(rect.size,NO,scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGFloat locations[] = { 0.0, 1.0 };
    NSArray *colors = @[(__bridge id)startColor.CGColor, (__bridge id)endColor.CGColor];
    startPoint.x *= rect.size.width;
    startPoint.y *= rect.size.height;
    endPoint.x *= rect.size.width;
    endPoint.y *= rect.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    
    CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    return img;
}

+ (UIImage *)l_radialGradientImageWithSize:(CGSize)size startColor:(UIColor *)startColor startCenter:(CGPoint)startCenter startRadius:(CGFloat)startRadius endColor:(UIColor *)endColor endCenter:(CGPoint)endCenter endRadius:(CGFloat)endRadius {
    if (size.width <= 0  ||  size.height <= 0) return nil;
    CGRect rect = CGRectZero;
    rect.size = size;
    CGFloat scale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(rect.size,NO,scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGFloat locations[] = { 0.0, 1.0 };
    NSArray *colors = @[(__bridge id)startColor.CGColor, (__bridge id)endColor.CGColor];
    startCenter.x *= rect.size.width;
    startCenter.y *= rect.size.height;
    endCenter.x *= rect.size.width;
    endCenter.y *= rect.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    CGContextDrawRadialGradient(ctx, gradient, startCenter, startRadius, endCenter, endRadius, 0);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    return img;
}
@end
