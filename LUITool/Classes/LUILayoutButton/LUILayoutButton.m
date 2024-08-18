//
//  LUILayoutButton.m
//  LUITool
//
//  Created by 六月 on 2024/8/18.
//

#import "LUILayoutButton.h"
#import "LUILayoutConstraintItemWrapper.h"
#import "UIImageView+LUI.h"
#import "LUIMacro.h"
@interface LUILayoutButton()

@property (nonatomic, strong) id<LUILayoutConstraintItemProtocol> imageViewLayoutConstraint;
@property (nonatomic, strong) id<LUILayoutConstraintItemProtocol> titleLabelLayoutConstraint;
@property (nonatomic, strong) UILabel *sizeFitTitleLabel;//用于计算size的label
@property (nonatomic, strong) UIImageView *sizeFitImageView;//用于计算size的imageView

@end

@implementation LUILayoutButton
- (id)initWithFrame:(CGRect)frame {
    if (self=[super initWithFrame:frame]) {
        [self __myInit_LUIFlowLayoutButton];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self=[super initWithCoder:aDecoder]) {
        [self __myInit_LUIFlowLayoutButton];
    }
    return self;
}
- (id)initWithContentStyle:(LUILayoutButtonContentStyle)contentStyle {
    if (self=[self init]) {
        self.contentStyle = contentStyle;
    }
    return self;
}
- (UILabel *)sizeFitTitleLabel {
    if (!_sizeFitTitleLabel) {
        Class c = self.titleLabel.class?:[UILabel class];
        _sizeFitTitleLabel = [[c alloc] init];
    }
    UILabel *titleLabel = self.titleLabel;
    _sizeFitTitleLabel.attributedText = nil;
    _sizeFitTitleLabel.text = nil;
    _sizeFitTitleLabel.contentMode = titleLabel.contentMode;
    _sizeFitTitleLabel.font = titleLabel.font;
    _sizeFitTitleLabel.shadowOffset = titleLabel.shadowOffset;
    _sizeFitTitleLabel.textAlignment = titleLabel.textAlignment;
    _sizeFitTitleLabel.lineBreakMode = titleLabel.lineBreakMode;
    _sizeFitTitleLabel.highlighted = titleLabel.isHighlighted;
    _sizeFitTitleLabel.enabled = titleLabel.enabled;
    _sizeFitTitleLabel.numberOfLines = titleLabel.numberOfLines;
    _sizeFitTitleLabel.adjustsFontSizeToFitWidth = titleLabel.adjustsFontSizeToFitWidth;
    _sizeFitTitleLabel.baselineAdjustment = titleLabel.baselineAdjustment;
    _sizeFitTitleLabel.minimumScaleFactor = titleLabel.minimumScaleFactor;
    _sizeFitTitleLabel.allowsDefaultTighteningForTruncation = titleLabel.allowsDefaultTighteningForTruncation;
//    _sizeFitTitleLabel.lineBreakStrategy = titleLabel.lineBreakStrategy;
    _sizeFitTitleLabel.preferredMaxLayoutWidth = titleLabel.preferredMaxLayoutWidth;
    return _sizeFitTitleLabel;
}
- (UIImageView *)sizeFitImageView {
    if (!_sizeFitImageView) {
        Class c = self.imageView.class?:[UIImageView class];
        _sizeFitImageView = [[c alloc] init];
    }
    UIImageView *imageView = self.imageView;
    _sizeFitImageView.image = nil;
    _sizeFitImageView.contentMode = imageView.contentMode;
    return _sizeFitImageView;
}
- (UIControlState)__filterState:(UIControlState)originState {//过滤掉多状态中的高亮状态
    UIControlState state = originState;
    if (state!=UIControlStateNormal
       &&state!=UIControlStateHighlighted
       &&state!=UIControlStateDisabled
       &&state!=UIControlStateSelected
       &&state!=UIControlStateFocused
       &&state!=UIControlStateApplication
       &&state!=UIControlStateReserved
       ) {
        //多状态
        state &= ~UIControlStateHighlighted;//去掉高亮状态
    }
    return state;
}
- (void)__myInit_LUIFlowLayoutButton {
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    _flowLayout = [[LUIFlowLayoutConstraint alloc] init];
    _flowLayout.layoutHiddenItem = YES;
    _flowLayout.layoutDirection = LUILayoutConstraintDirectionHorizontal;
    @LUI_WEAKIFY(self);
    self.imageViewLayoutConstraint = [LUILayoutConstraintItemWrapper wrapItem:self.imageView sizeThatFitsBlock:^CGSize(LUILayoutConstraintItemWrapper * _Nonnull wrapper, CGSize size, BOOL resizeItems) {
        @LUI_NORMALIZE(self);
        CGSize imageSize = self.imageSize;
        
        if (!self.hideImageViewForNoImage&&imageSize.width>0&&imageSize.height>0) {
            return imageSize;
        }
        
        UIImageView *imageView = wrapper.originItem;
        UIImage *oldImage = imageView.image;
        UIControlState state = [self __filterState:self.state];
        UIImage *stateImage = [self imageForState:state];
        
        if (!stateImage && self.hideImageViewForNoImage) {
            return CGSizeZero;
        }
        
        if (oldImage!=stateImage) {
            UIImageView *sizeFitImageView = self.sizeFitImageView;
            sizeFitImageView.image = stateImage;
            imageView = sizeFitImageView;
        }
        if (imageSize.width>0&&imageSize.height>0) {
            return imageSize;
        }
        if (imageSize.width>0) {
            size.width = imageSize.width;
        }
        if (imageSize.height>0) {
            size.height = imageSize.height;
        }

        CGSize s = [imageView l_sizeThatFits:size];
        
        if (s.width>0 && imageSize.width>0) {
            s.height = imageSize.width*s.height/s.width;
            s.width = imageSize.width;
        }
        if (s.height>0 && imageSize.height>0) {
            s.width = imageSize.height*s.width/s.height;
            s.height = imageSize.height;
        }
        return s;
    }];
    self.titleLabelLayoutConstraint = [LUILayoutConstraintItemWrapper wrapItem:self.titleLabel sizeThatFitsBlock:^CGSize(LUILayoutConstraintItemWrapper * _Nonnull wrapper, CGSize size, BOOL resizeItems) {
        @LUI_NORMALIZE(self);
        UILabel *titleLabel = wrapper.originItem;
        NSString *oldTitle = titleLabel.text;
        NSAttributedString *oldAttrString = titleLabel.attributedText;
        UIControlState state = [self __filterState:self.state];
        NSString *stateTitle = [self titleForState:state];
        NSAttributedString *stateAttrText = [self attributedTitleForState:state];
        if (stateAttrText) {
            if (stateAttrText==oldAttrString || [stateAttrText isEqualToAttributedString:oldAttrString]) {
                
            } else {
                UILabel *sizeFitTitleLabel = self.sizeFitTitleLabel;
                sizeFitTitleLabel.attributedText = stateAttrText;
                titleLabel = sizeFitTitleLabel;
            }
        } else if (stateTitle) {
            if (stateTitle==oldTitle || [stateTitle isEqualToString:oldTitle]) {
                
            } else {
                UILabel *sizeFitTitleLabel = self.sizeFitTitleLabel;
                sizeFitTitleLabel.text = stateTitle;
                titleLabel = sizeFitTitleLabel;
            }
        } else {
            return CGSizeZero;
        }
        
        CGSize s = [titleLabel sizeThatFits:size];
        return s;
    }];
    _flowLayout.items = _reverseContent?@[self.titleLabelLayoutConstraint,self.imageViewLayoutConstraint]:@[self.imageViewLayoutConstraint,self.titleLabelLayoutConstraint];
    self.interitemSpacing = 3;
    self.contentStyle = LUILayoutButtonContentStyleHorizontal;
    self.minHitSize = CGSizeMake(30, 30);
}
- (void)setLayoutHorizontalAlignment:(LUILayoutConstraintHorizontalAlignment)layoutHorizontalAlignment {
    if (self.layoutHorizontalAlignment==layoutHorizontalAlignment) {
        return;
    }
    _flowLayout.layoutHorizontalAlignment = layoutHorizontalAlignment;
    [self setNeedsLayout];
}
- (LUILayoutConstraintHorizontalAlignment)layoutHorizontalAlignment {
    return _flowLayout.layoutHorizontalAlignment;
}
- (void)setLayoutVerticalAlignment:(LUILayoutConstraintVerticalAlignment)layoutVerticalAlignment {
    if (self.layoutVerticalAlignment==layoutVerticalAlignment) {
        return;
    }
    _flowLayout.layoutVerticalAlignment = layoutVerticalAlignment;
    [self setNeedsLayout];
}
- (LUILayoutConstraintVerticalAlignment)layoutVerticalAlignment {
    return _flowLayout.layoutVerticalAlignment;
}
- (void)setContentInsets:(UIEdgeInsets)contentInsets {
    if (UIEdgeInsetsEqualToEdgeInsets(self.contentInsets, contentInsets)) {
        return;
    }
    _flowLayout.contentInsets = contentInsets;
    [self setNeedsLayout];
}
- (UIEdgeInsets)contentInsets {
    return _flowLayout.contentInsets;
}
- (void)setInteritemSpacing:(NSInteger)interitemSpacing {
    if (self.interitemSpacing==interitemSpacing) {
        return;
    }
    _flowLayout.interitemSpacing = interitemSpacing;
    [self setNeedsLayout];
}
- (NSInteger)interitemSpacing {
    return _flowLayout.interitemSpacing;
}
- (void)setContentStyle:(LUILayoutButtonContentStyle)contentStyle {
    if (_contentStyle == contentStyle) {
        return;
    }
    _contentStyle = contentStyle;
    switch (self.contentStyle) {
        case LUILayoutButtonContentStyleHorizontal:
            _flowLayout.layoutDirection = LUILayoutConstraintDirectionHorizontal;
            break;
        case LUILayoutButtonContentStyleVertical:
            _flowLayout.layoutDirection = LUILayoutConstraintDirectionVertical;
            break;
        default:
            break;
    }
    [self setNeedsLayout];
}
- (void)setImageSize:(CGSize)imageSize {
    if (CGSizeEqualToSize(imageSize, _imageSize)) {
        return;
    }
    _imageSize = imageSize;
    [self setNeedsLayout];
}
- (void)setReverseContent:(BOOL)reverseContent {
    if (_reverseContent==reverseContent) {
        return;
    }
    _reverseContent = reverseContent;
    _flowLayout.items = _reverseContent?@[self.titleLabelLayoutConstraint,self.imageViewLayoutConstraint]:@[self.imageViewLayoutConstraint,self.titleLabelLayoutConstraint];
    [self setNeedsLayout];
}
- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    _flowLayout.bounds = bounds;
    [_flowLayout layoutItemsWithResizeItems:YES];
}
- (CGSize)sizeThatFits:(CGSize)size {
    CGSize s = [_flowLayout sizeThatFits:size resizeItems:YES];
    return s;
}
- (CGSize)intrinsicContentSize {
    CGSize s = [self sizeThatFits:CGSizeMake(99999999, 99999999)];
    return s;
}
- (void)sizeToFit {
    CGRect bounds = self.bounds;
    bounds.size = self.intrinsicContentSize;
    self.bounds = bounds;
}
#pragma mark - touch event
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (!self.userInteractionEnabled || self.isHidden || !self.enabled) {
        return NO;
    }
    CGSize minHitSize = self.minHitSize;
    CGRect bounds = self.bounds;
    CGPoint center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    bounds.size.width = MAX(bounds.size.width,minHitSize.width);
    bounds.size.height = MAX(bounds.size.height,minHitSize.height);
    bounds.origin.x = center.x-bounds.size.width/2;
    bounds.origin.y = center.y-bounds.size.height/2;
    BOOL isInside = CGRectContainsPoint(bounds, point);
    return isInside;
}
@end
