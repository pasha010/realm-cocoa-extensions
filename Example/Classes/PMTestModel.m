//
//  PMTestModel
//  realm-cocoa-extensions
// 
//  Created by Pavel Malkov on 27.10.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "PMTestModel.h"


@implementation PMTestModel

+ (NSString *)primaryKey {
    return NSStringFromSelector(@selector(id));
}

+ (NSDictionary<NSString *, id> *)preprocessedJSON:(NSDictionary<NSString *, id> *)jsonDictionary {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    return jsonDictionary;
}

+ (NSDictionary<NSString *, id> *)JSONInboundMappingDictionary {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    return @{
            @"json_name": NSStringFromSelector(@selector(name)),
            @"json_info": NSStringFromSelector(@selector(info)),
            @"json_id": NSStringFromSelector(@selector(id)),
    };
}

+ (NSValueTransformer *)JSONTransformerForProperty:(NSString *)propertyName {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    return nil;
}

+ (NSDictionary<NSString *, id> *)JSONOutboundMappingDictionary {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    return @{
            NSStringFromSelector(@selector(name)): @"json_name",
            NSStringFromSelector(@selector(info)): @"json_info",
            NSStringFromSelector(@selector(id)): @"json_id",
    };
}


@end