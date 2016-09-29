//
//  PMNotificationManager.h
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 12/15/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PMThread;
@interface PMNotificationManager : NSObject

+ (void)scheduleNotificationForMail:(PMThread *)mailModel;
+ (void)cancelNotificationForMail:(PMThread *)mailModel;
+ (void)cancelAllNotifications;

@end
