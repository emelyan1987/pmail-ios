//
//  DBAccount+CoreDataProperties.h
//  planckMailiOS
//
//  Created by LionStar on 12/25/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DBAccount.h"

NS_ASSUME_NONNULL_BEGIN

@interface DBAccount (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *id;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSString *email;
@property (nullable, nonatomic, retain) NSString *descript;     
@property (nullable, nonatomic, retain) NSString *type;         // email, cloud
@property (nullable, nonatomic, retain) NSString *provider;     // Outlook.com, Gmail, iCloud, Exchange, Yahoo, Dropbox, Box, GoogleDrive, OneDrive
@property (nullable, nonatomic, retain) NSString *token;
@property (nullable, nonatomic, retain) NSString *accountId;
@end

NS_ASSUME_NONNULL_END
