//
//  LUICollectionViewSupplementaryView.m
//  LUITool
//
//  Created by 六月 on 2024/8/16.
//

#import "LUICollectionViewSupplementaryView.h"
#import "UIView+LUI.h"

@implementation LUICollectionViewSupplementaryView
- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.contentView = [[UIView alloc] init];
        self.contentView.accessibilityLabel = @"contentView";
        [self addSubview:self.contentView];
    }
    return self;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    //适配iphoneX
    if (@available(iOS 11.0,*)) {
        bounds = self.safeAreaLayoutGuide.layoutFrame;
    }
    self.contentView.frame = bounds;
}
#pragma mark - protocol:LUICollectionViewSupplementaryElementProtocol
- (void)setCollectionSectionModel:(LUICollectionViewSectionModel *)sectionModel forKind:(NSString *)kind {
    self.sectionModel = sectionModel;
    self.kind = kind;
}
+ (CGSize)referenceSizeWithCollectionView:(UICollectionView *)collectionView collectionSectionModel:(LUICollectionViewSectionModel *)sectionModel forKind:(NSString *)kind {
    return CGSizeZero;
}
@end
