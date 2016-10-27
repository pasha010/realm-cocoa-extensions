//
//  RLMObject(RealmExtensions)
//  Pods
// 
//  Created by Pavel Malkov on 27.10.16.
//

@import Foundation;
@import Realm.RLMObject;

NS_ASSUME_NONNULL_BEGIN

@protocol RLMObjectJSONProcessing <NSObject>
@optional

/**
 * Calling before json dictionary processing
 * @param jsonDictionary - initial json dictionary
 * @return json dictionary for JSON mapping
 */
+ (nullable NSDictionary<NSString *, id> *)preprocessedJSON:(nonnull NSDictionary<NSString *, id> *)jsonDictionary;

/**
 * JSON => RLMObject
 * @return dictionary where key is JSON property name, value is RLMObject property name
 */
+ (nonnull NSDictionary<NSString *, id> *)JSONInboundMappingDictionary;

/**
 * @param propertyName - name of property
 * @return value transformer for property
 */
+ (nonnull NSValueTransformer *)JSONTransformerForProperty:(nonnull NSString *)propertyName;

/**
 * RLMObject => JSON
 * @return dictionary where key is value of realm object and value is json property name
 */
+ (nonnull NSDictionary<NSString *, id> *)JSONOutboundMappingDictionary;

@end

@interface RLMObject (RealmExtensions) <RLMObjectJSONProcessing>

#pragma mark - copying

- (nonnull instancetype)deepCopy;

#pragma mark - JSON mapping

- (nonnull instancetype)initWithJSONDictionary:(nonnull NSDictionary<NSString *, id> *)dictionary;

- (nullable  NSDictionary<NSString *, id> *)JSONDictionary;

@end

NS_ASSUME_NONNULL_END