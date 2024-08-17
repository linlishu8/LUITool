//
//  LUICollectionViewTitleSupplementaryView.m
//  LUITool
//
//  Created by 六月 on 2024/8/16.
//

#import "LUICollectionViewTitleSupplementaryView.h"
#import "UICollectionReusableView+LUICollectionViewSupplementaryElementProtocol.h"
#import "UIColor+LUI.h"

@implementation LUICollectionViewTitleSupplementaryView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _myInit];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self=[super initWithCoder:aDecoder]) {
        [self _myInit];
    }
    return self;
}
- (void)_myInit {
    self.textLabel = [[UILabel alloc] init];
    self.textLabel.font = [UIFont boldSystemFontOfSize:17];
    self.textLabel.numberOfLines = 0;
    self.textLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:self.textLabel];
    self.backgroundColor = [UIColor l_colorWithLight:[UIColor colorWithWhite:0.9 alpha:1] dark:[UIColor colorWithWhite:0.2 alpha:1]];
    self.textLabel.textColor = [UIColor l_colorWithLight:[UIColor colorWithWhite:0.14 alpha:1] dark:[UIColor colorWithWhite:0.86 alpha:1]];
}
- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.contentView.bounds;
    UIEdgeInsets insets = [self.class contentInsets];
    //
    CGRect f1 = UIEdgeInsetsInsetRect(bounds, insets);
    self.textLabel.frame = f1;
}
+ (UIEdgeInsets)contentInsets {
    UIEdgeInsets insets = UIEdgeInsetsMake(5, 5, 5,5);
    return insets;
}
- (CGSize)sizeThatFits:(CGSize)size {
    UIEdgeInsets insets = [self.class contentInsets];
    size.width -= insets.left+insets.right;
    size.height -= insets.top+insets.bottom;
    CGSize s = [self.textLabel sizeThatFits:size];
    if (!CGSizeEqualToSize(CGSizeZero, s)) {
        s.width += insets.left+insets.right;
        s.height += insets.top+insets.bottom;
    }
    return s;
}
#pragma mark - protocol:LUICollectionViewSupplementaryElementProtocol
- (void)setCollectionSectionModel:(LUICollectionViewSectionModel *)sectionModel forKind:(NSString *)kind {
    [super setCollectionSectionModel:sectionModel forKind:kind];
    if ([sectionModel isKindOfClass:[LUICollectionViewTitleSupplementarySectionModel class]]) {
        self.titleSectionModel = (LUICollectionViewTitleSupplementarySectionModel *)sectionModel;
    } else {
        self.titleSectionModel = nil;
    }
    NSString *text = nil;
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        text = self.titleSectionModel.headTitle;
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        text = self.titleSectionModel.footTitle;
    }
    self.textLabel.text = text;
}
LUIDEF_SINGLETON(LUICollectionViewTitleSupplementaryView)
+ (CGSize)referenceSizeWithCollectionView:(UICollectionView *)collectionView collectionSectionModel:(LUICollectionViewSectionModel *)sectionModel forKind:(NSString *)kind {
    CGSize size = [self dynamicReferenceSizeWithCollectionView:collectionView collectionSectionModel:sectionModel forKind:kind viewShareInstance:[self sharedInstance] calBlock:^CGSize(UICollectionView *collectionView, LUICollectionViewSectionModel *sectionModel, NSString *kind, LUICollectionViewTitleSupplementaryView *view) {
        CGSize s = [view sizeThatFits:view.bounds.size];
        return s;
    }];
    return size;
}

@end
