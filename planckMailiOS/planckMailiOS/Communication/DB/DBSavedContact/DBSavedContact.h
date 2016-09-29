//
//  DBSavedContact.h
//  planckMailiOS
//
//  Created by LionStar on 1/7/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "CLPerson.h"

NS_ASSUME_NONNULL_BEGIN

@interface DBSavedContact : NSManagedObject <NSSecureCoding>

// Insert code here to declare functionality of your managed object subclass
+ (DBSavedContact *)createOrUpdateContactWithData:(NSDictionary*)data onContext:(NSManagedObjectContext*)context;
+ (DBSavedContact *)createOrUpdateContactWithCLPerson:(CLPerson*)person onContext:(NSManagedObjectContext*)context;
+ (DBSavedContact *)getContactWithId:(NSString*)contactId;
+ (DBSavedContact *)getContactWithId:(NSString*)contactId onContext:(NSManagedObjectContext*)context;
+ (DBSavedContact *)getContactWithEmail:(NSString *)email;
+ (void)getContactsWithEmailsInBackground:(NSArray *)emails completion:(void(^)(NSArray *contacts))handler;

- (NSDictionary*)convertToDictionary;

- (NSString*)getTitle;
- (NSString*)getTitle:(NSString*)email;
- (NSString*)getJobTitle;
- (NSArray*)getEmailArray;
- (NSArray*)getPhoneArray;
- (NSString*)getFirstEmailAddress;
- (void)addEmail:(NSString*)email;

- (NSString*)getContactType;
- (NSInteger)getContactTypeValue;
@end

NS_ASSUME_NONNULL_END

#import "DBSavedContact+CoreDataProperties.h"
