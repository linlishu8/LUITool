//
//  UITableView+LUI.m
//  LUITool
//
//  Created by 六月 on 2023/8/11.
//

#import "UITableView+LUI.h"
#import "UIScrollView+LUI.h"
#import "UITableViewCell+LUI.h"

@implementation UITableView (LUI)

- (void)l_hiddenHeaderAreaBlank {
    if (self.tableHeaderView  ==  nil && self.style  ==  UITableViewStyleGrouped) {
        UIView *emptyHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        self.tableHeaderView = emptyHeaderView;
    }
}
- (void)l_hiddenFooterAreaSeparators {
    if (self.tableFooterView  ==  nil && self.separatorStyle != UITableViewCellSeparatorStyleNone) {
        UIView *emptyFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        self.tableFooterView = emptyFooterView;
    }
}
- (NSIndexPath *)l_indexPathForMaxVisibleArea {
    CGRect bounds = self.bounds;
    bounds.origin = CGPointZero;
    CGPoint offset = self.contentOffset;
    NSArray *indexpaths = [self indexPathsForVisibleRows];
    CGFloat maxArea = -1;
    NSIndexPath *maxAreaIndexPath = nil;
    for (NSIndexPath *indexpath in indexpaths) {
        UITableViewCell *cell = [self cellForRowAtIndexPath:indexpath];
        CGRect f1 = cell.frame;
        f1.origin.x -= offset.x;
        f1.origin.y -= offset.y;
        CGRect interRect = CGRectIntersection(f1, bounds);
        CGFloat area = interRect.size.width*interRect.size.height;
        if (area > maxArea) {
            maxArea = area;
            maxAreaIndexPath = indexpath;
        }
    }
    return maxAreaIndexPath;
}
- (CGFloat)l_separatorHeight {
    CGFloat h = self.separatorStyle  ==  UITableViewCellSeparatorStyleNone ? 0 : 1.0 / [UIScreen mainScreen].scale;
    return h;
}
+ (BOOL)l_isAutoAddSeparatorHeightToCell {
    CGFloat version = [UIDevice currentDevice].systemVersion.floatValue;
    BOOL is = NO;
    //ios10、11、12时，cell的contentView尺寸会被压缩，扣掉分隔线的调度
    //ios13时，cell的高度会被系统自动添加上分隔线的高度
    if (version >= 13) {
        is = YES;
    }
    return is;
}
- (NSArray<__kindof UITableViewCell * >  *)l_visibleCellsWithClass:(Class)cellClass {
    NSArray<__kindof UITableViewCell * >  *cells = self.visibleCells;
    NSMutableArray<UITableViewCell * >  *list = [[NSMutableArray alloc] initWithCapacity:cells.count];
    for (UITableViewCell *c in cells) {
        if ([c isKindOfClass:cellClass]) {
            [list addObject:c];
        }
    }
    return list;
}
@end

#import "LUIMacro.h"
@interface __LUI_UITableViewDefaultSectionView : UIView
LUIAS_SINGLETON(__LUI_UITableViewDefaultSectionView)
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UILabel *titleLabel;
+ (UIEdgeInsets)contentInsets;
@end
@implementation __LUI_UITableViewDefaultSectionView
LUIDEF_SINGLETON(__LUI_UITableViewDefaultSectionView)
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.font = [UIFont systemFontOfSize:13];
        [self addSubview:self.titleLabel];
    }
    return self;
}
+ (UIEdgeInsets)contentInsets { return UIEdgeInsetsMake(33, 15, 7, 15); }
- (void)setTitle:(NSString *)title { self.titleLabel.text = title; }
- (NSString *)title { return self.titleLabel.text; }
- (CGSize)sizeThatFits:(CGSize)size {
    UIEdgeInsets insets = self.class.contentInsets;
    CGSize limitSize = CGSizeMake(size.width-insets.left-insets.right, size.height-insets.top-insets.bottom);
    CGSize sizeFits = [self.titleLabel sizeThatFits:limitSize];
    if (!CGSizeEqualToSize(sizeFits, CGSizeZero)) {
        sizeFits.width += insets.left+insets.right;
        sizeFits.height += insets.top+insets.bottom;
    }
    sizeFits.height = MAX(18,sizeFits.height);
    return sizeFits;
}
@end
@interface __LUI_UITableViewDefaultGroupHeadSectionView : __LUI_UITableViewDefaultSectionView
@end
@implementation __LUI_UITableViewDefaultGroupHeadSectionView
LUIDEF_SINGLETON(__LUI_UITableViewDefaultGroupHeadSectionView)
@end
@interface __LUI_UITableViewDefaultGroupFootSectionView : __LUI_UITableViewDefaultSectionView
@end
@implementation __LUI_UITableViewDefaultGroupFootSectionView
LUIDEF_SINGLETON(__LUI_UITableViewDefaultGroupFootSectionView)
+ (UIEdgeInsets)contentInsets {
    UIEdgeInsets insets = [super contentInsets];
    insets.top = 8;
    return insets;
}
@end

