//
//  DBTrackDetail+CoreDataProperties.h
//  planckMailiOS
//
//  Created by LionStar on 1/15/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DBTrackDetail.h"

NS_ASSUME_NONNULL_BEGIN

@interface DBTrackDetail (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *id;
@property (nullable, nonatomic, retain) NSNumber *trackId;
@property (nullable, nonatomic, retain) NSString *actorEmail;
@property (nullable, nonatomic, retain) NSString *actionType;
@property (nullable, nonatomic, retain) NSString *ipAddress;
@property (nullable, nonatomic, retain) NSString *location;
@property (nullable, nonatomic, retain) NSNumber *isMobile;
@property (nullable, nonatomic, retain) NSDate *createdTime;

@end

NS_ASSUME_NONNULL_END
