//
//  ZKVODelegate.h
//  crashfix
//
//  Created by allen on 2018/10/9.
//  Copyright © 2018 allen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZKVOInfo : NSObject
@property (nonatomic, weak) id observer;
@end

NS_ASSUME_NONNULL_BEGIN

@interface ZKVODelegate : NSObject
@property (nonatomic, strong) NSMutableDictionary *kvoInfoMaps;
@property (nonatomic, weak) id weakObserOject;

@end

NS_ASSUME_NONNULL_END
