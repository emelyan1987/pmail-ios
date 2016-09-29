//
//  DBManager.m
//  pfaUkraine
//
//  Created by Admin on 29.10.14.
//  Copyright (c) 2014 Indeema. All rights reserved.
//

#import "DBManager.h"
#import "Config.h"
#import "PMSettingsManager.h"


@implementation DBManager

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"planckMailiOS.sqlite"];
    NSLog(@"storeURL %@", storeURL);
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)masterContext
{
    if (_masterContext != nil) {
        return _masterContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _masterContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        
        [_masterContext setPersistentStoreCoordinator:coordinator];
    }
    return _masterContext;
}
- (NSManagedObjectContext *)mainContext
{
    if (_mainContext != nil) {
        return _mainContext;
    }
    
    _mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    _mainContext.parentContext = self.masterContext;
    
    return _mainContext;
}

- (NSManagedObjectContext*) workerContext
{
    //if (_mainContext != nil) {
    //    return _mainContext;
    //}
    
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    context.parentContext = self.mainContext;
    
    return context;
}

- (NSManagedObjectContext*)backgroundContext
{
    NSManagedObjectContext *masterContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    masterContext.persistentStoreCoordinator = [self persistentStoreCoordinator];
    NSManagedObjectContext *mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    mainContext.parentContext = masterContext;
    NSManagedObjectContext *backgroundContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    backgroundContext.parentContext = mainContext;
    
    return backgroundContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"planckMailiOS" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - save db method

- (void)save {
    __block NSError *error;
    [_mainContext performBlock:^{
        if ([_mainContext save:&error])
        {
            [_masterContext performBlock:^{
                [_masterContext save:&error];
            }];
        }
    }];
}

- (void)saveOnContext:(NSManagedObjectContext *)context
{
    __block NSError *error = nil;
    
    [context performBlock:^{
        if ([context save:&error])
        {
            [context.parentContext performBlock:^{
                if([context.parentContext save:&error])
                {
                    [context.parentContext.parentContext performBlock:^{
                        [context.parentContext.parentContext save:&error];
                    }];
                }
            }];
        }
    }];
}

- (void)saveOnContext:(NSManagedObjectContext*)context completion:(void(^)(NSError *error))handler
{
    __block NSError *error = nil;
    
    [context performBlock:^{
        if ([context save:&error])
        {
            [context.parentContext performBlock:^{
                if([context.parentContext save:&error])
                {
                    [context.parentContext.parentContext performBlock:^{
                        [context.parentContext.parentContext save:&error];
                        
                        if(handler) handler(error);
                    }];
                }
            }];
        }
    }];
}

#pragma mark - creates new DB objects methods

+ (DBNamespace *)createNewNamespace
{
    DBManager *lDBManager = [DBManager instance];
    DBNamespace *lForm = (DBNamespace *)[NSEntityDescription insertNewObjectForEntityForName:@"DBNamespace" inManagedObjectContext:lDBManager.mainContext];
    
    lForm.id = @"";
    lForm.object = @"";
    lForm.namespace_id = @"";
    lForm.account_id = @"";
    lForm.email_address = @"";
    lForm.name = @"";
    lForm.provider = @"";
    lForm.token = @"";
    
    return lForm;
}

+ (DBCalendar*)createNewCalendar {
    DBManager *lDBManager = [DBManager instance];
    DBCalendar *lDBCalendar = (DBCalendar *)[NSEntityDescription insertNewObjectForEntityForName:@"DBCalendar" inManagedObjectContext:lDBManager.mainContext];
    
    lDBCalendar.account_id = @"";
    lDBCalendar.calendarDescription = @"";
    lDBCalendar.calendarId = @"";
    lDBCalendar.name = @"";
    lDBCalendar.object = @"";
    lDBCalendar.readOnly = @NO;
    lDBCalendar.color = @0;
    lDBCalendar.selected = @YES;
    
    return lDBCalendar;
}


#pragma mark - properties

- (NSArray *)getNamespaces {
    NSError *lError;
    NSFetchRequest *lFetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DBNamespace"
                                              inManagedObjectContext:self.mainContext];
    [lFetchRequest setEntity:entity];
    _namespaces = [self.mainContext executeFetchRequest:lFetchRequest error:&lError];
    
    for(DBNamespace *namespace in _namespaces)
    {
        NSLog(@"Namespace:%@,%@,%@,%@", namespace.email_address, namespace.provider, namespace.name, namespace.account_id);
    }
    return _namespaces;
}


