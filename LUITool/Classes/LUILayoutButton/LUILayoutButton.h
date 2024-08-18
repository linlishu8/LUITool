//
//  LUILayoutButton.h
//  LUITool
//
//  Created by 六月 on 2024/8/18.
//

#import <UIKit/UIKit.h>
#import "LUIFlowLayoutConstraint.h"

typedef NS_ENUM(NSUInteger, LUILayoutButtonContentStyle) {
    LUILayoutButtonContentStyleHorizontal,//左图标,右文本.默认样式
    LUILayoutButtonContentStyleVertical,//上图标,下文本
};

NS_ASSUME_NONNULL_BEGIN

@interface LUILayoutButton : UIButton {
@protected
    LUIFlowLayoutConstraint *_flowLayout;
}

@property (nonatomic) LUILayoutButtonContentStyle contentStyle;
@property (nonatomic) NSInteger interitemSpacing;//图标与文字之间的间距,默认是3px
@property (nonatomic) BOOL reverseContent;//是否逆转图标与文字的顺序,默认是NO:图标在左/上,文本在右/下
@property (nonatomic) CGSize imageSize;//imageView尺寸,如果某一边为0，代表不限制。默认为(0,0),代表自动根据图片大小计算
@property (nonatomic) BOOL hideImageViewForNoImage;//当没有图片时，是否隐藏imageView。默认为NO，不隐藏imageView，如果imageSize不为(0,0),imageView将继续占用空间。

@property (nonatomic) LUILayoutConstraintVerticalAlignment layoutVerticalAlignment;//所有元素作为一个整体,在垂直方向上的位置,以及每一个元素在整体内的垂直方向上的对齐方式.默认为LUILayoutConstraintVerticalAlignmentCenter.详细查看LUIFlowLayoutConstraint.h

@property (nonatomic) LUILayoutConstraintHorizontalAlignment layoutHorizontalAlignment;//所有元素作为一个整体,在水平方向上的位置,以及每一个元素在整体内的水平方向上的对方方式.默认为LUILayoutConstraintHorizontalAlignmentCenter.详细查看LUIFlowLayoutConstraint.h
@property (nonatomic) UIEdgeInsets contentInsets;//内边距,默认为(0,0,0,0)
- (id)initWithContentStyle:(LUILayoutButtonContentStyle)contentStyle;

@property (nonatomic) CGSize minHitSize;//最小的点击区域尺寸，通过设置该值，可以使得点击区域大于self.bounds(当minHitSize>bounds.size时)。默认为30x30
@end

NS_ASSUME_NONNULL_END
