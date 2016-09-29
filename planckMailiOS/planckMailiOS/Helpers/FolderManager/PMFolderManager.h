//
//  PMFolderManager.h
//  planckMailiOS
//
//  Created by LionStar on 6/22/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SCHEDULED_FOLDER_NAME @"FollowUps"

@interface PMFolderManager : NSObject
+(PMFolderManager*)sharedInstance;

- (NSArray*)getFoldersForAccount:(NSString*)accountId;

- (NSNumber*)getUnreadsForAllAccounts:(NSString*)folderName;
- (NSNumber*)getUnreadsForAccount:(NSString*)accountId folderName:(NSString*)folderName;

- (void)decreaseUnreadsForFolder:(NSString*)folderId;
- (void)increaseUnreadsForFolder:(NSString*)folderId;

- (NSString*)getFolderIdForAccount:(NSString*)accountId folderName:(NSString*)folderName;
- (NSDictionary*)getFolderDataForAccount:(NSString *)accountId folderName:(NSString *)folderName;

- (NSString*)getScheduledFolderIdForAccount:(NSString*)accountId;
@end
