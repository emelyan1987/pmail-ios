//
//  DBNamespace+CoreDataProperties.h
//  planckMailiOS
//
//  Created by nazar on 10/29/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DBNamespace.h"
#import "PMAccountProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface DBNamespace (CoreDataProperties) <PMAccountProtocol>

@property (nullable, nonatomic, copy) NSString *account_id;
@property (nullable, nonatomic, retain) NSString *email_address;
@property (nullable, nonatomic, copy) NSString *id;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, copy) NSString *namespace_id;
@property (nullable, nonatomic, retain) NSString *object;
@property (nullable, nonatomic, retain) NSString *provider;
@property (nullable, nonatomic, copy) NSString *token;
@property (nullable, nonatomic, retain) NSDecimalNumber *unreadCount;
@property (nullable, nonatomic, retain) DBCalendar *accountId;
@property (nullable, nonatomic, retain) NSSet<DBInboxMailModel *> *follow_ups;

@end

@interface DBNamespace (CoreDataGeneratedAccessors)

- (void)addFollow_upsObject:(DBInboxMailModel *)value;
- (void)removeFollow_upsObject:(DBInboxMailModel *)value;
- (void)addFollow_ups:(DBInboxMailModel*)values;
- (void)removeFollow_ups:(NSSet<DBInboxMailModel *> *)values;

@end

NS_ASSUME_NONNULL_END
