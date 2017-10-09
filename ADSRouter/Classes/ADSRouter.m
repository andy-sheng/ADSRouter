//
//  ADSRouter.m
//  annotation-demo
//
//  Created by Andy on 2017/9/25.
//  Copyright © 2017年 andy. All rights reserved.
//

#import "ADSRouter.h"
#import "ADSRouteInfo.h"
#import "NSURL+ASURL.h"
#import "ADSClassInfo.h"
#import "ADSSetValueToProperty.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>


NSArray<NSString*>* ADSGetMethodNames(Class klass) {
    unsigned int methodCnt;
    Method *methods = class_copyMethodList(klass, &methodCnt);
    NSMutableArray<NSString*> *methodNames = [NSMutableArray arrayWithCapacity:methodCnt];
    for (int i = 0; i < methodCnt; ++i) {
        SEL methodSelector = method_getName(methods[i]);
        methodNames[i] = NSStringFromSelector(methodSelector);
    }
    free(methods);
    
    return methodNames;
}

ADSRouteInfo *ADSGetRouteInfoFromVC(NSString *klassName) {
    ADSRouteInfo *routeInfo = [ADSRouteInfo new];
    routeInfo.klass = klassName;
    id vc = [NSClassFromString(klassName) new];
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([vc respondsToSelector:@selector(ads_storyBoardName)]) {
        routeInfo.isAwakeFromStoryBoard = YES;
        routeInfo.storyBoardName = [vc performSelector:@selector(ads_storyBoardName)];
        routeInfo.storyBoardId = [vc performSelector:@selector(ads_storyBoardId)];
    }
    
    if ([vc respondsToSelector:@selector(ads_beforeJumpBlock)]) {
        routeInfo.beforeJumpBlock = [vc performSelector:@selector(ads_beforeJumpBlock)];
    }
    
    routeInfo.hideNav = [vc respondsToSelector:@selector(ads_hideNav)];

#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSMutableDictionary *paramMapping = [NSMutableDictionary dictionary];
    routeInfo.animation = YES;
    for (NSString *methodName in ADSGetMethodNames(NSClassFromString(klassName))) {
        if ([methodName hasPrefix:@"ads_propertymapping_"]) {
            NSDictionary *mapping = [vc performSelector:NSSelectorFromString(methodName)];
            paramMapping[mapping[@"paramName"]] = mapping[@"propertyName"];
        } else if ([methodName hasPrefix:@"ads_showstyle_"]) {
            if ([methodName isEqualToString:@"ads_showstyle_push"]) {
                routeInfo.showStyle = ADSVCShowStylePush;
            } else if ([methodName isEqualToString:@"ads_showstyle_present"]) {
                routeInfo.showStyle = ADSVCShowStylePresent;
            }
            routeInfo.animation = [vc performSelector:NSSelectorFromString(methodName)];
        }
    }
    routeInfo.paramMapping = [paramMapping copy];
    
    return routeInfo;
}

UIViewController* ADSTopViewControllerWithRootViewController(UIViewController *rootViewController) {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return ADSTopViewControllerWithRootViewController(tabBarController.selectedViewController);
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return ADSTopViewControllerWithRootViewController(navigationController.visibleViewController);
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return ADSTopViewControllerWithRootViewController(presentedViewController);
    } else {
        return rootViewController;
    }
}

UIViewController* ADSTopViewController() {
    return ADSTopViewControllerWithRootViewController([UIApplication sharedApplication].keyWindow.rootViewController);
}



@interface ADSRouter ()

@property (nonatomic, strong) NSMutableDictionary *urlAndVCMapping;
@property (nonatomic, strong) NSCache<NSString*, ADSRouteInfo*> *routeCache;

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

@implementation ADSRouter (Open)

- (void)openUrl:(NSString *)aUrl {
    NSURL *url = [NSURL URLWithString:aUrl];
    ADSRouteInfo *routeInfo = [self _ads_getRouteInfo:url.ads_compareString];
    if (!routeInfo) {
        return;
    }
    [self _ads_openUrl:routeInfo params:url.ads_parameters];
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

- (void)_ads_openUrl:(ADSRouteInfo*)routeInfo params:(NSDictionary*)parameters {
    UIViewController *destVC;
    if (routeInfo.isAwakeFromStoryBoard) {
        destVC = [[UIStoryboard storyboardWithName:routeInfo.storyBoardName bundle:nil] instantiateViewControllerWithIdentifier:routeInfo.storyBoardId];
    } else {
        destVC = [NSClassFromString(routeInfo.klass) new];
    }
    [self _ads_prepareVC:destVC routeInfo:routeInfo params:parameters];
    if (routeInfo.beforeJumpBlock) {
        routeInfo.beforeJumpBlock();
    }
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

- (void)_ads_prepareVC:(UIViewController*)vc routeInfo:(ADSRouteInfo*)routeInfo params:(NSDictionary*)parameters {
    ADSClassInfo *classInfo = [ADSClassInfo classInfoWithClassName:routeInfo.klass];
    [parameters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *propertyName = routeInfo.paramMapping[key];
        if (propertyName && classInfo.propertyInfos[propertyName]) {
            ADSSetValueToProperty(vc, obj, classInfo.propertyInfos[propertyName]);
        }
    }];
}

- (void)_ads_pushVC:(UIViewController*)vc animated:(BOOL)animated {
    UINavigationController *navCtl = ADSTopViewController().navigationController;
    if (!navCtl) {
        //
        return;
    }
    [navCtl pushViewController:vc animated:animated];
}

- (void)_ads_presentVC:(UIViewController*)vc animated:(BOOL)animated completion:(void(^)(void))completion {
    UIViewController *fromVC = ADSTopViewController();
    [fromVC presentViewController:vc animated:animated completion:completion];
}

@end
