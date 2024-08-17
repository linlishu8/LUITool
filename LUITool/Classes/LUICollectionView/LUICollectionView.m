//
//  LUICollectionView.m
//  LUITool
//
//  Created by 六月 on 2024/8/15.
//

#import "LUICollectionView.h"
#import "UICollectionViewFlowLayout+LUI.h"
@implementation LUICollectionView
- (id)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout{
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        self.model = [[LUICollectionViewModel alloc] initWithCollectionView:self];
    }
    return self;
}
- (void)setModel:(LUICollectionViewModel *)model {
    if (_model  !=  model) {
        _model = model;
        [_model setCollectionViewDataSourceAndDelegate:self];
    }
}
- (CGSize)sizeThatFits:(CGSize)size{
    CGSize s = CGSizeZero;
    UICollectionViewLayout *layout = self.collectionViewLayout;
    if ([layout conformsToProtocol:@protocol(LUICollectionViewLayoutSizeFitsProtocol)]) {
        s = [(id<LUICollectionViewLayoutSizeFitsProtocol>)layout l_sizeThatFits:size];
    } else {
        s = [super sizeThatFits:size];
    }
    return s;
}
- (void)dealloc{
    //ios10时，会因为实现了scrollViewDidScroll：方法，导致闪退，需要手动清空delegate
    self.delegate = nil;
}
#ifdef DEBUG
- (void)setContentOffset:(CGPoint)contentOffset{
    [super setContentOffset:contentOffset];
}
#endif
@end

@implementation LUICollectionFlowLayoutView
- (id)initWithFrame:(CGRect)frame{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        
    }
    return self;
}
- (void)setCollectionViewFlowLayout:(UICollectionViewFlowLayout *)collectionViewFlowLayout{
    self.collectionViewLayout = collectionViewFlowLayout;
}
- (UICollectionViewFlowLayout *)collectionViewFlowLayout{
    return (UICollectionViewFlowLayout *)self.collectionViewLayout;
}
@end
