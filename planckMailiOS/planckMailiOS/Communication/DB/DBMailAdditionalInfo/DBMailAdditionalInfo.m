//
//  DBMailAdditionalInfo.m
//  planckMailiOS
//
//  Created by LionStar on 2/23/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import "DBMailAdditionalInfo.h"
#import "DBManager.h"

#define DB_MAIL_ADDITIONAL_INFO @"DBMailAdditionalInfo"

@implementation DBMailAdditionalInfo

// Insert code here to add functionality to your managed object subclass
+ (DBMailAdditionalInfo*)createOrUpdateMailAdditionalInfoWithData:(NSDictionary*)data onContext:(NSManagedObjectContext*)context
{
    
    NSString *messageId = notNullStrValue(data[@"message_id"]);
    if(!messageId)
    {
        return nil;
    }
    
    
    DBMailAdditionalInfo *info = [DBMailAdditionalInfo getMailAdditionalInfoWithMessageId:messageId context:context];
    
    
    if(!info)
        info = (DBMailAdditionalInfo *)[NSEntityDescription insertNewObjectForEntityForName:DB_MAIL_ADDITIONAL_INFO inManagedObjectContext:context];
    
    info.messageId = messageId;
    info.threadId = data[@"thread_id"];
    info.salesforce = data[@"salesforce"];
    info.startTime = data[@"start_time"];
    info.endTime = data[@"end_time"];
    info.status = data[@"status"];
    info.date = data[@"date"];
    
    return info;
}

+ (DBMailAdditionalInfo *)getMailAdditionalInfoWithMessageId:(NSString *)messageId {
    
    DBManager *dbManager = [DBManager instance];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:DB_MAIL_ADDITIONAL_INFO];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"messageId == %@", messageId]];
    
    NSError *error;
    NSArray *results = [[dbManager mainContext] executeFetchRequest:request error:&error];
    
    if(error==nil && results.count>0) return (DBMailAdditionalInfo*)results[0];
    return nil;
}
+ (DBMailAdditionalInfo *)getMailAdditionalInfoWithMessageId:(NSString *)messageId context:(NSManagedObjectContext*)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:DB_MAIL_ADDITIONAL_INFO];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"messageId == %@", messageId]];
    
    NSError *error;
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    if(error==nil && results.count>0) return (DBMailAdditionalInfo*)results[0];
    return nil;
}



+ (DBMailAdditionalInfo *)getMailAdditionalInfoWithThreadId:(NSString *)threadId {
    
    DBManager *dbManager = [DBManager instance];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:DB_MAIL_ADDITIONAL_INFO];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"threadId == %@", threadId]];
    [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]];
    
    NSError *error;
    NSArray *results = [[dbManager mainContext] executeFetchRequest:request error:&error];
    
    if(error==nil && results.count>0) return (DBMailAdditionalInfo*)results[0];
    return nil;
}
+ (DBMailAdditionalInfo *)getMailAdditionalInfoWithThreadId:(NSString *)threadId context:(NSManagedObjectContext*)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:DB_MAIL_ADDITIONAL_INFO];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"threadId == %@", threadId]];
    [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]];
    
    NSError *error;
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    if(error==nil && results.count>0) return (DBMailAdditionalInfo*)results[0];
    return nil;
}

- (NSDictionary*)convertToDictionary
{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    [dict setObject:self.messageId forKey:@"message_id"];
    [dict setObject:self.threadId forKey:@"thread_id"];
    [dict setObject:self.date forKey:@"date"];
    if(self.startTime)
        [dict setObject:self.startTime forKey:@"start_time"];
    if(self.endTime)
        [dict setObject:self.endTime forKey:@"end_time"];
    if(self.status)
        [dict setObject:self.status forKey:@"status"];
    if(self.salesforce)
        [dict setObject:self.salesforce forKey:@"salesforce"];
    
    return dict;
    
}
@end
