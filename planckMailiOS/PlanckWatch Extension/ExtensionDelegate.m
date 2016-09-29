//
//  ExtensionDelegate.m
//  PlanckWatch Extension
//
//  Created by nazar on 11/23/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "ExtensionDelegate.h"
#import "WatchKitDefines.h"

@implementation ExtensionDelegate

+ (ExtensionDelegate*)sharedInstance
{
    return (ExtensionDelegate*)[WKExtension sharedExtension].delegate;
}
- (void)applicationDidFinishLaunching {
    // Perform any final initialization of your application.

    if ([WCSession isSupported]) {
        self.session = [WCSession defaultSession];
        self.session.delegate = self;
        [self.session activateSession];        
        
        [self.session sendMessage:@{WK_REQUEST_TYPE: @(PMWatchRequestGetContacts)} replyHandler:nil errorHandler:nil];
    }
}

- (void)applicationDidBecomeActive {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

}

- (void)applicationWillResignActive {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, etc.

}

- (void)session:(WCSession *)session didReceiveUserInfo:(NSDictionary<NSString *,id> *)userInfo
{
    if(userInfo[WK_CONTACT_LIST])
    {
        [[NSUserDefaults standardUserDefaults] setObject:userInfo[WK_CONTACT_LIST] forKey:WK_CONTACT_LIST];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:WK_NOTIFICATION_DID_RECEIVE_CONTACT_LIST object:nil];
    }
}
@end
