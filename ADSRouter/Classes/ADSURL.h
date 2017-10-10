//
//  ADSURL.h
//  ADSRouter
//
//  Created by Andy on 2017/10/9.
//

#import <Foundation/Foundation.h>

@interface ADSURL : NSObject

@property (nonatomic, copy, readonly) NSString *compareString;
@property (nonatomic, strong, readonly) NSDictionary *parameters;
@property (nonatomic, readonly) NSString *absoluteString;

+ (instancetype)URLWithString:(NSString*)url;
- (instancetype)initWithString:(NSString*)url;

@end
