//
//  PMStorageManager.m
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 10/21/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMStorageManager.h"
#import "Config.h"
#import "NSDictionary+CaseInsensitive.h"
#import "PMAPIManager.h"

//info keys
#define ACCOUNT_FOLDERS @"account_folders"
#define ACCOUNT_FOLDER_IDS @"account_folder_ids"
#define ACCOUNT_SCHEDULED_FOLDER_ID @"account_scheduled_folder_id"
#define ACCOUNT_UNREADS @"account_unreads"

#define USER_CREATED_FOLDER @"user_created_folder"


#define orderByFolder @{@"inbox":@"1", @"sent":@"2", @"archive":@"3", @"trash":@"4", @"drafts":@"5", @"outbox":@"6", @"spam":@"7", @"junk": @"8", @"important":@"9", @"all":@"10"};

@implementation PMStorageManager

#pragma mark - Init

- (instancetype)init {
    if(self = [super init]) {
        
    }
    return self;
}

+ (instancetype)sharedInstance {
    static PMStorageManager *sharedManager = nil;
    static dispatch_once_t dispatchToken;
    dispatch_once(&dispatchToken, ^{
        sharedManager = [PMStorageManager new];
    });
    return sharedManager;
}

+ (void)updateFoldersForAccount:(NSString *)accountId
{
    [[PMAPIManager shared] getFoldersWithAccount:accountId comlpetion:^(id data, id error, BOOL success) {
        if(success && data) {
            [PMStorageManager setFolders:data forAccount:accountId];
            
            for(NSDictionary *folder in data)
            {
                NSString *folderId = folder[@"id"];
                [[PMAPIManager shared] getUnreadCountForFolder:folderId forAccount:accountId completion:^(id data, id error, BOOL success) {
                    if(success)
                    {
                        [PMStorageManager setUnreadCount:[data integerValue] forFolder:folderId forAccount:accountId];
                    }
                }];
            }
        }
    }];
}
#pragma mark - Follow-up methods

+ (void)setFolders:(NSArray *)folders forAccount:(NSString *)accountId {
    NSMutableArray *mutableFolders = [NSMutableArray arrayWithArray:folders];
    for(NSInteger index=0; index<mutableFolders.count; index++)
    {
        NSMutableDictionary *mutableFolder = [NSMutableDictionary dictionaryWithDictionary:mutableFolders[index]];
        if([mutableFolder[@"name"] isEqual:([NSNull null])])
            [mutableFolder setObject:USER_CREATED_FOLDER forKey:@"name"];
        
        [mutableFolders replaceObjectAtIndex:index withObject:mutableFolder];
    }
    NSMutableDictionary *accountInfo = [self infoForAccount:accountId];
    [accountInfo setObject:mutableFolders forKey:ACCOUNT_FOLDERS];
    
    NSString *folderId = nil;
    NSMutableArray *folderIdsArray = [NSMutableArray array];
    
    BOOL hasScheduledFolder = NO;
    for(NSDictionary *folder in folders) {
        NSDictionary *folderDict = [NSDictionary dictionary];

        folderId = folder[@"id"];
        
        if (folder[@"name"] && ![folder[@"name"] isKindOfClass:[NSNull class]]) {
            
            folderDict = @{folder[@"name"] : folderId};
            [folderIdsArray addObject:folderDict];

        } else {
            folderDict = @{folder[@"display_name"] : folderId};
            [folderIdsArray addObject:folderDict];
            
            if (!accountInfo[ACCOUNT_SCHEDULED_FOLDER_ID]) {
                if ([[folder[@"display_name"] lowercaseString] isEqualToString:[SCHEDULED lowercaseString]]) {
                    [accountInfo setObject:folderId forKey:ACCOUNT_SCHEDULED_FOLDER_ID];
                    hasScheduledFolder = YES;
                }
            } else if(!hasScheduledFolder) {
                if([[accountInfo objectForKey:ACCOUNT_SCHEDULED_FOLDER_ID] isEqualToString:folderId]) {
                    hasScheduledFolder = YES;
                }
            }
        }
        [accountInfo setObject:folderIdsArray forKey:ACCOUNT_FOLDER_IDS];
    }
    
    if(!hasScheduledFolder) {
        [accountInfo removeObjectForKey:ACCOUNT_SCHEDULED_FOLDER_ID];
    }
    DLog(@"account info = %@", accountInfo);
    [[PMStorageManager sharedInstance] writeInfo:accountInfo intoFile:accountId];
}

