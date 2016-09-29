//
//  DBSavedContact+CoreDataProperties.h
//  planckMailiOS
//
//  Created by LionStar on 1/7/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DBSavedContact.h"

NS_ASSUME_NONNULL_BEGIN

@interface DBSavedContact (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *id;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *address;
@property (nullable, nonatomic, retain) NSString *company;
@property (nullable, nonatomic, retain) NSString *job;
@property (nullable, nonatomic, retain) NSString *phoneNumbers;
@property (nullable, nonatomic, retain) NSString *emails;
@property (nullable, nonatomic, retain) NSDate *birthday;
@property (nullable, nonatomic, retain) NSDate *createdTime;
@property (nullable, nonatomic, retain) NSDate *modifiedTime;
@property (nullable, nonatomic, retain) NSString *ringtone;
@property (nullable, nonatomic, retain) NSData *profileData;

@end

NS_ASSUME_NONNULL_END
