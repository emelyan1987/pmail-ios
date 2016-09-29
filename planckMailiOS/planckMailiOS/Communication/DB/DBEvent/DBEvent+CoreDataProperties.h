//
//  DBEvent+CoreDataProperties.h
//  planckMailiOS
//
//  Created by Matko Lajbaher on 12/6/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DBEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface DBEvent (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *object;
@property (nullable, nonatomic, retain) NSString *id;
@property (nullable, nonatomic, retain) NSString *message_id;
@property (nullable, nonatomic, retain) NSString *calendar_id;
@property (nullable, nonatomic, retain) NSString *account_id;
@property (nullable, nonatomic, retain) NSString *location;
@property (nullable, nonatomic, retain) NSString *owner;
@property (nullable, nonatomic, retain) NSString *event_description;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSString *participants;
@property (nullable, nonatomic, retain) NSString *when;
@property (nullable, nonatomic, retain) NSNumber *busy;
@property (nullable, nonatomic, retain) NSString *status;
@property (nullable, nonatomic, retain) NSNumber *read_only;
@property (nullable, nonatomic, retain) NSDate *start_time;
@property (nullable, nonatomic, retain) NSDate *end_time;
@end

NS_ASSUME_NONNULL_END