//TODO:
/*
 в accountInfo зберігати окремо масив отаких штук @{"folderName": folderId}, -> ACCOUNT_FOLDERS
 і окремо id scheduled folder ACCOUNT_SCHEDULED_FOLDER_ID
 
 folderName = folder[@"name"](якщо таке існує в іншому випадку folder[@"display_name"])
 
 if якщо немає значення ACCOUNT_SCHEDULED_FOLDER_ID то: {
 
 кожного разу коли переписується масив фолдерів шукати папку з display_name = SCHEDULED, і якщо така є то запихнути folderId за ключем ACCOUNT_SCHEDULED_FOLDER_ID;
 
 }else {
 
 якщо є значення ACCOUNT_SCHEDULED_FOLDER_ID то:
 перевірити чи з серед нових фолдерів є фолдер з id який записаний за ключем ACCOUNT_SCHEDULED_FOLDER_ID
 
 if якщо немає такого фолдера {
 
 то видалити значення за ключем ACCOUNT_SCHEDULED_FOLDER_ID (тобто це означає, що користувач видалив папку SCHEDULED)
 
 }
 
 else {
 
 якщо є така папка то нічого не робити
 
 }
 
 }
 
 */
+ (void)setScheduledFolderId:(NSString *)folderId forAccount:(NSString *)accountId {
    if(folderId) {
        NSMutableDictionary *accountInfo = [self infoForAccount:accountId];
        [accountInfo setObject:folderId forKey:ACCOUNT_SCHEDULED_FOLDER_ID];
        
        [[PMStorageManager sharedInstance] writeInfo:accountInfo intoFile:accountId];
    }
}

+ (void)setFolder:(NSDictionary *)folder forAccount:(NSString*)accountId
{
    
    NSMutableDictionary *accountInfo = [self infoForAccount:accountId];
    
    NSMutableArray *accountFolders = accountInfo[ACCOUNT_FOLDERS];
    [accountFolders addObject:folder];
    
    NSMutableArray *accountFolderIds = accountInfo[ACCOUNT_FOLDER_IDS];
    
    if (folder[@"name"] && ![folder[@"name"] isKindOfClass:[NSNull class]])
    {
        [accountFolderIds addObject:@{[folder[@"name"] lowercaseString]:folder[@"id"]}];
    }
    else
    {
        [accountFolderIds addObject:@{[folder[@"display_name"] lowercaseString]:folder[@"id"]}];
    }
    
    [accountInfo setObject:accountFolderIds forKey:ACCOUNT_FOLDER_IDS];
    [accountInfo setObject:accountFolders forKey:ACCOUNT_FOLDERS];
    
    
    [[PMStorageManager sharedInstance] writeInfo:accountInfo intoFile:accountId];
}

+ (void)setUnreads:(NSDictionary *)unreadsData forAccount:(NSString *)accountId
{
    if(unreadsData)
    {
        NSMutableDictionary *accountInfo = [self infoForAccount:accountId];
        [accountInfo setObject:unreadsData forKey:ACCOUNT_UNREADS];
        
        [[PMStorageManager sharedInstance] writeInfo:accountInfo intoFile:accountId];
    }
}
+ (void)setUnreadCount:(NSInteger)count forFolder:(NSString *)folderId forAccount:(NSString *)accountId
{
    NSMutableDictionary *unreadsData = [NSMutableDictionary dictionaryWithDictionary:[self getUnreadsForAccount:accountId]];
    
    [unreadsData setObject:@(count) forKey:folderId];
    
    [self setUnreads:unreadsData forAccount:accountId];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UNREAD_COUNT_CHANGED object:nil];
    
}
+ (NSArray *)getFolderIdsForAccount:(NSString *)accountId {
    
    NSMutableDictionary *accountInfo = [self infoForAccount:accountId];
    return [accountInfo objectForKey:ACCOUNT_FOLDER_IDS];
}

