//
//  RLMResults(RealmExtensions)
//  RealmExtensions
// 
//  Created by Pavel Malkov on 27.10.16.
//

#import "RLMResults+RealmExtensions.h"
#import "RLMObject+RealmExtensions.h"

@implementation RLMResults (RealmExtensions)

- (nonnull NSArray<RLMObject *> *)deepCopy {
    NSMutableArray<RLMObject *> *objects = [NSMutableArray arrayWithCapacity:self.count];
    for (RLMObject *object in self) {
        [objects addObject:[object deepCopy]];
    }
    return [objects copy];
}

@end