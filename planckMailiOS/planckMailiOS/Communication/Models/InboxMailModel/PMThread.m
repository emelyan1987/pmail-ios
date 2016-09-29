//
//  PMInboxMailModel.m
//  planckMailiOS
//
//  Created by admin on 5/25/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMThread.h"
#import "Config.h"

@implementation PMThread

- (instancetype)init {
    self = [super init];
    if (self) {
        _ownerName = @"";
        _snippet = @"";
        _subject = @"";
        _accountId = @"";
        _id = @"";
        _lastMessageTimestamp = @"";
    }
    return self;
}

+ (PMThread *)initWithDicationary:(NSDictionary *)item ownerEmail:(NSString *)ownerEmail token:(NSString *)token
{
    PMThread *thread = [PMThread new];
    thread.snippet = item[@"snippet"];
    thread.subject = item[@"subject"];
    thread.accountId = item[@"account_id"];
    thread.id = item[@"id"];
    thread.version = [item[@"version"] unsignedIntegerValue];
    thread.messageIds = item[@"message_ids"];
    
    if(item[@"labels"])
    {
        thread.folders = item[@"labels"];
    }
    else if(item[@"folders"])
    {
        thread.folders = item[@"folders"];
    }
    
    thread.isUnread = NO;
    
    NSTimeInterval lastTimeStamp = [item[@"last_message_timestamp"] doubleValue];
    thread.lastMessageDate = [NSDate dateWithTimeIntervalSince1970:lastTimeStamp];
    
    NSArray *lTagsArray =  item[@"tags"];
    
    for (NSDictionary *itemTag in lTagsArray) {
        if ([itemTag[@"id"] isEqualToString:@"unread"]) {
            thread.isUnread = YES;
        }
    }
    
    NSArray *participants = item[@"participants"];
    thread.ownerEmail = ownerEmail;
    for (NSDictionary *user in participants)
    {
        if (![user[@"email"] isEqualToString:ownerEmail])
        {
            thread.ownerName = user[@"name"]&&((NSString*)user[@"name"]).length?user[@"name"]:user[@"email"];
            break;
        }
    }
    
    thread.participants = participants;
    thread.token = token;
    
    thread.hasAttachments = [item[@"has_attachments"] intValue] > 0;
    thread.isFlagged = [item[@"starred"] boolValue];
    
    NSArray *messageIds = item[@"message_ids"];
    thread.messagesCount = messageIds.count;
    
    
    
    NSNumber *lastMessageTimestamp = [item[@"object"] isEqualToString:@"draft"]?item[@"date"]:item[@"last_message_timestamp"];
    
    thread.lastMessageDate = [NSDate dateWithTimeIntervalSince1970:[lastMessageTimestamp doubleValue]];
    
    thread.lastMessageTimestamp = [lastMessageTimestamp stringValue];
    
    return thread;
}

+ (BOOL)supportsSecureCoding {
  return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_ownerEmail forKey:@"owner_email"];
    [aCoder encodeObject:_ownerName forKey:@"owner_name"];
    [aCoder encodeObject:_snippet forKey:@"snippet"];
    [aCoder encodeObject:_subject forKey:@"subject"];
    [aCoder encodeObject:_id forKey:@"id"];
    [aCoder encodeObject:_accountId forKey:@"account_id"];
    [aCoder encodeObject:_token forKey:@"token"];
    [aCoder encodeBool:_isUnread forKey:@"isUnread"];
    [aCoder encodeObject:_lastMessageDate forKey:@"last_message_date"];
    [aCoder encodeObject:_snoozeDate forKey:@"snooze_date"];
    [aCoder encodeObject:[NSNumber numberWithInt:_snoozeDateType] forKey:@"snooze_date_type"];
    [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:_version] forKey:@"version"];
    [aCoder encodeObject:_messageIds forKey:@"message_ids"];
    [aCoder encodeObject:_folders forKey:@"folders"];
    [aCoder encodeObject:_participants forKey:@"participants"];

}

