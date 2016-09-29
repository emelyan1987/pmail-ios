//
//  PMSettingsManager.m
//  planckMailiOS
//
//  Created by LionStar on 12/25/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMSettingsManager.h"
#import "PMAPIManager.h"


// Settings Key Define
#define APP_INITIALIZED @"kAppInitialized"
#define PHONE_CONTACTS_LOADED @"kPhoneContactsLoaded"
#define DEFAULT_EMAIL @"kDefaultEmail"
#define DEFAULT_CALENDAR_ID @"kDefaultCalendarId"
#define WEEK_START @"kWeekStart"
#define OPEN_LINKS_WITH @"kOpenLinksWith"
#define ENABLED_IMPORTANT @"kEnabledImportant"
#define ORGANIZE_MAIL_BY_THREAD @"kOrganizeMailByThread"
#define PER_ACCOUNT_SIGNATURE @"kPerAccountSignature"
#define SIGNATURES_FOR_ACCOUNT @"kSignatures"
#define GENERAL_SIGNATURE @"kGeneralSignature"
#define LEFT_SWIPE_OPTION @"kLeftSwipeOption"
#define RIGHT_SWIPE_OPTION @"kRightSwipeOption"
#define MAIL_NOTIFICATIONS_ENABLED @"kMailNotificationsEnabled"
#define CALENDAR_NOTIFICATIONS_ENABLED @"kCalendarNotificationsEnabled"
#define MAIL_NOTIFICATIONS_SOUND @"kMailNotificationsSound"
#define CALENDAR_NOTIFICATIONS_SOUND @"kCalendarNotificationsSound"
#define ENABLED_SALESFORCE @"kEnabledSalesforce"
#define SALESFORCE_CREDENTIAL @"kSalesforceCredential"
#define SALESFORCE_USERINFO @"kSalesforceUserInfo"
#define SALESFORCE_ORGANIZATION @"kSalesforceOrganization"
#define SALESFORCE_EMAILS @"kSalesforceEmails"

#define THREAD_VERSION_DICTIONARY @"kThreadVersionDictionary"
#define MESSAGE_IDS @"kMessageIds"
#define EVENT_FLAGS_DICTIONARY @"kEventFlagsDictionary"

#define UNREAD_COUNT @"kUnreadCount"

#define ACTIVE_SPAMMERS_DICTIONARY @"kActiveSpammersDictionary"
#define ACTIVE_SPAMMERS_UPDATED_TIME @"kActiveSpammersUpdatedTime"

@implementation PMSettingsManager

+(PMSettingsManager*)instance
{
    static PMSettingsManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [PMSettingsManager new];
    });
    return instance;
}

-(void)setInitialized:(BOOL)initialized
{
    [self setObject:@(initialized) forKey:APP_INITIALIZED];
}
-(BOOL)getInitialized
{
    NSNumber *initialized = [self objectForKey:APP_INITIALIZED];
    if(initialized)
        return [initialized boolValue];
    
    return NO;
}

-(void)setPhoneContactsLoaded:(BOOL)loaded
{
    [self setObject:@(loaded) forKey:PHONE_CONTACTS_LOADED];
}
-(BOOL)getPhoneContactsLoaded
{
    NSNumber *loaded = [self objectForKey:PHONE_CONTACTS_LOADED];
    if(loaded)
        return [loaded boolValue];
    
    return NO;
}

-(void)setDefaultEmail:(NSString *)email
{
    [self setObject:email forKey:DEFAULT_EMAIL];
}

-(NSString*)getDefaultEmail
{
    NSString *email = [self objectForKey:DEFAULT_EMAIL];
    
    if(email && email.length) return email;
    
    return [PMAPIManager shared].namespaceId.email_address;
}

-(void)setDefaultCalendar:(DBCalendar *)calendar
{
    NSString *calendarId = calendar.calendarId;
    
    [self setObject:calendarId forKey:DEFAULT_CALENDAR_ID];
}

-(DBCalendar*)getDefaultCalendar
{
    NSString *calendarId = [self objectForKey:DEFAULT_CALENDAR_ID];
    if(calendarId && calendarId.length) return [DBCalendar getCalendarWithId:calendarId];
    
    NSArray *calendars = [[DBManager instance] getCalendars];
    if(calendars.count) return calendars[0];
    return nil;
}

-(void)setWeekStart:(NSString *)weekStart
{
    [self setObject:weekStart forKey:WEEK_START];
}

