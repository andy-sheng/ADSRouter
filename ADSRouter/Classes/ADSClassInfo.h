//
//  ADSClassInfo.h
//  ADSRouter
//
//  Created by Andy on 2017/10/3.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Type encoding's type.
 */
typedef NS_OPTIONS(NSUInteger, ADSEncodingType) {
    ADSEncodingTypeMask       = 0xFF, ///< mask of type value
    ADSEncodingTypeUnknown    = 0, ///< unknown
    ADSEncodingTypeVoid       = 1, ///< void
    ADSEncodingTypeBool       = 2, ///< bool
    ADSEncodingTypeInt8       = 3, ///< char / BOOL
    ADSEncodingTypeUInt8      = 4, ///< unsigned char
    ADSEncodingTypeInt16      = 5, ///< short
    ADSEncodingTypeUInt16     = 6, ///< unsigned short
    ADSEncodingTypeInt32      = 7, ///< int
    ADSEncodingTypeUInt32     = 8, ///< unsigned int
    ADSEncodingTypeInt64      = 9, ///< long long
    ADSEncodingTypeUInt64     = 10, ///< unsigned long long
    ADSEncodingTypeFloat      = 11, ///< float
    ADSEncodingTypeDouble     = 12, ///< double
    ADSEncodingTypeLongDouble = 13, ///< long double
    ADSEncodingTypeObject     = 14, ///< id
    ADSEncodingTypeClass      = 15, ///< Class
    ADSEncodingTypeSEL        = 16, ///< SEL
    ADSEncodingTypeBlock      = 17, ///< block
    ADSEncodingTypePointer    = 18, ///< void*
    ADSEncodingTypeStruct     = 19, ///< struct
    ADSEncodingTypeUnion      = 20, ///< union
    ADSEncodingTypeCString    = 21, ///< char*
    ADSEncodingTypeCArray     = 22, ///< char[10] (for example)
    
    ADSEncodingTypeQualifierMask   = 0xFF00,   ///< mask of qualifier
    ADSEncodingTypeQualifierConst  = 1 << 8,  ///< const
    ADSEncodingTypeQualifierIn     = 1 << 9,  ///< in
    ADSEncodingTypeQualifierInout  = 1 << 10, ///< inout
    ADSEncodingTypeQualifierOut    = 1 << 11, ///< out
    ADSEncodingTypeQualifierBycopy = 1 << 12, ///< bycopy
    ADSEncodingTypeQualifierByref  = 1 << 13, ///< byref
    ADSEncodingTypeQualifierOneway = 1 << 14, ///< oneway
    
    ADSEncodingTypePropertyMask         = 0xFF0000, ///< mask of property
    ADSEncodingTypePropertyReadonly     = 1 << 16, ///< readonly
    ADSEncodingTypePropertyCopy         = 1 << 17, ///< copy
    ADSEncodingTypePropertyRetain       = 1 << 18, ///< retain
    ADSEncodingTypePropertyNonatomic    = 1 << 19, ///< nonatomic
    ADSEncodingTypePropertyWeak         = 1 << 20, ///< weak
    ADSEncodingTypePropertyCustomGetter = 1 << 21, ///< getter=
    ADSEncodingTypePropertyCustomSetter = 1 << 22, ///< setter=
    ADSEncodingTypePropertyDynamic      = 1 << 23, ///< @dynamic
};

/**
 Instance variable information.
 */
@interface ADSClassIvarInfo : NSObject
@property (nonatomic, assign, readonly) Ivar ivar;              ///< ivar opaque struct
@property (nonatomic, strong, readonly) NSString *name;         ///< Ivar's name
@property (nonatomic, assign, readonly) ptrdiff_t offset;       ///< Ivar's offset
@property (nonatomic, strong, readonly) NSString *typeEncoding; ///< Ivar's type encoding
@property (nonatomic, assign, readonly) ADSEncodingType type;    ///< Ivar's type

/**
 Creates and returns an ivar info object.
 
 @param ivar ivar opaque struct
 @return A new object, or nil if an error occurs.
 */
- (instancetype)initWithIvar:(Ivar)ivar;
@end

/**
 Method information.
 */
