//
//  LUIMacro.h
//  LUITool
//
//  Created by 六月 on 2024/8/12.
//

#undef lui_weakify
#define lui_weakify( x )     __weak __typeof__(x) __weak_##x##__ = x;

#undef    lui_strongify
#define lui_strongify( x )     __strong __typeof__(x) x = __weak_##x##__;
