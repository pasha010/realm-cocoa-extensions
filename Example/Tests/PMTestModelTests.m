//
//  PMTestModelTests.m
//  realm-cocoa-extensions
//
//  Created by Pavel Malkov on 27.10.16.
//  Copyright © 2016 Pavel Malkov. All rights reserved.
//

#import <XCTest/XCTest.h>
@import RealmExtensions;
#import "PMTestModel.h"

@interface PMTestModelTests : XCTestCase
@end

@implementation PMTestModelTests

- (void)testFromJSONToRealm {
    NSDictionary<NSString *, id> *jsonDictionary = @{
            @"json_name": @"John",
            @"json_info": @"Doe",
            @"json_id": @2
    };
    PMTestModel *model = [[PMTestModel alloc] initWithJSONDictionary:jsonDictionary];
    XCTAssertEqualObjects(model.name, jsonDictionary[@"json_name"]);
    XCTAssertEqualObjects(model.info, jsonDictionary[@"json_info"]);
    XCTAssertEqualObjects(model.id, jsonDictionary[@"json_id"]);
}

- (void)testFromRealmToJSON {
    PMTestModel *model = [[PMTestModel alloc] init];
    model.name = @"kjnbh";
    model.info = @"90i8hf7";
    model.id = @234;
    NSDictionary<NSString *, id> *jsonDictionary = [model JSONDictionary];
    XCTAssertEqualObjects(model.name, jsonDictionary[@"json_name"]);
    XCTAssertEqualObjects(model.info, jsonDictionary[@"json_info"]);
    XCTAssertEqualObjects(model.id, jsonDictionary[@"json_id"]);
}

- (void)testDeepCopying {
    PMTestModel *model = [[PMTestModel alloc] init];
    model.name = @"kjnbh";
    model.info = @"90i8hf7";
    model.id = @234;

    PMTestModel *anotherModel = [model deepCopy];
    XCTAssertEqualObjects(model.name, anotherModel.name);
    XCTAssertEqualObjects(model.info, anotherModel.info);
    XCTAssertEqualObjects(model.id, anotherModel.id);
}

@end
