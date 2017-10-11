//
//  ASSetValueToProperty.m
//  ASRouter
//
//  Created by Andy on 2017/10/9.
//

#import <Foundation/Foundation.h>
#import "ADSSetValueToProperty.h"
#import "ADSClassInfo.h"
#import <objc/message.h>

#define force_inline __inline__ __attribute__((always_inline))

/// Get the Foundation class type from property info.
static force_inline ADSEncodingNSType ADSClassGetNSType(Class cls) {
    if (!cls) return ADSEncodingTypeNSUnknown;
    if ([cls isSubclassOfClass:[NSMutableString class]]) return ADSEncodingTypeNSMutableString;
    if ([cls isSubclassOfClass:[NSString class]]) return ADSEncodingTypeNSString;
    if ([cls isSubclassOfClass:[NSDecimalNumber class]]) return ADSEncodingTypeNSDecimalNumber;
    if ([cls isSubclassOfClass:[NSNumber class]]) return ADSEncodingTypeNSNumber;
    if ([cls isSubclassOfClass:[NSValue class]]) return ADSEncodingTypeNSValue;
    if ([cls isSubclassOfClass:[NSMutableData class]]) return ADSEncodingTypeNSMutableData;
    if ([cls isSubclassOfClass:[NSData class]]) return ADSEncodingTypeNSData;
    if ([cls isSubclassOfClass:[NSDate class]]) return ADSEncodingTypeNSDate;
    if ([cls isSubclassOfClass:[NSURL class]]) return ADSEncodingTypeNSURL;
    //    if ([cls isSubclassOfClass:[NSMutableArray class]]) return ASEncodingTypeNSMutableArray;
    //    if ([cls isSubclassOfClass:[NSArray class]]) return ASEncodingTypeNSArray;
    //    if ([cls isSubclassOfClass:[NSMutableDictionary class]]) return ASEncodingTypeNSMutableDictionary;
    //    if ([cls isSubclassOfClass:[NSDictionary class]]) return ASEncodingTypeNSDictionary;
    //    if ([cls isSubclassOfClass:[NSMutableSet class]]) return ASEncodingTypeNSMutableSet;
    //    if ([cls isSubclassOfClass:[NSSet class]]) return ASEncodingTypeNSSet;
    return ADSEncodingTypeNSUnknown;
}


/// Parse a number value from 'id'.
static force_inline NSNumber *ADSNSNumberCreateFromID(__unsafe_unretained id value) {
    static NSCharacterSet *dot;
    static NSDictionary *dic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dot = [NSCharacterSet characterSetWithRange:NSMakeRange('.', 1)];
        dic = @{@"TRUE" :   @(YES),
                @"True" :   @(YES),
                @"true" :   @(YES),
                @"FALSE" :  @(NO),
                @"False" :  @(NO),
                @"false" :  @(NO),
                @"YES" :    @(YES),
                @"Yes" :    @(YES),
                @"yes" :    @(YES),
                @"NO" :     @(NO),
                @"No" :     @(NO),
                @"no" :     @(NO),
                @"NIL" :    (id)kCFNull,
                @"Nil" :    (id)kCFNull,
                @"nil" :    (id)kCFNull,
                @"NULL" :   (id)kCFNull,
                @"Null" :   (id)kCFNull,
                @"null" :   (id)kCFNull,
                @"(NULL)" : (id)kCFNull,
                @"(Null)" : (id)kCFNull,
                @"(null)" : (id)kCFNull,
                @"<NULL>" : (id)kCFNull,
                @"<Null>" : (id)kCFNull,
                @"<null>" : (id)kCFNull};
    });
    
    if (!value || value == (id)kCFNull) return nil;
    if ([value isKindOfClass:[NSNumber class]]) return value;
    if ([value isKindOfClass:[NSString class]]) {
        NSNumber *num = dic[value];
        if (num) {
            if (num == (id)kCFNull) return nil;
            return num;
        }
        if ([(NSString *)value rangeOfCharacterFromSet:dot].location != NSNotFound) {
            const char *cstring = ((NSString *)value).UTF8String;
            if (!cstring) return nil;
            double num = atof(cstring);
            if (isnan(num) || isinf(num)) return nil;
            return @(num);
        } else {
            const char *cstring = ((NSString *)value).UTF8String;
            if (!cstring) return nil;
            return @(atoll(cstring));
        }
    }
    return nil;
}

