//
//  DBTrack+CoreDataProperties.h
//  planckMailiOS
//
//  Created by LionStar on 1/15/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DBTrack.h"

NS_ASSUME_NONNULL_BEGIN

@interface DBTrack (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *id;
@property (nullable, nonatomic, retain) NSString *messageId;
@property (nullable, nonatomic, retain) NSString *subject;
@property (nullable, nonatomic, retain) NSString *ownerEmail;
@property (nullable, nonatomic, retain) NSString *targetEmails;
@property (nullable, nonatomic, retain) NSNumber *opens;
@property (nullable, nonatomic, retain) NSNumber *links;
@property (nullable, nonatomic, retain) NSNumber *replies;
@property (nullable, nonatomic, retain) NSDate *createdTime;
@property (nullable, nonatomic, retain) NSDate *modifiedTime;

@end

NS_ASSUME_NONNULL_END
