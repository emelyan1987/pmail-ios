//
//  DBEvent.h
//  planckMailiOS
//
//  Created by Matko Lajbaher on 12/6/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBEvent : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
+ (DBEvent *)createOrUpdateEventWithData:(NSDictionary*)data onContext:(NSManagedObjectContext*)context;
+ (DBEvent *)getEventWithId:(NSString *)eventId;
+ (DBEvent *)getEventWithId:(NSString *)eventId context:(NSManagedObjectContext*)context;
+ (NSArray *)getEventsWithAccountId:(NSString *)accountId params:(nullable NSDictionary*)params;
+ (NSArray *)getEventsWithAccountId:(NSString *)accountId params:(nullable NSDictionary*)params context:(NSManagedObjectContext*)context;
+ (void)getEventInBackground:(NSString *)eventId context:(NSManagedObjectContext*)context completion:(void (^)(DBEvent *event))handler;

+ (void)deleteModel:(DBEvent*)model;
- (NSDictionary*)convertToDictionary;
@end

NS_ASSUME_NONNULL_END

#import "DBEvent+CoreDataProperties.h"
