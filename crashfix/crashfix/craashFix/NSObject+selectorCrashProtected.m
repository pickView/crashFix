//
//  NSObject+selectorCrashProtected.m
//  crashfix
//
//  Created by allen on 2018/10/8.
//  Copyright © 2018 allen. All rights reserved.
//

#import "NSObject+selectorCrashProtected.h"
#import "NSObject+Runtime.h"
#import <objc/runtime.h>

char * const ZBaymaxProtectorName = "ZBaymaxProtector";

id baymaxProtected(id self, SEL sel){
    return nil;
}

@implementation NSObject (selectorCrashProtected)
+(void)load{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleInstanceMethodWithOrginalSel:@selector(forwardingTargetForSelector:) swizzledSel:@selector(bayMax_forwardingTargetForSelector:)];
        
        [self swizzleInstanceMethodWithOrginalSel:@selector(addObserver:forKeyPath:options:context:) swizzledSel:@selector(baymax_addObserver:forKeyPath:options:context:)];
    });
    
}

#pragma mark - Unrecognize Selector Protected
- (id)bayMax_forwardingTargetForSelector:(SEL)aSelector{
    if ([self isMethodOverWrite:[self class] selector:@selector(forwardInvocation:)] ||
        ![NSObject isMainBundleClass:[self class]]) {
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

#pragma mark - KVO Protected
- (void)baymax_addObserver:(NSObject *)observer
                forKeyPath:(NSString *)keyPath
                   options:(NSKeyValueObservingOptions)options
                   context:(void *)context {
    if ([observer isKindOfClass:[CPKVODelegate class]]) {
        return [self baymax_addObserver:observer
                             forKeyPath:keyPath
                                options:options
                                context:context];
    }
    
    if (keyPath.length == 0 || !observer) {
        NSLog(@"Add Observer Error:Check KVO KeyPath OR Observer");
        return;
    }
    
    if (!self.kvoDelegate) {
        self.kvoDelegate = [CPKVODelegate new];
        self.kvoDelegate.weakObservedObject = self;
    }
    
    CPKVODelegate *kvoDelegate = self.kvoDelegate;
    NSMutableDictionary *kvoInfoMaps = kvoDelegate.kvoInfoMaps;
    NSMutableArray *infoArray = kvoInfoMaps[keyPath];
    CPKVOInfo *kvoInfo = [CPKVOInfo new];
    kvoInfo.observer = observer;
    
    if (infoArray.count) {
        BOOL didAddObserver = NO;
        
        for (CPKVOInfo *info in infoArray) {
            if (info.observer == observer) {
                didAddObserver = YES;
                break;
            }
        }
        
        if (didAddObserver) {
            NSLog(@"BaymaxKVOProtector:%@ Has added Already", observer);
        } else {
            [infoArray addObject:kvoInfo];
        }
    } else {
        infoArray = [NSMutableArray new];
        [infoArray addObject:kvoInfo];
        kvoInfoMaps[keyPath] = infoArray;
        [self baymax_addObserver:kvoDelegate forKeyPath:keyPath options:options context:context];
    }
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
