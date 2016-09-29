//
//  AppDelegate.h
//  planckMailiOS
//
//  Created by Admin on 5/10/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PMTabBarController.h"
#define kMainViewController (MainViewController *)[[(AppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController]
#define kNavigationController (UINavigationController *)[(MainViewController *)[[(AppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] rootViewController]

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;

+(instancetype)sharedInstance;

- (void)updateUnreadCount;

@property (strong, nonatomic) PMTabBarController *tabBarController;

@property NSString *deviceToken;
@end

