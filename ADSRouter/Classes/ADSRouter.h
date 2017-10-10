//
//  ASRouter.h
//  annotation-demo
//
//  Created by Andy on 2017/9/25.
//  Copyright © 2017年 andy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADSAnnotation.h"



@interface ADSRouter : NSObject

+ (instancetype)sharedRouter;

@end

@interface ADSRouter (ADSRegister)

- (void)registerRouteWithUrl:(NSString*)aUrl VC:(NSString*)klass;

@end


@interface ADSRouter (ADSOpen)

- (void)openUrl:(NSString*)aUrl;

@end