/// Parse string to date.
static force_inline NSDate *ADSNSDateFromString(__unsafe_unretained NSString *string) {
    typedef NSDate* (^ADSNSDateParseBlock)(NSString *string);
#define kParserNum 34
    static ADSNSDateParseBlock blocks[kParserNum + 1] = {0};
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        {
            /*
             2014-01-20  // Google
             */
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter.dateFormat = @"yyyy-MM-dd";
            blocks[10] = ^(NSString *string) { return [formatter dateFromString:string]; };
        }
        
        {
            /*
             2014-01-20 12:24:48
             2014-01-20T12:24:48   // Google
             2014-01-20 12:24:48.000
             2014-01-20T12:24:48.000
             */
            NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
            formatter1.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter1.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter1.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
            
            NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
            formatter2.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter2.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter2.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            
            NSDateFormatter *formatter3 = [[NSDateFormatter alloc] init];
            formatter3.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter3.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter3.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS";
            
            NSDateFormatter *formatter4 = [[NSDateFormatter alloc] init];
            formatter4.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter4.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter4.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
            
            blocks[19] = ^(NSString *string) {
                if ([string characterAtIndex:10] == 'T') {
                    return [formatter1 dateFromString:string];
                } else {
                    return [formatter2 dateFromString:string];
                }
            };
            
            blocks[23] = ^(NSString *string) {
                if ([string characterAtIndex:10] == 'T') {
                    return [formatter3 dateFromString:string];
                } else {
                    return [formatter4 dateFromString:string];
                }
            };
        }
        
        {
            /*
             2014-01-20T12:24:48Z        // Github, Apple
             2014-01-20T12:24:48+0800    // Facebook
             2014-01-20T12:24:48+12:00   // Google
             2014-01-20T12:24:48.000Z
             2014-01-20T12:24:48.000+0800
             2014-01-20T12:24:48.000+12:00
             */
            NSDateFormatter *formatter = [NSDateFormatter new];
            formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
            
            NSDateFormatter *formatter2 = [NSDateFormatter new];
            formatter2.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter2.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZ";
            
            blocks[20] = ^(NSString *string) { return [formatter dateFromString:string]; };
            blocks[24] = ^(NSString *string) { return [formatter dateFromString:string]?: [formatter2 dateFromString:string]; };
            blocks[25] = ^(NSString *string) { return [formatter dateFromString:string]; };
            blocks[28] = ^(NSString *string) { return [formatter2 dateFromString:string]; };
            blocks[29] = ^(NSString *string) { return [formatter2 dateFromString:string]; };
        }
        
        {
            /*
             Fri Sep 04 00:12:21 +0800 2015 // Weibo, Twitter
             Fri Sep 04 00:12:21.000 +0800 2015
             */
            NSDateFormatter *formatter = [NSDateFormatter new];
            formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter.dateFormat = @"EEE MMM dd HH:mm:ss Z yyyy";
            
            NSDateFormatter *formatter2 = [NSDateFormatter new];
            formatter2.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter2.dateFormat = @"EEE MMM dd HH:mm:ss.SSS Z yyyy";
            
            blocks[30] = ^(NSString *string) { return [formatter dateFromString:string]; };
            blocks[34] = ^(NSString *string) { return [formatter2 dateFromString:string]; };
        }
    });
    if (!string) return nil;
    if (string.length > kParserNum) return nil;
    ADSNSDateParseBlock parser = blocks[string.length];
    if (!parser) return nil;
    return parser(string);
#undef kParserNum
}


