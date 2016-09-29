//
//  DBCalendar.h
//  planckMailiOS
//
//  Created by Lyubomyr Hlozhyk on 11/15/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DBNamespace;

NS_ASSUME_NONNULL_BEGIN

@interface DBCalendar : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
+ (DBCalendar*)createOrUpdateCalendarWithData:(NSDictionary*)data onContext:(NSManagedObjectContext*)context;
+ (NSArray*)getCalendarsWithAccountId:(NSString*)accountId;
+ (NSArray*)getWritableCalendars;
+ (NSArray*)getCalendars;
+ (NSArray*)getCalendars:(NSManagedObjectContext*)context;
+ (DBCalendar*)getCalendarWithId:(NSString*)calendarId;
+ (void)deleteModel:(DBCalendar*)model;
@end

NS_ASSUME_NONNULL_END

#import "DBCalendar+CoreDataProperties.h"
