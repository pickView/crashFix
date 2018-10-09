//
//  NSObject+Runtime.h
//  crashfix
//
//  Created by allen on 2018/10/9.
//  Copyright © 2018 allen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Runtime)

/**
 Determine if the class is custom

 @param class Class Name
 @return y or n
 */
+ (BOOL)isMainBundleClass:(Class)cls;
@end

NS_ASSUME_NONNULL_END
