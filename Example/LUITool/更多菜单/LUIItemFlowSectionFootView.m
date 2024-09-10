//
//  LUIItemFlowSectionFootView.m
//  LUITool_Example
//
//  Created by 六月 on 2024/9/10.
//  Copyright © 2024 Your Name. All rights reserved.
//

#import "LUIItemFlowSectionFootView.h"

@interface LUIItemFlowSectionFootView () <LUICollectionViewSupplementaryElementProtocol>

@end

@implementation LUIItemFlowSectionFootView

- (void)setCollectionSectionModel:(nullable __kindof  LUICollectionViewSectionModel *)sectionModel forKind:(NSString *)kind{
}
+ (CGSize)referenceSizeWithCollectionView:(UICollectionView *)collectionView collectionSectionModel:(__kindof LUICollectionViewSectionModel *)sectionModel forKind:(NSString *)kind{
    CGRect bounds = collectionView.bounds;
    return CGSizeMake(bounds.size.width, 10);
}
@end
