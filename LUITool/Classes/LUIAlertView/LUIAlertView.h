//
//  LUIAlertView.h
//  LUITool
//
//  Created by 六月 on 2024/8/18.
//

#import <UIKit/UIKit.h>
#im

typedef enum : NSUInteger {
    LUIAlertActionStyleDefault = 0,//确定按钮（蓝色）
    LUIAlertActionStyleCancel,//取消按钮（加粗蓝色）
    LUIAlertActionStyleDestructive//删除等按钮（红色）
} LUIAlertActionStyle;

typedef NS_ENUM(NSInteger, LUIAlertViewStyle) {
    LUIAlertViewStyleActionSheet = 0,//居下展示弹出窗
    LUIAlertViewStyleAlert//居中展示弹出窗
};

NS_ASSUME_NONNULL_BEGIN

@interface LUIAlertView : UIView

+ (instancetype)alertViewWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(LUIAlertViewStyle)preferredStyle;

//所有视图的容器（Group样式）。不可滚动。分组背景色为UIColor.l_alertBackgroundColor。如果为ActionsSheets且有cacnel样式的按钮，所有的cancel按钮，将会放在第二个分组中进行显示。
//第一个分组设置为不展示分隔线，第二个分组展示默认的分隔线。
//contentView第一个分组，显示headContentView、bodyContentView、footContentView、actionContentView。其中只有bodyContentView和actionContentView可以滚动。
@property (nonatomic, readonly) luitable *contentView;

@property (nonatomic, readonly) MKUIListView *headContentView;//顶部内容区域列表（Group样式）。位于contentView的第一个分组的第一个位置，不可滚动。

//主体内容区域列表（Group样式）。位于contentView的第一个分组的第二个位置。
//该列表展示默认的分隔线。
@property (nonatomic, readonly) MKUIListView *bodyContentView;

@property (nonatomic, readonly) MKUIListView *footContentView;//底部内容区域列表（Group样式）。位于按钮区域的上部，不可滚动。

//按钮展示列表（Group样式），位于contentView的第一个分组的第三个位置。
//该列表展示默认的分隔线。
@property (nonatomic, readonly) MKUIListView *actionContentView;


//alert样式：只有一个分组。bodyContentView和按钮都在第一个分组中展示。cancel类型的按钮，排在按钮末尾。
//actionSheet样式：可能有两个分组（当含有cancel按钮时，会有第二个分组）。bodyContentView和非cancel类型的按钮都在第一个分组中展示。cancel类型的按钮，在第二个分组中展示。
@property (nonatomic, assign) LUIAlertViewStyle preferredStyle;

@property (nonatomic, strong, nullable) NSString *title;//标题，位于bodyContentView的0-0位置
@property (nonatomic, readonly) MKUIAlertViewTextCellView *titleView;//标题视图
@property (nonatomic, strong, nullable) NSString *message;//消息，位于bodyContentView的0-1位置
@property (nonatomic, readonly) MKUIAlertViewTextCellView *messageView;//消息视图

//按钮的规则：
//alert时，如果按钮数量<=self.alertActionsCountForHorizontal，按钮将一行展示，左右平分。且cancel按钮固定在最左侧。如果按钮数量>self.alertActionsCountForHorizontal，按钮将垂直列表展示，且cancel按钮位到列表最下面。
//actionSheet时，按钮列表展示，非cancel按钮在第一个分组展示，cancel按钮在第二个分组展示。
- (void)addAction:(MKUIAlertAction *)action;
@property (nonatomic, strong, nullable) NSArray<MKUIAlertAction *> *actions;
@property (nonatomic, assign) NSInteger alertActionsCountForHorizontal;//alert弹窗时，按钮水平平铺的数量上限。当超过该值时，按钮垂直显示。默认为2
@property (nonatomic, copy, nullable) void(^whenClickAction)(__kindof MKUIAlertView *alertView,__kindof MKUIAlertAction *action);
- (void)handleAction:(MKUIAlertAction *)action;//触发按钮点击事件(直接点击某个按钮或者在actionSheet时，点击背景蒙版）
@property (nonatomic, assign) Class actionCellClass;//action按钮的展示类，默认为MKUIAlertActionView.class
@property (nonatomic, readonly) CGFloat actionCellHeight;//按钮单元格的高度值。alert为44，actionSheet为57。如果要定制按钮高度，需要实现子类
- (CGFloat)widthThatFits:(CGSize)size;//限定尺寸下，自身的width值，默认alert为270，actionSheet为275