- (NSArray *)getCalendars {
    NSError *lError;
    NSFetchRequest *lFetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DBCalendar" inManagedObjectContext:self.mainContext];
    [lFetchRequest setEntity:entity];
    _calendars = [self.mainContext executeFetchRequest:lFetchRequest error:&lError];
    
    return _calendars;
}
- (NSArray *)getWritableCalendars {
    NSError *lError;
    NSFetchRequest *lFetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DBCalendar" inManagedObjectContext:self.mainContext];
    [lFetchRequest setEntity:entity];
    [lFetchRequest setPredicate:[NSPredicate predicateWithFormat:@"readOnly == 0"]];
    _calendars = [self.mainContext executeFetchRequest:lFetchRequest error:&lError];
    
    return _calendars;
}


- (NSArray *)getInboxMailModel {
    NSError *lError;
    NSFetchRequest *lFetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DBThread"
                                              inManagedObjectContext:self.mainContext];
    [lFetchRequest setEntity:entity];
    _inboxInboxMailModels = [self.mainContext executeFetchRequest:lFetchRequest error:&lError];
    
    return _inboxInboxMailModels;
    
}

- (NSArray *)getInboxMailModelsWithParams:(NSDictionary *)params namespaceId:(NSString*)namespaceId {
    NSError *lError;
    NSFetchRequest *lFetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DBThread"
                                              inManagedObjectContext:[self mainContext]];
    [lFetchRequest setEntity:entity];
    
    if(params[@"in"])
    {
        NSString *inParam = [NSString stringWithFormat:@"*\"%@\"*", params[@"in"]];
        
        
        [lFetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(accountId like %@) and (folders like[cd] %@)", namespaceId, inParam]];
    }
    else if(params[@"participant"])
    {
        NSString *email = [params[@"participant"] lowercaseString];
        NSString *filterStr = [NSString stringWithFormat:@"*\"%@\"*", email];
        
        
        [lFetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(accountId like %@) and (participants like[cd] %@)", namespaceId, filterStr]];
    }
    else if(params[@"participants"])
    {
        NSPredicate *accountPredicate = [NSPredicate predicateWithFormat:@"accountId like %@", namespaceId];
        
        NSMutableArray *participantPredicates = [NSMutableArray new];
        NSArray *emails = params[@"participants"];
        
        for(NSString *email in emails)
        {
            NSString *filterStr = [NSString stringWithFormat:@"*\"%@\"*", email];
            
            [participantPredicates addObject:[NSPredicate predicateWithFormat:@"participants like[cd] %@", filterStr]];
        }
        NSCompoundPredicate *participantsPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:participantPredicates];
        
        
        [lFetchRequest setPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:@[accountPredicate, participantsPredicate]]];
    }
    else
    {
        [lFetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(accountId like %@)", namespaceId]];
    }
    
    if(params[@"offset"])
        [lFetchRequest setFetchOffset:[params[@"offset"] integerValue]];
    if(params[@"limit"])
        [lFetchRequest setFetchLimit:[params[@"limit"] integerValue]];
    
    [lFetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"lastMessageDate" ascending:NO]]];
    _inboxInboxMailModels = [[self mainContext] executeFetchRequest:lFetchRequest error:&lError];
    
    return _inboxInboxMailModels;
    
}

- (NSArray *)getSnoozedThreadsForAccount:(NSString *)accountId
{
    NSError *err;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DBThread"
                                              inManagedObjectContext:[self mainContext]];
    [request setEntity:entity];
    
    
    if(accountId)
    {
        [request setPredicate:[NSPredicate predicateWithFormat:@"(accountId like %@) and snoozeDate!=nil", accountId]];
    }
    else
    {
        [request setPredicate:[NSPredicate predicateWithFormat:@"snoozeDate!=nil"]];
    }
    
    [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"lastMessageDate" ascending:NO]]];
    
    NSArray *threads = [[self mainContext] executeFetchRequest:request error:&err];
    
    return threads;
    
}

