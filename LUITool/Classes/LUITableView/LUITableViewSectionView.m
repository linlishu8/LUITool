//
//  LUITableViewSectionView.m
//  LUITool
//
//  Created by 六月 on 2021/8/13.
//

#import "LUITableViewSectionView.h"
#import "UIView+LUI.h"
#import "UIScrollView+LUI.h"
#import "UIColor+LUI.h"
@implementation LUITableViewSectionView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self _myInit];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self _myInit];
    }
    return self;
}
- (void)_myInit{
    self.contentView = [[UIView alloc] init];
    [self addSubview:self.contentView];
    //
    self.textLabel = [[UILabel alloc] init];
    self.textLabel.font = [UIFont boldSystemFontOfSize:17];
    self.textLabel.numberOfLines = 0;
    self.textLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:self.textLabel];
    self.backgroundColor = [UIColor l_colorWithLight:[UIColor colorWithWhite:0.9 alpha:1] dark:[UIColor colorWithWhite:0.2 alpha:1]];
    self.textLabel.textColor = [UIColor l_colorWithLight:[UIColor colorWithWhite:0.14 alpha:1] dark:[UIColor colorWithWhite:0.86 alpha:1]];
}
- (void)layoutSubviews{
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    //适配iphoneX
    if (@available(iOS 11.0,*)) {
        bounds = self.safeAreaLayoutGuide.layoutFrame;
    }
    self.contentView.frame = bounds;
    //text
    CGFloat margin = 16;
    UIEdgeInsets insets = UIEdgeInsetsMake(0, margin, 0, margin);
    CGRect f1 = UIEdgeInsetsInsetRect(self.contentView.bounds, insets);
    self.textLabel.frame = f1;
}
- (CGSize)sizeThatFits:(CGSize)size{
    return CGSizeMake(size.width, kLUITableViewSectionViewDefaultHeight);
}
#pragma mark - delegate:LUITableViewSectionViewProtocol
+ (CGFloat)heightWithTableView:(UITableView *)tableView sectionModel:(LUITableViewSectionModel *)sectionModel kind:(LUITableViewSectionViewKind)kind {
    CGFloat height = UITableViewAutomaticDimension;
    return height;
}
- (void)setSectionModel:(LUITableViewSectionModel *)sectionModel kind:(LUITableViewSectionViewKind)kind {
    self.sectionModel = sectionModel;
    self.kind = kind;
    
    self.textLabel.text = kind == LUITableViewSectionViewKindOfHead?sectionModel.headTitle:sectionModel.footTitle;
    [self setNeedsLayout];
    [self setNeedsDisplay];
}
@end
