//
//  RLMObject(RealmExtensions)
//  Pods
// 
//  Created by Pavel Malkov on 27.10.16.
//

#import "RLMObject+RealmExtensions.h"
@import Realm;
#import <objc/runtime.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

@interface RLMSchema ()

+ (nullable Class)classForString:(NSString *)className;

@end

@interface RLMObject (RealmExtensionsJSONInternal)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

+ (RLMObjectSchema *)sharedSchema;
#pragma clang diagnostic pop

@end

static NSString *MCTypeStringFromPropertyKey(Class class, NSString *key) {
    const objc_property_t property = class_getProperty(class, [key UTF8String]);
    if (!property) {
        [NSException raise:NSInternalInconsistencyException format:@"Class %@ does not have property %@", class, key];
    }
    const char *type = property_getAttributes(property);
    return [NSString stringWithUTF8String:type];
}

@interface NSString (RealmExtensions)

- (nonnull NSString *)camelToSnakeCase;

@end

@implementation RLMObject (RealmExtensions)

#pragma mark - copying

- (nonnull instancetype)deepCopy {
    RLMObject *object = (RLMObject *) [[NSClassFromString(self.objectSchema.className) alloc] init];

    for (RLMProperty *property in self.objectSchema.properties) {
        if (property.type == RLMPropertyTypeArray) {
            RLMArray *thisArray = [self valueForKeyPath:property.name];
            RLMArray *newArray = [object valueForKeyPath:property.name];

            for (RLMObject *currentObject in thisArray) {
                [newArray addObject:[currentObject deepCopy]];
            }
        } else if (property.type == RLMPropertyTypeObject) {
            RLMObject *value = [self valueForKeyPath:property.name];
            [object setValue:[value deepCopy] forKeyPath:property.name];
        } else {
            id value = [self valueForKeyPath:property.name];
            [object setValue:value forKeyPath:property.name];
        }
    }

    return object;
}

#pragma mark - JSON mapping

- (nonnull instancetype)initWithJSONDictionary:(nonnull NSDictionary<NSString *, id> *)dictionary {
    return [self initWithValue:[[self class] _createObjectFromJSONDictionary:dictionary]];
}

- (nullable NSDictionary<NSString *, id> *)JSONDictionary {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSDictionary *mapping = [[self class] _outboundMapping];

    for (NSString *objectKeyPath in mapping) {
        NSString *dictionaryKeyPath = mapping[objectKeyPath];

        id value = [self valueForKeyPath:objectKeyPath];
        if (value) {
            Class propertyClass = [[self class] _classForPropertyKey:objectKeyPath];

            NSValueTransformer *transformer = [[self class] _transformerForPropertyKey:objectKeyPath];
            if (transformer) {
                value = [transformer reverseTransformedValue:value];
            }
            else if ([propertyClass isSubclassOfClass:[RLMObject class]]) {
                value = [value JSONDictionary];
            }
            else if ([propertyClass isSubclassOfClass:[RLMArray class]]) {
                NSMutableArray *array = [NSMutableArray array];
                for (RLMObject *item in (RLMArray *) value) {
                    [array addObject:[item JSONDictionary]];
                }
                value = [array copy];
            }

            if ([dictionaryKeyPath isEqualToString:@"self"]) {
                return value;
            }

            NSArray *keyPathComponents = [dictionaryKeyPath componentsSeparatedByString:@"."];
            id currentDictionary = result;
            for (NSString *component in keyPathComponents) {
                if ([currentDictionary valueForKey:component] == nil) {
                    [currentDictionary setValue:[NSMutableDictionary dictionary] forKey:component];
                }
                currentDictionary = [currentDictionary valueForKey:component];
            }

            [result setValue:value forKeyPath:dictionaryKeyPath];
        } else {
            [result setValue:[NSNull null] forKeyPath:dictionaryKeyPath];
        }
    }

    return [result copy];
}

#pragma clang diagnostic push
#pragma ide diagnostic ignored "OCDFAInspection"

+ (nonnull id)_createObjectFromJSONDictionary:(nonnull NSDictionary<NSString *, id> *)origDict {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSDictionary *mapping = [[self class] _inboundMapping];

    NSDictionary *dictionary;
    SEL preprocessingSel = @selector(preprocessedJSON:);
    if ([self respondsToSelector:preprocessingSel]) {
        dictionary = [self performSelector:preprocessingSel withObject:origDict];
    } else {
        dictionary = origDict;
    }

    for (NSString *dictionaryKeyPath in mapping) {
        NSString *objectKeyPath = mapping[dictionaryKeyPath];

        id value = [dictionary valueForKeyPath:dictionaryKeyPath];

        if (value) {
            Class propertyClass = [[self class] _classForPropertyKey:objectKeyPath];

            NSValueTransformer *transformer = [[self class] _transformerForPropertyKey:objectKeyPath];
            if (transformer) {
                value = [transformer transformedValue:value];
            } else if ([propertyClass isSubclassOfClass:[RLMObject class]]) {
                if ([value isEqual:[NSNull null]]) {
                    continue;
                }

                if ([value isKindOfClass:[NSDictionary class]]) {
                    value = [propertyClass _createObjectFromJSONDictionary:value];
                }
            } else if ([propertyClass isSubclassOfClass:[RLMArray class]]) {
                RLMProperty *property = [self _realmPropertyForPropertyKey:objectKeyPath];
                Class elementClass = [RLMSchema classForString:property.objectClassName];

                NSMutableArray *array = [NSMutableArray array];
                for (id item in(NSArray *) value) {
                    [array addObject:[elementClass _createObjectFromJSONDictionary:item]];
                }
                value = [array copy];
            }

            if ([objectKeyPath isEqualToString:@"self"]) {
                return value;
            }

            NSArray *keyPathComponents = [objectKeyPath componentsSeparatedByString:@"."];
            id currentDictionary = result;
            for (NSString *component in keyPathComponents) {
                if ([currentDictionary valueForKey:component] == nil) {
                    [currentDictionary setValue:[NSMutableDictionary dictionary] forKey:component];
                }
                currentDictionary = [currentDictionary valueForKey:component];
            }

            value = value ?: [NSNull null];
            [result setValue:value forKeyPath:objectKeyPath];
        }
    }

    return [result copy];
}