static force_inline void ADSSetNumberToProperty(__unsafe_unretained id vc,
                                                 __unsafe_unretained id value,
                                                 __unsafe_unretained ADSClassPropertyInfo *propertyInfo) {
    NSNumber *num = ADSNSNumberCreateFromID(value);
    switch (propertyInfo.type & ADSEncodingTypeMask) {
        case ADSEncodingTypeBool: {
            ((void (*)(id, SEL, bool))(void *) objc_msgSend)((id)vc, propertyInfo.setter, num.boolValue);
        } break;
        case ADSEncodingTypeInt8: {
            ((void (*)(id, SEL, int8_t))(void *) objc_msgSend)((id)vc, propertyInfo.setter, (int8_t)num.charValue);
        } break;
        case ADSEncodingTypeUInt8: {
            ((void (*)(id, SEL, uint8_t))(void *) objc_msgSend)((id)vc, propertyInfo.setter, (uint8_t)num.unsignedCharValue);
        } break;
        case ADSEncodingTypeInt16: {
            ((void (*)(id, SEL, int16_t))(void *) objc_msgSend)((id)vc, propertyInfo.setter, (int16_t)num.shortValue);
        } break;
        case ADSEncodingTypeUInt16: {
            ((void (*)(id, SEL, uint16_t))(void *) objc_msgSend)((id)vc, propertyInfo.setter, (uint16_t)num.unsignedShortValue);
        } break;
        case ADSEncodingTypeInt32: {
            ((void (*)(id, SEL, int32_t))(void *) objc_msgSend)((id)vc, propertyInfo.setter, (int32_t)num.intValue);
        }
        case ADSEncodingTypeUInt32: {
            ((void (*)(id, SEL, uint32_t))(void *) objc_msgSend)((id)vc, propertyInfo.setter, (uint32_t)num.unsignedIntValue);
        } break;
        case ADSEncodingTypeInt64: {
            if ([num isKindOfClass:[NSDecimalNumber class]]) {
                ((void (*)(id, SEL, int64_t))(void *) objc_msgSend)((id)vc, propertyInfo.setter, (int64_t)num.stringValue.longLongValue);
            } else {
                ((void (*)(id, SEL, uint64_t))(void *) objc_msgSend)((id)vc, propertyInfo.setter, (uint64_t)num.longLongValue);
            }
        } break;
        case ADSEncodingTypeUInt64: {
            if ([num isKindOfClass:[NSDecimalNumber class]]) {
                ((void (*)(id, SEL, int64_t))(void *) objc_msgSend)((id)vc, propertyInfo.setter, (int64_t)num.stringValue.longLongValue);
            } else {
                ((void (*)(id, SEL, uint64_t))(void *) objc_msgSend)((id)vc, propertyInfo.setter, (uint64_t)num.unsignedLongLongValue);
            }
        } break;
        case ADSEncodingTypeFloat: {
            float f = num.floatValue;
            if (isnan(f) || isinf(f)) f = 0;
            ((void (*)(id, SEL, float))(void *) objc_msgSend)((id)vc, propertyInfo.setter, f);
        } break;
        case ADSEncodingTypeDouble: {
            double d = num.doubleValue;
            if (isnan(d) || isinf(d)) d = 0;
            ((void (*)(id, SEL, double))(void *) objc_msgSend)((id)vc, propertyInfo.setter, d);
        } break;
        case ADSEncodingTypeLongDouble: {
            long double d = num.doubleValue;
            if (isnan(d) || isinf(d)) d = 0;
            ((void (*)(id, SEL, long double))(void *) objc_msgSend)((id)vc, propertyInfo.setter, (long double)d);
        } // break; commented for code coverage in next line
        default: break;
    }
}

