//
//  DBMailAdditionalInfo+CoreDataProperties.h
//  planckMailiOS
//
//  Created by LionStar on 2/23/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DBMailAdditionalInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface DBMailAdditionalInfo (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *threadId;
@property (nullable, nonatomic, retain) NSString *messageId;
@property (nullable, nonatomic, retain) NSNumber *salesforce;
@property (nullable, nonatomic, retain) NSDate *startTime;
@property (nullable, nonatomic, retain) NSDate *endTime;
@property (nullable, nonatomic, retain) NSString *status;

@property (nullable, nonatomic, retain) NSNumber *date;

@end

NS_ASSUME_NONNULL_END
