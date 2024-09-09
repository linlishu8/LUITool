//
//  LUILedBannerVerticalView.h
//  LUITool
//  垂直方向滚动的跑马灯控件
//  Created by 六月 on 2024/9/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LUILedBannerVerticalView;
@protocol LUILedBannerVerticalViewDelegate <NSObject>
@optional
- (void)ledBannerVerticalView:(LUILedBannerVerticalView *)view didScrollToBannerWithIndex:(NSInteger)currentIndex;//滚动到显示某一项
- (void)ledBannerVerticalView:(LUILedBannerVerticalView *)view didClickBannerWithIndex:(NSInteger)currentIndex bannerContent:(NSObject *)content;//点击了某一项
- (Class)ledBannerVerticalView:(LUILedBannerVerticalView *)view cellClassForBannerContent:(NSObject *)content;//定制指定数据的显示视图，要求为LUICollectionViewCellBase子类
@end

@interface LUILedBannerVerticalView : UIView
@property (nonatomic, weak, nullable) id<LUILedBannerVerticalViewDelegate> delegate;
@property (nonatomic, strong) NSArray<NSObject *> *contents;//被展示的数据
@property (nonatomic, assign,nullable) Class defaultContentCellClass;//默认的被展示数据显示视图，要求为LUICollectionViewCellBase子类
- (void)reloadData;//刷新数据
@property (nonatomic, assign) NSInteger currentIndex;
- (void)setCurrentIndex:(NSInteger)currentIndex animated:(BOOL)animated;
- (void)setCurrentIndexWithDistance:(NSInteger)distance animated:(BOOL)animated;
#pragma mark - 定时滚动
@property (nonatomic, readonly) BOOL isAutoScrolling;
- (void)startAutoScrollingWithDistance:(NSInteger)distance duration:(NSTimeInterval)duration;
- (void)stopAutoScrolling;
@end

NS_ASSUME_NONNULL_END
