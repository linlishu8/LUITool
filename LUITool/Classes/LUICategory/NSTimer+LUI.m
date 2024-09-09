//
//  NSTimer+LUI.m
//  LUITool
//
//  Created by 六月 on 2023/8/18.
//

#import "NSTimer+LUI.h"

@interface __LUINSTimerHandler : NSObject
@property (nonatomic, copy) void(^whenTimer)(NSTimer *timer);
- (void)onTimer:(NSTimer *)timer;
@end
@implementation __LUINSTimerHandler
- (void)onTimer:(NSTimer *)timer{
    if (self.whenTimer) {
        self.whenTimer(timer);
    }
}
@end

@implementation NSTimer (LUI)
+ (NSTimer *)l_scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(NSTimer *timer))block{
    if (@available(iOS 10.0, *)) {
        return [NSTimer scheduledTimerWithTimeInterval:interval repeats:repeats block:block];
    } else {
        __LUINSTimerHandler *timerHandler = [[__LUINSTimerHandler alloc] init];
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:interval target:timerHandler selector:@selector(onTimer:) userInfo:nil repeats:repeats];
        timerHandler.whenTimer = block;
        return timer;
    }
}
@end
