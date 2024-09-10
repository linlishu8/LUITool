//
//  LUIMenuGroup.m
//  LUITool_Example
//
//  Created by 六月 on 2023/9/9.
//  Copyright © 2024 Your Name. All rights reserved.
//

#import "LUIMenuGroup.h"

@implementation LUIMenu

- (id)copyWithZone:(NSZone *)zone {
    LUIMenu *obj = [LUIMenu allocWithZone:zone];
    obj.title = self.title;
    obj.icon = self.icon;
    obj.iconUrl = self.iconUrl;
    obj.iconName = self.iconName;
    obj.badge = self.badge;
    return obj;
}
+ (LUIMenu *)menuWithIconName:(NSString *)iconName title:(NSString *)title badge:(NSString *)badge{
    LUIMenu *menu = [[LUIMenu alloc] init];
    menu.iconName = iconName;
    menu.title = title;
    menu.badge = badge;
    return menu;
}
+ (LUIMenu *)menuWithIconUrl:(NSString *)iconUrl title:(NSString *)title badge:(NSString *)badge{
    LUIMenu *menu = [[LUIMenu alloc] init];
    menu.iconUrl = iconUrl;
    menu.title = title;
    menu.badge = badge;
    return menu;
}
- (UIImage *)icon{
    if(!_icon){
        _icon = [self.originImage l_scaleImageToAspectFitSize:CGSizeMake(80, 80)];
    }
    return _icon;
}
- (UIImage *)originImage{
    if(!_originImage){
        _originImage = [UIImage imageNamed:self.iconName];
    }
    return _originImage;
}
+ (LUIMenu *)random{
    NSArray<LUIMenu *> *list = [self sharedMenus];
    NSInteger index = arc4random()%list.count;
    LUIMenu *menu = list[index];
    return menu;
}
+ (UIImage *)randomImage{
    UIImage *img = [self random].icon;
    if(img){
        return img;
    }else{
        return [UIImage imageNamed:@"app-icon-1.png"];
    }
}
+ (void)load{
    //预加载图片
    UIImage *img;
    for(LUIMenu *menu in [LUIMenu sharedUrlMenus]){
        img = menu.icon;
    }
}
+ (NSArray<LUIMenu *> *)sharedUrlMenus{
    NSMutableArray<LUIMenu *> *allMenus = [[NSMutableArray alloc] initWithCapacity:13];
    [allMenus addObject:[LUIMenu menuWithIconUrl:@"app-icon-1.png" title:@"1-2下载、游戏" badge:nil]];
    [allMenus addObject:[LUIMenu menuWithIconUrl:@"app-icon-1.png" title:@"1下载菜单" badge:nil]];
    [allMenus addObject:[LUIMenu menuWithIconUrl:@"app-icon-2.png" title:@"2游戏app" badge:@"Hot"]];
    [allMenus addObject:[LUIMenu menuWithIconUrl:@"app-icon-3.png" title:@"3办公软件" badge:nil]];
    [allMenus addObject:[LUIMenu menuWithIconUrl:@"app-icon-4.png" title:@"4钥匙串" badge:nil]];
    [allMenus addObject:[LUIMenu menuWithIconUrl:@"app-icon-5.png" title:@"5我的创意" badge:nil]];
    [allMenus addObject:[LUIMenu menuWithIconUrl:@"app-icon-6.png" title:@"6添加功能" badge:nil]];
    [allMenus addObject:[LUIMenu menuWithIconUrl:nil title:@"这是一个非常长的菜单" badge:nil]];
    [allMenus addObject:[LUIMenu menuWithIconUrl:@"app-icon-7.png" title:@"7确认事项" badge:@"99+"]];
    [allMenus addObject:[LUIMenu menuWithIconUrl:@"app-icon-8.png" title:@"8我的主页" badge:nil]];
    [allMenus addObject:[LUIMenu menuWithIconUrl:@"app-icon-9.png" title:@"9帮助" badge:nil]];
    [allMenus addObject:[LUIMenu menuWithIconUrl:@"app-icon-10.png" title:@"10倒计时" badge:nil]];
    [allMenus addObject:[LUIMenu menuWithIconUrl:@"app-icon-1.png" title:@"11温馨提示" badge:nil]];
    [allMenus addObject:[LUIMenu menuWithIconUrl:@"app-icon-4.png" title:@"12暂停一下" badge:nil]];
    [allMenus addObject:[LUIMenu menuWithIconUrl:@"app-icon-2.png" title:@"13我的金融" badge:nil]];
    [allMenus addObject:[LUIMenu menuWithIconUrl:@"app-icon-6.png" title:@"这是一个非常长的菜单，应该要换行显示！！这是一个非常长的菜单，应该要换行显示！！" badge:nil]];
    
    return allMenus;
}

