//
//  UIGestureRecognizer+LUI.h
//  LUITool
//
//  Created by 六月 on 2023/8/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//响应手势，生成平移手势相应的属性值
@interface LUIGestureRecognizerMoveAction : NSObject
@property (nonatomic, weak, nullable) UIGestureRecognizer *gestureRecognizer;//设置关联的手势（会将自己添加到手势的target中）
@property (nonatomic, readonly) CGVector moveVector;//平移的瞬间向量，值=endPoint-prePoint
@property (nonatomic, readonly) CGVector moveDistance;//平移的总距离向量，值=endPoint-beginPoint

//以下point相对于坐标系为self.gestureRecognizer.view所在有window
@property (nonatomic, readonly) CGPoint beginPoint;//手势开始时的触控点
@property (nonatomic, readonly) CGPoint prePoint;//手势上一个触控点
@property (nonatomic, readonly) CGPoint endPoint;//手势结束点

@property (nonatomic, strong, nullable) id userInfo;//扩展字段,可用于存储手势的相关状态
@property (nonatomic, copy, nullable) void(^whenAction)(LUIGestureRecognizerMoveAction *action);//手势事件
@end

@interface UIGestureRecognizer (LUI)

@property (nonatomic, readonly) LUIGestureRecognizerMoveAction *l_moveAction;//平移动作

@end

NS_ASSUME_NONNULL_END
