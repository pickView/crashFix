//
//  ZKVODelegate.m
//  crashfix
//
//  Created by allen on 2018/10/9.
//  Copyright © 2018 allen. All rights reserved.
//

#import "ZKVODelegate.h"
#import "NSObject+Runtime.h"

@implementation ZKVOInfo
@end

@implementation ZKVODelegate
+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleInstanceMethodWithOrginalSel:@selector(observeValueForKeyPath:ofObject:change:context:) swizzledSel:@selector(baymax_observeValueForKeyPath:ofObject:change:context:)];
      
    });
}

- (void)baymax_observeValueForKeyPath:(NSString *)keyPath
                             ofObject:(id)object
                               change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                              context:(void *)context{
    
    NSMutableDictionary *kvoInfoMaps = self.kvoInfoMaps;
    NSMutableArray *infoArray = kvoInfoMaps[keyPath];
    NSMutableArray *invalidArray = [NSMutableArray new];
    
    for (ZKVOInfo *info in infoArray) {
        //由于info中对real observer是弱引用
        //所以这里如果observer释放之后 info中的observer会被置为nil
        if (!info.observer) {
            [invalidArray addObject:info];
        }else{
            [info.observer observeValueForKeyPath:keyPath
                                         ofObject:object
                                           change:change
                                          context:context];
        }
        
    }
    
    [infoArray removeObjectsInArray:invalidArray];
    
    if (!infoArray.count) {
        [self.weakObserOject removeObserver:self forKeyPath:keyPath];
        kvoInfoMaps[keyPath] = nil;
    }
}

-(NSMutableDictionary *)kvoInfoMaps{
    if (!_kvoInfoMaps) {
        _kvoInfoMaps = [NSMutableDictionary new];
    }
    
    return _kvoInfoMaps;
}
@end
