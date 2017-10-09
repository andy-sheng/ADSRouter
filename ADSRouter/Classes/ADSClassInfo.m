//
//  ASClassInfo.m
//  ASRouter
//
//  Created by Andy on 2017/10/3.
//

#import "ADSClassInfo.h"

ADSEncodingType ADSEncodingGetType(const char *typeEncoding) {
    char *type = (char *)typeEncoding;
    if (!type) return ADSEncodingTypeUnknown;
    size_t len = strlen(type);
    if (len == 0) return ADSEncodingTypeUnknown;
    
    ADSEncodingType qualifier = 0;
    bool prefix = true;
    while (prefix) {
        switch (*type) {
            case 'r': {
                qualifier |= ADSEncodingTypeQualifierConst;
                type++;
            } break;
            case 'n': {
                qualifier |= ADSEncodingTypeQualifierIn;
                type++;
            } break;
            case 'N': {
                qualifier |= ADSEncodingTypeQualifierInout;
                type++;
            } break;
            case 'o': {
                qualifier |= ADSEncodingTypeQualifierOut;
                type++;
            } break;
            case 'O': {
                qualifier |= ADSEncodingTypeQualifierBycopy;
                type++;
            } break;
            case 'R': {
                qualifier |= ADSEncodingTypeQualifierByref;
                type++;
            } break;
            case 'V': {
                qualifier |= ADSEncodingTypeQualifierOneway;
                type++;
            } break;
            default: { prefix = false; } break;
        }
    }
    
    len = strlen(type);
    if (len == 0) return ADSEncodingTypeUnknown | qualifier;
    
    switch (*type) {
        case 'v': return ADSEncodingTypeVoid | qualifier;
        case 'B': return ADSEncodingTypeBool | qualifier;
        case 'c': return ADSEncodingTypeInt8 | qualifier;
        case 'C': return ADSEncodingTypeUInt8 | qualifier;
        case 's': return ADSEncodingTypeInt16 | qualifier;
        case 'S': return ADSEncodingTypeUInt16 | qualifier;
        case 'i': return ADSEncodingTypeInt32 | qualifier;
        case 'I': return ADSEncodingTypeUInt32 | qualifier;
        case 'l': return ADSEncodingTypeInt32 | qualifier;
        case 'L': return ADSEncodingTypeUInt32 | qualifier;
        case 'q': return ADSEncodingTypeInt64 | qualifier;
        case 'Q': return ADSEncodingTypeUInt64 | qualifier;
        case 'f': return ADSEncodingTypeFloat | qualifier;
        case 'd': return ADSEncodingTypeDouble | qualifier;
        case 'D': return ADSEncodingTypeLongDouble | qualifier;
        case '#': return ADSEncodingTypeClass | qualifier;
        case ':': return ADSEncodingTypeSEL | qualifier;
        case '*': return ADSEncodingTypeCString | qualifier;
        case '^': return ADSEncodingTypePointer | qualifier;
        case '[': return ADSEncodingTypeCArray | qualifier;
        case '(': return ADSEncodingTypeUnion | qualifier;
        case '{': return ADSEncodingTypeStruct | qualifier;
        case '@': {
            if (len == 2 && *(type + 1) == '?')
                return ADSEncodingTypeBlock | qualifier;
            else
                return ADSEncodingTypeObject | qualifier;
        }
        default: return ADSEncodingTypeUnknown | qualifier;
    }
}

@implementation ADSClassIvarInfo

- (instancetype)initWithIvar:(Ivar)ivar {
    if (!ivar) return nil;
    self = [super init];
    _ivar = ivar;
    const char *name = ivar_getName(ivar);
    if (name) {
        _name = [NSString stringWithUTF8String:name];
    }
    _offset = ivar_getOffset(ivar);
    const char *typeEncoding = ivar_getTypeEncoding(ivar);
    if (typeEncoding) {
        _typeEncoding = [NSString stringWithUTF8String:typeEncoding];
        _type = ADSEncodingGetType(typeEncoding);
    }
    return self;
}

@end

@implementation ADSClassPropertyInfo

