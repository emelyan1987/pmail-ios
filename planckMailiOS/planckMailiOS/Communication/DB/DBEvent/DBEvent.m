//
//  DBEvent.m
//  planckMailiOS
//
//  Created by Matko Lajbaher on 12/6/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "DBEvent.h"
#import "DBManager.h"

@implementation DBEvent

// Insert code here to add functionality to your managed object subclass

+ (DBEvent*)createOrUpdateEventWithData:(NSDictionary*)data onContext:(NSManagedObjectContext*)context
{
    
    NSString *eventId = notNullStrValue(data[@"id"]);
    if(!eventId)
    {
        return nil;
    }
    
    
    DBEvent *event = [DBEvent getEventWithId:eventId context:context];
    
    
    if(!event)
        event = (DBEvent *)[NSEntityDescription insertNewObjectForEntityForName:@"DBEvent" inManagedObjectContext:context];
    
    event.id = eventId;
    event.object = data[@"object"];
    event.message_id = notEmptyStrValue(data[@"message_id"]);
    event.account_id = data[@"account_id"];
    
    if(![data[@"calendar_id"] isEqual:[NSNull null]])
    {
        NSString *calendarId = data[@"calendar_id"];
        event.calendar_id = calendarId;
    }
    
    event.owner = notEmptyStrValue(data[@"owner"]);
    event.event_description = notEmptyStrValue(data[@"description"]);
    event.location = notEmptyStrValue(data[@"location"]);
    event.title = notEmptyStrValue(data[@"title"]);
    event.status = notEmptyStrValue(data[@"status"]);
    event.read_only = data[@"read_only"];
    event.busy = data[@"busy"];
    
    if(data[@"participants"])
    {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data[@"participants"]
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        event.participants = jsonString;
    }
    
    if(data[@"when"])
    {
        NSDictionary *when = data[@"when"];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:when
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        event.when = jsonString;
        
        
        NSString *whenObject = when[@"object"];
        if([whenObject isEqualToString:@"time"])
        {
            NSDate *time = [NSDate dateWithTimeIntervalSince1970:[when[@"time"] doubleValue]];
            event.start_time = time;
            event.end_time = time;
        }
        else if([whenObject isEqualToString:@"timespan"])
        {
            event.start_time = [NSDate dateWithTimeIntervalSince1970:[when[@"start_time"] doubleValue]];
            event.end_time = [NSDate dateWithTimeIntervalSince1970:[when[@"end_time"] doubleValue]];
        }
        else if([whenObject isEqualToString:@"date"])
        {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"YYYY-MM-DD"];
            NSDate *time = [dateFormatter dateFromString:when[@"date"]];
            event.start_time = time;
            event.end_time = time;
        }
        else if([whenObject isEqualToString:@"datespan"])
        {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"YYYY-MM-DD"];
            event.start_time = [dateFormatter dateFromString:when[@"start_date"]];
            event.end_time = [dateFormatter dateFromString:when[@"end_date"]];
        }
    }
    
    return event;
}

+ (DBEvent *)getEventWithId:(NSString *)eventId {
    
    DBManager *dbManager = [DBManager instance];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"DBEvent"];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"id == %@", eventId]];
    
    NSError *error;
    NSArray *results = [[dbManager mainContext] executeFetchRequest:request error:&error];
    
    if(error==nil && results.count>0) return (DBEvent*)results[0];
    return nil;
}
+ (DBEvent *)getEventWithId:(NSString *)eventId context:(NSManagedObjectContext*)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"DBEvent"];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"id == %@", eventId]];
    
    NSError *error;
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    if(error==nil && results.count>0) return (DBEvent*)results[0];
    return nil;
}

+ (NSArray *)getEventsWithAccountId:(NSString *)accountId params:(nullable NSDictionary *)params
{
    DBManager *dbManager = [DBManager instance];
    NSError *lError;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"DBEvent"];
    
    NSMutableArray *predicates = [NSMutableArray new];
    [predicates addObject:[NSPredicate predicateWithFormat:@"account_id == %@", accountId]];
    
    if(params)
    {
        if(params[@"calendar_id"])
            [predicates addObject:[NSPredicate predicateWithFormat:@"calendar_id == %@", params[@"calendar_id"]]];
        
        if(params[@"starts_after"])
        {
            NSDate *startTime = [NSDate dateWithTimeIntervalSince1970:[params[@"starts_after"] doubleValue]];
            [predicates addObject:[NSPredicate predicateWithFormat:@"start_time >= %@", startTime]];
        }
        if(params[@"ends_before"])
        {
            NSDate *endTime = [NSDate dateWithTimeIntervalSince1970:[params[@"ends_before"] doubleValue]];
            [predicates addObject:[NSPredicate predicateWithFormat:@"end_time <= %@", endTime]];
        }
    }
    [request setPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:predicates]];
    
    NSArray *results = [[dbManager mainContext] executeFetchRequest:request error:&lError];
    
    return results;
}

