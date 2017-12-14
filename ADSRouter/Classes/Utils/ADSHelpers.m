//
//  ADSHelpers.m
//  
//
//  Created by Andy on 2017/10/11.
//

#import "ADSHelpers.h"
#import "ADSRouterConfig.h"
#import "ADSRouteInfo.h"
#import "ADSURL.h"
#import "ADSClassInfo.h"
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

ADSRouteInfo *ADSGetRouteInfoFromVC(NSString *clsName) {
    ADSRouteInfo *routeInfo = [ADSRouteInfo new];
    routeInfo.clsName = clsName;
    id vc = [NSClassFromString(clsName) new];
#pragma clang diagnostic ignored "-Wundeclared-selector"
    
    // ADS_STORYBOARD(storyBoardName, storyBoardId)
    if ([vc respondsToSelector:@selector(ads_storyBoardName)]) {
        routeInfo.isAwakeFromStoryBoard = YES;
        routeInfo.bundleName = [vc performSelector:@selector(ads_bundleName)];
        routeInfo.storyBoardName = [vc performSelector:@selector(ads_storyBoardName)];
        routeInfo.storyBoardId = [vc performSelector:@selector(ads_storyBoardId)];
    }
    
    // ADS_BEFORE_JUMP(beforeJumpBlock)
    if ([vc respondsToSelector:@selector(ads_beforeJumpBlock)]) {
        routeInfo.beforeJumpBlock = [vc performSelector:@selector(ads_beforeJumpBlock)];
    }
    
    // ADS_SUPPORT_FLY
    routeInfo.supportFly = [vc respondsToSelector:@selector(ads_supportFly)];
    
    // ADS_HIDE_NAV
    routeInfo.hideNav = [vc respondsToSelector:@selector(ads_hideNav)];
    
    // ADS_HIDE_BOTTOM_BAR
    routeInfo.hideBottomBar = [vc respondsToSelector:@selector(ads_hideBottomBar)];
    
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    
    // ADS_SHOWSTYLE
    NSMutableDictionary *paramMapping = [NSMutableDictionary dictionary];
    routeInfo.animation = YES;
    for (NSString *methodName in ADSGetMethodNames(NSClassFromString(clsName))) {
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
