//
//  PMStorageManager.h
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 10/21/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SCHEDULED @"FollowUps"

@interface PMStorageManager : NSObject


#pragma mark - Follow-up methods
+ (instancetype)sharedInstance;

+ (void)updateFoldersForAccount:(NSString*)accountId;
+ (void)setFolders:(NSArray *)folders forAccount:(NSString *)accountId;
+ (void)setScheduledFolderId:(NSString *)folderId forAccount:(NSString *)accountId;
+ (void)deleteScheduledFolderIdForAccout:(NSString *)accountId;
+ (void)setFolder:(NSDictionary *)folder forAccount:(NSString*)accountId;
+ (void)setUnreads:(NSDictionary *)unreadsData forAccount:(NSString*)accountId;
+ (void)setUnreadCount:(NSInteger)count forFolder:(NSString*)folderId forAccount:(NSString*)accountId;
+ (NSArray *)getFolderIdsForAccount:(NSString *)accountId;
+ (NSArray *)getFoldersForAccount:(NSString *)accountId;
+ (NSString *)getScheduledFolderIdForAccount:(NSString *)accountId;
+ (NSString *)getFolderIdForAccount:(NSString *)accountId forKey:(NSString*)key;
+ (NSDictionary*)getFolderData:(NSString*)folderName forAccount:(NSString*)accountId;

+ (NSArray *)getStandardFoldersForAccount:(NSString *)accountId;
+ (NSArray *)getUserFoldersForAccount:(NSString *)accountId;
+ (NSDictionary *)getUnreadsForAccount:(NSString *)accountId;
+ (NSInteger)getUnreadsForFolder:(NSString*)folderId forAccount:(NSString*)accountId;
+ (NSInteger)getAllAccountUnreadsForFolderName:(NSString*)folderName;

+ (void)increaseUnreadCount:(NSString*)folderId forAccount:(NSString*)accountId;
+ (void)decreaseUnreadCount:(NSString*)folderId forAccount:(NSString*)accountId;

- (void)setBlackList:(NSArray*)list forEmail:(NSString*)email;
- (NSArray*)getBlackList:(NSString*)email;
@end
/*
if true
  
 + (NSString *)getScheduledFolderIdForAccount:(NSString *)accountId;
 getScheduledFolderIdForAccount  -> namespace_id


 
 else 
 create scheduled folder with name Scheduled (#define SCHEDULED @"scheduled") also (API Method)
 + (void)setScheduledFolderId:(NSString *)folderId forAccount:(NSString *)accountId;


*/