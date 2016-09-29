//
//  PMSettingsManager.h
//  planckMailiOS
//
//  Created by LionStar on 12/25/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBCalendar.h"
#import "PMThread.h"

@interface PMSettingsManager : NSUserDefaults

+(PMSettingsManager*)instance;
-(void)setInitialized:(BOOL)initialized;
-(BOOL)getInitialized;
-(void)setPhoneContactsLoaded:(BOOL)loaded;
-(BOOL)getPhoneContactsLoaded;
-(void)setDefaultEmail:(NSString*)email;
-(NSString*)getDefaultEmail;
-(void)setDefaultCalendar:(DBCalendar*)calendar;
-(DBCalendar*)getDefaultCalendar;
-(void)setWeekStart:(NSString*)weekStart;
-(NSString*)getWeekStart;
-(void)setBrowserName:(NSString*)browserName;
-(NSString*)getBrowserName;
-(void)setEnabledImportant:(BOOL)enabled;
-(BOOL)getEnabledImportant;
-(void)setOrganizeMailByThread:(BOOL)value;
-(BOOL)getOrganizeMailByThread;
-(void)setPerAccountSignature:(BOOL)value;
-(BOOL)getPerAccountSignature;
-(void)setGeneralSignature:(NSString*)signature;
-(NSString*)getGeneralSignature;
-(void)setSignaturesForAccount:(NSDictionary*)signatures;
-(NSDictionary*)getSignaturesForAccount;
-(void)setLeftSwipeOption:(NSString*)option;
-(NSString*)getLeftSwipeOption;
-(void)setRightSwipeOption:(NSString*)option;
-(NSString*)getRightSwipeOption;
-(void)setMailNotificationEnabled:(BOOL)enabled email:(NSString*)email;
-(BOOL)getMailNotificationEnabled:(NSString*)email;
-(void)setMailNotificationSound:(NSString*)sound email:(NSString*)email;
-(NSString*)getMailNotificationSound:(NSString*)email;
-(void)setCalendarNotificationEnabled:(BOOL)enabled email:(NSString*)email;
-(BOOL)getCalendarNotificationEnabled:(NSString*)email;
-(void)setCalendarNotificationSound:(NSString*)sound email:(NSString*)email;
-(NSString*)getCalendarNotificationSound:(NSString*)email;

-(void)setEnabledSalesforce:(BOOL)enabled;
-(BOOL)getEnabledSalesforce;

-(void)setSalesforceCredential:(NSDictionary*)credential;
-(NSDictionary*)getSalesforceCredential;

-(void)setSalesforceUserInfo:(NSDictionary*)userInfo;
-(NSDictionary*)getSalesforceUserInfo;

-(void)setSalesforceOrganization:(NSDictionary*)data;
-(NSDictionary*)getSalesforceOrganization;

-(void)setSalesforceEmails:(NSArray*)emails;
-(NSArray*)getSalesforceEmails;


- (NSMutableDictionary*)getThreadVersionDictionary;
- (NSNumber*)getVersionForThreadId:(NSString*)threadId;
- (void)setVersionForThreadId:(NSString*)threadId timestamp:(NSNumber*)timestamp;

- (void)addMessageId:(NSString*)messageId;
- (NSMutableArray*)getMessageIds;

- (NSMutableDictionary*)getEventFlagsDictionary;
- (NSNumber*)wasFlaggedForEventId:(NSString*)eventId;
- (void)setFlagForEventId:(NSString*)eventId;

- (void)setUnreadCount:(NSInteger)cnt;
- (void)decreaseUnreadCount:(NSInteger)cnt;
- (void)increaseUnreadCount:(NSInteger)cnt;
- (NSInteger)getUnreadCount;

- (void)addActiveSpammer:(NSDictionary*)from forAccount:(NSString*)accountId;
- (NSMutableArray*)getActiveSpammersForAccount:(NSString*)accountId;
- (NSMutableDictionary*)getActiveSpammersDictionary;
- (void)setUpdatedTimeForActiveSpammers:(NSDate*)date forAccount:(NSString*)accountId;
- (NSDate*)getUpdatedTimeForActiveSpammersForAccount:(NSString*)accountId;


@end
