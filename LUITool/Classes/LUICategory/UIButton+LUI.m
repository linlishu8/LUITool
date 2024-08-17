//
//  UIButton+LUI.m
//  LUITool
//
//  Created by 六月 on 2023/8/11.
//

#import "UIButton+LUI.h"
#import "UIImage+LUI.h"

@implementation UIButton (LUI)

- (void)l_setBackgroundColor:(UIColor *)color forState:(UIControlState)state {
    UIImage *image = [UIImage l_imageWithUIColor:color];
    [self setBackgroundImage:image forState:state];
}

@end

@interface __LUIButtonActionBlockObject : NSObject
@property (nonatomic, copy) LUIButtonActionBlock actionBlock;
@property (nonatomic, weak) id context;

- (id)initWithActionBlock:(LUIButtonActionBlock)block context:(id)context;
- (void)doAction;

@end


@implementation __LUIButtonActionBlockObject

- (id)initWithActionBlock:(LUIButtonActionBlock)block context:(id)context {
    if (self = [super init]) {
        self.actionBlock = block;
        self.context = context;
    }
    return self;
}

- (void)doAction {
    if (self.actionBlock) {
        self.actionBlock(self.context);
    }
}
#ifdef DEBUG
- (void)dealloc {
    
}
#endif
@end

#import <objc/runtime.h>
@implementation UIButton (LUI_ActionBlock)
- (NSMutableArray<__LUIButtonActionBlockObject *> *)__LUIButtonActionBlockObjectList {
    NSMutableArray<__LUIButtonActionBlockObject *> *list = objc_getAssociatedObject(self, @"__LUIButtonActionBlockObjectList");
    if (!list) {
        list = [[NSMutableArray alloc] init];
        objc_setAssociatedObject(self, @"__LUIButtonActionBlockObjectList", list, OBJC_ASSOCIATION_RETAIN);
    }
    return list;
}
- (void)l_addClickActionBlock:(LUIButtonActionBlock)block context:(id)context {
    __LUIButtonActionBlockObject *action = [[__LUIButtonActionBlockObject alloc] initWithActionBlock:block context:context];
    [[self __LUIButtonActionBlockObjectList] addObject:action];
    [self addTarget:action action:@selector(doAction) forControlEvents:UIControlEventTouchUpInside];
}
@end
