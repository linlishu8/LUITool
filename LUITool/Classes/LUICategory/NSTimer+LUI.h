//
//  NSTimer+LUI.h
//  LUITool
//
//  Created by 六月 on 2023/8/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSTimer (LUI)
/**
 *  由于+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo;
方法会持有target,直到invalidate,这种方式很容易造成循环引用.
 *
 *  @param interval      时间间隔
 *  @param repeats 是否重复
 *  @param block 每次调用的block
 *
 *  @return 定时器
 */
+ (NSTimer *)l_scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(NSTimer *timer))block;
@end

NS_ASSUME_NONNULL_END