-(NSArray *)getContactsWithKeyword:(NSString *)keyword namespaceId:(NSString*)namespaceId {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"DBContact"];
    
    if(keyword)
    {
        NSString *keywordString = [NSString stringWithFormat:@"*%@*", keyword];
        [request setPredicate:[NSPredicate predicateWithFormat:@"(account_id like %@ or account_id=='phonecontact') and ((name like[cd] %@) or (email like[cd] %@))", namespaceId, keywordString, keywordString]];
    } else {
        [request setPredicate:[NSPredicate predicateWithFormat:@"account_id like %@ or account_id=='phonecontact'", namespaceId]];
    }
    
    NSError *error;
    NSArray *results = [[self mainContext] executeFetchRequest:request error:&error];
    
    return results;
    
}

-(NSArray *)getMessagesWithThreadId:(NSString *)threadId
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"DBMessage"];
    
    if(threadId)
        [request setPredicate:[NSPredicate predicateWithFormat:@"thread_id == %@", threadId]];
    [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]];
    
    
    NSError *error;
    NSArray *results = [[self mainContext] executeFetchRequest:request error:&error];
    
    return results;
}
-(void)getMessagesWithThreadIdInBackground:(NSString *)threadId context:(NSManagedObjectContext*)context completion:(void (^)(NSArray *))handler
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"DBMessage"];
    
    if(threadId)
        [request setPredicate:[NSPredicate predicateWithFormat:@"thread_id == %@", threadId]];
    [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]];
    
    
    [context performBlock:^{
        NSError *error;
        NSArray *results = [context executeFetchRequest:request error:&error];
        
        
        [self.mainContext performBlock:^{
            if(results)
            {
                NSMutableArray *messages = [NSMutableArray new];
                for(NSManagedObject *obj in results)
                {
                    DBMessage *message = [self.mainContext objectWithID:obj.objectID];
                    [messages addObject:message];
                    DLog(@"DBMessageID in DBManager %@,%@", message.id, message.thread_id);
                }
                
                if(handler)
                    handler(messages);
            }
            else
            {
                if(handler)
                    handler(nil);
            }
            
        }];
        
    }];
    
}

-(DBMessage *)getMessageWithMessageId:(NSString *)messageId
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"DBMessage"];
    
    if(messageId)
        [request setPredicate:[NSPredicate predicateWithFormat:@"id == %@", messageId]];
    
    
    
    NSError *error;
    NSArray *results = [[self mainContext] executeFetchRequest:request error:&error];
    
    if(results.count)
        return results[0];
    return nil;
}
-(NSArray *)getEventsWithMessageId:(NSString *)messageId
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"DBEvent"];
    
    if(messageId)
        [request setPredicate:[NSPredicate predicateWithFormat:@"message_id == %@", messageId]];
    
    
    NSError *error;
    NSArray *results = [[self mainContext] executeFetchRequest:request error:&error];
    
    return results;
}
-(void)getEventsWithMessageIdInBackground:(NSString *)messageId context:(NSManagedObjectContext*)context completion:(void (^)(NSArray *))handler
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"DBEvent"];
    
    if(messageId)
        [request setPredicate:[NSPredicate predicateWithFormat:@"message_id == %@", messageId]];
    
    
    [context performBlock:^{
        
        NSError *error;
        NSArray *results = [context executeFetchRequest:request error:&error];
        
        [self.mainContext performBlock:^{
            if(results)
            {
                NSMutableArray *events = [NSMutableArray new];
                for(NSManagedObject *obj in results)
                {
                    DBEvent *event = [self.mainContext objectWithID:obj.objectID];
                    [events addObject:event];
                }
                if(handler)
                    handler(events);
            }
            else
            {
                if(handler)
                    handler(nil);
            }
        }];
        
    }];
}
-(void)getMailAdditionalInfoWithMessageIdInBackground:(NSString *)messageId context:(NSManagedObjectContext*)context completion:(void (^)(DBMailAdditionalInfo *))handler
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"DBMailAdditionalInfo"];
    
    if(messageId)
        [request setPredicate:[NSPredicate predicateWithFormat:@"messageId == %@", messageId]];
    
    
    [context performBlock:^{
        
        NSError *error;
        NSArray *results = [context executeFetchRequest:request error:&error];
        
        [self.mainContext performBlock:^{
            if(results && results.count)
            {
                NSManagedObject *obj = results[0];
                DBMailAdditionalInfo *info = [self.mainContext objectWithID:obj.objectID];
                if(handler)
                    handler(info);
            }
            else
            {
                if(handler)
                    handler(nil);
            }
        }];
        
    }];
}