+ (NSArray *)getEventsWithAccountId:(NSString *)accountId params:(nullable NSDictionary *)params context:(NSManagedObjectContext*)context
{
    NSError *lError;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"DBEvent"];
    
    NSMutableArray *predicates = [NSMutableArray new];
    [predicates addObject:[NSPredicate predicateWithFormat:@"account_id == %@", accountId]];
    
    if(params)
    {
        if(params[@"calendar_id"])
            [predicates addObject:[NSPredicate predicateWithFormat:@"calendar_id == %@", params[@"calendar_id"]]];
        
        if(params[@"starts_after"])
        {
            NSDate *startTime = [NSDate dateWithTimeIntervalSince1970:[params[@"starts_after"] doubleValue]];
            [predicates addObject:[NSPredicate predicateWithFormat:@"start_time >= %@", startTime]];
        }
        if(params[@"ends_before"])
        {
            NSDate *endTime = [NSDate dateWithTimeIntervalSince1970:[params[@"ends_before"] doubleValue]];
            [predicates addObject:[NSPredicate predicateWithFormat:@"end_time <= %@", endTime]];
        }
    }
    [request setPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:predicates]];
    
    NSArray *results = [context executeFetchRequest:request error:&lError];
    
    return results;
}

+ (void)getEventInBackground:(NSString *)eventId context:(NSManagedObjectContext*)context completion:(void (^)(DBEvent *event))handler
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"DBEvent"];
    
    if(eventId)
        [request setPredicate:[NSPredicate predicateWithFormat:@"id == %@", eventId]];
    
    
    [context performBlock:^{
        
        NSError *error;
        NSArray *results = [context executeFetchRequest:request error:&error];
        
        NSManagedObjectContext *mainContext = [DBManager instance].mainContext;
        [mainContext performBlock:^{
            if(results && results.count)
            {
                NSManagedObject *obj = results[0];
                DBEvent *event = [mainContext objectWithID:obj.objectID];
                if(handler)
                    handler(event);
            }
            else
            {
                if(handler)
                    handler(nil);
            }
        }];
        
    }];
}


+ (void)deleteModel:(DBCalendar *)model
{
    DBManager *dbManager = [DBManager instance];
    
    [dbManager.mainContext deleteObject:model];
    [dbManager save];
    
}
-(NSDictionary*)convertToDictionary
{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    NSString *eventId = self.id;
    [dict setObject:eventId forKey:@"id"];
    [dict setObject:self.object forKey:@"object"];
    [dict setObject:self.message_id forKey:@"message_id"];
    [dict setObject:self.account_id forKey:@"account_id"];
    [dict setObject:self.calendar_id forKey:@"calendar_id"];
    
    if(self.event_description)
        [dict setObject:self.event_description forKey:@"description"];
    if(self.location)
        [dict setObject:self.location forKey:@"location"];
    if(self.owner)
        [dict setObject:self.owner forKey:@"owner"];
    [dict setObject:self.read_only forKey:@"read_only"];
    [dict setObject:self.busy forKey:@"busy"];
    if(self.title)
        [dict setObject:self.title forKey:@"title"];
    
    if(self.participants && self.participants.length>0)
    {
        
        NSData *jsonData = [self.participants dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData!=nil)
        {
            NSArray *participants = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                    options:NSJSONReadingMutableContainers
                                                                      error:nil];
            [dict setObject:participants forKey:@"participants"];
        }
    }
    if(self.when && self.when.length>0)
    {
        
        NSData *jsonData = [self.when dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData!=nil)
        {
            NSArray *when = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                    options:NSJSONReadingMutableContainers
                                                                      error:nil];
            [dict setObject:when forKey:@"when"];
        }
    }
    
    return dict;
    
}
@end
