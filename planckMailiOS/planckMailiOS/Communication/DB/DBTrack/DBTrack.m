//
//  DBTrack.m
//  planckMailiOS
//
//  Created by LionStar on 1/15/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import "DBTrack.h"
#import "DBManager.h"

#import "Config.h"

#define DB_TRACK @"DBTrack"

@implementation DBTrack

// Insert code here to add functionality to your managed object subclass
+ (DBTrack*)createOrUpdateTrackWithData:(NSDictionary*)data onContext:(nonnull NSManagedObjectContext *)context
{    
    NSNumber *trackId = data[@"id"];
    
    DBTrack *track;
    
    track = [DBTrack getTrackWithId:trackId onContext:context];
    
    if(!track)
    {
        track = (DBTrack *)[NSEntityDescription insertNewObjectForEntityForName:DB_TRACK inManagedObjectContext:context];
    }
    
    track.id = trackId;
    track.messageId = data[@"message_id"];
    track.subject = notNullStrValue(data[@"subject"]);
    track.ownerEmail = notNullStrValue(data[@"owner_email"]);
    track.targetEmails = notNullStrValue(data[@"target_emails"]);
    track.opens = notNullValue(data[@"opens"]);
    track.links = notNullValue(data[@"links"]);
    track.replies = notNullValue(data[@"replies"]);
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    track.createdTime = [dateFormatter dateFromString:data[@"created_time"]];
    track.modifiedTime = [dateFormatter dateFromString:data[@"modified_time"]];
    
    return track;
}

+ (DBTrack*)getTrackWithId:(NSString*)trackId
{
    
    DBManager *dbManager = [DBManager instance];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:DB_TRACK];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"id == %@", trackId]];
    
    NSError *error;
    NSArray *results = [[dbManager mainContext] executeFetchRequest:request error:&error];
    
    if(error==nil && results.count>0) return (DBTrack*)results[0];
    return nil;
}
+ (DBTrack*)getTrackWithId:(NSString*)trackId onContext:(NSManagedObjectContext*)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:DB_TRACK];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"id == %@", trackId]];
    
    NSError *error;
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    if(error==nil && results.count>0) return (DBTrack*)results[0];
    return nil;
}

- (NSDictionary*)toDictionary
{
    NSMutableDictionary *data = [NSMutableDictionary new];
    
    if(self.id) [data setObject:self.id forKey:@"id"];
    if(self.messageId) [data setObject:self.messageId forKey:@"message_id"];
    if(self.ownerEmail) [data setObject:self.ownerEmail forKey:@"owner_email"];
    if(self.subject) [data setObject:self.subject forKey:@"subject"];
    if(self.targetEmails) [data setObject:self.targetEmails forKey:@"target_emails"];
    if(self.opens) [data setObject:self.opens forKey:@"opens"];
    if(self.links) [data setObject:self.links forKey:@"links"];
    if(self.replies) [data setObject:self.replies forKey:@"replies"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    if(self.createdTime) [data setObject:[dateFormatter stringFromDate:self.createdTime] forKey:@"created_time"];
    if(self.modifiedTime) [data setObject:[dateFormatter stringFromDate:self.modifiedTime] forKey:@"modified_time"];
    
    return data;
}
@end
