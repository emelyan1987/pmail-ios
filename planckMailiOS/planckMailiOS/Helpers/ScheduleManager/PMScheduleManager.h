//
//  PMScheduleManager.h
//  planckMailiOS
//
//  Created by LionStar on 3/25/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PMThread.h"

typedef enum : NSUInteger {
    SNOOZE,
    REMINDER
} ScheduleType;

@interface PMScheduleManager : NSObject

+ (PMScheduleManager*)sharedInstance;
- (NSString*)getStringTypeFromEnum:(ScheduleDateType)type;
- (void)scheduleMail:(PMThread*)mail scheduleDateType:(ScheduleDateType)type scheduleDate:(NSDate*)date autoAsk:(NSInteger)autoAsk;
- (void)finishScheduleMail:(PMThread*)mail date:(NSDate*)date dateType:(ScheduleDateType)type;
- (void)addMailToScheduledList:(PMThread*)mail;
- (NSMutableArray*)getScheduledMailList;
- (NSInteger)getUnreadCount;
@end
