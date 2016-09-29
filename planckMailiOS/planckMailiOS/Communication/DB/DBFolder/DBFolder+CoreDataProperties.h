//
//  DBFolder+CoreDataProperties.h
//  planckMailiOS
//
//  Created by LionStar on 6/21/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DBFolder.h"

NS_ASSUME_NONNULL_BEGIN

@interface DBFolder (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *id;
@property (nullable, nonatomic, retain) NSString *object;
@property (nullable, nonatomic, retain) NSString *accountId;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *displayName;
@property (nullable, nonatomic, retain) NSNumber *unreads;

@end

NS_ASSUME_NONNULL_END
