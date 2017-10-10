//
//  ADSURL.m
//  ADSRouter
//
//  Created by Andy on 2017/10/9.
//

#import "ADSURL.h"

@interface ADSURL()

@property (nonatomic, copy) NSURL *url;

@end

@implementation ADSURL

+ (instancetype)URLWithString:(NSString *)url {
    ADSURL *instance = [[ADSURL alloc] initWithString:url];
    return instance;
}

- (instancetype)initWithString:(NSString *)url {
    self = [super init];
    if (self) {
        _url = [NSURL URLWithString:url];
        
        NSMutableString *compareString = [NSMutableString stringWithFormat:@"%@://%@", _url.scheme, _url.host];
        if (_url.path) {
            [compareString appendString:_url.path];
        }
        _compareString = [compareString copy];
        
        NSMutableDictionary<NSString*, NSString*> *parameters = [NSMutableDictionary dictionary];
        NSURLComponents *components = [NSURLComponents componentsWithURL:_url resolvingAgainstBaseURL:NO];
        [components.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [parameters setObject:obj.value forKey:obj.name];
        }];
        _parameters = [parameters copy];
        
    }
    return self;
}

- (NSString*)absoluteString {
    return _url.absoluteString;
}

- (NSUInteger)hash {
    __block NSUInteger hash = _compareString.hash;
    [_parameters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        hash ^= [key hash];
        hash ^= [obj hash];
    }];
    return hash;
}

- (BOOL)isEqual:(id)object {
    if (object ==  self) {
        return YES;
    }
    if (![object isMemberOfClass:[ADSURL class]]) {
        return NO;
    }
    ADSURL *url = object;
    if (![self.compareString isEqualToString:url.compareString]) {
        return NO;
    }
    if (self.parameters.count != url.parameters.count) {
        return NO;
    }
    return [self.parameters isEqual:url.parameters];
}

@end
