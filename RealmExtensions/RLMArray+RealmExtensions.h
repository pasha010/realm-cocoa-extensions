//
//  RLMArray(RealmExtensions)
//  Pods
// 
//  Created by Pavel Malkov on 27.10.16.
//

@import Foundation;
@import Realm.RLMArray;

NS_ASSUME_NONNULL_BEGIN

@interface RLMArray<RLMObjectType: RLMObject *> (RealmExtensions)

/**
 * @return NSArray with deep copies of realm objects
 */
- (nonnull NSArray<RLMObjectType> *)toNSArray;

@end

NS_ASSUME_NONNULL_END