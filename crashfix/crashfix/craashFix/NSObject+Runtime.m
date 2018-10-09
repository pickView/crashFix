//
//  NSObject+Runtime.m
//  crashfix
//
//  Created by allen on 2018/10/9.
//  Copyright © 2018 allen. All rights reserved.
//

#import "NSObject+Runtime.h"

@implementation NSObject (Runtime)

+ (void)swizzleInstanceMethodWithOrginalSel:(SEL)oriSel swizzledSel:(SEL)swiSel {
    Method systemMethod = class_getInstanceMethod([self class], oriSel);
    
    Method newMethod = class_getInstanceMethod([self class], swiSel);
    
    // class_addMethod:如果发现方法已经存在，会失败返回，也可以用来做检查用,我们这里是为了避免源方法没有实现的情况;如果方法没有存在,我们则先尝试添加被替换的方法的实现
    BOOL addMethod = class_addMethod([self class], oriSel, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    
    if (addMethod) {
        class_replaceMethod([self class], oriSel, method_getImplementation(systemMethod), method_getTypeEncoding(systemMethod));
    }else{
        method_exchangeImplementations(systemMethod, newMethod);
    }
}

+ (BOOL)isMainBundleClass:(Class)cls{
    return cls && [[NSBundle bundleForClass:cls] isEqual:[NSBundle mainBundle]];
}
@end
