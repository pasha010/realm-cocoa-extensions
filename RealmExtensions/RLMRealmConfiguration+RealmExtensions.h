//
//  RLMRealmConfiguration+RealmExtensions.h
//  RealmExtensions
//
//  Created by Pavel Malkov on 27.10.16.
//
//

@import Realm.RLMRealmConfiguration;

NS_ASSUME_NONNULL_BEGIN

@interface RLMRealmConfiguration (RealmExtensions)

@property (nullable, nonatomic, copy) NSString *fileName;

@end

NS_ASSUME_NONNULL_END