-(NSString*)getWeekStart
{
    NSString *weekStart = [self objectForKey:WEEK_START];
    
    if(weekStart==nil) weekStart = @"Sunday";
    
    return weekStart;
}

-(void)setBrowserName:(NSString *)browserName
{
    [self setObject:browserName forKey:OPEN_LINKS_WITH];
}

-(NSString*)getBrowserName
{
    NSString *browserName = [self objectForKey:OPEN_LINKS_WITH];
    
    if(browserName==nil) browserName = @"Safari";
    
    return browserName;
}
-(void)setEnabledImportant:(BOOL)enabled
{
    [self setObject:@(enabled) forKey:ENABLED_IMPORTANT];
}
-(BOOL)getEnabledImportant
{
    NSNumber *value = [self objectForKey:ENABLED_IMPORTANT];
    
    
    if(value)
        return [value boolValue];
    
    if(!value) [self setEnabledImportant:YES];
    return YES;
}


-(void)setOrganizeMailByThread:(BOOL)value
{
    [self setObject:@(value) forKey:ORGANIZE_MAIL_BY_THREAD];
}
-(BOOL)getOrganizeMailByThread
{
    NSNumber *value = [self objectForKey:ORGANIZE_MAIL_BY_THREAD];
    
    if(value)
        return [value boolValue];
    
    [self setOrganizeMailByThread:YES];
    
    return YES;
}

-(void)setPerAccountSignature:(BOOL)value
{
    [self setObject:@(value) forKey:PER_ACCOUNT_SIGNATURE];
}
-(BOOL)getPerAccountSignature
{
    NSNumber *value = [self objectForKey:PER_ACCOUNT_SIGNATURE];
    
    if(value)
        return [value boolValue];
    
    [self setPerAccountSignature:YES];
    
    return YES;
}
-(void)setGeneralSignature:(NSString *)signature
{
    [self setObject:signature forKey:GENERAL_SIGNATURE];
}
-(NSString*)getGeneralSignature
{
    NSString *signature = [self objectForKey:GENERAL_SIGNATURE];
    
    if(signature==nil) signature = @"Sent from PlanckMail";
    
    return signature;
}
-(void)setSignaturesForAccount:(NSDictionary *)signatures
{
    [self setObject:signatures forKey:SIGNATURES_FOR_ACCOUNT];
}
-(NSDictionary*)getSignaturesForAccount
{
    NSDictionary *signatures = [self objectForKey:SIGNATURES_FOR_ACCOUNT];
    
    return signatures;
}

-(void)setLeftSwipeOption:(NSString *)option
{
    [self setObject:option forKey:LEFT_SWIPE_OPTION];
}
-(NSString*)getLeftSwipeOption
{
    NSString *option = [self objectForKey:LEFT_SWIPE_OPTION];
    if(!option) option = @"none";
    
    return option;
}

-(void)setRightSwipeOption:(NSString *)option
{
    [self setObject:option forKey:RIGHT_SWIPE_OPTION];
}
-(NSString*)getRightSwipeOption
{
    NSString *option = [self objectForKey:RIGHT_SWIPE_OPTION];
    if(!option) option = @"none";
    
    return option;
}

