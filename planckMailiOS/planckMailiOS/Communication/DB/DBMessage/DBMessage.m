//
//  DBMessage.m
//  planckMailiOS
//
//  Created by Matko Lajbaher on 11/19/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "DBMessage.h"
#import "DBThread.h"
#import "DBNamespace.h"
#import "DBManager.h"
#import "PMEventModel.h"
#import "DBMailAdditionalInfo.h"
#import "PMAPIManager.h"
#import "PMSettingsManager.h"

#define DB_MESSAGE @"DBMessage"
@implementation DBMessage

// Insert code here to add functionality to your managed object subclass


+ (DBMessage*)createOrUpdateMessageFromDictionary:(NSDictionary*)dic onContext:(NSManagedObjectContext*)context
{
    
    NSString *messageId = dic[@"id"];
    
    DBMessage *dbMessage = [DBMessage getMessageWithId:messageId context:context];
    if(!dbMessage)
        dbMessage = (DBMessage *)[NSEntityDescription insertNewObjectForEntityForName:DB_MESSAGE inManagedObjectContext:context];
    
    dbMessage.id = dic[@"id"];
    
    dbMessage.object = dic[@"object"];
    
    dbMessage.account_id = dic[@"namespace_id"]?dic[@"namespace_id"]:dic[@"account_id"];
    
    dbMessage.thread_id = dic[@"thread_id"];
    
    dbMessage.subject = dic[@"subject"];
    
    dbMessage.date = dic[@"date"];
    
    dbMessage.unread = dic[@"unread"];
    
    dbMessage.starred = dic[@"starred"];
    
    dbMessage.snippet = dic[@"snippet"];
    
    dbMessage.body = dic[@"body"];
    
    
    NSMutableDictionary *info = [NSMutableDictionary new];      // Mail Additional Info Data
    
    [info setObject:dic[@"id"] forKey:@"message_id"];
    
    [info setObject:dic[@"thread_id"] forKey:@"thread_id"];
    
    [info setObject:dic[@"date"] forKey:@"date"];
    
    
    
    NSString *myEmail = [[PMAPIManager shared] namespaceId].email_address;
    
    
    
    NSArray *from = dic[@"from"];
    
    if(from && ![from isEqual:[NSNull null]] && from.count>0)
        
    {
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:from
                            
                                                           options:NSJSONWritingPrettyPrinted
                            
                                                             error:nil];
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        dbMessage.from = jsonString;
        
        
        
        NSArray *salesforceEmails = [[PMSettingsManager instance] getSalesforceEmails];
        
        for(NSDictionary *item in from)
            
        {
            
            NSString *email = item[@"email"];
            
            if([email isEqualToString:myEmail]) continue;
            
            if([salesforceEmails containsObject:email])
                
            {
                
                [info setObject:@(YES) forKey:@"salesforce"];
                
                break;
                
            }
            
        }
        
    }
    
    NSArray *to = dic[@"to"];
    
    if(to && ![to isEqual:[NSNull null]] &&  to.count>0)
        
    {
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:to
                            
                                                           options:NSJSONWritingPrettyPrinted
                            
                                                             error:nil];
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        dbMessage.to = jsonString;
        
        
        
        
        
    }
    
    NSArray *cc = dic[@"cc"];
    
    if(cc && ![cc isEqual:[NSNull null]] &&  cc.count>0)
        
    {
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:cc
                            
                                                           options:NSJSONWritingPrettyPrinted
                            
                                                             error:nil];
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        dbMessage.cc = jsonString;
        
    }
    
    NSArray *bcc = dic[@"bcc"];
    
    if(bcc && ![bcc isEqual:[NSNull null]] &&  bcc.count>0)
        
    {
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bcc
                            
                                                           options:NSJSONWritingPrettyPrinted
                            
                                                             error:nil];
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        dbMessage.bcc = jsonString;
        
    }
    
    NSArray *replyTo = dic[@"reply_to"];
    
    if(replyTo && ![replyTo isEqual:[NSNull null]] &&  replyTo.count>0)
        
    {
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:replyTo
                            
                                                           options:NSJSONWritingPrettyPrinted
                            
                                                             error:nil];
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        dbMessage.reply_to = jsonString;
        
    }
    
    
    
    NSDictionary *folder = dic[@"folder"];
    
    if(folder && ![folder isEqual:[NSNull null]] &&  folder.count>0)
        
    {
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:folder
                            
                                                           options:NSJSONWritingPrettyPrinted
                            
                                                             error:nil];
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        dbMessage.folder = jsonString;
        
    }
    
    
    
    NSDictionary *labels = dic[@"labels"];
    
    if(labels && ![labels isEqual:[NSNull null]] &&  labels.count>0)
        
    {
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:labels
                            
                                                           options:NSJSONWritingPrettyPrinted
                            
                                                             error:nil];
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        dbMessage.labels = jsonString;
        
    }
    
    
    
    NSArray *files = dic[@"files"];
    
    if(files && ![files isEqual:[NSNull null]] &&  files.count>0)
        
    {
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:files
                            
                                                           options:NSJSONWritingPrettyPrinted
                            
                                                             error:nil];
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        dbMessage.files = jsonString;
        
    }
    
    NSArray *events = dic[@"events"];
    
    if(events && ![events isEqual:[NSNull null]] &&  events.count>0)
        
    {
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:events
                            
                                                           options:NSJSONWritingPrettyPrinted
                            
                                                             error:nil];
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        dbMessage.events = jsonString;
        
        
        
        
        
        for(NSDictionary *event in events)
            
        {
            if([event isKindOfClass:[NSDictionary class]])
            {
                DBEvent *eventModel = [DBEvent createOrUpdateEventWithData:event onContext:context];
                
                [info setObject:eventModel.start_time forKey:@"start_time"];
                [info setObject:eventModel.end_time forKey:@"end_time"];
                
                for(NSDictionary *participant in event[@"participants"])
                {
                    if([participant[@"email"] isEqualToString:myEmail])
                    {
                        [info setObject:participant[@"status"] forKey:@"status"];
                        
                        break;
                    }
                }
            }
        }
        
    }
    [DBMailAdditionalInfo createOrUpdateMailAdditionalInfoWithData:info onContext:context];
    
    return nil;
    
}
+ (DBMessage *)getMessageWithId:(NSString *)id {
    
    DBManager *dbManager = [DBManager instance];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:DB_MESSAGE];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"id == %@", id]];
    
    NSError *error;
    NSArray *results = [[dbManager mainContext] executeFetchRequest:request error:&error];
    
    if(error==nil && results.count>0) return (DBMessage*)results[0];
    return nil;
}
+ (DBMessage *)getMessageWithId:(NSString *)id context:(NSManagedObjectContext*)context {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:DB_MESSAGE];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"id == %@", id]];
    
    NSError *error;
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    if(error==nil && results.count>0) return (DBMessage*)results[0];
    return nil;
}