static force_inline void ADSSetObjcToProperty(__unsafe_unretained id vc,
                                               __unsafe_unretained id value,
                                               __unsafe_unretained ADSClassPropertyInfo *propertyInfo) {
    ADSEncodingNSType type = ADSClassGetNSType(propertyInfo.cls);
    switch (type) {
        case ADSEncodingTypeNSString:
        case ADSEncodingTypeNSMutableString: {
            if ([value isKindOfClass:[NSString class]]) {
                if (type == ADSEncodingTypeNSString) {
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)vc, propertyInfo.setter, value);
                } else {
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)vc, propertyInfo.setter, ((NSString *)value).mutableCopy);
                }
            } else if ([value isKindOfClass:[NSNumber class]]) {
                ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)vc,
                                                               propertyInfo.setter,
                                                               (type == ADSEncodingTypeNSString) ?
                                                               ((NSNumber *)value).stringValue :
                                                               ((NSNumber *)value).stringValue.mutableCopy);
            } else if ([value isKindOfClass:[NSData class]]) {
                NSMutableString *string = [[NSMutableString alloc] initWithData:value encoding:NSUTF8StringEncoding];
                ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)vc, propertyInfo.setter, string);
            } else if ([value isKindOfClass:[NSURL class]]) {
                ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)vc,
                                                               propertyInfo.setter,
                                                               (type == ADSEncodingTypeNSString) ?
                                                               ((NSURL *)value).absoluteString :
                                                               ((NSURL *)value).absoluteString.mutableCopy);
            } else if ([value isKindOfClass:[NSAttributedString class]]) {
                ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)vc,
                                                               propertyInfo.setter,
                                                               (type == ADSEncodingTypeNSString) ?
                                                               ((NSAttributedString *)value).string :
                                                               ((NSAttributedString *)value).string.mutableCopy);
            }
        } break;
            
        case ADSEncodingTypeNSValue:
        case ADSEncodingTypeNSNumber:
        case ADSEncodingTypeNSDecimalNumber: {
            if (type == ADSEncodingTypeNSNumber) {
                ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)vc, propertyInfo.setter, ADSNSNumberCreateFromID(value));
            } else if (type == ADSEncodingTypeNSDecimalNumber) {
                if ([value isKindOfClass:[NSDecimalNumber class]]) {
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)vc, propertyInfo.setter, value);
                } else if ([value isKindOfClass:[NSNumber class]]) {
                    NSDecimalNumber *decNum = [NSDecimalNumber decimalNumberWithDecimal:[((NSNumber *)value) decimalValue]];
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)vc, propertyInfo.setter, decNum);
                } else if ([value isKindOfClass:[NSString class]]) {
                    NSDecimalNumber *decNum = [NSDecimalNumber decimalNumberWithString:value];
                    NSDecimal dec = decNum.decimalValue;
                    if (dec._length == 0 && dec._isNegative) {
                        decNum = nil; // NaN
                    }
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)vc, propertyInfo.setter, decNum);
                }
            } else {
                if ([value isKindOfClass:[NSValue class]]) {
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)vc, propertyInfo.setter, value);
                }
            }
        } break;
            
        case ADSEncodingTypeNSData:
        case ADSEncodingTypeNSMutableData: {
            if ([value isKindOfClass:[NSData class]]) {
                if (type == ADSEncodingTypeNSData) {
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)vc, propertyInfo.setter, value);
                } else {
                    NSMutableData *data = ((NSData *)value).mutableCopy;
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)vc, propertyInfo.setter, data);
                }
            } else if ([value isKindOfClass:[NSString class]]) {
                NSData *data = [(NSString *)value dataUsingEncoding:NSUTF8StringEncoding];
                if (type == ADSEncodingTypeNSMutableData) {
                    data = ((NSData *)data).mutableCopy;
                }
                ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)vc, propertyInfo.setter, data);
            }
        } break;
            
        case ADSEncodingTypeNSDate: {
            if ([value isKindOfClass:[NSDate class]]) {
                ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)vc, propertyInfo.setter, value);
            } else if ([value isKindOfClass:[NSString class]]) {
                ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)vc, propertyInfo.setter, ADSNSDateFromString(value));
            }
        } break;
            
        case ADSEncodingTypeNSURL: {
            if ([value isKindOfClass:[NSURL class]]) {
                ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)vc, propertyInfo.setter, value);
            } else if ([value isKindOfClass:[NSString class]]) {
                NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
                NSString *str = [value stringByTrimmingCharactersInSet:set];
                if (str.length == 0) {
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)vc, propertyInfo.setter, nil);
                } else {
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)vc, propertyInfo.setter, [[NSURL alloc] initWithString:str]);
                }
            }
        } break;
        default: break;
    }
}

void ADSSetValueToProperty(__unsafe_unretained id vc,
                          __unsafe_unretained id value,
                          __unsafe_unretained ADSClassPropertyInfo *propertyInfo) {
    switch (propertyInfo.type & ADSEncodingTypeMask) {
        case ADSEncodingTypeBool:
        case ADSEncodingTypeInt8:
        case ADSEncodingTypeUInt8:
        case ADSEncodingTypeInt16:
        case ADSEncodingTypeUInt16:
        case ADSEncodingTypeInt32:
        case ADSEncodingTypeUInt32:
        case ADSEncodingTypeInt64:
        case ADSEncodingTypeUInt64:
        case ADSEncodingTypeFloat:
        case ADSEncodingTypeDouble:
        case ADSEncodingTypeLongDouble:
            ADSSetNumberToProperty(vc, value, propertyInfo);
            break;
        case ADSEncodingTypeObject:
            ADSSetObjcToProperty(vc, value, propertyInfo);
            break;
        default:
            break;
    }
}
