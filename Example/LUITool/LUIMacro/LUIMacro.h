//
//  LUIMacro.h
//  LUITool
//
//  Created by 六月 on 2023/8/18.
//  Copyright © 2024 Your Name. All rights reserved.
//


#undef lui_weakify
#define lui_weakify( x )     __weak __typeof__(x) __weak_##x##__ = x;

#undef    lui_strongify
#define lui_strongify( x )     __strong __typeof__(x) x = __weak_##x##__;

#define ODDingTalkScheme @"lark://"
