//
//  DBInboxMailModel+CoreDataProperties.h
//  planckMailiOS
//
//  Created by nazar on 10/29/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DBThread.h"

NS_ASSUME_NONNULL_BEGIN

@interface DBThread (CoreDataProperties)



@property (nullable, nonatomic, retain) NSString *id;
@property (nullable, nonatomic, retain) NSString *accountId;
@property (nullable, nonatomic, retain) NSNumber *lastMessageTimestamp;
@property (nullable, nonatomic, retain) NSString *subject;
@property (nullable, nonatomic, retain) NSString *ownerName;
@property (nullable, nonatomic, retain) NSString *ownerEmail;
@property (nullable, nonatomic, retain) NSString *snippet;
@property (nullable, nonatomic, retain) NSNumber *follow_up;
@property (nullable, nonatomic, retain) NSDate *lastMessageDate;
@property (nullable, nonatomic, retain) NSNumber *version;
@property (nullable, nonatomic, retain) NSNumber *isUnread;
@property (nullable, nonatomic, retain) NSNumber *isFlagged;
@property (nullable, nonatomic, retain) NSNumber *isLoadMore;
@property (nullable, nonatomic, retain) NSNumber *hasAttachments;
@property (nullable, nonatomic, retain) NSString *folders;
@property (nullable, nonatomic, retain) NSString *token;
@property (nullable, nonatomic, retain) NSString *messageIds;
@property (nullable, nonatomic, retain) NSNumber *messagesCount;
@property (nullable, nonatomic, retain) NSString *participants;

@property (nullable, nonatomic, retain) NSDate *snoozeDate;
@property (nullable, nonatomic, retain) NSNumber *snoozeDateType;

@end

@interface DBThread (CoreDataGeneratedAccessors)

- (void)addLabelsObject:(DBThread *)value;
- (void)removeLabelsObject:(DBThread *)value;
- (void)addLabels:(NSSet<DBThread *> *)values;
- (void)removeLabels:(NSSet<DBThread *> *)values;

@end

NS_ASSUME_NONNULL_END
