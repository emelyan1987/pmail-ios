//
//  DBManager.h
//  pfaUkraine
//
//  Created by Admin on 29.10.14.
//  Copyright (c) 2014 Indeema. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "DBNamespace.h"
#import "DBCalendar.h"
#import "DBThread.h"
#import "DBContact.h"
#import "DBMessage.h"
#import "DBEvent.h"
#import "DBSavedContact.h"
#import "DBMailAdditionalInfo.h"
#import "DBFolder.h"



@interface DBManager : NSObject
@property (nonatomic, strong) NSManagedObjectContext *masterContext;
@property (nonatomic, strong) NSManagedObjectContext *mainContext;
@property (nonatomic, strong) NSManagedObjectContext *workerContext;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong) NSArray *namespaces;
@property (nonatomic, strong) NSArray *calendars;
@property (nonatomic, strong) NSArray *inboxInboxMailModels;

- (NSManagedObjectContext*)backgroundContext;
- (void)save;
- (void)saveOnContext:(NSManagedObjectContext*)context;
- (void)saveOnContext:(NSManagedObjectContext*)context completion:(void(^)(NSError *error))handler;
- (NSArray *)getNamespaces;
- (NSArray *)getCalendars;
- (NSArray *)getWritableCalendars;
- (NSArray *)getInboxMailModel;
- (NSArray *)getInboxMailModelsWithParams:(NSDictionary*)params namespaceId:(NSString*)namespaceId;
- (NSArray *)getSnoozedThreadsForAccount:(NSString*)accountId;

- (NSArray *)getContactsWithKeyword:(NSString *)keyword namespaceId:(NSString*)namespaceId;
- (NSArray *)getMessagesWithThreadId:(NSString *)threadId;
- (void)getMessagesWithThreadIdInBackground:(NSString *)threadId context:(NSManagedObjectContext*)context completion:(void(^)(NSArray *data))handler;
- (NSArray *)getEventsWithMessageId:(NSString *)messageId;
- (void)getEventsWithMessageIdInBackground:(NSString *)messageId context:(NSManagedObjectContext*)context completion:(void(^)(NSArray *data))handler;
- (void)getMailAdditionalInfoWithThreadIdInBackground:(NSString *)threadId context:(NSManagedObjectContext*)context completion:(void(^)(DBMailAdditionalInfo *info))handler;
- (void)getMailAdditionalInfoWithMessageIdInBackground:(NSString *)messageId context:(NSManagedObjectContext*)context completion:(void(^)(DBMailAdditionalInfo *info))handler;

- (DBMessage *)getMessageWithMessageId:(NSString *)messageId;
- (NSArray *)getMessagesWithAnyEmail:(NSString *)email namespaceId:(NSString*)namespaceId;

- (NSArray *)getSavedContacts;
- (NSArray *)getSavedContactsWithType:(NSString*)contactType;
- (NSArray *)getSavedContactsWithType:(NSString*)contactType offset:(NSInteger)offset limit:(NSInteger)limit;
- (void)getSavedContactsWithTypeInBackground:(NSString*)contactType completion:(void(^)(NSArray *data))handler;

- (void)deleteSalesforceContacts;

+ (void)deleteAllDataFromDB;
+ (void)deleteNamespace:(DBNamespace *)item;
+ (void)deleteAllInboxMailModelFromDB;
- (void)deleteAccountData:(NSString*)accountId;

+ (DBManager *)instance;


+ (DBNamespace *)createNewNamespace;
+ (DBCalendar *)createNewCalendar;

- (NSArray *)getAccounts;
- (NSArray *)getAccountsByProvider:(NSString*)provider;

- (NSArray*)getTracks:(NSString*)email trackStatus:(NSString*)status time:(NSString*)time;
- (NSArray*)getTrackDetails:(NSNumber*)trackId;

- (NSInteger)getUnreadCountWithAccountId:(NSString*)accountId;
- (NSInteger)getUnreadCountForFolder:(NSString*)folderId;

- (NSArray*)getFromItemsInFolder:(NSString*)folder forAccount:(NSString*)accountId;


- (NSArray*)getFoldersForAccount:(NSString*)accountId;
- (DBFolder*)getFolderForAccount:(NSString*)accountId folderName:(NSString*)folderName;

- (DBThread*)getThreadWithMessageId:(NSString*)messageId;
@end