+ (NSArray<LUIMenu *> *)staticSharedMenus{
    static dispatch_once_t onceToken;
    static NSMutableArray<LUIMenu *> *allMenus;
    dispatch_once(&onceToken, ^{
        allMenus = [[NSMutableArray alloc] initWithCapacity:13];
        [allMenus addObject:[LUIMenu menuWithIconName:@"app-icon-1.png" title:@"下载菜单" badge:nil]];
        [allMenus addObject:[LUIMenu menuWithIconName:@"app-icon-2.png" title:@"游戏app" badge:@"Hot"]];
        [allMenus addObject:[LUIMenu menuWithIconName:@"app-icon-3.png" title:@"办公软件" badge:nil]];
        [allMenus addObject:[LUIMenu menuWithIconName:@"app-icon-4.png" title:@"钥匙串" badge:nil]];
        [allMenus addObject:[LUIMenu menuWithIconName:@"app-icon-5.png" title:@"我的创意" badge:nil]];
        [allMenus addObject:[LUIMenu menuWithIconName:@"app-icon-6.png" title:@"添加功能" badge:nil]];
        [allMenus addObject:[LUIMenu menuWithIconName:nil title:@"这是一个非常长的菜单" badge:nil]];
        [allMenus addObject:[LUIMenu menuWithIconName:@"app-icon-7.png" title:@"确认事项" badge:@"99+"]];
        [allMenus addObject:[LUIMenu menuWithIconName:@"app-icon-8.png" title:@"我的主页" badge:nil]];
        [allMenus addObject:[LUIMenu menuWithIconName:@"app-icon-9.png" title:@"帮助" badge:nil]];
        [allMenus addObject:[LUIMenu menuWithIconName:@"app-icon-10.png" title:@"倒计时" badge:nil]];
        [allMenus addObject:[LUIMenu menuWithIconName:@"app-icon-4.png" title:@"温馨提示" badge:nil]];
        [allMenus addObject:[LUIMenu menuWithIconName:@"app-icon-5.png" title:@"暂停一下" badge:nil]];
        [allMenus addObject:[LUIMenu menuWithIconName:@"app-icon-7.png" title:@"我的金融" badge:nil]];
        [allMenus addObject:[LUIMenu menuWithIconName:nil title:@"这是一个非常长的菜单，应该要换行显示！！这是一个非常长的菜单，应该要换行显示！！" badge:nil]];
    });
    return allMenus;
}
+ (NSArray<LUIMenu *> *)sharedMenus{
    return [self sharedMenusWithCount:13];
}
+ (NSArray<LUIMenu *> *)sharedMenusWithCount:(NSInteger)count haveAddMenu:(BOOL)haveAddMenu{
    NSMutableArray<LUIMenu *> *list = [[NSMutableArray alloc] initWithCapacity:count];
    
    NSArray<LUIMenu *> *allMenus = [self staticSharedMenus];
    NSInteger total = allMenus.count;
    for (int i=0; i<count; i++) {
        NSInteger index = i%total;
        LUIMenu *obj = [allMenus[index] copy];
        obj.title = [NSString stringWithFormat:@"%@%@",@(i),obj.title];
        if(!haveAddMenu&&[obj.title isEqualToString:@"添加功能"]){
            continue;
        }
        [list addObject:obj];
    }
    return list;
}
+ (NSArray<LUIMenu *> *)sharedMenusWithCount:(NSInteger)count {
    NSMutableArray<LUIMenu *> *list = [[NSMutableArray alloc] initWithCapacity:count];
    
    NSArray<LUIMenu *> *allMenus = [self staticSharedMenus];
    NSInteger total = allMenus.count;
    for (int i=0; i<count; i++) {
        NSInteger index = i%total;
        LUIMenu *obj = [allMenus[index] copy];
        obj.title = [NSString stringWithFormat:@"%@%@",@(i),obj.title];
        [list addObject:obj];
    }
    return list;
}
- (void)getIconWithCompletion:(void(^)(UIImage *image,NSError *error))completion{
    if(self.icon){
        if(completion){
            completion(self.icon,nil);
        }
    }else{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIImage *icon = [UIImage imageNamed:self.iconUrl];
            NSError *error = nil;
            if(icon){
                self.icon = icon;
            }else{
                error = [NSError errorWithDomain:@"MKUITestApp" code:-1 userInfo:nil];
            }
            if(completion){
                completion(icon,error);
            }
        });
    }
}
+ (LUIMenu *)addMenu{
    return [LUIMenu menuWithIconName:@"app-icon-6" title:nil badge:nil];
}
@end

@implementation LUIMenuGroup
+ (LUIMenuGroup *)menuGroupWithTitle:(nullable NSString *)title menus:(nullable NSArray<LUIMenu *> *)menus{
    LUIMenuGroup *group = [[LUIMenuGroup alloc] init];
    group.title = title;
    group.menus = menus;
    return group;
}
- (void)removeMenu:(LUIMenu *)menu{
    NSMutableArray *menus = [self.menus mutableCopy];
    [menus removeObject:menu];
    self.menus = menus;
}
@end
