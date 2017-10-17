//
//  ASRouter.h
//  annotation-demo
//
//  Created by Andy on 2017/9/25.
//  Copyright © 2017年 andy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADSAnnotation.h"
#import "ADSRouterConfig.h"

@protocol ADSRouterInterceptor <NSObject>

@required
- (ADSURL*)intercept:(ADSURL*)url;

@end


@interface ADSRouter : NSObject

@property (nonatomic, weak) id<ADSRouterInterceptor> routerInterceptor;

+ (instancetype)sharedRouter;

@end

@interface ADSRouter (ADSConfig)

- (void)setRouterInfoCacheCapacity:(NSUInteger)capacity;
- (void)setVCCacheCapacity:(NSUInteger)capacity;
- (void)setRouteMismatchCallback:(ADSRouteMismatchCallback)callback;

@end

@interface ADSRouter (ADSRegister)

- (void)registerRouteWithUrl:(NSString*)aUrl VC:(NSString*)klass;

@end


@interface ADSRouter (ADSOpen)

- (void)openUrlString:(NSString*)aUrl;

- (void)openUrl:(NSURL*)aUrl;

@end