-(void)getMailAdditionalInfoWithThreadIdInBackground:(NSString *)threadId context:(NSManagedObjectContext*)context completion:(void (^)(DBMailAdditionalInfo *))handler
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"DBMailAdditionalInfo"];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"threadId == %@", threadId]];
    [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]];
    
    [context performBlock:^{
        
        NSError *error;
        NSArray *results = [context executeFetchRequest:request error:&error];
        
        [self.mainContext performBlock:^{
            if(results && results.count)
            {
                NSManagedObject *obj = results[0];
                DBMailAdditionalInfo *info = [self.mainContext objectWithID:obj.objectID];
                if(handler)
                    handler(info);
            }
            else
            {
                if(handler)
                    handler(nil);
            }
        }];
        
    }];
}
-(NSArray *)getMessagesWithAnyEmail:(NSString *)email namespaceId:(NSString*)namespaceId
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"DBMessage"];
    
    
    if(email)
    {
        NSString *keyword = [NSString stringWithFormat:@"*\"%@\"*", email];
        
        [request setPredicate:[NSPredicate predicateWithFormat:@"(account_id like %@) and ((from like[cd] %@) or (to like[cd] %@) or (cc like[cd] %@) or (bcc like[cd] %@))", namespaceId, keyword, keyword, keyword, keyword]];
        
    } else {
        [request setPredicate:[NSPredicate predicateWithFormat:@"(account_id like %@)", namespaceId]];
    }
    
    [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]];
    
    
    NSError *error;
    NSArray *results = [[self mainContext] executeFetchRequest:request error:&error];
    
    return results;
}

-(NSArray*)getSavedContacts
{
    NSError *lError;
    NSFetchRequest *lFetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DBSavedContact" inManagedObjectContext:self.mainContext];
    [lFetchRequest setEntity:entity];
    [lFetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
    
    NSArray *results = [self.mainContext executeFetchRequest:lFetchRequest error:&lError];
    
    return results;
}

-(NSArray*)getSavedContactsWithType:(NSString *)contactType
{
    NSError *lError;
    NSFetchRequest *lFetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DBSavedContact" inManagedObjectContext:self.mainContext];
    [lFetchRequest setEntity:entity];
    
    if(contactType)
        [lFetchRequest setPredicate:[NSPredicate predicateWithFormat:@"id contains %@", contactType]];
    
    //[lFetchRequest setFetchLimit:10];
    [lFetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
    
    NSArray *results = [self.mainContext executeFetchRequest:lFetchRequest error:&lError];
    
    return results;
}

-(void)getSavedContactsWithTypeInBackground:(NSString *)contactType completion:(void (^)(NSArray *))handler
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"DBSavedContact"];
    
    if(contactType)
        [request setPredicate:[NSPredicate predicateWithFormat:@"id contains %@", contactType]];
    
    NSManagedObjectContext *context = [self workerContext];
    
    [context performBlock:^{
        
        NSError *error;
        NSArray *results = [context executeFetchRequest:request error:&error];
        
        [self.mainContext performBlock:^{
            if(results)
            {
                NSMutableArray *contacts = [NSMutableArray new];
                for(NSManagedObject *obj in results)
                {
                    DBSavedContact *contact = [self.mainContext objectWithID:obj.objectID];
                    [contacts addObject:contact];
                }
                if(handler)
                    handler(contacts);
            }
            else
            {
                if(handler)
                    handler(nil);
            }
        }];
        
    }];
}

