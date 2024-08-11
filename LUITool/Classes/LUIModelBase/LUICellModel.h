//
//  LUICellModel.h
//  LUITool
//
//  Created by 六月 on 2024/8/11.
//

#import "LUIModelBase.h"

NS_ASSUME_NONNULL_BEGIN

@class LUISectionModel, LUIModel;

@interface LUICellModel : LUIModelBase {
    @protected
    __weak LUISectionModel *_sectionModel;
}

@property (nonatomic, readonly, nullable) __kindof LUIModel *lModel;//集合模型对象
@property (nonatomic, strong, nullable) id userInfo;//自定义的扩展对象
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) BOOL focused;//是否获取焦点
@property (nonatomic, readonly) NSInteger indexInSectionModel;
@property (nonatomic, readonly, nullable) NSIndexPath *indexPathInModel;
@property (nonatomic, readonly, nullable) NSIndexPath *indexPathOfPreCell;//上一个单元格的indexpath
@property (nonatomic, readonly, nullable) NSIndexPath *indexPathOfNextCell;//下一个单元格的indexpath
//是否是整个model中第一个元素
@property (nonatomic, readonly) BOOL isFirstInAllCellModels;
//是否是整个model中最后一个元素
@property (nonatomic, readonly) BOOL isLastInAllCellModels;
//弱引用上層的分组對象
- (void)setSectionModel:(nullable LUISectionModel *)sectionModel;
- (nullable __kindof LUISectionModel *)sectionModel;

- (NSComparisonResult)compare:(LUICellModel *)otherObject;

@end

NS_ASSUME_NONNULL_END