@interface ADSClassMethodInfo : NSObject
@property (nonatomic, assign, readonly) Method method;                  ///< method opaque struct
@property (nonatomic, strong, readonly) NSString *name;                 ///< method name
@property (nonatomic, assign, readonly) SEL sel;                        ///< method's selector
@property (nonatomic, assign, readonly) IMP imp;                        ///< method's implementation
@property (nonatomic, strong, readonly) NSString *typeEncoding;         ///< method's parameter and return types
@property (nonatomic, strong, readonly) NSString *returnTypeEncoding;   ///< return value's type
@property (nullable, nonatomic, strong, readonly) NSArray<NSString *> *argumentTypeEncodings; ///< array of arguments' type

/**
 Creates and returns a method info object.
 
 @param method method opaque struct
 @return A new object, or nil if an error occurs.
 */
- (instancetype)initWithMethod:(Method)method;
@end

/**
 Property information.
 */
@interface ADSClassPropertyInfo : NSObject
@property (nonatomic, assign, readonly) objc_property_t property; ///< property's opaque struct
@property (nonatomic, strong, readonly) NSString *name;           ///< property's name
@property (nonatomic, assign, readonly) ADSEncodingType type;      ///< property's type
@property (nonatomic, strong, readonly) NSString *typeEncoding;   ///< property's encoding value
@property (nonatomic, strong, readonly) NSString *ivarName;       ///< property's ivar name
@property (nullable, nonatomic, assign, readonly) Class cls;      ///< may be nil
@property (nullable, nonatomic, strong, readonly) NSArray<NSString *> *protocols; ///< may nil
@property (nonatomic, assign, readonly) SEL getter;               ///< getter (nonnull)
@property (nonatomic, assign, readonly) SEL setter;               ///< setter (nonnull)

/**
 Creates and returns a property info object.
 
 @param property property opaque struct
 @return A new object, or nil if an error occurs.
 */
- (instancetype)initWithProperty:(objc_property_t)property;
@end

@interface ADSClassInfo : NSObject
@property (nonatomic, assign, readonly) Class cls; ///< class object
@property (nullable, nonatomic, assign, readonly) Class superCls; ///< super class object
@property (nullable, nonatomic, assign, readonly) Class metaCls;  ///< class's meta class object
@property (nonatomic, readonly) BOOL isMeta; ///< whether this class is meta class
@property (nonatomic, strong, readonly) NSString *name; ///< class name
@property (nullable, nonatomic, strong, readonly) ADSClassInfo *superClassInfo; ///< super class's class info
@property (nullable, nonatomic, strong, readonly) NSDictionary<NSString *, ADSClassIvarInfo *> *ivarInfos; ///< ivars
@property (nullable, nonatomic, strong, readonly) NSDictionary<NSString *, ADSClassMethodInfo *> *methodInfos; ///< methods
@property (nullable, nonatomic, strong, readonly) NSDictionary<NSString *, ADSClassPropertyInfo *> *propertyInfos; ///< properties

/**
 If the class is changed (for example: you add a method to this class with
 'class_addMethod()'), you should call this methodpro to refresh the class info cache.
 
 After called this method, `needUpdate` will returns `YES`, and you should call
 'classInfoWithClass' or 'classInfoWithClassName' to get the updated class info.
 */
- (void)setNeedUpdate;

/**
 If this method returns `YES`, you should stop using this instance and call
 `classInfoWithClass` or `classInfoWithClassName` to get the updated class info.
 
 @return Whether this class info need update.
 */
- (BOOL)needUpdate;

/**
 Get the class info of a specified Class.
 
 @discussion This method will cache the class info and super-class info
 at the first access to the Class. This method is thread-safe.
 
 @param cls A class.
 @return A class info, or nil if an error occurs.
 */
+ (nullable instancetype)classInfoWithClass:(Class)cls;

/**
 Get the class info of a specified Class.
 
 @discussion This method will cache the class info and super-class info
 at the first access to the Class. This method is thread-safe.
 
 @param className A class name.
 @return A class info, or nil if an error occurs.
 */
+ (nullable instancetype)classInfoWithClassName:(NSString *)className;

@end

NS_ASSUME_NONNULL_END
