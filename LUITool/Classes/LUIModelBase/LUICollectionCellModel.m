//
//  LUICellModel.m
//  LUITool
//
//  Created by 六月 on 2023/8/11.
//

#import "LUICollectionCellModel.h"
#import "LUICollectionSectionModel.h"
#import "LUICollectionModel.h"

@implementation LUICollectionCellModel

- (id)copyWithZone:(NSZone *)zone {
    LUICollectionCellModel *obj = [super copyWithZone:zone];
    obj.userInfo = self.userInfo;
    obj.selected = self.selected;
    obj.focused = self.focused;
    obj->_sectionModel = self->_sectionModel;
    return obj;
}

- (NSIndexPath *)indexPathOfPreCell {
    NSIndexPath *preIndexPath;
    NSInteger row = [self indexInSectionModel];
    NSInteger section = [self.sectionModel indexInModel];
    if (row > 0) {
        preIndexPath = [NSIndexPath indexPathForRow:row-1 inSection:section];
    } else {
        for (NSInteger i=section-1; i>=0; i++)  {
            LUICollectionSectionModel *sm = [self.collectionModel sectionModelAtIndex:i];
            if (sm.numberOfCells>0) {
                preIndexPath = [NSIndexPath indexPathForRow:sm.numberOfCells-1 inSection:i];
                break;
            }
        }
    }
    return preIndexPath;
}
- (NSIndexPath *)indexPathOfNextCell {
    NSIndexPath *nextIndexPath;
    NSInteger row = [self indexInSectionModel];
    NSInteger section = [self.sectionModel indexInModel];
    if (row+1<self.sectionModel.numberOfCells) {
        nextIndexPath = [NSIndexPath indexPathForRow:row+1 inSection:section];
    } else {
        NSInteger sectionCount = [self.collectionModel numberOfSections];
        for (NSInteger i=section+1; i<sectionCount; i++)  {
            LUICollectionSectionModel *sm = [self.collectionModel sectionModelAtIndex:i];
            if (sm.numberOfCells > 0) {
                nextIndexPath = [NSIndexPath indexPathForRow:0 inSection:i];
                break;
            }
        }
    }
    return nextIndexPath;
}
- (BOOL)isFirstInAllCellModels {
    BOOL is = self.indexPathOfPreCell == nil;
    return is;
}
- (BOOL)isLastInAllCellModels {
    BOOL is = self.indexPathOfNextCell == nil;
    return is;
}
- (NSInteger)indexInSectionModel {
    NSInteger index = [self.sectionModel indexOfCellModel:self];
    return index;
}
- (NSIndexPath *)indexPathInModel {
    NSInteger cellIndex = [self indexInSectionModel];
    NSInteger sectionIndex = [self.sectionModel indexInModel];
    NSIndexPath *indexPath;
    if (cellIndex!=NSNotFound&&sectionIndex!=NSNotFound) {
        indexPath = [NSIndexPath indexPathForRow:cellIndex inSection:sectionIndex];
    }
    return indexPath;
}
- (LUICollectionModel *)collectionModel {
    LUICollectionModel *model = [[self sectionModel] collectionModel];
    return model;
}
- (void)setSectionModel:(LUICollectionSectionModel *)sectionModel {
    _sectionModel = sectionModel;
}
- (LUICollectionSectionModel *)sectionModel {
    return _sectionModel;
}
- (NSComparisonResult)compare:(LUICollectionCellModel *)otherObject {
    NSComparisonResult r = [self.sectionModel compare:otherObject.sectionModel];
    if (r == NSOrderedSame) {
        NSInteger row1 = [self.sectionModel indexOfCellModel:self];
        NSInteger row2 = [otherObject.sectionModel indexOfCellModel:otherObject];
        if (row1 < row2) {
            r = NSOrderedAscending;
        } else if (row1 > row2) {
            r = NSOrderedDescending;
        }
    }
    return r;
}

@end
