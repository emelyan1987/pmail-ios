//
//  PMLocalNotification.h
//  planckMailiOS
//
//  Created by Lyubomyr Hlozhyk on 10/24/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    DisabledLocalNotificationTypeNone,
    DisabledLocalNotificationTypeAlert,
    DisabledLocalNotificationTypeBadge,
    DisabledLocalNotificationTypeSound,
    DisabledLocalNotificationTypeAll
} DisabledLocalNotificationType;

@interface PMLocalNotification : NSObject

+ (void)setUpNotificationForApplication:(UIApplication *)application;

+ (void)createLocalNotificationWithBody:(NSString *)body
                              andAction:(NSString *)action
                                  delay:(NSTimeInterval)delay
                               userInfo:(NSDictionary *)userInfo;

+ (void)cancelNotifications;

+ (void)checkDisabledLocalNotification:(void(^)(DisabledLocalNotificationType type))handler;

@end