- (instancetype)initWithProperty:(objc_property_t)property {
    if (!property) return nil;
    self = [super init];
    _property = property;
    const char *name = property_getName(property);
    if (name) {
        _name = [NSString stringWithUTF8String:name];
    }
    
    ADSEncodingType type = 0;
    unsigned int attrCount;
    objc_property_attribute_t *attrs = property_copyAttributeList(property, &attrCount);
    for (unsigned int i = 0; i < attrCount; i++) {
        switch (attrs[i].name[0]) {
            case 'T': { // Type encoding
                if (attrs[i].value) {
                    _typeEncoding = [NSString stringWithUTF8String:attrs[i].value];
                    type = ADSEncodingGetType(attrs[i].value);
                    
                    if ((type & ADSEncodingTypeMask) == ADSEncodingTypeObject && _typeEncoding.length) {
                        NSScanner *scanner = [NSScanner scannerWithString:_typeEncoding];
                        if (![scanner scanString:@"@\"" intoString:NULL]) continue;
                        
                        NSString *clsName = nil;
                        if ([scanner scanUpToCharactersFromSet: [NSCharacterSet characterSetWithCharactersInString:@"\"<"] intoString:&clsName]) {
                            if (clsName.length) _cls = objc_getClass(clsName.UTF8String);
                        }
                        
                        NSMutableArray *protocols = nil;
                        while ([scanner scanString:@"<" intoString:NULL]) {
                            NSString* protocol = nil;
                            if ([scanner scanUpToString:@">" intoString: &protocol]) {
                                if (protocol.length) {
                                    if (!protocols) protocols = [NSMutableArray new];
                                    [protocols addObject:protocol];
                                }
                            }
                            [scanner scanString:@">" intoString:NULL];
                        }
                        _protocols = protocols;
                    }
                }
            } break;
            case 'V': { // Instance variable
                if (attrs[i].value) {
                    _ivarName = [NSString stringWithUTF8String:attrs[i].value];
                }
            } break;
            case 'R': {
                type |= ADSEncodingTypePropertyReadonly;
            } break;
            case 'C': {
                type |= ADSEncodingTypePropertyCopy;
            } break;
            case '&': {
                type |= ADSEncodingTypePropertyRetain;
            } break;
            case 'N': {
                type |= ADSEncodingTypePropertyNonatomic;
            } break;
            case 'D': {
                type |= ADSEncodingTypePropertyDynamic;
            } break;
            case 'W': {
                type |= ADSEncodingTypePropertyWeak;
            } break;
            case 'G': {
                type |= ADSEncodingTypePropertyCustomGetter;
                if (attrs[i].value) {
                    _getter = NSSelectorFromString([NSString stringWithUTF8String:attrs[i].value]);
                }
            } break;
            case 'S': {
                type |= ADSEncodingTypePropertyCustomSetter;
                if (attrs[i].value) {
                    _setter = NSSelectorFromString([NSString stringWithUTF8String:attrs[i].value]);
                }
            } // break; commented for code coverage in next line
            default: break;
        }
    }
    if (attrs) {
        free(attrs);
        attrs = NULL;
    }
    
    _type = type;
    if (_name.length) {
        if (!_getter) {
            _getter = NSSelectorFromString(_name);
        }
        if (!_setter) {
            _setter = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", [_name substringToIndex:1].uppercaseString, [_name substringFromIndex:1]]);
        }
    }
    return self;
}

@end

@implementation ADSClassInfo {
    BOOL _needUpdate;
}

- (instancetype)initWithClass:(Class)cls {
    if (!cls) return nil;
    self = [super init];
    _cls = cls;
    _superCls = class_getSuperclass(cls);
    _isMeta = class_isMetaClass(cls);
    if (!_isMeta) {
        _metaCls = objc_getMetaClass(class_getName(cls));
    }
    _name = NSStringFromClass(cls);
    [self _update];
    
    _superClassInfo = [self.class classInfoWithClass:_superCls];
    return self;
}

- (void)_update {
    _ivarInfos = nil;
    _methodInfos = nil;
    _propertyInfos = nil;
    
    Class cls = self.cls;
//    unsigned int methodCount = 0;
//    Method *methods = class_copyMethodList(cls, &methodCount);
//    if (methods) {
//        NSMutableDictionary *methodInfos = [NSMutableDictionary new];
//        _methodInfos = methodInfos;
//        for (unsigned int i = 0; i < methodCount; i++) {
//            ASClassMethodInfo *info = [[ASClassMethodInfo alloc] initWithMethod:methods[i]];
//            if (info.name) methodInfos[info.name] = info;
//        }
//        free(methods);
//    }
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList(cls, &propertyCount);
    if (properties) {
        NSMutableDictionary *propertyInfos = [NSMutableDictionary new];
        _propertyInfos = propertyInfos;
        for (unsigned int i = 0; i < propertyCount; i++) {
            ADSClassPropertyInfo *info = [[ADSClassPropertyInfo alloc] initWithProperty:properties[i]];
            if (info.name) propertyInfos[info.name] = info;
        }
        free(properties);
    }
    
    unsigned int ivarCount = 0;
    Ivar *ivars = class_copyIvarList(cls, &ivarCount);
    if (ivars) {
        NSMutableDictionary *ivarInfos = [NSMutableDictionary new];
        _ivarInfos = ivarInfos;
        for (unsigned int i = 0; i < ivarCount; i++) {
            ADSClassIvarInfo *info = [[ADSClassIvarInfo alloc] initWithIvar:ivars[i]];
            if (info.name) ivarInfos[info.name] = info;
        }
        free(ivars);
    }
    
    if (!_ivarInfos) _ivarInfos = @{};
    if (!_methodInfos) _methodInfos = @{};
    if (!_propertyInfos) _propertyInfos = @{};
    
    _needUpdate = NO;
}

- (void)setNeedUpdate {
    _needUpdate = YES;
}

- (BOOL)needUpdate {
    return _needUpdate;
}

+ (instancetype)classInfoWithClass:(Class)cls {
    if (!cls) return nil;
    static CFMutableDictionaryRef classCache;
    static CFMutableDictionaryRef metaCache;
    static dispatch_once_t onceToken;
    static dispatch_semaphore_t lock;
    dispatch_once(&onceToken, ^{
        classCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        metaCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        lock = dispatch_semaphore_create(1);
    });
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    ADSClassInfo *info = CFDictionaryGetValue(class_isMetaClass(cls) ? metaCache : classCache, (__bridge const void *)(cls));
    if (info && info->_needUpdate) {
        [info _update];
    }
    dispatch_semaphore_signal(lock);
    if (!info) {
        info = [[ADSClassInfo alloc] initWithClass:cls];
        if (info) {
            dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
            CFDictionarySetValue(info.isMeta ? metaCache : classCache, (__bridge const void *)(cls), (__bridge const void *)(info));
            dispatch_semaphore_signal(lock);
        }
    }
    return info;
}

+ (instancetype)classInfoWithClassName:(NSString *)className {
    Class cls = NSClassFromString(className);
    return [self classInfoWithClass:cls];
}

@end
