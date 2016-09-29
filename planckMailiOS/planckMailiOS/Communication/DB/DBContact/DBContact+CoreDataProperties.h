//
//  DBContact+CoreDataProperties.h
//  planckMailiOS
//
//  Created by Matko Lajbaher on 11/16/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DBContact.h"

NS_ASSUME_NONNULL_BEGIN

@interface DBContact (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *account_id;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *email;
@property (nullable, nonatomic, retain) DBNamespace *account;
@property (nullable, nonatomic, retain) NSString *phone_numbers;

@end

@interface DBContact (CoreDataGeneratedAccessors)


@end

NS_ASSUME_NONNULL_END
