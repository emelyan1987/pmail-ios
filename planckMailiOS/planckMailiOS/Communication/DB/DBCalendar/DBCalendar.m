//
//  DBCalendar.m
//  planckMailiOS
//
//  Created by Lyubomyr Hlozhyk on 11/15/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "DBCalendar.h"
#import "DBNamespace.h"
#import "DBManager.h"

#define DB_CALENDAR @"DBCalendar"
@implementation DBCalendar

// Insert code here to add functionality to your managed object subclass
+ (DBCalendar*)createOrUpdateCalendarWithData:(NSDictionary*)data onContext:(nonnull NSManagedObjectContext *)context
{
    
    NSString *calendarId = data[@"id"];
    
    DBCalendar *dbCalendar = [DBCalendar getCalendarWithId:calendarId onContext:context];
    
    if(!dbCalendar)
    {
        dbCalendar = (DBCalendar *)[NSEntityDescription insertNewObjectForEntityForName:DB_CALENDAR inManagedObjectContext:context];
        dbCalendar.color = @([DBCalendar getCalendarsCount:context] % 12);
        dbCalendar.selected = @YES;
    }
    
    if(data[@"account_id"])
    {
        dbCalendar.account_id = data[@"account_id"];
    }
    
    dbCalendar.calendarDescription = [data[@"description"] isEqual:[NSNull null]]?@"":data[@"description"];
    dbCalendar.calendarId = data[@"id"];
    dbCalendar.name = data[@"name"];
    dbCalendar.object = data[@"object"];
    dbCalendar.readOnly = data[@"read_only"];
    
    //dbCalendar.selected = @YES;
    
    
    return dbCalendar;
}

+ (DBCalendar *)getCalendarWithId:(NSString *)calendarId {
    
    DBManager *dbManager = [DBManager instance];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:DB_CALENDAR];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"calendarId == %@", calendarId]];
    
    NSError *error;
    NSArray *results = [[dbManager mainContext] executeFetchRequest:request error:&error];
    
    if(error==nil && results.count>0) return (DBCalendar*)results[0];
    return nil;
}
+ (DBCalendar *)getCalendarWithId:(NSString *)calendarId onContext:(NSManagedObjectContext*)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:DB_CALENDAR];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"calendarId == %@", calendarId]];
    
    NSError *error;
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    if(error==nil && results.count>0) return (DBCalendar*)results[0];
    return nil;
}

+ (NSInteger)getCalendarsCount
{
    NSError *error;
    DBManager *dbManager = [DBManager instance];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:DB_CALENDAR];
    
    NSArray *results = [[dbManager mainContext] executeFetchRequest:request error:&error];
    
    return results.count;
}

+ (NSInteger)getCalendarsCount:(NSManagedObjectContext*)context
{
    NSError *error;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:DB_CALENDAR];
    
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    return results.count;
}

+ (NSArray *)getCalendarsWithAccountId:(NSString*)accountId {
    NSError *error;
    DBManager *dbManager = [DBManager instance];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:DB_CALENDAR];
    [request setPredicate:[NSPredicate predicateWithFormat:@"account_id == %@", accountId]];
    
    NSArray *results = [[dbManager mainContext] executeFetchRequest:request error:&error];
    
    return results;
}


+ (NSArray *)getWritableCalendars {
    NSError *error;
    DBManager *dbManager = [DBManager instance];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:DB_CALENDAR];
    [request setPredicate:[NSPredicate predicateWithFormat:@"readOnly == 0"]];
    
    NSArray *results = [[dbManager mainContext] executeFetchRequest:request error:&error];
    
    return results;    
}

+ (NSArray *)getCalendars {
    NSError *error;
    DBManager *dbManager = [DBManager instance];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:DB_CALENDAR];
    //[request setPredicate:[NSPredicate predicateWithFormat:@"readOnly == 0"]];
    
    NSArray *results = [[dbManager mainContext] executeFetchRequest:request error:&error];
    
    return results;
}

+ (NSArray *)getCalendars:(NSManagedObjectContext*)context {
    NSError *error;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:DB_CALENDAR];
    //[request setPredicate:[NSPredicate predicateWithFormat:@"readOnly == 0"]];
    
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    return results;
}

+ (void)deleteModel:(DBCalendar *)model
{
    DBManager *dbManager = [DBManager instance];
    
    [dbManager.mainContext deleteObject:model];
    [dbManager save];
    
}
@end
