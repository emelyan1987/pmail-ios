//
//  DBTrack+CoreDataProperties.m
//  planckMailiOS
//
//  Created by LionStar on 1/15/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DBTrack+CoreDataProperties.h"

@implementation DBTrack (CoreDataProperties)

@dynamic id;
@dynamic messageId;
@dynamic subject;
@dynamic ownerEmail;
@dynamic targetEmails;
@dynamic opens;
@dynamic links;
@dynamic replies;
@dynamic createdTime;
@dynamic modifiedTime;

@end
