//
//  PMFolderManager.m
//  planckMailiOS
//
//  Created by LionStar on 6/22/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import "PMFolderManager.h"
#import "DBManager.h"



@implementation PMFolderManager

+(PMFolderManager*)sharedInstance{
    static PMFolderManager *instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [PMFolderManager new];
    });
    return instance;
}

- (NSArray*)getFoldersForAccount:(NSString *)accountId
{
    DBManager *dbManager = [DBManager instance];
    
    NSArray *folders = [dbManager getFoldersForAccount:accountId];
    
    return folders;
}

- (NSNumber*)getUnreadsForAllAccounts:(NSString *)folderName
{
    NSInteger cnt = 0;
    DBManager *dbManager = [DBManager instance];
    for(DBNamespace *namespace in [dbManager getNamespaces])
    {
        NSString *accountId = namespace.account_id;
        
        NSArray *folders = [dbManager getFoldersForAccount:accountId];
        
        for(NSDictionary *folder in folders)
        {
            NSString *folderDisplayName = [folder[@"display_name"] lowercaseString];
            
            if([[folderName lowercaseString] isEqualToString:folderDisplayName])
            {
                cnt += [folder[@"unreads"] integerValue]; break;
            }
        }
        
    }
    
    return [NSNumber numberWithInteger:cnt];
}

- (NSNumber*)getUnreadsForAccount:(NSString *)accountId folderName:(NSString *)folderName
{
    DBManager *dbManager = [DBManager instance];
    
    NSArray *folders = [dbManager getFoldersForAccount:accountId];
    
    for(NSDictionary *folder in folders)
    {
        NSString *folderDisplayName = [folder[@"display_name"] lowercaseString];
        
        if([[folderName lowercaseString] isEqualToString:folderDisplayName])
            return folder[@"unreads"];
    }
    
    return nil;
}

- (void)decreaseUnreadsForFolder:(NSString *)folderId
{
    DBFolder *folder = [DBFolder getFolderWithId:folderId];
    
    NSInteger unreads = [folder.unreads integerValue];
    unreads --;
    
    folder.unreads = [NSNumber numberWithInteger:unreads];
    
    [[DBManager instance] save];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UNREAD_COUNT_CHANGED object:nil];
}

- (void)increaseUnreadsForFolder:(NSString *)folderId
{
    DBFolder *folder = [DBFolder getFolderWithId:folderId];
    
    NSInteger unreads = [folder.unreads integerValue];
    unreads ++;
    
    folder.unreads = [NSNumber numberWithInteger:unreads];
    
    [[DBManager instance] save];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UNREAD_COUNT_CHANGED object:nil];
}

- (NSString*)getFolderIdForAccount:(NSString *)accountId folderName:(NSString *)folderName
{
    DBManager *dbManager = [DBManager instance];
    
    NSArray *folders = [dbManager getFoldersForAccount:accountId];
    
    for(NSDictionary *folder in folders)
    {
        NSString *folderDisplayName = [folder[@"display_name"] lowercaseString];
        
        if([[folderName lowercaseString] isEqualToString:folderDisplayName])
            return folder[@"id"];
    }
    
    return nil;
}

- (NSDictionary*)getFolderDataForAccount:(NSString *)accountId folderName:(NSString *)folderName
{
    DBManager *dbManager = [DBManager instance];
    
    NSArray *folders = [dbManager getFoldersForAccount:accountId];
    
    for(NSDictionary *folder in folders)
    {
        NSString *folderDisplayName = [folder[@"display_name"] lowercaseString];
        
        if([[folderName lowercaseString] isEqualToString:folderDisplayName])
            return folder;
    }
    
    return nil;
}

- (NSString*)getScheduledFolderIdForAccount:(NSString *)accountId
{
    return [self getFolderIdForAccount:accountId folderName:SCHEDULED_FOLDER_NAME];
}
@end
