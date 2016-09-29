//
//  DBContact.h
//  planckMailiOS
//
//  Created by Matko Lajbaher on 11/16/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DBNamespace, DBPhoneNumber;

NS_ASSUME_NONNULL_BEGIN

@interface DBContact : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
+ (DBContact *)createOrUpdateContactWithData:(NSDictionary*)data onContext:(NSManagedObjectContext*)context;
+ (DBContact *)getContactWithEmail:(NSString *)email;
+ (DBContact *)getContactWithEmail:(NSString *)email context:(NSManagedObjectContext*)context;

- (NSDictionary*)convertToDictionary;
@end

NS_ASSUME_NONNULL_END

#import "DBContact+CoreDataProperties.h"