@implementation UITableView(l_SizeFits)
- (CGFloat)l_cellHeightForIndexPath:(NSIndexPath *)p {
    CGFloat cellHeight = 0;
    if ([self.delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
        cellHeight = [self.delegate tableView:self heightForRowAtIndexPath:p];
    }
    if (cellHeight  ==  UITableViewAutomaticDimension) {
        UITableViewCell *cell = [self.dataSource tableView:self cellForRowAtIndexPath:p];
        BOOL nosuperView = cell.superview  ==  nil;
        if (nosuperView) {//在计算动态高度时，会用到tableView.l_separatorHeight,因此cell必须临时添加到tableView中
            [self addSubview:cell];
        }
        CGRect originCellBounds = cell.frame;
        CGRect originContentBounds = cell.contentView.frame;
        //设置cell、cell.contentView的frame
        UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
        if (@available(iOS 11.0, *)) {
            safeAreaInsets = self.safeAreaInsets;
        }
        CGRect bounds = self.l_contentBounds;
        CGRect cellBounds = bounds;
        cellBounds.size.height = 99999999;
        cellBounds.origin = CGPointZero;
        CGRect contentViewBounds = UIEdgeInsetsInsetRect(cellBounds, safeAreaInsets);
        
        if (cell.accessoryView  ==  nil) {
            if (cell.accessoryView) {
                contentViewBounds.size.width -= cell.accessoryView.bounds.size.width+cell.l_accessoryCustomViewLeftMargin+cell.l_accessoryCustomViewRightMargin;//扣掉自定义accessoryView的宽度
            } else {
                contentViewBounds.size.width -= cell.l_accessorySystemTypeViewWidth+cell.l_accessorySystemTypeViewLeftMargin+cell.l_accessorySystemTypeViewRightMargin;//扣掉系统的accessoryType视图宽度
            }
        }
        cell.frame = cellBounds;
        cell.contentView.frame = contentViewBounds;
        
        CGSize cellSize = [cell sizeThatFits:CGSizeMake(cellBounds.size.width, 99999999)];
        
        if (nosuperView) {
            [cell removeFromSuperview];
        }
        
        cell.frame = originCellBounds;
        cell.contentView.frame = originContentBounds;
        
        cellHeight = cellSize.height;
    }
    return cellHeight;
}
- (CGFloat)__l_sectionHeightInSection:(NSInteger)section forHeader:(BOOL)isHeader {
    CGFloat sectionHeight = 0;
    if (isHeader) {
        if ([self.delegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)]) {
            sectionHeight = [self.delegate tableView:self heightForHeaderInSection:section];
        } else {
            sectionHeight = self.sectionHeaderHeight;
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(tableView:heightForFooterInSection:)]) {
            sectionHeight = [self.delegate tableView:self heightForFooterInSection:section];
        } else {
            sectionHeight = self.sectionFooterHeight;
        }
    }
    if (sectionHeight  ==  UITableViewAutomaticDimension) {
        UIView *sectionView = nil;
        if (isHeader) {
            if ([self.delegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)]) {
                sectionView = [self.delegate tableView:self viewForHeaderInSection:section];
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(tableView:viewForFooterInSection:)]) {
                sectionView = [self.delegate tableView:self viewForFooterInSection:section];
            }
        }
        if (!sectionView) {
            if (self.style  ==  UITableViewStylePlain) {
                CGFloat fixHeight = 28;//使用系统自带的头/尾，固定尺寸为28（没有title也占用同样的尺寸）
                if (isHeader) {
                    if ([self.dataSource respondsToSelector:@selector(tableView:titleForHeaderInSection:)] || [self.delegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)]) {
                        sectionHeight = fixHeight;//有实现这个方法，就会显示view
                    }
                } else {
                    if ([self.dataSource respondsToSelector:@selector(tableView:titleForFooterInSection:)] || [self.delegate respondsToSelector:@selector(tableView:viewForFooterInSection:)]) {
                        sectionHeight = fixHeight;//有实现这个方法，就会显示view
                    }
                }
            } else {
                NSString *title = nil;
                __LUI_UITableViewDefaultSectionView *v = nil;
                if (isHeader) {
                    if ([self.dataSource respondsToSelector:@selector(tableView:titleForHeaderInSection:)]) {
                        title = [self.dataSource tableView:self titleForHeaderInSection:section];
                    }
                    v = [__LUI_UITableViewDefaultGroupHeadSectionView sharedInstance];
                } else {
                    if ([self.dataSource respondsToSelector:@selector(tableView:titleForFooterInSection:)]) {
                        title = [self.dataSource tableView:self titleForFooterInSection:section];
                    }
                    v = [__LUI_UITableViewDefaultGroupFootSectionView sharedInstance];
                }
                v.title = title;
                sectionView = v;
            }
        }
        if (sectionView) {
            CGRect bounds = self.l_contentBounds;
            UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
            if (@available(iOS 11.0, *)) {
                safeAreaInsets = self.safeAreaInsets;
            }
            bounds = UIEdgeInsetsInsetRect(bounds, safeAreaInsets);
            CGSize size = [sectionView sizeThatFits:CGSizeMake(bounds.size.width, 99999999)];
            sectionHeight = size.height;
        }
    }
    if (isHeader) {
        sectionHeight += [self __l_sectionHeaderTopPadding];
    }
    return sectionHeight;
}
- (CGFloat)__l_sectionHeaderTopPadding {
    CGFloat padding = 0;
    if (@available(iOS 15.0, *)) {
        CGFloat sectionHeaderTopPadding = self.sectionHeaderTopPadding;
        if (sectionHeaderTopPadding  ==  UITableViewAutomaticDimension) {
            //iOS15,系统给section的头部添加了22的间距
            padding += 22;
        } else {
            padding += sectionHeaderTopPadding;
        }
    }
    return padding;
}
- (CGFloat)__l_tableHeadFootViewHeightThatFits:(CGFloat)boundsWidth isHead:(BOOL)isHead {
    CGFloat height = 0;
    UIView *view = isHead?self.tableHeaderView:self.tableFooterView;
    if (view) {
        CGRect bounds = self.l_contentBounds;
        CGSize size = [view sizeThatFits:CGSizeMake(bounds.size.width, 99999999)];
        height = MAX(size.height,0);
    }
    return height;
}
- (CGFloat)l_heightThatFits:(CGFloat)boundsWidth {
    CGFloat height = 0;
    
    CGRect originBounds = self.bounds;
    if (originBounds.size.width != boundsWidth) {
        CGRect bounds = originBounds;
        bounds.size.width = boundsWidth;
        self.bounds = bounds;
    }
    
    UIEdgeInsets insets = self.contentInset;
    height += insets.top+insets.bottom;
    
    height += [self __l_tableHeadFootViewHeightThatFits:boundsWidth isHead:YES];
    height += [self __l_tableHeadFootViewHeightThatFits:boundsWidth isHead:NO];
    
    CGFloat separatorHeight = self.l_separatorHeight;
    CGFloat separatorCount = 0;
    for (int i=0; i<self.numberOfSections; i++) {
        NSInteger cellCount = [self numberOfRowsInSection:i];
        CGFloat sectionHeaderHeight = [self __l_sectionHeightInSection:i forHeader:YES];
        CGFloat sectionFooterHeight = [self __l_sectionHeightInSection:i forHeader:NO];
        height += sectionHeaderHeight;
        height += sectionFooterHeight;
        
        for (int j=0; j<cellCount; j++) {
            NSIndexPath *p = [NSIndexPath indexPathForRow:j inSection:i];
            CGFloat cellHeight = [self l_cellHeightForIndexPath:p];
            if (cellHeight > 0) {
                separatorCount++;
            }
            height += cellHeight;
        }
    }
    if ([self.class l_isAutoAddSeparatorHeightToCell]) {
        height += separatorCount*separatorHeight;
        height += separatorHeight;//由于多个cell之间因为分隔线的累加，可能会造成浮点误差。这里额外添加一次分隔线
    }
    
    if (self.style  ==  UITableViewStyleGrouped && self.separatorStyle  ==  UITableViewCellSeparatorStyleNone) {
        height += 20;//group且没有分隔线时，tableview会自动添加20的contentSize
    }
    
    height = ceil(height);//消除浮点误差
    
    if (originBounds.size.width != boundsWidth) {
        self.bounds = originBounds;
    }
    return height;
}

@end
