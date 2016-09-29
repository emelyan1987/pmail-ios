//
//  DBCalendar+CoreDataProperties.h
//  planckMailiOS
//
//  Created by Lyubomyr Hlozhyk on 11/15/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DBCalendar.h"
NS_ASSUME_NONNULL_BEGIN

@interface DBCalendar (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *account_id;
@property (nullable, nonatomic, retain) NSString *calendarDescription;
@property (nullable, nonatomic, retain) NSString *calendarId;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *object;
@property (nullable, nonatomic, retain) NSNumber *readOnly;
@property (nullable, nonatomic, retain) NSNumber *color;
@property (nullable, nonatomic, retain) NSNumber *selected;


@end

NS_ASSUME_NONNULL_END
