//
//  PMNotificationManager.m
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 12/15/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMNotificationManager.h"
#import "PMThread.h"

#define NOTIFICATION_ID @"notification_id"

@implementation PMNotificationManager

#pragma mark - Public methods

+ (void)scheduleNotificationForMail:(PMThread *)mailModel {
    UILocalNotification *localNotif = [self notificationForMail:mailModel];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}

+ (void)cancelNotificationForMail:(PMThread *)mailModel {
    NSString *threadId = mailModel.id;
    
    NSArray *notifications = [UIApplication sharedApplication].scheduledLocalNotifications;
    for(UILocalNotification *localNotif in notifications) {
        NSString *noficationID = localNotif.userInfo[NOTIFICATION_ID];
        if([threadId isEqualToString:noficationID]) {
            [[UIApplication sharedApplication] cancelLocalNotification:localNotif];
        }
    }
}

+ (void)cancelAllNotifications {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

#pragma mark - Private methods

+ (UILocalNotification *)notificationForMail:(PMThread *)mailModel {
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    localNotif.fireDate = mailModel.snoozeDate;
    
    localNotif.alertBody = [NSString stringWithFormat:@"Deffered email from %@", mailModel.ownerName];
    NSString *notificationID = mailModel.id;
    localNotif.userInfo = @{NOTIFICATION_ID: notificationID};
    
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    //localNotif.applicationIconBadgeNumber = 1;
    
    return localNotif;
}

@end
