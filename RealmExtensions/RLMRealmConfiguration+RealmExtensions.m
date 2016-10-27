//
//  RLMRealmConfiguration+RealmExtensions.m
//  RealmExtensions
//
//  Created by Pavel Malkov on 27.10.16.
//
//

#import "RLMRealmConfiguration+RealmExtensions.h"

@implementation RLMRealmConfiguration (RealmExtensions)

- (nullable NSString *)fileName {
    return [self.fileURL lastPathComponent];
}

- (void)setFileName:(nullable NSString *)fileName {
    if (fileName.length == 0) {
        return;
    }
    self.fileURL = [[[self.fileURL URLByDeletingLastPathComponent]
            URLByAppendingPathComponent:fileName]
            URLByAppendingPathExtension:@"realm"];
}

@end