-(void)setMailNotificationEnabled:(BOOL)enabled email:(NSString *)email
{
    NSDictionary *notifications = [self objectForKey:MAIL_NOTIFICATIONS_ENABLED];
    
    NSMutableDictionary *mutableNotifications;
    
    if(notifications)
        mutableNotifications = [NSMutableDictionary dictionaryWithDictionary:notifications];
    else
        mutableNotifications = [NSMutableDictionary new];
    
    [mutableNotifications setObject:@(enabled) forKey:email];
    [self setObject:mutableNotifications forKey:MAIL_NOTIFICATIONS_ENABLED];
}
-(BOOL)getMailNotificationEnabled:(NSString *)email
{
    NSDictionary *notifications = [self objectForKey:MAIL_NOTIFICATIONS_ENABLED];
    
    NSNumber *enabled = [notifications objectForKey:email];
    
    if(!enabled)
    {
        [self setMailNotificationEnabled:YES email:email];
        return YES;
    }
    
    return [enabled boolValue];
}
-(void)setMailNotificationSound:(NSString*)sound email:(NSString *)email
{
    NSDictionary *sounds = [self objectForKey:MAIL_NOTIFICATIONS_SOUND];
    
    NSMutableDictionary *mutableSounds;
    
    if(sounds)
        mutableSounds = [NSMutableDictionary dictionaryWithDictionary:sounds];
    else
        mutableSounds = [NSMutableDictionary new];
    
    [mutableSounds setObject:sound forKey:email];
    [self setObject:mutableSounds forKey:MAIL_NOTIFICATIONS_SOUND];
}
-(NSString*)getMailNotificationSound:(NSString *)email
{
    NSDictionary *sounds = [self objectForKey:MAIL_NOTIFICATIONS_SOUND];
    
    NSString *sound = [sounds objectForKey:email];
    
    if(!sound)
    {
        [self setMailNotificationSound:@"Default" email:email];
        return @"Default";
    }
    
    return sound;
}
-(void)setCalendarNotificationEnabled:(BOOL)enabled email:(NSString *)email
{
    NSDictionary *notifications = [self objectForKey:CALENDAR_NOTIFICATIONS_ENABLED];
    
    NSMutableDictionary *mutableNotifications;
    
    if(notifications)
        mutableNotifications = [NSMutableDictionary dictionaryWithDictionary:notifications];
    else
        mutableNotifications = [NSMutableDictionary new];
    
    [mutableNotifications setObject:@(enabled) forKey:email];
    [self setObject:mutableNotifications forKey:CALENDAR_NOTIFICATIONS_ENABLED];
}
-(BOOL)getCalendarNotificationEnabled:(NSString *)email
{
    NSDictionary *notifications = [self objectForKey:CALENDAR_NOTIFICATIONS_ENABLED];
    
    NSNumber *enabled = [notifications objectForKey:email];
    
    if(!enabled)
    {
        [self setCalendarNotificationEnabled:YES email:email];
        return YES;
    }
    
    return [enabled boolValue];
}
-(void)setCalendarNotificationSound:(NSString*)sound email:(NSString *)email
{
    NSDictionary *sounds = [self objectForKey:CALENDAR_NOTIFICATIONS_SOUND];
    
    NSMutableDictionary *mutableSounds;
    
    if(sounds)
        mutableSounds = [NSMutableDictionary dictionaryWithDictionary:sounds];
    else
        mutableSounds = [NSMutableDictionary new];
    
    [mutableSounds setObject:sound forKey:email];
    [self setObject:mutableSounds forKey:CALENDAR_NOTIFICATIONS_SOUND];
}
-(NSString*)getCalendarNotificationSound:(NSString *)email
{
    NSDictionary *sounds = [self objectForKey:CALENDAR_NOTIFICATIONS_SOUND];
    
    NSString *sound = [sounds objectForKey:email];
    
    if(!sound)
    {
        [self setCalendarNotificationSound:@"Default" email:email];
        return @"Default";
    }
    
    return sound;
}

-(void)setEnabledSalesforce:(BOOL)enabled
{
    [self setObject:@(enabled) forKey:ENABLED_SALESFORCE];
}
-(BOOL)getEnabledSalesforce
{
    NSNumber *value = [self objectForKey:ENABLED_SALESFORCE];
    
    if(value)
        return [value boolValue];
    return NO;
}

-(void)setSalesforceCredential:(NSDictionary *)credential
{
    [self setObject:credential forKey:SALESFORCE_CREDENTIAL];
}
-(NSDictionary*)getSalesforceCredential
{
    return [self objectForKey:SALESFORCE_CREDENTIAL];
}

-(void)setSalesforceUserInfo:(NSDictionary *)userInfo
{
    [self setObject:userInfo forKey:SALESFORCE_USERINFO];
}
-(NSDictionary*)getSalesforceUserInfo
{
    return [self objectForKey:SALESFORCE_USERINFO];
}

-(void)setSalesforceOrganization:(NSDictionary *)data
{
    [self setObject:data forKey:SALESFORCE_ORGANIZATION];
}
-(NSDictionary*)getSalesforceOrganization
{
    return [self objectForKey:SALESFORCE_ORGANIZATION];
}

-(void)setSalesforceEmails:(NSArray *)emails
{
    [self setObject:emails forKey:SALESFORCE_EMAILS];
}
-(NSArray*)getSalesforceEmails
{
    return [self objectForKey:SALESFORCE_EMAILS];
}




- (NSMutableDictionary*)getThreadVersionDictionary
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:THREAD_VERSION_DICTIONARY];
    
    NSMutableDictionary *threadsDic = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    if(threadsDic==nil) threadsDic = [NSMutableDictionary new];
    return threadsDic;
}

- (NSNumber*)getVersionForThreadId:(NSString *)threadId
{
    NSMutableDictionary *threadsDic = [self getThreadVersionDictionary];
    
    return threadsDic[threadId];
}

