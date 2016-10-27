//
//  PMTestModel
//  realm-cocoa-extensions
// 
//  Created by Pavel Malkov on 27.10.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Realm;
@import RealmExtensions.RLMObject_RealmExtensions;

NS_ASSUME_NONNULL_BEGIN

@interface PMTestModel : RLMObject

@property NSString *name;
@property NSString *info;
@property NSNumber <RLMInt> *id;

@end

NS_ASSUME_NONNULL_END