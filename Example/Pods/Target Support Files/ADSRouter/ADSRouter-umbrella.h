#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "ADSAnnotation.h"
#import "ADSClassInfo.h"
#import "ADSRouteInfo.h"
#import "ADSRouter.h"
#import "ADSRouterConfig.h"
#import "ADSURL.h"
#import "ADSHelpers.h"
#import "ADSSetValueToProperty.h"

FOUNDATION_EXPORT double ADSRouterVersionNumber;
FOUNDATION_EXPORT const unsigned char ADSRouterVersionString[];

