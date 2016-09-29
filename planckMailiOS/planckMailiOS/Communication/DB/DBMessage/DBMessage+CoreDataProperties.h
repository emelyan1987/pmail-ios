//
//  DBMessage+CoreDataProperties.h
//  planckMailiOS
//
//  Created by Matko Lajbaher on 11/19/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DBMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface DBMessage (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *id;
@property (nullable, nonatomic, retain) NSString *object;
@property (nullable, nonatomic, retain) NSString *account_id;
@property (nullable, nonatomic, retain) NSString *thread_id;
@property (nullable, nonatomic, retain) NSString *subject;
@property (nullable, nonatomic, retain) NSString *from;
@property (nullable, nonatomic, retain) NSString *to;
@property (nullable, nonatomic, retain) NSString *cc;
@property (nullable, nonatomic, retain) NSString *bcc;
@property (nullable, nonatomic, retain) NSString *reply_to;
@property (nullable, nonatomic, retain) NSNumber *date;
@property (nullable, nonatomic, retain) NSNumber *unread;
@property (nullable, nonatomic, retain) NSNumber *starred;
@property (nullable, nonatomic, retain) NSString *folder;
@property (nullable, nonatomic, retain) NSString *labels;
@property (nullable, nonatomic, retain) NSString *snippet;
@property (nullable, nonatomic, retain) NSString *body;
@property (nullable, nonatomic, retain) NSString *files;
@property (nullable, nonatomic, retain) NSString *events;
@property (nullable, nonatomic, retain) DBNamespace *account;
@property (nullable, nonatomic, retain) DBThread *thread;

@end

NS_ASSUME_NONNULL_END
