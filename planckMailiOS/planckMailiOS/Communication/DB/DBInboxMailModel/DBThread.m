//
//  DBInboxMailModel.m
//  planckMailiOS
//
//  Created by nazar on 10/29/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "DBThread.h"
#import "DBNamespace.h"
#import "DBManager.h"

#define DB_MailModel @"DBThread"

@implementation DBThread



// Insert code here to add functionality to your managed object subclass

+ (DBThread*)createOrUpdateWithData:(NSDictionary*)data
{
    DBManager *manager = [DBManager instance];
    NSString *threadId = data[@"id"];
    
    DBThread *model = [DBThread getThreadWithId:threadId];
    
    if(!model)
        model = (DBThread *)[NSEntityDescription insertNewObjectForEntityForName:DB_MailModel inManagedObjectContext:manager.mainContext];
    
    model.id = threadId;
    model.snippet = data[@"snippet"];
    model.subject = data[@"subject"];
    model.accountId = data[@"account_id"];
    model.version = data[@"version"];
    
    model.isUnread = data[@"unread"];
    model.isFlagged = data[@"starred"];
    
    
    NSTimeInterval lastTimeStamp = [data[@"last_message_timestamp"] doubleValue];
    
    model.lastMessageTimestamp = [NSNumber numberWithLong:lastTimeStamp];
    model.lastMessageDate = [NSDate dateWithTimeIntervalSince1970:lastTimeStamp];
    
    
    
    model.hasAttachments = [NSNumber numberWithBool:([data[@"has_attachments"] intValue] > 0)];
    
    
    NSArray *messageIds = data[@"message_ids"];
    if(messageIds != nil)
    {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:messageIds
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        model.messageIds = jsonString;
        
        model.messagesCount = [NSNumber numberWithInteger:messageIds.count];
        
    }
    
    NSArray *participants = data[@"participants"];
    if(participants!=nil)
    {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:participants
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        model.participants = jsonString;
    }
    
    
    
    
    DBNamespace *namespace = [DBNamespace getNamespaceWithAccountId:data[@"account_id"]];
    model.ownerEmail = namespace.email_address;
    
    NSArray *folders;
    if([namespace.organizationUnit isEqualToString:@"label"])
        folders = data[@"labels"];
    else
        folders = data[@"folders"];
    
    if(folders!=nil)
    {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:folders
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        
        model.folders = jsonString;
    }
    [manager save];
    return model;
}

+ (DBThread*)createOrUpdateFromPMThread:(PMThread *)thread onContext:(nonnull NSManagedObjectContext *)context
{
    
    NSString *threadId = thread.id;
    
    DBThread *dbThread = [DBThread getThreadWithId:threadId context:context];
    
    
    if(!dbThread)
        dbThread = (DBThread *)[NSEntityDescription insertNewObjectForEntityForName:DB_MailModel inManagedObjectContext:context];
    
    dbThread.id = threadId;
    dbThread.ownerName = thread.ownerName;
    dbThread.ownerEmail = thread.ownerEmail;
    dbThread.snippet = thread.snippet;
    dbThread.subject = thread.subject;
    dbThread.accountId = thread.accountId;
    dbThread.version = [NSNumber numberWithInteger:thread.version];
    dbThread.isUnread = [NSNumber numberWithBool:thread.isUnread];
    dbThread.isFlagged = [NSNumber numberWithBool:thread.isFlagged];
    dbThread.follow_up = @(YES);
    
    dbThread.lastMessageTimestamp = [NSNumber numberWithLong:[thread.lastMessageTimestamp integerValue]];
    dbThread.lastMessageDate = thread.lastMessageDate;
    
    
    dbThread.hasAttachments = [NSNumber numberWithBool:thread.hasAttachments];
    
    dbThread.messagesCount = @(thread.messagesCount);
    
    if(thread.messageIds!=nil)
    {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:thread.messageIds
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        dbThread.messageIds = jsonString;
    }
    
    if(thread.participants!=nil)
    {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:thread.participants
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        dbThread.participants = jsonString;
    }
    
    if(thread.folders!=nil)
    {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:thread.folders
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    
        dbThread.folders = jsonString;
    }
    
    
    return dbThread;
}

+(DBThread*)getThreadWithId:(NSString *)threadId
{
    DBManager *dbManager = [DBManager instance];
    
    NSError *error = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:DB_MailModel];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"id == %@", threadId]];
    
    NSArray *results = [[dbManager mainContext] executeFetchRequest:request error:&error];
    
    if(results.count>0) return (DBThread*)results[0];
    return nil;
}

+(DBThread*)getThreadWithId:(NSString *)threadId context:(NSManagedObjectContext*)context
{
    NSError *error = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:DB_MailModel];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"id == %@", threadId]];
    
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    if(results.count>0) return (DBThread*)results[0];
    return nil;
}