-(NSArray*)getSavedContactsWithType:(NSString *)contactType offset:(NSInteger)offset limit:(NSInteger)limit
{
    NSError *lError;
    NSFetchRequest *lFetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DBSavedContact" inManagedObjectContext:[self mainContext]];
    [lFetchRequest setEntity:entity];
    
    if(contactType)
        [lFetchRequest setPredicate:[NSPredicate predicateWithFormat:@"id contains %@", contactType]];
    
    [lFetchRequest setFetchOffset:offset];
    [lFetchRequest setFetchLimit:limit];
    [lFetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
    
    NSArray *results = [[self mainContext] executeFetchRequest:lFetchRequest error:&lError];
    
    return results;
}
+ (void)deleteAllDataFromDB {
    DBManager *lDBManager = [DBManager instance];
    
    NSFetchRequest * allCars = [[NSFetchRequest alloc] init];
    [allCars setEntity:[NSEntityDescription entityForName:@"DBNamespace" inManagedObjectContext:lDBManager.mainContext]];
    [allCars setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError * error = nil;
    NSArray * cars = [lDBManager.mainContext executeFetchRequest:allCars error:&error];
    //error handling goes here
    for (NSManagedObject * car in cars) {
        [lDBManager.mainContext deleteObject:car];
    }
    NSError *saveError = nil;
    [lDBManager.mainContext save:&saveError];
}

+ (void)deleteAllInboxMailModelFromDB {
    DBManager *lDBManager = [DBManager instance];
    
    NSFetchRequest * allInboxMailModels = [[NSFetchRequest alloc] init];
    [allInboxMailModels setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    [allInboxMailModels setEntity:[NSEntityDescription entityForName:@"DBThread" inManagedObjectContext:lDBManager.mainContext]];

    NSError * error = nil;
    NSArray * inboxMailModels = [lDBManager.mainContext executeFetchRequest:allInboxMailModels error:&error];
    //error handling goes here
    for (NSManagedObject * car in inboxMailModels) {
        [lDBManager.mainContext deleteObject:car];
    }
    NSError *saveError = nil;
    [lDBManager.mainContext save:&saveError];
}

+ (void)deleteNamespace:(DBNamespace *)item {
    
    NSString *accountId = item.account_id;
    [[DBManager instance] deleteAccountData:accountId];
    
    [[DBManager instance].mainContext deleteObject:item];
    
    [[DBManager instance] save];
}

- (void)deleteAccountData:(NSString *)accountId
{
    // Delete inbox contents of this account
    NSArray *inboxModels = [self getInboxMailModelsWithParams:nil namespaceId:accountId];
    
    for(DBThread *inboxModel in inboxModels)
    {
        // Delete messages of this inbox model
        NSArray *messages = [self getMessagesWithThreadId:inboxModel.id];
        for(DBMessage *message in messages)
        {
            [DBMessage deleteModel:message];
        }
        
        [DBThread deleteModel:inboxModel];
    }
    
    // Delete events of this account
    NSArray *events = [DBEvent getEventsWithAccountId:accountId params:nil];
    
    for(DBEvent *event in events)
    {
        [DBEvent deleteModel:event];
    }
    
    // Delete calendars of this account
    NSArray *calendars = [DBCalendar getCalendarsWithAccountId:accountId];
    
    for(DBCalendar *calendar in calendars)
    {
        [DBCalendar deleteModel:calendar];
    }
    
}
#pragma mark - instance

+ (DBManager *)instance {
    static DBManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [DBManager new];
    });
    return instance;
}

- (NSArray *)getAccounts
{
    NSManagedObjectContext *context = self.mainContext;
    NSFetchRequest *lFetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DBAccount" inManagedObjectContext:context];
    [lFetchRequest setEntity:entity];
   
    
    NSError *error;
    
    NSArray *accounts = [context executeFetchRequest:lFetchRequest error:&error];
    
    return accounts;
}

- (NSArray *)getAccountsByProvider:(NSString *)provider
{
    NSManagedObjectContext *context = self.mainContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DBAccount" inManagedObjectContext:context];
    [request setEntity:entity];
    [request setPredicate:[NSPredicate predicateWithFormat:@"provider == %@", provider]];
    
    NSError *error;
    NSArray *accounts = [context executeFetchRequest:request error:&error];
    
    
    return accounts;
}

-(NSArray*)getTracks:(NSString *)email trackStatus:(NSString *)status time:(NSString *)time
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"DBTrack"];
    
    NSMutableArray *predicates = [NSMutableArray new];
    [predicates addObject:[NSPredicate predicateWithFormat:@"ownerEmail==%@", email]];
    
    if(status)
    {
        if([status isEqualToString:EMAIL_TRACKING_OPENED])
            [predicates addObject:[NSPredicate predicateWithFormat:@"opens>0"]];
        else if([status isEqualToString:EMAIL_TRACKING_UNOPENED])
            [predicates addObject:[NSPredicate predicateWithFormat:@"(opens==nil or opens==0)"]];
    }
    
    if(time)
    {
        NSDateComponents* comps = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
        NSDate *today = [[NSCalendar currentCalendar] dateFromComponents:comps];
        
        if([time isEqualToString:EMAIL_TRACKING_TODAY])
        {
            [predicates addObject:[NSPredicate predicateWithFormat:@"(modifiedTime>=%@ and modifiedTime<=%@)", today, [NSDate dateWithTimeInterval:24*60*60 sinceDate:today]]];
        }
        else if([time isEqualToString:EMAIL_TRACKING_LAST7])
        {
            [predicates addObject:[NSPredicate predicateWithFormat:@"(modifiedTime>=%@ and modifiedTime<=%@)", [NSDate dateWithTimeInterval:-7*24*60*60 sinceDate:today], [NSDate dateWithTimeInterval:24*60*60 sinceDate:today]]];
        }
        else if([time isEqualToString:EMAIL_TRACKING_LAST31])
        {
            [predicates addObject:[NSPredicate predicateWithFormat:@"(modifiedTime>=%@ and modifiedTime<=%@)", [NSDate dateWithTimeInterval:-31*24*60*60 sinceDate:today], [NSDate dateWithTimeInterval:24*60*60 sinceDate:today]]];
        }
    }
    
    [request setPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:predicates]];

    [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"modifiedTime" ascending:NO]]];
    
    NSError *error;
    NSArray *results = [self.mainContext executeFetchRequest:request error:&error];
    
    return results;
}
-(NSArray*)getTrackDetails:(NSNumber *)trackId
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"DBTrackDetail"];
    
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"trackId == %@", trackId]];
    [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdTime" ascending:NO]]];
    
    NSError *error;
    NSArray *results = [self.mainContext executeFetchRequest:request error:&error];
    
    return results;
}

