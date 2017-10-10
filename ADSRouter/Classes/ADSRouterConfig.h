//
//  ADSRouterConfig.h
//  ADSRouter
//
//  Created by Andy on 2017/10/10.
//

#import <Foundation/Foundation.h>
#import "ADSURL.h"

typedef void(^ADSRouteMismatchCallback)(ADSURL *url);

@interface ADSRouterConfig : NSObject

@property (nonatomic, assign) NSUInteger routerInfoCacheCapacity;
@property (nonatomic, assign) NSUInteger VCCacheCapacity;
@property (nonatomic, copy) ADSRouteMismatchCallback routeMismatchCallback;

@end
