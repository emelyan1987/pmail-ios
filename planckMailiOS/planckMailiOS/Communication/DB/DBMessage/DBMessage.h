//
//  DBMessage.h
//  planckMailiOS
//
//  Created by Matko Lajbaher on 11/19/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DBThread, DBNamespace;

NS_ASSUME_NONNULL_BEGIN

@interface DBMessage : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
+ (DBMessage*)createOrUpdateMessageFromDictionary:(NSDictionary*)dic onContext:(NSManagedObjectContext*)context;
+ (DBMessage *)getMessageWithId:(NSString *)id;
+ (DBMessage *)getMessageWithId:(NSString *)id context:(NSManagedObjectContext*)context;
+ (void)getMessageInBackground:(NSString *)messageId context:(NSManagedObjectContext*)context completion:(void (^)(DBMessage *message))handler;

+ (void)deleteModel:(DBMessage*)model;
- (NSDictionary*)convertToDictionary;
- (NSArray*)getEventArray;
- (NSArray*)getFileArray;
- (NSDictionary*)getFrom;
- (NSArray*)getFromArray;
@end

NS_ASSUME_NONNULL_END

#import "DBMessage+CoreDataProperties.h"