#pragma clang diagnostic pop

+ (nullable RLMProperty *)_realmPropertyForPropertyKey:(nullable NSString *)key {
    if (key.length == 0) {
        return nil;
    }
    RLMObjectSchema *schema = [self sharedSchema];
    for (RLMProperty *property in schema.properties) {
        if ([property.name isEqualToString:key]) {
            return property;
        }
    }
    return nil;
}

+ (nullable Class)_classForPropertyKey:(NSString *)key {
    NSString *attributes = MCTypeStringFromPropertyKey(self, key);
    if ([attributes hasPrefix:@"T@"]) {
        static NSCharacterSet *set = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            set = [NSCharacterSet characterSetWithCharactersInString:@"\"<"];
        });

        @synchronized (set) {
            NSString *string;
            NSScanner *scanner = [NSScanner scannerWithString:attributes];
            scanner.charactersToBeSkipped = set;
            [scanner scanUpToCharactersFromSet:set intoString:NULL];
            [scanner scanUpToCharactersFromSet:set intoString:&string];
            return NSClassFromString(string);
        }
    }
    return nil;
}

+ (nullable NSValueTransformer *)_transformerForPropertyKey:(nonnull NSString *)propertyName {
    if (propertyName.length == 0) {
        return nil;
    }
    SEL selector = @selector(JSONTransformerForProperty:);

    NSValueTransformer *transformer = nil;
    if ([self respondsToSelector:selector]) {
        transformer = [self performSelector:selector withObject:propertyName];
    }

    return transformer;
}

+ (nonnull NSDictionary<NSString *, id> *)_inboundMapping {
    static NSMutableDictionary *mappingForClassName = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mappingForClassName = [NSMutableDictionary dictionary];
    });
    @synchronized (mappingForClassName) {
        NSDictionary<NSString *, id> *mapping = mappingForClassName[[self className]];
        if (!mapping) {
            SEL selector = @selector(JSONInboundMappingDictionary);
            if ([self respondsToSelector:selector]) {
                mapping = [self performSelector:selector];
            } else {
                mapping = [self _defaultInboundMapping];
            }
            mappingForClassName[[self className]] = mapping;
        }
        return mapping;
    }
}

+ (NSDictionary *)_outboundMapping {
    static NSMutableDictionary *mappingForClassName = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mappingForClassName = [NSMutableDictionary dictionary];
    });

    @synchronized(mappingForClassName) {
        NSDictionary *mapping = mappingForClassName[[self className]];
        if (!mapping) {
            SEL selector = @selector(JSONOutboundMappingDictionary);
            if ([self respondsToSelector:selector]) {
                mapping = [self performSelector:selector];
            }
            else {
                mapping = [self _defaultOutboundMapping];
            }
            mappingForClassName[[self className]] = mapping;
        }
        return mapping;
    }
}

+ (NSDictionary *)_defaultInboundMapping {
    RLMObjectSchema *schema = [self sharedSchema];
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    for (RLMProperty *property in schema.properties) {
        result[[property.name camelToSnakeCase]] = property.name;

    }
    return [result copy];
}

+ (NSDictionary *)_defaultOutboundMapping {
    RLMObjectSchema *schema = [self sharedSchema];
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    for (RLMProperty *property in schema.properties) {
        result[property.name] = [property.name camelToSnakeCase];

    }
    return [result copy];
}

@end

@implementation NSString (RealmExtensions)

- (nonnull NSString *)camelToSnakeCase {
    NSScanner *scanner = [NSScanner scannerWithString:self];
    NSCharacterSet *uppercaseSet = [NSCharacterSet uppercaseLetterCharacterSet];
    scanner.charactersToBeSkipped = uppercaseSet;

    NSMutableString *result = [NSMutableString string];
    NSString *buffer = nil;

    while (![scanner isAtEnd]) {
        [scanner scanUpToCharactersFromSet:uppercaseSet intoString:&buffer];
        [result appendString:[buffer lowercaseString]];

        if (![scanner isAtEnd]) {
            [result appendString:@"_"];
            [result appendString:[[self substringWithRange:NSMakeRange(scanner.scanLocation, 1)] lowercaseString]];
        }
    }

    return result;
}

@end

#pragma clang diagnostic pop