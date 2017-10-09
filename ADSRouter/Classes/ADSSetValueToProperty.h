//
//  ASSetValueToProperty.h
//  Pods
//
//  Created by Andy on 2017/10/9.
//

#ifndef ASSetValueToProperty_h
#define ASSetValueToProperty_h

@class ADSClassPropertyInfo;

/// Foundation Class Type
typedef NS_ENUM (NSUInteger, ADSEncodingNSType) {
    ADSEncodingTypeNSUnknown = 0,
    ADSEncodingTypeNSString,
    ADSEncodingTypeNSMutableString,
    ADSEncodingTypeNSValue,
    ADSEncodingTypeNSNumber,
    ADSEncodingTypeNSDecimalNumber,
    ADSEncodingTypeNSData,
    ADSEncodingTypeNSMutableData,
    ADSEncodingTypeNSDate,
    ADSEncodingTypeNSURL,
//    ASEncodingTypeNSArray,
//    ASEncodingTypeNSMutableArray,
//    ASEncodingTypeNSDictionary,
//    ASEncodingTypeNSMutableDictionary,
//    ASEncodingTypeNSSet,
//    ASEncodingTypeNSMutableSet,
};

 void ADSSetValueToProperty(__unsafe_unretained id vc,
                           __unsafe_unretained id value,
                           __unsafe_unretained ADSClassPropertyInfo *propertyInfo);

#endif /* ADSSetValueToProperty_h */
