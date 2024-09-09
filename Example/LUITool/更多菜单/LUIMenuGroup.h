//
//  LUIMenuGroup.h
//  LUITool_Example
//
//  Created by 六月 on 2024/9/9.
//  Copyright © 2024 Your Name. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LUIMenu : NSObject<NSCopying>
@property (nonatomic, strong, nullable) UIImage *icon;//小图标
@property (nonatomic, strong, nullable) NSString *iconName;
@property (nonatomic, strong, nullable) NSString *iconUrl;
@property (nonatomic, strong, nullable) NSString *title;//标题
@property (nonatomic, strong, nullable) NSString *badge;//角标
@property (nonatomic, strong, nullable) UIImage *originImage;
+ (NSArray<LUIMenu *> *)sharedMenus;
+ (NSArray<LUIMenu *> *)sharedMenusWithCount:(NSInteger)count;
+ (NSArray<LUIMenu *> *)sharedMenusWithCount:(NSInteger)count haveAddMenu:(BOOL)haveAddMenu;
+ (NSArray<LUIMenu *> *)sharedUrlMenus;
+ (LUIMenu *)menuWithIconName:(nullable NSString *)iconName title:(nullable NSString *)title badge:(nullable NSString *)badge;
//模拟异步获取图片iconName或iconUrl图片
- (void)getIconWithCompletion:(void(^)(UIImage *image, NSError *error))completion;
+ (LUIMenu *)random;
+ (LUIMenu *)addMenu;
+ (UIImage *)randomImage;
@end

@interface LUIMenuGroup : NSObject

@property (nonatomic, strong, nullable) NSArray<LUIMenu *> *menus;
@property (nonatomic, strong, nullable) NSString *title;
@property (nonatomic, assign) BOOL expand;
+ (LUIMenuGroup *)menuGroupWithTitle:(nullable NSString *)title menus:(nullable NSArray<LUIMenu *> *)menus;
- (void)removeMenu:(LUIMenu *)menu;

@end

NS_ASSUME_NONNULL_END