@property (nonatomic, strong, nullable) MKUIListViewSeparatorView *separatorViewBetweentTextAndActions;//bodyContent与actionContent按钮之间的分隔线视图。如果要取消分隔线，将该字段设置为nil即可。默认显示listview的分隔线视图效果

- (void)reloadData;///马上刷新视图数据
- (void)setNeedReloadData;//设置需要刷新视图数据，将在layoutSubviews和sizeThatFits:方法中进行reloadData。如果需要马上生效，请调用[self reloadDataIfNeeded]
- (void)reloadDataIfNeeded;//如果需要刷新数据，将马上调用reloadData

#pragma mark - 响应键盘事件
@property (nonatomic, assign) BOOL autoAdjustContentWhenKeyboardChange;//当有键盘时，是否自动调整弹窗位置。默认为YES
@property (nonatomic, assign) Class autoAdjustViewClassWhenKeyboardChange;//当键盘弹起时，输入框所外层视图的类，该视图将保持不被键盘挡住。如使用MKUIAlertView.class时，那整个弹窗保持在键盘上面。nil代表当前输入框对象。默认为MKUIAlertView.class
/// 调整视图位置，使得输入框不被键盘挡信
/// - Parameters:
///   - noti: 键盘通知事件
///   - responderViewClass: 输入框所外层视图的子类，该视图将保持不被键盘挡住。如使用MKUIAlertView.class时，那整个弹窗保持在键盘上面。nil代表当前输入框对象
- (void)adjustContentWithUIKeyboardChangeNotification:(NSNotification *)noti responderViewClass:(nullable Class)responderViewClass;

#pragma mark - mask
@property (nonatomic, assign) BOOL showMaskView;//是否显示弹窗背部的半透明遮罩，默认是YES
@property (nonatomic, readonly) UIView *maskView;//弹窗后面的半透明遮罩

#pragma mark - alert
/// 展示在指定视图中。当alert时，弹窗居中展示；当actionSheet时，弹窗居下展示。如果whenClickAction=nil时，此方法会设置whenClickAction，在点击被按钮时，自动调用[dismissFromSuperViewWithAnimated:completion]取消弹窗
/// - Parameters:
///   - container: 容器
///   - animated: 是否动画
///   - completion: 完成回调
- (void)presentToView:(UIView *)container animated:(BOOL)animated completion:(void(^ _Nullable)(BOOL finished))completion;

/// 从父容器中移除弹窗
/// - Parameters:
///   - animated: 是否动画
///   - completion: 完成回调
- (void)dismissFromSuperViewWithAnimated:(BOOL)animated completion:(void(^ _Nullable)(BOOL finished))completion;

//在视图容器中，设定自身的frame。子类可以重写访方法，定制self.l_frameSafety
- (void)layoutSelfInContainerView:(UIView *)container;
@end

@interface UIView (MKUIAlertView)
/// 在当前视图中显示弹窗。如果已经有一个弹窗，会将旧的弹窗取消掉，然后再显示新的弹窗。
/// - Parameters:
///   - alertView: 要展示的弹窗
///   - animated: 是否动画
///   - completion: 完成回调
- (void)l_presentAlertView:(nullable MKUIAlertView *)alertView animated:(BOOL)animated completion:(void(^ _Nullable)(BOOL finished))completion;

/// 取消当前视图中的弹窗
/// - Parameters:
///   - alertView: 要取消的弹窗
///   - animated: 是否动画
///   - completion: 完成回调
- (void)l_dismissAlertView:(nullable MKUIAlertView *)alertView animated:(BOOL)animated completion:(void(^ _Nullable)(BOOL finished))completion;
@property (nonatomic, readonly, nullable) MKUIAlertView *l_alertView;//当前视图下的弹窗

@end

NS_ASSUME_NONNULL_END
