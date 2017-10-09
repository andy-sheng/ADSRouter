//
//  NSURL+ASURL.h
//  ASRouter
//
//  Created by Andy on 2017/9/29.
//

#import <Foundation/Foundation.h>

@interface NSURL (ADSURL)

@property (nonatomic, readonly, copy) NSString *ads_compareString;
@property (nonatomic, readonly, strong) NSDictionary *ads_parameters;

@end