+ (NSArray *)getFoldersForAccount:(NSString *)accountId {
    
    NSMutableDictionary *accountInfo = [self infoForAccount:accountId];
    return [accountInfo objectForKey:ACCOUNT_FOLDERS];
}

+ (NSDictionary*)getFolderData:(NSString*)folderName forAccount:(NSString*)accountId
{
    folderName = [folderName lowercaseString];
    
    NSArray *folders = [self getFoldersForAccount:accountId];
    
    for (NSDictionary *folder in folders) {
        if([folderName isEqualToString:[folder[@"display_name"] lowercaseString]])
            return folder;
    }
    
    return nil;
}

+ (NSString *)getScheduledFolderIdForAccount:(NSString *)accountId {
    DLog(@"account id = %@", accountId);
    
    NSMutableDictionary *accountInfo = [self infoForAccount:accountId];
    DLog(@"return [accountInfo] = %@",accountInfo);

    return [accountInfo objectForKey:ACCOUNT_SCHEDULED_FOLDER_ID];
}

+ (NSString *)getFolderIdForAccount:(NSString *)accountId forKey:(NSString*)key {
  
    key = [key lowercaseString];
    NSMutableDictionary *accountInfo = [self infoForAccount:accountId];
    DLog(@"return [accountInfo] = %@",accountInfo);
    
    NSArray *folderIds = accountInfo[ACCOUNT_FOLDER_IDS];
    __block NSString *folderId = nil;
    [folderIds enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *folder = (NSDictionary *)obj;
        NSString *value = [folder objectForCaseInsensitiveKey:key];
        if(value) folderId = value;
    }];
    
    return folderId;
    
}

+ (void)deleteScheduledFolderIdForAccout:(NSString *)accountId {

    NSMutableDictionary *dict =[self infoForAccount:accountId];
    
    [dict removeObjectForKey:ACCOUNT_SCHEDULED_FOLDER_ID];
    
    [[PMStorageManager sharedInstance] writeInfo:dict intoFile:accountId];
    
}

+ (NSArray*)getStandardFoldersForAccount:(NSString *)accountId
{
    NSMutableArray *standardFolders = [NSMutableArray new];
    
    NSArray *folders = [PMStorageManager getFoldersForAccount:accountId];
    for(NSDictionary *folder in folders)
    {
        if(![folder[@"name"] isEqualToString:USER_CREATED_FOLDER] && ![folder[@"name"] containsString:@"calendar"] && ![folder[@"name"] containsString:@"contact"])
            [standardFolders addObject:folder];
    }
    
    NSDictionary *tags = orderByFolder;
    NSArray *aSortedArray = [standardFolders sortedArrayUsingComparator:^(NSDictionary *obj1, NSDictionary *obj2) {
        NSString *num1 =[tags objectForKey:[obj1 objectForKey:@"name"]];
        NSString *num2 =[tags objectForKey:[obj2 objectForKey:@"name"]];
        return (NSComparisonResult) [num1 compare:num2 options:(NSNumericSearch)];
    }];
    
    return aSortedArray;
}

+ (NSArray*)getUserFoldersForAccount:(NSString *)accountId
{
    NSMutableArray *userFolders = [NSMutableArray new];
    NSArray *folders = [PMStorageManager getFoldersForAccount:accountId];
    for(NSDictionary *folder in folders)
    {
        if([folder[@"name"] isEqualToString:USER_CREATED_FOLDER])
            [userFolders addObject:folder];
    }
    
    NSArray *aSortedArray = [userFolders sortedArrayUsingComparator:^(NSDictionary *obj1, NSDictionary *obj2) {
        NSString *num1 =[obj1 objectForKey:@"display_name"];
        NSString *num2 =[obj2 objectForKey:@"display_name"];
        return (NSComparisonResult) [num1 compare:num2];
    }];
    
    return aSortedArray;
}

