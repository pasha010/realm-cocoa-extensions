//
//  RLMArray(RealmExtensions)
//  Pods
// 
//  Created by Pavel Malkov on 27.10.16.
//

#import "RLMArray+RealmExtensions.h"
#import "RLMObject+RealmExtensions.h"

@implementation RLMArray (RealmExtensions)

- (nonnull NSArray<RLMObject *> *)toNSArray {
    NSMutableArray<RLMObject *> *array = [NSMutableArray arrayWithCapacity:self.count];
    for (RLMObject *object in self) {
        [array addObject:[object deepCopy]];
    }
    return [array copy];
}

@end