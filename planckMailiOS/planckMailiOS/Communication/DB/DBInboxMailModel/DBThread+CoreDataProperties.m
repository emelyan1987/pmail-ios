//
//  DBInboxMailModel+CoreDataProperties.m
//  planckMailiOS
//
//  Created by nazar on 10/29/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DBThread+CoreDataProperties.h"

@implementation DBThread (CoreDataProperties)


@dynamic id;
@dynamic accountId;
@dynamic lastMessageTimestamp;@dynamic subject;
@dynamic ownerName;
@dynamic snippet;
@dynamic follow_up;
@dynamic lastMessageDate;
@dynamic version;
@dynamic isUnread;
@dynamic isLoadMore;
@dynamic token;
@dynamic folders;
@dynamic hasAttachments;
@dynamic isFlagged;
@dynamic messageIds;
@dynamic snoozeDate;
@dynamic snoozeDateType;
@end
