//
//  DBEvent+CoreDataProperties.m
//  planckMailiOS
//
//  Created by Matko Lajbaher on 12/6/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DBEvent+CoreDataProperties.h"

@implementation DBEvent (CoreDataProperties)

@dynamic object;
@dynamic id;
@dynamic message_id;
@dynamic calendar_id;
@dynamic account_id;
@dynamic location;
@dynamic owner;
@dynamic event_description;
@dynamic title;
@dynamic participants;
@dynamic when;
@dynamic busy;
@dynamic status;
@dynamic read_only;
@dynamic start_time;
@dynamic end_time;
@end