- (void)setVersionForThreadId:(NSString *)threadId timestamp:(NSNumber *)timestamp
{
    NSMutableDictionary *threadsDic = [self getThreadVersionDictionary];
    
    [threadsDic setObject:timestamp forKey:threadId];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:threadsDic];
    [self setObject:data forKey:THREAD_VERSION_DICTIONARY];
}

- (void)addMessageId:(NSString *)messageId
{
    NSMutableArray *ids = [self getMessageIds];
    
    [ids addObject:messageId];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:ids];
    [self setObject:data forKey:MESSAGE_IDS];
}

- (NSMutableArray*)getMessageIds
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:MESSAGE_IDS];
    
    NSMutableArray *ids = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    if(ids==nil) ids = [NSMutableArray new];
    
    return ids;
}
- (NSMutableDictionary*)getEventFlagsDictionary
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:EVENT_FLAGS_DICTIONARY];
    
    NSMutableDictionary *eventsDic = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    if(eventsDic==nil) eventsDic = [NSMutableDictionary new];
    return eventsDic;
}
- (NSNumber*)wasFlaggedForEventId:(NSString *)eventId
{
    NSMutableDictionary *eventsDic = [self getEventFlagsDictionary];
    
    return eventsDic[eventId];
}

- (void)setFlagForEventId:(NSString *)eventId
{
    NSMutableDictionary *eventsDic = [self getEventFlagsDictionary];
    
    [eventsDic setObject:@(YES) forKey:eventId];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:eventsDic];
    [self setObject:data forKey:EVENT_FLAGS_DICTIONARY];
}


- (void)setUnreadCount:(NSInteger)cnt
{
    [self setObject:@(cnt) forKey:UNREAD_COUNT];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UNREAD_COUNT_CHANGED object:nil];
}
- (void)decreaseUnreadCount:(NSInteger)cnt
{
    NSInteger unreads = [self getUnreadCount];
    unreads -= cnt;
    [self setUnreadCount:unreads];
}
- (void)increaseUnreadCount:(NSInteger)cnt
{
    NSInteger unreads = [self getUnreadCount];
    unreads += cnt;
    [self setUnreadCount:unreads];
}
- (NSInteger)getUnreadCount
{
    NSNumber *count = [self objectForKey:UNREAD_COUNT];
    if(count==nil) return 0;
    
    return [count integerValue];
}

- (void)addActiveSpammer:(NSDictionary *)from forAccount:(NSString *)accountId
{
    NSMutableDictionary *dict = [self getActiveSpammersDictionary];
    
    NSMutableArray *spammers;
    if(!dict[accountId]) spammers = [NSMutableArray new];
    else spammers = dict[accountId];
    
    BOOL bFound = NO;
    
    for(NSDictionary *item in spammers)
    {
        if([item[@"email"] isEqualToString:from[@"email"]])
        {
            bFound = YES; break;
        }
    }
    
    if(!bFound)
    {
        [spammers addObject:from];
        
        [dict setObject:spammers forKey:accountId];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dict];
        [self setObject:data forKey:ACTIVE_SPAMMERS_DICTIONARY];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ACTIVE_SPAMMER_ADDED object:accountId];
    }
}

- (NSMutableDictionary*)getActiveSpammersDictionary
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:ACTIVE_SPAMMERS_DICTIONARY];
    
    NSMutableDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    return dict?dict:[NSMutableDictionary new];
}

- (NSMutableArray*)getActiveSpammersForAccount:(NSString *)accountId
{
    
    NSMutableDictionary *dict = [self getActiveSpammersDictionary];
    if(dict[accountId] == nil) return [NSMutableArray new];
    else return [NSMutableArray arrayWithArray:dict[accountId]];
    
}

- (void)setUpdatedTimeForActiveSpammers:(NSDate *)date forAccount:(NSString *)accountId
{
    
    NSMutableDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:ACTIVE_SPAMMERS_UPDATED_TIME]];
    
    [dict setObject:date forKey:accountId];
    
    
    [self setObject:[NSKeyedArchiver archivedDataWithRootObject:dict] forKey:ACTIVE_SPAMMERS_DICTIONARY];
}

- (NSDate*)getUpdatedTimeForActiveSpammersForAccount:(NSString *)accountId
{
    NSMutableDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:ACTIVE_SPAMMERS_UPDATED_TIME]];
    
    if(!dict) return nil;
    
    return dict[accountId];
}
@end