-(NSInteger)getUnreadCountWithAccountId:(NSString *)accountId
{
    
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"DBThread"];
    
    if(accountId)
    {
        [request setPredicate:[NSPredicate predicateWithFormat:@"accountId == %@ AND isUnread=TRUE", accountId]];
    }
    else
    {
        [request setPredicate:[NSPredicate predicateWithFormat:@"isUnread=TRUE", accountId]];
    }
    
    
    
    NSError *error;
    NSArray *results = [self.mainContext executeFetchRequest:request error:&error];
    
    return results.count;
}

-(NSInteger)getUnreadCountForFolder:(NSString *)folderId
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"DBThread"];
    
    
    NSString *folderKey = [NSString stringWithFormat:@"*\"%@\"*", folderId];
    [request setPredicate:[NSPredicate predicateWithFormat:@"folders like[cd] %@ and isUnread=TRUE", folderKey, folderKey]];
    
    
    NSError *error;
    NSArray *results = [self.mainContext executeFetchRequest:request error:&error];
    
    return results.count;
}

-(void)deleteSalesforceContacts
{
    
    NSArray *dbSalesforceContacts = [self getSavedContactsWithType:CONTACT_TYPE_SALESFORCE];
    
    for(NSManagedObject *item in dbSalesforceContacts)
    {
        [self.mainContext deleteObject:item];
    }
    
    NSError *saveError = nil;
    [self.mainContext save:&saveError];
}

