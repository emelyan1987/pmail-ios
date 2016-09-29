//
//  DBInboxMailModel.h
//  planckMailiOS
//
//  Created by nazar on 10/29/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PMThread.h"

@class DBNamespace;

NS_ASSUME_NONNULL_BEGIN

@interface DBThread : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
+ (DBThread*)createOrUpdateFromPMThread:(PMThread*)pmInboxMailModel onContext:(NSManagedObjectContext*)context;
+ (DBThread*)createOrUpdateWithData:(NSDictionary*)data;
+ (DBThread*)getThreadWithId:(NSString*)threadId;
+ (DBThread*)getThreadWithId:(NSString*)threadId context:(NSManagedObjectContext*)context;
+ (void)deleteWithThreadId:(NSString*)threadId;
+ (void)deleteModel:(DBThread*)model;
- (PMThread*)toPMThread;
- (void)setMarkRead;
- (void)setMarkUnread;
- (void)setHasAttachmentsWithValue:(BOOL)value;
- (void)setHasEventsWithValue:(BOOL)value;
- (void)setFolder:(NSDictionary*)folder;
- (NSArray*)getFolders;
- (NSString*)getParticipantNames:(NSString*)myEmail;

- (void)setSnoozeDate:(NSDate*)date withDateType:(NSNumber*)type;
@end

NS_ASSUME_NONNULL_END

#import "DBThread+CoreDataProperties.h"
