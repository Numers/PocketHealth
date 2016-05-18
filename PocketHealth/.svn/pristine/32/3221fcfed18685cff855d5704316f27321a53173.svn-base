//
//  RSSwizzle.h
//  PocketHealth
//
//  Created by YangFan on 15/1/31.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
typedef IMP *IMPPointer;
@interface NSObject (RNSwizzle)
+ (IMP)swizzleSelector:(SEL)origSelector
               withIMP:(IMP)newIMP;
+ (BOOL)swizzle:(SEL)original with:(IMP)replacement store:(IMPPointer)store ;
@end
