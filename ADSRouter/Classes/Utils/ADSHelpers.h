//
//  ADSHelpers.h
//  Pods
//
//  Created by Andy on 2017/10/11.
//

#ifndef ADSHelpers_h
#define ADSHelpers_h

#import <Foundation/Foundation.h>

@class ADSRouter,ADSRouteInfo,UIViewController;

NSArray<NSString*>* ADSGetMethodNames(Class klass);

ADSRouteInfo *ADSGetRouteInfoFromVC(NSString *clsName);

UIViewController* ADSTopViewControllerWithRootViewController(UIViewController *rootViewController);

UIViewController* ADSTopViewController();


#endif /* ADSHelpers_h */
