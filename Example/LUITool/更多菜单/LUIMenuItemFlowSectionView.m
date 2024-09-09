//
//  LUIMenuItemFlowSectionView.m
//  LUITool_Example
//
//  Created by 六月 on 2024/9/9.
//  Copyright © 2024 Your Name. All rights reserved.
//

#import "LUIMenuItemFlowSectionView.h"
#import "LUIItemFlowView.h"

@implementation LUIMenuItemFlowSectionView

+ (CGFloat)sectionViewSize {
    CGFloat height = [LUIItemFlowView sizeWithDirectionVertical:NO];
    return height;
}

+ (CGSize)referenceSizeWithCollectionView:(UICollectionView *)collectionView collectionSectionModel:(__kindof LUICollectionViewSectionModel *)sectionModel forKind:(NSString *)kind{
    CGRect bounds = collectionView.l_contentBounds;
    CGSize s = bounds.size;
    s.height = self.sectionViewSize;
    s.width = bounds.size.width;
    return s;
}

@end
