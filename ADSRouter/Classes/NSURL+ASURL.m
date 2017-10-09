//
//  NSURL+ASURL.m
//  ASRouter
//
//  Created by Andy on 2017/9/29.
//

#import "NSURL+ASURL.h"
#import <objc/runtime.h>

@implementation NSURL (ADSURL)

- (NSDictionary*)_ads_parseParameters {
    NSMutableDictionary<NSString*, NSString*> *parameters = [NSMutableDictionary dictionary];
    NSURLComponents *components = [NSURLComponents componentsWithURL:self resolvingAgainstBaseURL:NO];
    [components.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [parameters setObject:obj.value forKey:obj.name];
    }];
    return [parameters copy];
}

- (NSString*)ads_compareString {
    NSMutableString *url = [NSMutableString stringWithFormat:@"%@://%@", self.scheme, self.host];
    if (self.path) {
        [url appendString:self.path];
    }
    return [url copy];
}

- (NSDictionary*)ads_parameters {
    NSDictionary *paramDic = objc_getAssociatedObject(self, @selector(parameters));
    if (!paramDic) {
        paramDic = [self _ads_parseParameters];
        objc_setAssociatedObject(self, @selector(parameters), paramDic, OBJC_ASSOCIATION_RETAIN);
    }
    return paramDic;
}
@end