+ (void)getMessageInBackground:(NSString *)messageId context:(NSManagedObjectContext*)context completion:(void (^)(DBMessage *message))handler
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:DB_MESSAGE];
    
    if(messageId)
        [request setPredicate:[NSPredicate predicateWithFormat:@"id == %@", messageId]];
    
    
    [context performBlock:^{
        
        NSError *error;
        NSArray *results = [context executeFetchRequest:request error:&error];
        
        NSManagedObjectContext *mainContext = [DBManager instance].mainContext;
        [mainContext performBlock:^{
            if(results && results.count)
            {
                NSManagedObject *obj = results[0];
                DBMessage *message = [mainContext objectWithID:obj.objectID];
                if(handler)
                    handler(message);
            }
            else
            {
                if(handler)
                    handler(nil);
            }
        }];
        
    }];
}
+ (void)deleteModel:(DBMessage *)model
{
    [[DBManager instance].mainContext deleteObject:model];
    [[DBManager instance] save];
}
-(NSDictionary*)convertToDictionary
{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    [dict setObject:self.id forKey:@"id"];
    [dict setObject:self.object forKey:@"object"];
    [dict setObject:self.account_id forKey:@"namespace_id"];
    [dict setObject:self.thread_id forKey:@"thread_id"];
    [dict setObject:self.subject forKey:@"subject"];
    [dict setObject:self.date forKey:@"date"];
    [dict setObject:self.unread forKey:@"unread"];
    [dict setObject:self.starred forKey:@"starred"];
    [dict setObject:self.snippet forKey:@"snippet"];
    [dict setObject:self.body forKey:@"body"];
    
    if(self.from && self.from.length>0)
    {
        
        NSData *jsonData = [self.from dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *from = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                options:NSJSONReadingMutableContainers
                                                                  error:nil];
        
        [dict setObject:from forKey:@"from"];
    }
    if(self.to && self.to.length>0)
    {
        
        NSData *jsonData = [self.to dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *to = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:nil];
        
        [dict setObject:to forKey:@"to"];
    }
    if(self.cc && self.cc.length>0)
    {
        
        NSData *jsonData = [self.cc dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *cc = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:nil];
        
        [dict setObject:cc forKey:@"cc"];
    }
    if(self.bcc && self.bcc.length>0)
    {
        
        NSData *jsonData = [self.bcc dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *bcc = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:nil];
        
        [dict setObject:bcc forKey:@"bcc"];
    }
    if(self.reply_to && self.reply_to.length>0)
    {
        
        NSData *jsonData = [self.reply_to dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *reply_to = [NSJSONSerialization JSONObjectWithData:jsonData
                                                       options:NSJSONReadingMutableContainers
                                                         error:nil];
        
        [dict setObject:reply_to forKey:@"reply_to"];
    }
    if(self.folder && self.folder.length>0)
    {
        
        NSData *jsonData = [self.folder dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *folder = [NSJSONSerialization JSONObjectWithData:jsonData
                                                       options:NSJSONReadingMutableContainers
                                                         error:nil];
        
        [dict setObject:folder forKey:@"folder"];
    }
    if(self.labels && self.labels.length>0)
    {
        
        NSData *jsonData = [self.labels dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *labels = [NSJSONSerialization JSONObjectWithData:jsonData
                                                               options:NSJSONReadingMutableContainers
                                                                 error:nil];
        
        [dict setObject:labels forKey:@"labels"];
    }
    if(self.files && self.files.length>0)
    {
        
        NSData *jsonData = [self.files dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *files = [NSJSONSerialization JSONObjectWithData:jsonData
                                                       options:NSJSONReadingMutableContainers
                                                         error:nil];
        
        [dict setObject:files forKey:@"files"];
    }
    if(self.events && self.events.length>0)
    {
        
        NSData *jsonData = [self.events dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *events = [NSJSONSerialization JSONObjectWithData:jsonData
                                                       options:NSJSONReadingMutableContainers
                                                         error:nil];
        
        [dict setObject:events forKey:@"events"];
    }
    
    return dict;
    
}

-(NSArray*)getEventArray
{
    if(self.events && self.events.length>0)
    {
        
        NSData *jsonData = [self.events dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *events = [NSJSONSerialization JSONObjectWithData:jsonData
                                                          options:NSJSONReadingMutableContainers
                                                            error:nil];
        
        return events;
    }
    
    return nil;
}

-(NSArray*)getFileArray
{
    if(self.files && self.files.length>0)
    {
        
        NSData *jsonData = [self.files dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *files = [NSJSONSerialization JSONObjectWithData:jsonData
                                                         options:NSJSONReadingMutableContainers
                                                           error:nil];
        
        return files;
    }
    
    return nil;
}

-(NSDictionary*)getFrom
{
    if(self.from && self.from.length>0)
    {
        NSData *jsonData = [self.from dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *from = [NSJSONSerialization JSONObjectWithData:jsonData
                                                         options:NSJSONReadingMutableContainers
                                                           error:nil];
        
        if(from.count) return from[0];
    }
    
    return nil;
}
-(NSArray*)getFromArray
{
    if(self.from && self.from.length>0)
    {
        NSData *jsonData = [self.from dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *from = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:nil];
        
        return from;
    }
    
    return nil;
}
@end
