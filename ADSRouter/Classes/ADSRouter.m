//
//  ADSRouter.m
//  annotation-demo
//
//  Created by Andy on 2017/9/25.
//  Copyright © 2017年 andy. All rights reserved.
//

#import "ADSRouter.h"
#import "ADSRouteInfo.h"
#import "ADSURL.h"
#import "ADSClassInfo.h"
#import "ADSSetValueToProperty.h"
#import "ADSRouterConfig.h"
#import "ADSHelpers.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>


@interface ADSRouter ()

@property (nonatomic, strong) NSMutableDictionary *urlAndVCMapping;
@property (nonatomic, strong) NSCache<NSString*, ADSRouteInfo*> *routeCache;
@property (nonatomic, strong) NSCache<NSString*, UIViewController*> *VCCache;

@property (nonatomic, strong) ADSRouterConfig *routerConfig;

@end


@implementation ADSRouter

+ (instancetype)sharedRouter {
    static ADSRouter *router;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        router = [ADSRouter new];
    });
    return router;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _urlAndVCMapping = [NSMutableDictionary dictionary];
        _routeCache = [NSCache new];
        _VCCache = [NSCache new];
        _routerConfig = [ADSRouterConfig new];
    }
    return self;
}

- (void)registerRouteWithUrl:(NSString *)aUrl VC:(NSString *)klass {
    if ([_urlAndVCMapping objectForKey:aUrl]) {
        NSLog(@"重复url");
    }
    [_urlAndVCMapping setObject:klass forKey:aUrl];
}

- (NSString*)description {
    return [_urlAndVCMapping description];
}

@end

@implementation ADSRouter (ADSConfig)

- (void)setVCCacheCapacity:(NSUInteger)capacity {
    _VCCache.countLimit = capacity;
    _routerConfig.VCCacheCapacity = capacity;
}

- (void)setRouterInfoCacheCapacity:(NSUInteger)capacity {
    _routeCache.countLimit = capacity;
    _routerConfig.routerInfoCacheCapacity = capacity;
}

- (void)setRouteMismatchCallback:(ADSRouteMismatchCallback)callback {
    _routerConfig.routeMismatchCallback = callback;
}

@end

@implementation ADSRouter (Open)

- (void)openUrlString:(NSString *)aUrl {
    
    // Parse URL
    ADSURL *url = [ADSURL URLWithString:aUrl];
    
    // Let interceptor intercept this URL
    if (_routerInterceptor && [_routerInterceptor respondsToSelector:@selector(intercept:)]) {
        url = [_routerInterceptor intercept:url];
    }
    
    // Get URL information from binary and runtime
    ADSRouteInfo *routeInfo = [self _ads_getRouteInfo:url.compareString];
    if (!routeInfo && _routerConfig.routeMismatchCallback) {
        _routerConfig.routeMismatchCallback(url);
        return;
    }
    
    // Do beforeJump
    [self _ads_doBeforeJumpWithRouteInfo:routeInfo url:url];
    
    // Instancelize destnation viewController
    UIViewController *dest = [self _ads_getVCWithRouteInfo:routeInfo url:url];
    
    // Show viewController
    [self _ads_showVC:dest withRouteInfo:routeInfo];
    
}

- (void)openUrl:(NSURL *)aUrl {
    [self openUrlString:aUrl.absoluteString];
}

- (ADSRouteInfo*)_ads_getRouteInfo:(NSString*)aUrl {
    ADSRouteInfo *routeInfo = [_routeCache objectForKey:aUrl];
    if (!routeInfo) {
        NSString *klass = [_urlAndVCMapping objectForKey:aUrl];
        if (!klass) {
            // route information doesn't exist
            return nil;
        }
        routeInfo = ADSGetRouteInfoFromVC(klass);
        [_routeCache setObject:routeInfo forKey:aUrl];
    }
    return routeInfo;
}

- (void)_ads_doBeforeJumpWithRouteInfo:(ADSRouteInfo*)routeInfo url:(ADSURL*)url {
    if (routeInfo.beforeJumpBlock) {
        BOOL abort = NO;
        routeInfo.beforeJumpBlock(url, &abort);
        if (abort) {
            return;
        }
    }
}

- (UIViewController*)_ads_getVCWithRouteInfo:(ADSRouteInfo*)routeInfo url:(ADSURL*)url {
    UIViewController *dest;
    if (!routeInfo.supportFly) {
        dest = [self _ads_VCFactory:routeInfo];
    } else {
        dest = [_VCCache objectForKey:url.compareString];
        if (!dest || dest.parentViewController) {
            dest = [self _ads_VCFactory:routeInfo];
        }
        [_VCCache setObject:dest forKey:url.compareString];
    }
    [self _ads_prepareVC:dest routeInfo:routeInfo params:url.parameters];
    return dest;
}

- (UIViewController*)_ads_VCFactory:(ADSRouteInfo*)routeInfo {
    UIViewController *destVC;
    if (routeInfo.isAwakeFromStoryBoard) {
        NSBundle *bundle = nil;
        if (![routeInfo.bundleName isEqualToString:@""]) {
            NSString *bundlePath = [[NSBundle mainBundle] pathForResource:routeInfo.bundleName ofType:@"bundle"];
            bundle = [NSBundle bundleWithPath:bundlePath];
        }
        destVC = [[UIStoryboard storyboardWithName:routeInfo.storyBoardName bundle:bundle] instantiateViewControllerWithIdentifier:routeInfo.storyBoardId];
    } else {
        destVC = [NSClassFromString(routeInfo.clsName) new];
    }
    return destVC;
}

- (void)_ads_prepareVC:(UIViewController*)vc routeInfo:(ADSRouteInfo*)routeInfo params:(NSDictionary*)parameters {
    ADSClassInfo *classInfo = [ADSClassInfo classInfoWithClassName:routeInfo.clsName];
    [parameters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *propertyName = routeInfo.paramMapping[key];
        if (propertyName && classInfo.propertyInfos[propertyName]) {
            ADSSetValueToProperty(vc, obj, classInfo.propertyInfos[propertyName]);
        }
    }];
}

- (void)_ads_showVC:(UIViewController*)destVC withRouteInfo:(ADSRouteInfo*)routeInfo {
    switch (routeInfo.showStyle) {
        case ADSVCShowStylePush:
            [self _ads_pushVC:destVC animated:routeInfo.animation];
            break;
        case ADSVCShowStylePresent:
            [self _ads_presentVC:destVC animated:routeInfo.animation completion:routeInfo.completion];
            break;
        default:
            break;
    }
}

- (void)_ads_pushVC:(UIViewController*)vc animated:(BOOL)animated {
    UINavigationController *navCtl = ADSTopViewController().navigationController;
    if (!navCtl) {
        return;
    }
    [navCtl pushViewController:vc animated:animated];
}

- (void)_ads_presentVC:(UIViewController*)vc animated:(BOOL)animated completion:(void(^)(void))completion {
    UIViewController *fromVC = ADSTopViewController();
    [fromVC presentViewController:vc animated:animated completion:completion];
}

@end
