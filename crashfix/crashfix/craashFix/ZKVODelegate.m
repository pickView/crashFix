//
//  ZKVODelegate.m
//  crashfix
//
//  Created by allen on 2018/10/9.
//  Copyright © 2018 allen. All rights reserved.
//

#import "ZKVODelegate.h"
#import "NSObject+selectorCrashProtected.h"

@implementation ZKVOInfo
@end

@implementation ZKVODelegate
+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
//        [self swizzleInstanceMethodWithOrginalSel:@selector(observeValueForKeyPath:ofObject:change:context:) swizzledSel:@selector(baymax_observeValueForKeyPath:ofObject:change:context:)];
    });
}
@end
