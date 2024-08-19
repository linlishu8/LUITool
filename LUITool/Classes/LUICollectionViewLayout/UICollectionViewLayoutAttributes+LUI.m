//
//  UICollectionViewLayoutAttributes+LUI.m
//  LUITool
//
//  Created by 六月 on 2024/8/18.
//

#import "UICollectionViewLayoutAttributes+LUI.h"

@implementation UICollectionViewLayoutAttributes (LUI)

- (CGRect)l_frameSafety {
    CGRect f = self.frame;
    if (!CGAffineTransformIsIdentity(self.transform)||!CATransform3DIsIdentity(self.transform3D)) {
        f.size = self.size;
        f.origin.x = self.center.x-self.size.width/2;
        f.origin.y = self.center.y-self.size.height/2;
    }
    return f;
}
- (void)setL_frameSafety:(CGRect)frame {
    if (!CGAffineTransformIsIdentity(self.transform)||!CATransform3DIsIdentity(self.transform3D)) {
        self.size = frame.size;
        self.center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
    }else{
        self.frame = frame;
    }
}

@end
