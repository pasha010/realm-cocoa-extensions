//
//  PMAppDelegate.m
//  realm-cocoa-extensions
//
//  Created by Pavel Malkov on 10/27/2016.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "PMAppDelegate.h"
@import Realm;
@import RealmExtensions;

@implementation PMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    RLMRealmConfiguration *configuration = [RLMRealmConfiguration defaultConfiguration];
    configuration.fileName = @"pm_example";
    configuration.schemaVersion = 1;

    [RLMRealmConfiguration setDefaultConfiguration:configuration];

    return YES;
}

@end
