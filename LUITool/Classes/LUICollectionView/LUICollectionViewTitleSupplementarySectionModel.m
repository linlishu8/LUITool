//
//  LUICollectionViewTitleSupplementarySectionModel.m
//  LUITool
//
//  Created by 六月 on 2024/8/16.
//

#import "LUICollectionViewTitleSupplementarySectionModel.h"
#import "LUICollectionViewTitleSupplementaryView.h"

@implementation LUICollectionViewTitleSupplementarySectionModel
- (id)init{
    if (self = [super init]) {
        self.headClass = [LUICollectionViewTitleSupplementaryView class];
        self.footClass = [LUICollectionViewTitleSupplementaryView class];
    }
    return self;
}
- (id)copyWithZone:(NSZone *)zone{
    LUICollectionViewTitleSupplementarySectionModel *obj = [super copyWithZone:zone];
    obj.showHead = self.showHead;
    obj.headTitle = self.headTitle;
    obj.headClass = self.headClass;
    obj.showFoot = self.showFoot;
    obj.footTitle = self.footTitle;
    obj.footClass = self.footClass;
    return obj;
}
- (void)setHeadClass:(Class<LUICollectionViewSupplementaryElementProtocol>)headClass{
    _headClass = headClass;
    if (self.showHead) {
        [self setSupplementaryElementViewClass:headClass forKind:UICollectionElementKindSectionHeader];
    }
}
- (void)setFootClass:(Class<LUICollectionViewSupplementaryElementProtocol>)footClass{
    _footClass = footClass;
    if (self.showFoot) {
        [self setSupplementaryElementViewClass:footClass forKind:UICollectionElementKindSectionFooter];
    }
}
- (void)setShowHead:(BOOL)showHead {
    _showHead = showHead;
    if (self.headClass) {
        if (self.showHead) {
            [self setSupplementaryElementViewClass:self.headClass forKind:UICollectionElementKindSectionHeader];
        } else {
            [self removeSupplementaryElementViewClassForKind:UICollectionElementKindSectionHeader];
        }
    }
}
- (void)setShowFoot:(BOOL)showFoot{
    _showFoot = showFoot;
    if (self.footClass) {
        if (self.showFoot) {
            [self setSupplementaryElementViewClass:self.footClass forKind:UICollectionElementKindSectionFooter];
        } else {
            [self removeSupplementaryElementViewClassForKind:UICollectionElementKindSectionFooter];
        }
    }
}
@end
