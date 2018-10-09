//
//  NSObject+selectorCrashProtected.m
//  crashfix
//
//  Created by allen on 2018/10/8.
//  Copyright © 2018 allen. All rights reserved.
//

#import "NSObject+selectorCrashProtected.h"
#import <objc/runtime.h>

char * const ZBaymaxProtectorName = "ZBaymaxProtector";

id baymaxProtected(id self, SEL sel){
    return nil;
}

@implementation NSObject (selectorCrashProtected)
+(void)load{
    
    Method systemMethod = class_getInstanceMethod([self class], @selector(forwardingTargetForSelector:));
    
    Method newMethod = class_getInstanceMethod([self class], @selector(bayMax_forwardingTargetForSelector:));
    
    // class_addMethod:如果发现方法已经存在，会失败返回，也可以用来做检查用,我们这里是为了避免源方法没有实现的情况;如果方法没有存在,我们则先尝试添加被替换的方法的实现
    BOOL addMethod = class_addMethod([self class], @selector(forwardingTargetForSelector:), method_getImplementation(newMethod), method_getTypeEncoding(newMethod));

    if (addMethod) {
        class_replaceMethod([self class], @selector(forwardingTargetForSelector:), method_getImplementation(systemMethod), method_getTypeEncoding(systemMethod));
    }else{
        method_exchangeImplementations(systemMethod, newMethod);
    }
}

#pragma mark - Unrecognize Selector Protected
- (id)bayMax_forwardingTargetForSelector:(SEL)aSelector{
    if ([self isMethodOverWrite:[self class] selector:@selector(forwardInvocation:)]) {
        return [self bayMax_forwardingTargetForSelector:aSelector];
    }
    NSLog(@"catch unrecognize selector crash %@ %@", self, NSStringFromSelector(aSelector));
    NSLog(@"%@", [NSThread callStackSymbols]);
    
    Class baymaxProtector = [NSObject addMethodToStubClass:aSelector];
    
    if (!self.baymax) {
        self.baymax = [baymaxProtector new];
    }
    
    return self.baymax;
}
- (BOOL)isMethodOverWrite:(Class)classz selector:(SEL)sel{
    IMP classImp = class_getMethodImplementation(classz,sel);
    IMP superClassImp = class_getMethodImplementation([classz superclass],sel);
    return classImp != superClassImp;
}

+ (Class)addMethodToStubClass:(SEL)aSelecctor {
    Class baymaxProtector = objc_getClass(ZBaymaxProtectorName);
    
    if (!baymaxProtector) {
        baymaxProtector = objc_allocateClassPair([NSObject class], ZBaymaxProtectorName, sizeof([self class]));
        objc_registerClassPair(baymaxProtector);
    }
    
    class_addMethod(baymaxProtector, aSelecctor, (IMP)baymaxProtected, "@@:");
    return baymaxProtector;
}

- (void)setBaymax:(id)baymax {
    objc_setAssociatedObject(self, @selector(baymax), baymax, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)baymax {
    return objc_getAssociatedObject(self, _cmd);
}
@end
