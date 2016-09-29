//
//  DBTrackDetail.m
//  planckMailiOS
//
//  Created by LionStar on 1/15/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import "DBTrackDetail.h"

#import "DBManager.h"

#import "Config.h"

#define DB_TRACK_DETAIL @"DBTrackDetail"


@implementation DBTrackDetail

// Insert code here to add functionality to your managed object subclass
+ (DBTrackDetail*)createOrUpdateTrackDetailWithData:(NSDictionary*)data onContext:(nonnull NSManagedObjectContext *)context
{
    
    NSNumber *detailId = data[@"id"];
    
    
    DBTrackDetail *detail;
    
    detail = [DBTrackDetail getTrackDetailWithId:detailId context:context];
    
    
    if(!detail)
    {
        detail = (DBTrackDetail *)[NSEntityDescription insertNewObjectForEntityForName:DB_TRACK_DETAIL inManagedObjectContext:context];
    }
    
    detail.id = detailId;
    detail.trackId = data[@"track_id"];
    detail.actorEmail = notNullStrValue(data[@"actor_email"]);
    detail.actionType = notNullStrValue(data[@"action_type"]);
    detail.ipAddress = notNullValue(data[@"ip_address"]);
    detail.location = notNullValue(data[@"location"]);
    detail.isMobile = data[@"is_mobile"]?data[@"is_mobile"]:@(NO);
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    detail.createdTime = [dateFormatter dateFromString:data[@"created_time"]];
    
    return detail;
}

+ (DBTrackDetail*)getTrackDetailWithId:(NSString*)detailId {
    
    DBManager *dbManager = [DBManager instance];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:DB_TRACK_DETAIL];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"id == %@", detailId]];
    
    NSError *error;
    NSArray *results = [[dbManager mainContext] executeFetchRequest:request error:&error];
    
    if(error==nil && results.count>0) return (DBTrackDetail*)results[0];
    return nil;
}

+ (DBTrackDetail*)getTrackDetailWithId:(NSString*)detailId context:(NSManagedObjectContext*)context
{
   
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:DB_TRACK_DETAIL];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"id == %@", detailId]];
    
    NSError *error;
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    if(error==nil && results.count>0) return (DBTrackDetail*)results[0];
    return nil;
}
- (NSDictionary*)toDictionary
{
    NSMutableDictionary *data = [NSMutableDictionary new];
    
    if(self.id) [data setObject:self.id forKey:@"id"];
    if(self.trackId) [data setObject:self.trackId forKey:@"track_id"];
    if(self.actorEmail) [data setObject:self.actorEmail forKey:@"actor_email"];
    if(self.ipAddress) [data setObject:self.ipAddress forKey:@"ip_address"];
    if(self.isMobile) [data setObject:self.isMobile forKey:@"is_mobile"];
    if(self.location) [data setObject:self.location forKey:@"location"];
    if(self.actionType) [data setObject:self.actionType forKey:@"action_type"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    if(self.createdTime) [data setObject:[dateFormatter stringFromDate:self.createdTime] forKey:@"created_time"];
    
    
    return data;
}
@end
