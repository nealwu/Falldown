//
//  AppDelegate.m
//  Falldown
//
//  Created by Neal Wu on 3/26/15.
//  Copyright (c) 2015 Neal Wu. All rights reserved.
//

#import "AppDelegate.h"

#import "FalldownViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = [[FalldownViewController alloc] init];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
