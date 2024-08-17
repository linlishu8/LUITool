//
//  LUICollectionViewTitleSupplementarySectionModel.h
//  LUITool
//  含有head与foot文字的补充元素
//  Created by 六月 on 2024/8/16.
//

#import "LUICollectionViewSectionModel.h"
#import "LUICollectionViewSupplementaryElementProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface LUICollectionViewTitleSupplementarySectionModel : LUICollectionViewSectionModel
@property (nonatomic, assign) BOOL showHead;//是否显示head,默认为NO
@property (nonatomic, strong, nullable) NSString *headTitle;
@property (nonatomic, assign, nullable) Class<LUICollectionViewSupplementaryElementProtocol> headClass;

@property (nonatomic, assign) BOOL showFoot;//是否显示foot,默认为NO
@property (nonatomic, strong, nullable) NSString *footTitle;
@property (nonatomic, assign, nullable) Class<LUICollectionViewSupplementaryElementProtocol> footClass;
@end

NS_ASSUME_NONNULL_END
