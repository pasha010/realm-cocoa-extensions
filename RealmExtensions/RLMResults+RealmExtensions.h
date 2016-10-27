//
//  RLMResults(RealmExtensions)
//  RealmExtensions
// 
//  Created by Pavel Malkov on 27.10.16.
//

@import Foundation;
@import Realm.RLMResults;

NS_ASSUME_NONNULL_BEGIN

@interface RLMResults<RLMObjectType: RLMObject *>  (RealmExtensions)

- (nonnull NSArray<RLMObjectType> *)deepCopy;


@end

NS_ASSUME_NONNULL_END