//
//  PMLocalNotification.m
//  planckMailiOS
//
//  Created by Lyubomyr Hlozhyk on 10/24/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMLocalNotification.h"

@implementation PMLocalNotification

+ (void)setUpNotificationForApplication:(UIApplication *)application  {
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [application registerForRemoteNotifications];
    }
}

+ (void)createLocalNotificationWithBody:(NSString *)body andAction:(NSString *)action delay:(NSTimeInterval)delay userInfo:(NSDictionary *)userInfo {
    
    UILocalNotification *lNotification = [UILocalNotification new];
    [lNotification setAlertBody:body];
    [lNotification setAlertAction:action];
    [lNotification setUserInfo:userInfo];
    [lNotification setFireDate:[NSDate dateWithTimeIntervalSinceNow:delay]];
    [lNotification setTimeZone:[NSTimeZone localTimeZone]];
    NSInteger lBageCount = [[UIApplication sharedApplication] applicationIconBadgeNumber];
    
    [lNotification setApplicationIconBadgeNumber:lBageCount++];
    [lNotification setSoundName:UILocalNotificationDefaultSoundName];
    
    UIApplicationState applicationState = [UIApplication sharedApplication].applicationState;
    if (applicationState == UIApplicationStateBackground) {
        
        [[UIApplication sharedApplication] scheduleLocalNotification:lNotification];
    }
}

+ (void)cancelNotifications {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    //[[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

+ (void)checkDisabledLocalNotification:(void(^)(DisabledLocalNotificationType type))handler {
    DisabledLocalNotificationType lResultType = DisabledLocalNotificationTypeNone;
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(currentUserNotificationSettings)]) {
        
        UIUserNotificationType notificationTypes = [[[UIApplication sharedApplication] currentUserNotificationSettings] types];
        
        if (notificationTypes == (UIUserNotificationTypeBadge | UIUserNotificationTypeAlert)) {
            // Badge & Alert
            lResultType = DisabledLocalNotificationTypeSound;
        } else if (notificationTypes == (UIUserNotificationTypeBadge | UIUserNotificationTypeSound)) {
            // Badge & Sound
            lResultType = DisabledLocalNotificationTypeAlert;
        } else if (notificationTypes == (UIUserNotificationTypeAlert | UIUserNotificationTypeSound)) {
            // Alert & Sound
            lResultType = DisabledLocalNotificationTypeBadge;
        } else if (notificationTypes != (UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound)) {
            // Badge, Alert & Sound
            lResultType = DisabledLocalNotificationTypeAll;
        }
        
    }
    handler(lResultType);
}

@end