+ (NSDictionary *)getUnreadsForAccount:(NSString *)accountId
{
    NSMutableDictionary *accountInfo = [self infoForAccount:accountId];
    
    if(!accountInfo[ACCOUNT_UNREADS]) return [NSDictionary new];
    return accountInfo[ACCOUNT_UNREADS];
}

+ (NSInteger)getUnreadsForFolder:(NSString *)folderId forAccount:(NSString *)accountId
{
    NSDictionary *unreadsData = [self getUnreadsForAccount:accountId];
    if(unreadsData)
        return [unreadsData[folderId] integerValue];
    return 0;
}

+ (NSInteger)getAllAccountUnreadsForFolderName:(NSString*)folderName
{
    NSInteger count = 0;
    for(DBNamespace *namespace in [[DBManager instance] getNamespaces])
    {
        NSString *accountId = namespace.account_id;
        
        NSDictionary *unreadsData = [self getUnreadsForAccount:accountId];
        if(unreadsData)
        {
            NSString *folderId = [self getFolderIdForAccount:accountId forKey:folderName];
        
            if(unreadsData[folderId])
            {
                count += [unreadsData[folderId] integerValue];
            }
        }
    }
    
    return count;
}

+ (void)increaseUnreadCount:(NSString *)folderId forAccount:(NSString *)accountId
{
    NSInteger count = [self getUnreadsForFolder:folderId forAccount:accountId];
    count++;
    [self setUnreadCount:count forFolder:folderId forAccount:accountId];
}
+ (void)decreaseUnreadCount:(NSString *)folderId forAccount:(NSString *)accountId
{
    NSInteger count = [self getUnreadsForFolder:folderId forAccount:accountId];
    count--;
    if(count>-1)
    [self setUnreadCount:count forFolder:folderId forAccount:accountId];
}
#pragma mark - Private methods

+ (NSMutableDictionary *)infoForAccount:(NSString *)name {
    NSMutableDictionary *accountInfo = [[PMStorageManager sharedInstance] infoFileWithName:name];
    if(!accountInfo) {
        accountInfo = [NSMutableDictionary new];
    }
    return accountInfo;
}

- (NSMutableDictionary *)infoFileWithName:(NSString *)name {
    NSString *fileName = [name stringByAppendingString:@".plist"];
    return [[NSMutableDictionary alloc] initWithContentsOfFile:[self filePath:fileName]];
}

- (void)writeInfo:(NSDictionary *)info intoFile:(NSString *)name {
    if(info) {
        NSString *fileName = [name stringByAppendingString:@".plist"];
        if([info writeToFile:[self filePath:fileName] atomically:YES])
            DLog(@"Write Account Folder Info Succeeded!");
        else
            DLog(@"Write Account Folder Info Failed!");
    }
}

- (NSString *)filePath:(NSString *)name {
    NSString *filePath = [NSHomeDirectory() stringByAppendingString:[NSString stringWithFormat:@"/Documents/%@", name]];
    return filePath;
}


- (void)setBlackList:(NSArray *)list forEmail:(NSString *)email
{
    
    NSDictionary *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"kBlackList"];
    
    NSMutableDictionary *blackListData;
    if(data==nil)
    {
        blackListData = [NSMutableDictionary new];
    }
    else
    {
        blackListData = [NSMutableDictionary dictionaryWithDictionary:data];
    }
    
    [blackListData setObject:list forKey:email];
    
    [[NSUserDefaults standardUserDefaults] setObject:blackListData forKey:@"kBlackList"];
}

- (NSArray*)getBlackList:(NSString*)email
{
    NSDictionary *blackListData = [[NSUserDefaults standardUserDefaults] objectForKey:@"kBlackList"];
    
    if(!blackListData) return nil;
    
    return blackListData[email];
}


@end