-(NSArray *)getFromItemsInFolder:(NSString *)folder forAccount:(NSString*)accountId
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"DBMessage"];
    
    NSString *folderKey = [NSString stringWithFormat:@"*\"%@\"*", folder];
    [request setPredicate:[NSPredicate predicateWithFormat:@"account_id == %@ and (folder like[cd] %@ or labels like[cd] %@)", accountId, folderKey, folderKey]];
    
    
    NSError *error;
    NSArray *results = [[self mainContext] executeFetchRequest:request error:&error];
    
    NSMutableArray *emails = [NSMutableArray new];
    NSMutableArray *items = [NSMutableArray new];
    for(DBMessage *message in results)
    {
        DLog(@"Message Folder:%@", message.folder);
        NSDictionary *from = [message getFrom];
        if(from)
        {
            NSString *email = from[@"email"];
            
            if(![emails containsObject:email])
            {
                [items addObject:from];
                [emails addObject:email];
            }
        }
    }
    return items;
}

-(NSArray *)getFoldersForAccount:(NSString *)accountId
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"DBFolder"];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"accountId==%@", accountId]];
    
    
    NSError *error;
    NSArray *results = [[self mainContext] executeFetchRequest:request error:&error];
    
    NSMutableArray *standardFolders = [NSMutableArray new];
    NSMutableArray *userFolders = [NSMutableArray new];
    
    for(DBFolder *folder in results)
    {
        DLog(@"Folder:%@", folder);
        
        if([folder.name containsString:@"calendar"] || [folder.name containsString:@"contact"])
            continue;
        
        if(folder.name.length > 0 && ![folder.name isEqualToString:@"user_created_folder"])
            [standardFolders addObject:[folder toDictionary]];
        else
            [userFolders addObject:[folder toDictionary]];
    }
    
    
    
    NSDictionary *tags = orderByFolder;
    NSArray *sortedStandardFolders = [standardFolders sortedArrayUsingComparator:^(NSDictionary *obj1, NSDictionary *obj2) {
        NSString *num1 =[tags objectForKey:[obj1 objectForKey:@"name"]];
        NSString *num2 =[tags objectForKey:[obj2 objectForKey:@"name"]];
        return (NSComparisonResult) [num1 compare:num2 options:(NSNumericSearch)];
    }];
    
    NSArray *sortedUserFolders = [userFolders sortedArrayUsingComparator:^(NSDictionary *obj1, NSDictionary *obj2) {
        NSString *num1 =[obj1 objectForKey:@"display_name"];
        NSString *num2 =[obj2 objectForKey:@"display_name"];
        return (NSComparisonResult) [num1 compare:num2];
    }];
    
    NSMutableArray *folders = [NSMutableArray new];
    [folders addObjectsFromArray:sortedStandardFolders];
    [folders addObjectsFromArray:sortedUserFolders];
    
    return folders;
}

-(DBFolder *)getFolderForAccount:(NSString *)accountId folderName:(NSString *)folderName
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"DBFolder"];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"accountId==%@ AND displayName like[c] %@", accountId, [NSString stringWithFormat:@"*%@*",folderName]]];
    
    
    NSError *error;
    NSArray *results = [[self mainContext] executeFetchRequest:request error:&error];
    
    if(results && results.count) return results[0];
    
    return nil;
}

- (DBThread *)getThreadWithMessageId:(NSString *)messageId
{
    
    NSError *error = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"DBThread"];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"messageIds like[cd] %@", [NSString stringWithFormat:@"*%@*",messageId]]];
    
    NSArray *results = [[self mainContext] executeFetchRequest:request error:&error];
    
    if(results.count>0) return (DBThread*)results[0];
    return nil;

}
@end
