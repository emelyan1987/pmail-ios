//
//  PMScheduleManager.m
//  planckMailiOS
//
//  Created by LionStar on 3/25/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import "PMScheduleManager.h"
#import "PMNotificationManager.h"
#import "PMSettingsManager.h"
#import "PMAPIManager.h"
#import "AlertManager.h"
#import "DBThread.h"
#import "PMFolderManager.h"

#define SCHEDULED_MAIL_LIST @"kScheduledMailList"

@implementation PMScheduleManager

+ (PMScheduleManager*)sharedInstance
{
    static PMScheduleManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedManager = [PMScheduleManager new];
    });
    return sharedManager;
    
}

- (NSString*)getStringTypeFromEnum:(ScheduleDateType)type
{
    
    NSArray *types = @[@"Later Today",@"This Evening",@"Tomorrow",@"This Weekend",@"Next Week",@"In A Month",@"Someday",@"Pick a Date"];
    
    return [types objectAtIndex:type];
    
}

-(void)addMailToScheduledList:(PMThread *)mail
{
    // Retrieve from NSUserDefaults
    NSMutableArray *mails = [self getScheduledMailList];
    
    if(mails==nil) mails = [NSMutableArray new];
    [mails addObject:mail];
    
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:mails];
    
    
    // Save to NSUserDefaults
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:SCHEDULED_MAIL_LIST];
}

- (NSMutableArray*)getScheduledMailList
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:SCHEDULED_MAIL_LIST];
    
    NSMutableArray *mails = [NSMutableArray array];
    mails = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    return mails;
}

- (void)finishScheduleMail:(PMThread*)mail date:(NSDate*)date dateType:(ScheduleDateType)type
{
    
    mail.snoozeDate = date;
    mail.snoozeDateType = type;
    
    [PMNotificationManager scheduleNotificationForMail:mail];
    
    DBThread *dbThread = [DBThread getThreadWithId:mail.id];
    [dbThread setSnoozeDate:date withDateType:@(type)];
    
    DLog(@"date = %@", mail.snoozeDate);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MAIL_SCHEDULED object:mail];
    
}

- (void)scheduleMail:(PMThread*)mail scheduleDateType:(ScheduleDateType)type scheduleDate:(NSDate*)date autoAsk:(NSInteger)autoAsk
{
    NSString *scheduledFolderId = [[PMFolderManager sharedInstance] getScheduledFolderIdForAccount:[PMAPIManager shared].namespaceId.namespace_id];
    
    if(!scheduledFolderId) {
        [AlertManager showErrorMessage:[NSString stringWithFormat:@"Could not find \"%@\"", SCHEDULED_FOLDER_NAME]];
        return;
    }
    
    NSString *autoAskString;
    
    
    NSDate *issuedTime = [NSDate date];
    if (autoAsk)
    {
        autoAskString = [NSString stringWithFormat:@"%lu", autoAsk];
        
        [AlertManager showStatusBarWithMessage:@"Setting reminder..." type:ACTIVITY_STATUS_TYPE_PROGRESS time:issuedTime];
        [[PMAPIManager shared] moveMailToReminderMailId:[PMAPIManager shared].emailAddress
                                                account:[PMAPIManager shared].namespaceId
                                                   time:[date timeIntervalSinceNow]
                                               threadId:scheduledFolderId
                                              messageId:mail.id
                                                autoAsk:autoAskString
                                                subject:mail.subject
                                             completion:^(id data, id error, BOOL success) {
            
            [AlertManager hideStatusBar:issuedTime];
            
            if(!error) {
                [AlertManager showStatusBarWithMessage:@"Reminder set." type:ACTIVITY_STATUS_TYPE_INFO time:nil];
                [self finishScheduleMail:mail date:date dateType:type];
            } else {
                NSLog(@"Error, Failed move to reminder, error = %@", [error localizedDescription]);
                [AlertManager showStatusBarWithMessage:@"Setting reminder failed." type:ACTIVITY_STATUS_TYPE_ERROR time:nil];
            }
            
        }];
        
    } else {
        autoAskString = @"";
        [AlertManager showStatusBarWithMessage:@"Snoozing Email..." type:ACTIVITY_STATUS_TYPE_PROGRESS time:issuedTime];
        
        
        [[PMAPIManager shared] moveThread:mail
                                 toFolder:scheduledFolderId
                               completion:^(id data, id error, BOOL success) {
            
            [AlertManager hideStatusBar:issuedTime];
            if (!error) {
                [AlertManager showStatusBarWithMessage:@"Email snoozed." type:ACTIVITY_STATUS_TYPE_INFO time:nil];
                [self finishScheduleMail:mail date:date dateType:type];
            }else {
                NSLog(@"Error, cannot move to follow up folder, error = %@", error);
                [AlertManager showStatusBarWithMessage:@"Snoozing Email failed." type:ACTIVITY_STATUS_TYPE_ERROR time:nil];
            }
            
        }];
        
        
    }
}

- (NSInteger)getUnreadCount
{
    NSArray *scheduledMails = [self getScheduledMailList];
    
    NSInteger unreads = 0;
    for(PMThread *mail in scheduledMails)
    {
        if(mail.isUnread)
        {
            unreads ++;
        }
    }
    
    return unreads;
}
@end