+(void) deleteWithThreadId:(NSString *)threadId
{
    DBManager *dbManager = [DBManager instance];
    
    DBThread *mailModel = [DBThread getThreadWithId:threadId];
    
    if(mailModel)
    {
        NSError *error;
        [dbManager.mainContext deleteObject:mailModel];
        [dbManager.mainContext save:&error];
    }
}

+(void) deleteModel:(DBThread *)model
{
    [[DBManager instance].mainContext deleteObject:model];
    [[DBManager instance] save];
}
-(PMThread*)toPMThread
{
    PMThread *thread = [[PMThread alloc] init];
    
    thread.ownerName = self.ownerName;
    thread.ownerEmail = self.ownerEmail;
    thread.snippet = self.snippet;
    thread.subject = self.subject;
    thread.id = self.id;
    thread.accountId = self.accountId;
    thread.lastMessageTimestamp = [self.lastMessageTimestamp stringValue];
    thread.token = self.token;

    thread.lastMessageDate = self.lastMessageDate;
    thread.version = [self.version integerValue];
    thread.isUnread = [self.isUnread boolValue];
    thread.isFlagged = [self.isFlagged boolValue];
    thread.isLoadMore = [self.isLoadMore boolValue];
    
    thread.hasAttachments = [self.hasAttachments boolValue];
    thread.messagesCount = [self.messagesCount integerValue];
    
    NSData *jsonMessageIdsData = [self.messageIds dataUsingEncoding:NSUTF8StringEncoding];
    if(jsonMessageIdsData!=nil)
    {
        NSArray *messageIds = [NSJSONSerialization JSONObjectWithData:jsonMessageIdsData
                                                                options:NSJSONReadingMutableContainers
                                                                  error:nil];
        
        thread.messageIds = messageIds;
    }
    
    NSData *jsonParticipantsData = [self.participants dataUsingEncoding:NSUTF8StringEncoding];
    if(jsonParticipantsData!=nil)
    {
        NSArray *participants = [NSJSONSerialization JSONObjectWithData:jsonParticipantsData
                                                           options:NSJSONReadingMutableContainers
                                                             error:nil];
        
        thread.participants = participants;
    }
    
    
    NSData *jsonFoldersData = [self.folders dataUsingEncoding:NSUTF8StringEncoding];
    if(jsonFoldersData!=nil)
    {
        NSArray *folders = [NSJSONSerialization JSONObjectWithData:jsonFoldersData
                                                       options:NSJSONReadingMutableContainers
                                                         error:nil];
    
        thread.folders = folders;
    }
    
    thread.snoozeDate = self.snoozeDate;
    thread.snoozeDateType = [self.snoozeDateType integerValue];
    return thread;
}
-(NSArray*)getFolders
{
    
    NSData *jsonFoldersData = [self.folders dataUsingEncoding:NSUTF8StringEncoding];
    if(jsonFoldersData!=nil)
    {
        NSArray *folders = [NSJSONSerialization JSONObjectWithData:jsonFoldersData
                                                           options:NSJSONReadingMutableContainers
                                                             error:nil];
        
        if(folders) return folders;
    }
    
    return nil;
}

-(void)setMarkRead
{
    self.isUnread = @(NO);
    
    [[DBManager instance] save];
}
-(void)setMarkUnread
{
    self.isUnread = @(YES);
    
    [[DBManager instance] save];
}

- (void)setFolder:(NSDictionary *)folder
{
    NSArray *folders = @[folder];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:folders
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    
    self.folders = jsonString;
    
    [[DBManager instance] save];
}

- (NSString*)getParticipantNames:(NSString*)myEmail
{
    NSMutableString *names = [NSMutableString new];
    
    NSMutableDictionary *participantsName = [NSMutableDictionary new];
    
    NSData *jsonParticipantsData = [self.participants dataUsingEncoding:NSUTF8StringEncoding];
    if(jsonParticipantsData!=nil)
    {
        NSArray *participants = [NSJSONSerialization JSONObjectWithData:jsonParticipantsData
                                                                options:NSJSONReadingMutableContainers
                                                                  error:nil];
        for(NSDictionary *participant in participants)
        {
            NSString *email = participant[@"email"];
            
            if([email isEqualToString:myEmail] && [self.messagesCount integerValue]==1) continue;
            
            NSString *name;
            if(![participantsName objectForKey:email])
            {
                if([email isEqualToString:myEmail])
                {
                    name = @"me";
                }
                else
                {
                    name = [participant[@"name"] isEqual:[NSNull null]] ? participant[@"email"] : participant[@"name"];
                }
                
                [participantsName setObject:name forKey:email];
                
                if(names.length>0)
                    [names appendFormat:@",%@", name];
                else
                    [names appendString:name];
            }
        }
        
    }
    
    
    
    return names;
}

-(void)setSnoozeDate:(NSDate *)date withDateType:(NSNumber*)type
{
    self.snoozeDate = date;
    self.snoozeDateType = type;
    
    [[DBManager instance] save];
}
@end