- (id)initWithCoder:(NSCoder *)aDecoder {
    PMThread *thread = [PMThread new];
    thread.ownerEmail = [aDecoder decodeObjectForKey:@"owner_email"];
    thread.ownerName = [aDecoder decodeObjectForKey:@"owner_name"];
    thread.snippet = [aDecoder decodeObjectForKey:@"snippet"];
    thread.subject = [aDecoder decodeObjectForKey:@"subject"];
    thread.id = [aDecoder decodeObjectForKey:@"id"];
    thread.accountId = [aDecoder decodeObjectForKey:@"account_id"];
    thread.token = [aDecoder decodeObjectForKey:@"token"];
    thread.isUnread = [aDecoder decodeBoolForKey:@"isUnread"];
    thread.lastMessageDate = [aDecoder decodeObjectForKey:@"last_message_date"];
    thread.snoozeDate = [aDecoder decodeObjectForKey:@"snooze_date"];
    thread.snoozeDateType = [[aDecoder decodeObjectForKey:@"snooze_date_type"] intValue];
    thread.version = [[aDecoder decodeObjectForKey:@"version"] unsignedIntegerValue];
    thread.messageIds = [aDecoder decodeObjectForKey:@"message_ids"];
    thread.folders = [aDecoder decodeObjectForKey:@"folders"];
    thread.participants = [aDecoder decodeObjectForKey:@"participants"];
  
  return thread;
}

- (NSString *)namespace_id {
  return _accountId;
}

- (NSString *)token {
  return _token;
}

- (BOOL)isReadLater{
    BOOL readLater = NO;
    for(NSDictionary *item in _folders) {
        NSString *lDisplayName = item[@"display_name"];
        if ([lDisplayName isEqualToString:@"Read Later"])  {
            readLater = YES;
        }
    }
        return readLater;
}

- (NSString*)getParticipantNames
{
    NSString *myEmail = [_ownerEmail lowercaseString];
    
    NSMutableString *names = [NSMutableString new];
    
    NSMutableDictionary *participantsName = [NSMutableDictionary new];
    for(NSDictionary *participant in self.participants)
    {
        NSString *email = [participant[@"email"] lowercaseString];
        if([email isEqualToString:myEmail] && self.messagesCount==1) continue;
        
        NSString *name;
        if(![participantsName objectForKey:email])
        {
            if([email isEqualToString:myEmail])
            {
                name = @"me";
            }
            else
            {
                name = [participant[@"name"] isEqual:[NSNull null]]||((NSString*)participant[@"name"]).length==0 ? participant[@"email"] : participant[@"name"];
            }
            
            [participantsName setObject:name forKey:email];
            
            if(names.length>0)
                [names appendFormat:@",%@", name];
            else
                [names appendString:name];
        }
    }
    
    return names;
}
- (NSArray*)getParticipantNamesExcludingMe
{
    NSString *myEmail = [_ownerEmail lowercaseString];
    
    NSMutableArray *names = [NSMutableArray new];
    
    for(NSDictionary *participant in self.participants)
    {
        NSString *email = [participant[@"email"] lowercaseString];
        if([email isEqualToString:myEmail]) continue;
        
        NSString *name = [participant[@"name"] isEqual:[NSNull null]]||((NSString*)participant[@"name"]).length==0 ? email : participant[@"name"];
        
        [names addObject:name];
    }
    
    return names;
}
- (NSArray*)getParticipantEmailsExcludingMe
{
    NSString *myEmail = [_ownerEmail lowercaseString];
    
    NSMutableArray *emails = [NSMutableArray new];
    
    for(NSDictionary *participant in self.participants)
    {
        NSString *email = [participant[@"email"] lowercaseString];
        if(![email isEqualToString:myEmail])
        {
            [emails addObject:email];
        }
    }
    
    return emails;
}
- (BOOL)belongsToFolder:(NSString *)folder
{
    
    if(!self.folders || [self.folders isEqual:[NSNull null]]) return NO;
    
    folder = [folder lowercaseString];
    for(NSDictionary *item in self.folders)
    {
        if(!item[@"display_name"] || [item[@"display_name"] isEqual:[NSNull null]]) continue;
        
        NSString *folderName = [item[@"display_name"] lowercaseString];
        if([folder isEqualToString:folderName]) return YES;
        
        NSString *folderId = item[@"id"];
        if([folder isEqualToString:folderId]) return YES;
    }
    
    return NO;
}
@end
