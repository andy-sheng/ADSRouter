//
//  ADSAppDelegate.m
//  ADSRouter
//
//  Created by andysheng@live.com on 10/09/2017.
//  Copyright (c) 2017 andysheng@live.com. All rights reserved.
//

#import "ADSAppDelegate.h"
#import "ADSRouter.h"

@interface ADSAppDelegate () <ADSRouterInterceptor>

@end

@implementation ADSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[ADSRouter sharedRouter] setRouterInterceptor:self];
    [[ADSRouter sharedRouter] setVCCacheCapacity:10];
    [[ADSRouter sharedRouter] setRouterInfoCacheCapacity:10];
    [[ADSRouter sharedRouter] setRouteMismatchCallback:^(ADSURL *url) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"url mismatch" message:url.compareString preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"cancle" style:UIAlertActionStyleCancel handler:nil]];
        [application.keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
    }];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (ADSURL*)intercept:(ADSURL *)url {
    // you can fetch some information from your server here
    if ([self urlMatchesSomeCondition:url]) {
        url = [ADSURL URLWithString:@"wfshop://present"];
    }
    return url;
}

- (BOOL)urlMatchesSomeCondition:(ADSURL*)url {
    if ([url.compareString isEqualToString:@"wfshop://interceptorTest"]) {
        return YES;
    }
    return NO;
}


@end
