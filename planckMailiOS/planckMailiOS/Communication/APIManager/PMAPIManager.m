//
//  PMAPIManager.m
//  planckMailiOS
//
//  Created by Admin on 5/10/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMAPIManager.h"
#import "OPDataLoader.h"
#import "PMRequest.h"
#import "PMThread.h"
#import "PMNetworkManager.h"
#import "PMEventModel.h"
#import "PMFileManager.h"
#import "DBContact.h"
#import "DBMessage.h"
#import "DBEvent.h"
#import "DBAccount.h"
#import "DBTrack.h"
#import "DBTrackDetail.h"
#import "PMSettingsManager.h"
#import "PMFolderManager.h"

#import "Config.h"
#import "CLContactLibrary.h"


#define TOKEN @"namespaces"

@interface PMAPIManager ()
@property(nonatomic, strong) PMNetworkManager *networkManager;
@end

@implementation PMAPIManager

#pragma mark - static methods

+ (PMAPIManager *)shared {
    static PMAPIManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedManager = [PMAPIManager new];
    });
    return sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _networkManager = [PMNetworkManager sharedPMNetworkManager];
    }
    return self;
}

#pragma mark - pablic methods

- (void)saveNamespaceIdFromToken:(NSString *)token completion:(ExtendedBlockHandler)handler {
    SAVE_VALUE(token, TOKEN);
    
    [_networkManager setCurrentToken:token];
    
    [_networkManager GET:@"/account" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        DLog(@"saveNamespaceIdFromToken-  stask - %@  / response - %@", task, responseObject);
        
        if([responseObject isKindOfClass:[NSDictionary class]])
        {
            
            NSDictionary *accountData = responseObject;
            
            
            NSString *accountId = accountData[@"account_id"];
            
            DBNamespace *lNewNamespace = [DBNamespace getNamespaceWithAccountId:accountId];
            
            if(lNewNamespace) {
                if(handler) handler(@{@"is_duplicated":@(YES)}, nil, NO);
                return;
            }
            
            DLog(@"Old namespace token:%@", lNewNamespace.token);
            
            if(!lNewNamespace) lNewNamespace = [DBManager createNewNamespace];
            
            lNewNamespace.id = accountData[@"id"];
            lNewNamespace.account_id = accountData[@"account_id"];
            lNewNamespace.email_address = accountData[@"email_address"];
            lNewNamespace.name = accountData[@"name"];
            lNewNamespace.namespace_id = accountData[@"namespace_id"]?accountData[@"namespace_id"]:accountData[@"account_id"];
            lNewNamespace.organizationUnit = accountData[@"organization_unit"];
            
            //DLog(@"namespace id - %@", accountDict[@"account_id"]);
            
            lNewNamespace.object = accountData[@"object"];
            lNewNamespace.provider = accountData[@"provider"];
            lNewNamespace.token = token;
            [[DBManager instance] save];
            
            
            // add account to local database
            
            [DBAccount createOrUpdateAccountWithData:@{
                                                       @"title": accountData[@"email_address"],
                                                       @"email": accountData[@"email_address"],
                                                       @"description": accountData[@"provider"],
                                                       @"type":ACCOUNT_TYPE_EMAIL,
                                                       @"provider": accountData[@"provider"],
                                                       @"token": token,
                                                       @"account_id": accountData[@"account_id"]
                                                       }];
            

            
            handler(accountData, nil, YES);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MAIL_ACCOUNT_ADDED object:lNewNamespace.account_id];
        }
        else
        {
            handler(nil, nil, NO);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"saveNamespaceIdFromToken - ftask - %@  / error - %@", task, error);
        
        NSString *errorString = [[NSString alloc] initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding];
        DLog(@"saveNamespaceIdFromToken Error Message:%@", errorString);
        handler(nil, nil, NO);
    }];
}

- (NSArray*)getThreadsWithAccount:(NSString*)accountId
                         folder:(NSString*)folder
                         offset:(NSUInteger)offset
                          limit:(NSUInteger)limit
{
    NSDictionary *params = @{@"in": folder,
                             @"offset": @(offset),
                             @"limit": @(limit)
                            };
    
    // First load mail models from local database
    DBManager *dbManager = [DBManager instance];
    
    NSArray *dbInboxMailModels = [dbManager getInboxMailModelsWithParams:params namespaceId:accountId];
    
    NSMutableArray *pmInboxMailModels = [NSMutableArray new];
    for(DBThread *dbInboxMailModel in dbInboxMailModels)
    {
        PMThread *pmInboxMailModel = [dbInboxMailModel toPMThread];
        
        DLog(@"%@:%@:%@ ======== %i", pmInboxMailModel.ownerEmail, pmInboxMailModel.participants, pmInboxMailModel.subject, pmInboxMailModel.isUnread);
        DLog(@"MessageIds:%@", pmInboxMailModel.messageIds);
        [pmInboxMailModels addObject:pmInboxMailModel];
    }
    
    return pmInboxMailModels;
}

- (void)getThreadsWithAccount:(NSString*)accountId
                     folder:(NSString *)folder
                     offset:(NSUInteger)offset
                      limit:(NSUInteger)limit
                 completion:(ExtendedBlockHandler)handler
{
    DLog(@"folder name:%@", folder);
    
    
    NSDictionary *params = @{@"in": folder,
                             @"offset": @(offset),
                             @"limit": @(limit)
                             };
    
    return [self getThreadsWithAccount:accountId
                          parameters:params
                                path:@"/threads"
                          completion:handler];
}



- (void)searchMailWithKeyword:(NSString *)keyword account:(id<PMAccountProtocol>)account completion:(ExtendedBlockHandler)handler {
    
    return [self getThreadsWithAccount:[account namespace_id] parameters:@{@"q" : keyword} path:@"/threads/search" completion:handler];
}

- (NSArray*)getMessagesWithThreadId:(NSString *)threadId forAccount:(NSString*)accountId completion:(ExtendedBlockHandler)handler
{
    NSDictionary *params = threadId ? @{@"thread_id" : threadId} : nil;
    
    DBNamespace *namespace = [DBNamespace getNamespaceWithAccountId:accountId];
    
    NSString *token = namespace.token; DLog(@"Token = %@", token);
    [_networkManager setCurrentToken:token];
    
    [_networkManager GET:@"/messages" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        DLog(@"getMessagesWithThreadId-  stask - %@  / response - %@", task, responseObject);
        
        if([responseObject isKindOfClass:[NSArray class]])
        {
            NSArray *messages = responseObject;
            
            // Save message to local sqlite db
            NSManagedObjectContext *context = [[DBManager instance] workerContext];
            for(NSDictionary *message in messages)
            {
                NSString *messageId = message[@"id"];
                NSMutableArray *localMessageIds = [[PMSettingsManager instance] getMessageIds];
                
                if(![localMessageIds containsObject:messageId])
                {
                    [DBMessage createOrUpdateMessageFromDictionary:message onContext:context];
                    
                    for (NSDictionary *toItem in message[@"to"]) {
                        NSString *toEmail = toItem[@"email"];
                        if(![toEmail isEqualToString:self.namespaceId.email_address])
                        {
                            NSDictionary *contactData =  @{@"account_id":message[@"account_id"], @"email":toEmail, @"name":toItem[@"name"]};
                            [DBContact createOrUpdateContactWithData:contactData onContext:context];
                        }
                    }
                    
                    [[PMSettingsManager instance] addMessageId:messageId];
                    
                    
                    NSArray *from = message[@"from"];
                    
                    if(from && from.count)
                    {
                        
                        if(message[@"folder"] && ![message[@"folder"] isEqual:[NSNull null]] && [message[@"folder"][@"display_name"] isEqualToString:@"Read Later"])
                        {
                            [[PMSettingsManager instance] addActiveSpammer:from[0] forAccount:accountId];
                        }
                        else if(message[@"labels"])
                        {
                            for(NSDictionary *label in message[@"labels"])
                            {
                                if([label[@"display_name"] isEqualToString:@"Read Later"])
                                {
                                    [[PMSettingsManager instance] addActiveSpammer:from[0] forAccount:accountId];
                                }
                            }
                        }
                    }
                }
            }
            
            [[DBManager instance] saveOnContext:context];
            
            if(handler) handler(messages, nil, YES);
        }
        else
        {
            if(handler) handler(nil, nil, NO);
        }
        
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"getMessagesWithThreadId - ftask - %@  / error - %@", task, error);
        if(handler) handler(nil, error, NO);

    }];
    
    NSMutableArray *messages = [NSMutableArray new];
    
    // First load mail models from local database
    DBManager *dbManager = [DBManager instance];
    
    NSArray *dbMessages = [dbManager getMessagesWithThreadId:threadId];
    
    for(DBMessage *dbMessage in dbMessages)
    {
        [messages addObject:[dbMessage convertToDictionary]];
    }
 
    return messages;
}

- (void)getMessagesWithParams:(NSDictionary *)params forAccount:(NSString*)accountId completion:(ExtendedBlockHandler)handler
{
    
    DBNamespace *namespace = [DBNamespace getNamespaceWithAccountId:accountId];
    
    NSString *token = namespace.token;
    [_networkManager setCurrentToken:token];
    
    [_networkManager GET:@"/messages" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        DLog(@"getMessagesWithParams-  stask - %@  / response - %@", task, responseObject);
        
        if([responseObject isKindOfClass:[NSArray class]])
        {
            NSArray *messages = responseObject;
            
            // Save message to local sqlite db
            NSManagedObjectContext *context = [[DBManager instance] workerContext];
            for(NSDictionary *message in messages)
            {
                NSString *messageId = message[@"id"];
                NSMutableArray *localMessageIds = [[PMSettingsManager instance] getMessageIds];
                
                if(![localMessageIds containsObject:messageId])
                {
                    [DBMessage createOrUpdateMessageFromDictionary:message onContext:context];
                    
                    [[PMSettingsManager instance] addMessageId:messageId];
                    
                    
                    NSArray *from = message[@"from"];
                    
                    if(from && from.count)
                    {
                        if(message[@"folder"] && ![message[@"folder"] isEqual:[NSNull null]] && [message[@"folder"][@"display_name"] isEqualToString:@"Read Later"])
                        {
                            [[PMSettingsManager instance] addActiveSpammer:from[0] forAccount:accountId];
                        }
                        else if(message[@"labels"])
                        {
                            for(NSDictionary *label in message[@"labels"])
                            {
                                if([label[@"display_name"] isEqualToString:@"Read Later"])
                                {
                                    [[PMSettingsManager instance] addActiveSpammer:from[0] forAccount:accountId];
                                }
                            }
                        }
                    }
                }
                
            }
            
            [[DBManager instance] saveOnContext:context];
            
            if(handler) handler(messages, nil, YES);
        }
        else
        {
            if(handler) handler(nil, nil, NO);
        }
        
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"getMessagesWithParams - ftask - %@  / error - %@", task, error);
        if(handler) handler(nil, error, NO);
        
    }];
    
}

- (NSArray*)getDetailWithAnyEmail:(NSString *)anyEmail account:(id<PMAccountProtocol>)account completion:(ExtendedBlockHandler)handler {
    
    NSDictionary *lParameters = @{@"any_email" : anyEmail};
    
    [_networkManager setCurrentToken:account.token];
    //[_networkManager GET:[NSString stringWithFormat:@"/n/%@/messages", account.namespace_id] parameters:lParameters success:^(NSURLSessionDataTask *task, id responseObject) {
    [_networkManager GET:@"/messages" parameters:lParameters success:^(NSURLSessionDataTask *task, id responseObject) {
            DLog(@"getDetailWithThreadId-  stask - %@  / response - %@", task, responseObject);
        
        NSArray *lResponse = responseObject;        
        
        if(handler) handler(lResponse, nil, YES);
        
        NSManagedObjectContext *context = [[DBManager instance] workerContext];
        for(NSDictionary *item in lResponse)
        {
            [DBMessage createOrUpdateMessageFromDictionary:item onContext:context];
        }
        
        [[DBManager instance] saveOnContext:context];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"getDetailWithThreadId - ftask - %@  / error - %@", task, error);
        if(handler) handler(nil, nil, NO);
    }];
    
    NSMutableArray *messages = [NSMutableArray new];
    
    // First load mail models from local database
    DBManager *dbManager = [DBManager instance];
    
    NSArray *dbMessages = [dbManager getMessagesWithAnyEmail:anyEmail namespaceId:self.namespaceId.namespace_id];
    
    for(DBMessage *dbMessage in dbMessages)
    {
        [messages addObject:[dbMessage convertToDictionary]];
    }
    
    return messages;
}

- (NSDictionary*)getMessageWithId:(NSString *)messageId account:(id<PMAccountProtocol>)account completion:(ExtendedBlockHandler)handler {
    
    
    [_networkManager setCurrentToken:account.token];
    //[_networkManager GET:[NSString stringWithFormat:@"/n/%@/messages", account.namespace_id] parameters:lParameters success:^(NSURLSessionDataTask *task, id responseObject) {
    [_networkManager GET:[NSString stringWithFormat:@"/messages/%@", messageId] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        DLog(@"getMessageWithId -  stask - %@  / response - %@", task, responseObject);
        
        NSDictionary *item = responseObject;
        
        if(handler) handler(item,nil,YES);
        
        // Save message to local sqlite db
        NSManagedObjectContext *context = [[DBManager instance] workerContext];
        [DBMessage createOrUpdateMessageFromDictionary:item onContext:context];
        [[DBManager instance] saveOnContext:context];
        
        //[[DBManager instance] save];
        
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"getMessageWithId - ftask - %@  / error - %@", task, error);
        if(handler) handler(nil, error, NO);
        
    }];
    
    
    DBMessage *dbMessage = [DBMessage getMessageWithId:messageId];
    
    if(dbMessage)
        return [dbMessage convertToDictionary];
    return nil;
}

- (void)getDraftWithId:(NSString *)draftId forAccount:(NSString*)accountId completion:(ExtendedBlockHandler)handler
{
    DBNamespace *namespace = [DBNamespace getNamespaceWithAccountId:accountId];
    
    [_networkManager setCurrentToken:namespace.token];
    
    [_networkManager GET:[NSString stringWithFormat:@"/drafts/%@", draftId] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject)
    {
        DLog(@"getDraftId -  stask - %@  / response - %@", task, responseObject);
        
        NSDictionary *item = responseObject;
        
        if(handler) handler(item, nil, YES);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"getDraftId - ftask - %@  / error - %@", task, error);
        if(handler) handler(nil, error, NO);
    }];
}


- (void)replyMessage:(NSDictionary *)message completion:(ExtendedBlockHandler)handler {
    [_networkManager POST:[PMRequest replyMessageWithNamespacesId:self.namespaceId.namespace_id] parameters:message success:^(NSURLSessionDataTask *task, id responseObject) {
        DLog(@"replyMessage-  stask - %@  / response - %@", task, responseObject);
        
        if(responseObject==nil || ![responseObject isKindOfClass:[NSDictionary class]]) {
            if(handler) {
                handler(nil, nil, NO);
            }
            return;
        }
        
        if(handler) {
            handler(responseObject, nil, YES);
        }
        
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"replyMessage - ftask - %@  / error - %@", task, error);
        if(handler) {
            handler(nil, error, NO);
        }
    }];
}

- (void)createDraft:(NSDictionary *)params completion:(ExtendedBlockHandler)handler
{
    NSString *url = [NSString stringWithFormat:@"%@/drafts", APP_SERVER_LINK];
    
    [_networkManager POST:url parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        DLog(@"createDraft-  stask - %@  / response - %@", task, responseObject);
        if(handler) {
            handler(responseObject, nil, YES);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSString *errorString = [[NSString alloc] initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding];
        NSLog(@"createDraft Error: %@", errorString);
        if(handler) {
            handler(nil, error, NO);
        }
    }];
}
- (void)updateDraft:(NSString*)draftId params:(NSDictionary *)params completion:(ExtendedBlockHandler)handler
{
    NSString *url = [NSString stringWithFormat:@"%@/drafts/%@", APP_SERVER_LINK, draftId];
    
    [_networkManager PUT:url parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        DLog(@"updateDraft-  stask - %@  / response - %@", task, responseObject);
        if(handler) {
            handler(responseObject, nil, YES);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"updateDraft - ftask - %@  / error - %@", task, error);
        if(handler) {
            handler(nil, error, NO);
        }
    }];
}
- (void)deleteDraft:(NSString*)draftId params:(NSDictionary *)params completion:(ExtendedBlockHandler)handler
{
    NSString *url = [NSString stringWithFormat:@"%@/drafts/%@", APP_SERVER_LINK, draftId];
    
    [_networkManager DELETE:url parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        DLog(@"deleteDraft-  stask - %@  / response - %@", task, responseObject);
        if(handler) {
            handler(responseObject, nil, YES);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSString *errorString = [[NSString alloc] initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding];
        NSLog(@"deleteDraft Error: %@", errorString);
        if(handler)
            handler(nil, error, NO);
    }];
}

- (void)setActiveNamespace:(DBNamespace *)namespace
{
    SAVE_VALUE(namespace.token, TOKEN);
    _namespaceId = namespace;
    _emailAddress = [namespace.email_address copy];
    
    [[NSUserDefaults standardUserDefaults] setObject:namespace.account_id forKey:@"active_account_id"];
}

- (DBNamespace*)getRecentNamespace
{
    NSString *accountId = [[NSUserDefaults standardUserDefaults] objectForKey:@"active_account_id"];
    DBNamespace *namespace;
    if(accountId)
    {
        namespace = [DBNamespace getNamespaceWithAccountId:accountId];
    }
    
    if(namespace==nil)
    {
        NSArray *lItemsArray = [[DBManager instance] getNamespaces];
        namespace = [lItemsArray firstObject];
    }
    
    return namespace;
}
- (void)getUnreadCountForNamespaseToken:(NSString *)token completion:(ExtendedBlockHandler)handler {
    
    [_networkManager setCurrentToken:token];
    [_networkManager GET:[PMRequest unreadMessagesCount] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        DLog(@"getUnreadCountForNamespaseToken -  stask - %@  / response - %@", task, responseObject);
        
        NSNumber *result = nil;
        if(responseObject) {
            result = [NSNumber numberWithInteger:[responseObject[@"count"] integerValue]];
        }
        if(handler) {
            handler(result, nil, YES);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if(handler) {
            handler(nil, error, NO);
        }
        DLog(@"getUnreadCountForNamespaseToken - ftask - %@  / error - %@", task, error);
    }];
}

- (void)getUnreadCountForFolder:(NSString *)folder forAccount:(NSString *)accountId completion:(ExtendedBlockHandler)handler
{
    DBNamespace *namespace = [DBNamespace getNamespaceWithAccountId:accountId];
    if (!namespace) {
        if(handler) handler(nil, nil, NO);
        return;
    }
    
    [_networkManager setCurrentToken:namespace.token];
    
    NSString *urlString = [PMRequest unreadMessagesCountForFolder:folder];
    [_networkManager GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        DLog(@"getUnreadCountForFolder -  stask - %@  / response - %@", task, responseObject);
        
        NSNumber *result = nil;
        if(responseObject) {
            result = [NSNumber numberWithInteger:[responseObject[@"count"] integerValue]];
        }
        if(handler) {
            handler(result, nil, YES);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if(handler) {
            handler(nil, error, NO);
        }
        DLog(@"getUnreadCountForFolder - ftask - %@  / error - %@", task, error);
    }];
}
#pragma mark - Folders

- (void)getFoldersWithAccount:(NSString*)accountId comlpetion:(ExtendedBlockHandler)handler
{
    DBNamespace *account = [DBNamespace getNamespaceWithAccountId:accountId];
    [_networkManager setCurrentToken:account.token];
    [_networkManager GET:[PMRequest foldersWithNamespaceId:account folderId:nil] parameters:nil success:^ (NSURLSessionDataTask *task, id responseObject)
    {
        DLog(@"getFoldersWithAccount: %@", responseObject);
        if(responseObject==nil || ![responseObject isKindOfClass:[NSArray class]])
        {
            if(handler) {
                handler(nil, nil, NO);
            }
            return;
        }
        
        for(NSDictionary *folder in responseObject) {
            [DBFolder createOrUpdateWithData:folder];
            
            NSString *folderId = folder[@"id"];
            [[PMAPIManager shared] getUnreadCountForFolder:folderId forAccount:accountId completion:^(id data, id error, BOOL success) {
                if(success)
                {
                    [DBFolder setUnreads:data forFolder:folderId];
                }
            }];
        }
        
        if(handler) {
            handler(responseObject, nil, YES);
        }
    } failure:^ (NSURLSessionDataTask * task, NSError *error) {
        handler(nil, error, NO);
    }];
    
}

- (void)getFoldersWithAccount:(id<PMAccountProtocol>)account folderId:(NSString*)folderId comlpetion:(ExtendedBlockHandler)handler {
    [_networkManager setCurrentToken:account.token];
    [_networkManager GET:[PMRequest foldersWithNamespaceId:account folderId:folderId] parameters:nil success:^ (NSURLSessionDataTask *task, id responseObject) {
        if(handler) {
            handler(responseObject, nil, YES);
        }
    } failure:^ (NSURLSessionDataTask * task, NSError *error) {
        handler(nil, error, NO);
    }];
    
}

- (void)createFolderWithName:(NSString *)folderName
                     account:(id<PMAccountProtocol>)account
                  comlpetion:(ExtendedBlockHandler)handler{
    NSDictionary *lParams = @{@"display_name":folderName};
    [_networkManager setCurrentToken:account.token];
    [_networkManager POST:[PMRequest foldersWithNamespaceId:account folderId:nil] parameters:lParams success:^ (NSURLSessionDataTask *task, id responseObject)
    {
        DLog(@"createFolderWithName success with data:%@", responseObject);
        if([responseObject isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *folder = responseObject;
            [DBFolder createOrUpdateWithData:folder];
            
            
            if(handler) {
                handler(responseObject, nil, YES);
            }
        }
        else
        {
            if(handler)
            {
                handler(nil, nil, NO);
            }
        }
    } failure:^ (NSURLSessionDataTask *task, NSError *error) {
        DLog(@"createFolderWithName failed with the error:%@", [error localizedDescription]);
        if(handler) {
            handler(nil, error, NO);
        }
    }];
    
}

- (void)renameFolderWithName:(NSString *)newFolderName
                     account:(id<PMAccountProtocol>)account
                    folderId:(NSString *)folderId
                  comlpetion:(ExtendedBlockHandler)handler {
    
    NSDictionary *lParams = @{@"display_name":newFolderName};
    [_networkManager setCurrentToken:account.token];
    [_networkManager PUT:[PMRequest foldersWithNamespaceId:account folderId:folderId] parameters:lParams success:^ (NSURLSessionDataTask *task, id responseObject) {
        if(handler) {
            handler(responseObject, nil, YES);
        }
    } failure:^ (NSURLSessionDataTask *task, NSError *error) {
        if(handler) {
            handler(nil, error, NO);
        }
    }];
}



- (void)deleteFolderWithId:(NSString*)folderId
                   account:(id<PMAccountProtocol>)account
                completion:(ExtendedBlockHandler)handler {
    
    [_networkManager setCurrentToken:account.token];
    [_networkManager DELETE:[PMRequest foldersWithNamespaceId:account folderId:folderId] parameters:nil
                    success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                        if (handler) {
                            handler(responseObject, nil, YES);
                        }
                    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
                        if (handler) {
                            handler(nil, error, NO);
                        }
                    }];
    
}


#pragma mark Snooze Relation
-(void)moveMailToReminderMailId:(NSString*)mailId account:(id<PMAccountProtocol>)account time:(int)time threadId:(NSString*)threadId messageId:(NSString*)messageId autoAsk:(NSString*)autoAsk subject:(NSString*)subject completion:(ExtendedBlockHandler)handler {

    NSDictionary *lParameters = nil;
    lParameters = @{@"email_id" : mailId, @"max_time" : [NSNumber numberWithInt:time], @"thread_id": threadId, @"msg_id" : messageId, @"auto_ask" : autoAsk, @"subject" : subject};
    
    [_networkManager setCurrentToken:account.token];
    _networkManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [_networkManager PUT:[PMRequest reminder] parameters:lParameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        DLog(@"success");
        handler(responseObject, nil, YES);
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        DLog(@"failure");
        DLog(@"error = %@",error);
        handler(nil, error, NO);
    }];
}

- (NSArray*)getSnoozedThreadsForAccount:(NSString *)accountId
{
    NSArray *dbThreads = [[DBManager instance] getSnoozedThreadsForAccount:accountId];
    
    NSMutableArray *pmThreads = [NSMutableArray new];
    for(DBThread *dbThread in dbThreads)
    {
        PMThread *pmThread = [dbThread toPMThread];
        
        //DLog(@"%@:%@:%@ ======== %i", pmThread.ownerEmail, pmThread.participants, pmThread.subject, pmThread.isUnread);
        [pmThreads addObject:pmThread];
    }
    
    return pmThreads;
}

- (void)updateThread:(NSString *)threadId
          forAccount:(NSString *)accountId
              params:(NSDictionary *)params
          completion:(ExtendedBlockHandler)handler
{
    DBNamespace *namespace = [DBNamespace getNamespaceWithAccountId:accountId];
    [_networkManager setCurrentToken:namespace.token];
    
    [_networkManager PUT:[PMRequest updateThread:threadId] parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject)
     {
         DLog(@"updateThread succeeded with the result:%@", responseObject);
         
         if([responseObject isKindOfClass:[NSDictionary class]])
         {
             [DBThread createOrUpdateWithData:responseObject];
             if(handler) handler(responseObject, nil, YES);
         }
         else
         {
             if(handler) handler(nil, nil, NO);
         }
     } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
         DLog(@"updateThread failed with the error: %@",[error localizedDescription]);
         handler(nil, error, NO);
     }];
}

- (void)moveThread:(PMThread*)thread toFolder:(NSString*)folderId completion:(ExtendedBlockHandler)handler
{
    if(folderId == nil)
    {
        if(handler) handler(nil, nil, NO);
        
        return;
    }
    DBNamespace *namespace = [DBNamespace getNamespaceWithAccountId:thread.accountId];
    
    NSDictionary *params;
    if([namespace.organizationUnit isEqualToString:@"folder"])
    {
        params = @{@"folder_id": folderId};
    }
    else if([namespace.organizationUnit isEqualToString:@"label"])
    {
        NSMutableArray *labelIds = [NSMutableArray new];
        for(NSDictionary *label in thread.folders)
        {
            if(![label[@"name"] isEqual:[NSNull null]] && [[label[@"name"] lowercaseString] isEqualToString:@"sent"])
            {
                [labelIds addObject:label[@"id"]];
            }
        }
        
        [labelIds addObject:folderId];
        params = @{@"label_ids": labelIds};
    }
    
    [self updateThread:thread.id forAccount:thread.accountId params:params completion:handler];
}
- (void)deleteThread:(PMThread *)thread completion:(ExtendedBlockHandler)handler
{
    NSString *accountId = thread.accountId;
    NSString *trashFolderId = [[PMFolderManager sharedInstance] getFolderIdForAccount:accountId folderName:@"trash"];
    DLog(@"trashFolderId = %@", trashFolderId);
    
    if(!trashFolderId)
    {
        DBNamespace *account = [DBNamespace getNamespaceWithAccountId:accountId];
        [[PMAPIManager shared] createFolderWithName:@"Trash" account:account comlpetion:^(id data, id error, BOOL success) {
           if(!success)
           {
               if(handler) handler(nil, nil, NO);
               return;
           }
           [[PMAPIManager shared] moveThread:thread toFolder:data[@"id"] completion:handler];
        }];
    }
    else
    {
        [[PMAPIManager shared] moveThread:thread toFolder:trashFolderId completion:handler];
    }
    
}
- (void)unsubscribeThread:(PMThread *)thread completion:(ExtendedBlockHandler)handler
{
    NSString *accountId = thread.accountId;
    NSString *folderId = [[PMFolderManager sharedInstance] getFolderIdForAccount:accountId folderName:@"Black Hole"];
    
    if(!folderId)
    {
        DBNamespace *account = [DBNamespace getNamespaceWithAccountId:accountId];
        [[PMAPIManager shared] createFolderWithName:@"Black Hole" account:account comlpetion:^(id data, id error, BOOL success) {
            if(!success)
            {
                if(handler) handler(nil, nil, NO);
                return;
            }
            [[PMAPIManager shared] moveThread:thread toFolder:data[@"id"] completion:handler];
        }];
    }
    else
    {
        [[PMAPIManager shared] moveThread:thread toFolder:folderId completion:handler];
    }
    
}
- (void)archiveThread:(PMThread *)thread completion:(ExtendedBlockHandler)handler
{
    NSString *accountId = thread.accountId;
    NSString *archiveFolderId = [[PMFolderManager sharedInstance] getFolderIdForAccount:accountId folderName:@"Archive"];
    DLog(@"archiveFolderId = %@", archiveFolderId);
    
    if(!archiveFolderId)
    {
        DBNamespace *account = [DBNamespace getNamespaceWithAccountId:accountId];
        [[PMAPIManager shared] createFolderWithName:@"Archive" account:account comlpetion:^(id data, id error, BOOL success) {
            if(!success)
            {
                if(handler) handler(nil, nil, NO);
                return;
            }
            [[PMAPIManager shared] moveThread:thread toFolder:data[@"id"] completion:handler];
        }];
    }
    else
    {
        [[PMAPIManager shared] moveThread:thread toFolder:archiveFolderId completion:handler];
    }
}
-(void)markReadThread:(PMThread *)thread completion:(BasicBlockHandler)handler
{
    DBNamespace *namespace = [DBNamespace getNamespaceWithAccountId:thread.accountId];
    [_networkManager setCurrentToken:namespace.token];
    
    NSDictionary *params = @{@"unread": @(NO)};
    NSString *accountId = thread.accountId;
    
    [self updateThread:thread.id forAccount:accountId params:params completion:^(id data, id error, BOOL success) {
        if(success)
        {
            if([namespace.organizationUnit isEqualToString:@"label"])
            {
                for(NSDictionary *label in data[@"labels"])
                {
                    NSString *labelId = label[@"id"];
                    
                    [[PMFolderManager sharedInstance] decreaseUnreadsForFolder:labelId];
                }
            }
            else if([namespace.organizationUnit isEqualToString:@"folder"])
            {
                for(NSDictionary *folder in data[@"folders"])
                {
                    NSString *folderId = folder[@"id"];
                    
                    [[PMFolderManager sharedInstance] decreaseUnreadsForFolder:folderId];
                }
            }
            DBThread *dbThread = [DBThread getThreadWithId:thread.id];
            
            [dbThread setMarkRead];
            if(handler) handler(nil, YES);
        }
        else
        {
            if(handler) handler(error, NO);
        }
        
        
    }];
}

-(void)markUnreadThread:(PMThread *)thread completion:(BasicBlockHandler)handler
{
    DBNamespace *namespace = [DBNamespace getNamespaceWithAccountId:thread.accountId];
    [_networkManager setCurrentToken:namespace.token];
    
    NSDictionary *params = @{@"unread": @(YES)};
    
    NSString *accountId = thread.accountId;
    [self updateThread:thread.id forAccount:accountId params:params completion:^(id data, id error, BOOL success) {
        if(success)
        {
            if([namespace.organizationUnit isEqualToString:@"label"])
            {
                for(NSDictionary *label in data[@"labels"])
                {
                    NSString *labelId = label[@"id"];
                    
                    [[PMFolderManager sharedInstance] increaseUnreadsForFolder:labelId];
                }
            }
            else if([namespace.organizationUnit isEqualToString:@"folder"])
            {
                for(NSDictionary *folder in data[@"folders"])
                {
                    NSString *folderId = folder[@"id"];
                    
                    [[PMFolderManager sharedInstance] increaseUnreadsForFolder:folderId];
                }
            }
            
            DBThread *dbThread = [DBThread getThreadWithId:thread.id];
            
            [dbThread setMarkUnread];
            
            if(handler) handler(nil, YES);
        }
        else
        {
            if(handler) handler(error, NO);
        }
    }];
}

- (void)markImportantThread:(PMThread *)thread completion:(BasicBlockHandler)handler
{
    NSString *accountId = thread.accountId;
    
    NSString *email = thread.ownerEmail;
    
    NSMutableArray *contactEmailsArray = [NSMutableArray new];
    
    for(NSDictionary *participant in thread.participants)
    {
        if(![email isEqualToString:participant[@"email"]])
            [contactEmailsArray addObject:participant[@"email"]];
    }
    
    NSString *contactEmails = [contactEmailsArray componentsJoinedByString:@";"];
    NSDictionary *params = @{@"email_id" : email, @"contact_email_id" : contactEmails, @"important": @(1)};
    
    NSString *urlString = [PMRequest markImportant];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    
    [manager POST:urlString parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"markImportantThread Success: %@", responseObject);
        
        if([responseObject isKindOfClass:[NSDictionary class]] && [responseObject[@"success"] boolValue])
        {
            NSString *folderId = [[PMFolderManager sharedInstance] getFolderIdForAccount:accountId folderName:@"Inbox"];
            [self moveThread:thread toFolder:folderId completion:^(id data, id error, BOOL success) {               
                
                if(handler)
                {
                    handler(nil, success);
                }
                
            }];
        }
        else
        {
            if(handler)
            {
                handler(nil, NO);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"markImportantThread Error: %@", error);
        if(handler)
            handler(error, NO);
    }];
}
- (void)markUnimportantThread:(PMThread *)thread completion:(BasicBlockHandler)handler
{
    NSString *accountId = thread.accountId;
    
    NSString *email = thread.ownerEmail;
    
    NSMutableArray *contactEmailsArray = [NSMutableArray new];
    
    for(NSDictionary *participant in thread.participants)
    {
        if(![email isEqualToString:participant[@"email"]])
            [contactEmailsArray addObject:participant[@"email"]];
    }
    
    NSString *contactEmails = [contactEmailsArray componentsJoinedByString:@";"];
    
    NSDictionary *params = @{@"email_id" : email, @"contact_email_id" : contactEmails, @"important": @(0)};
    
    NSString *urlString = [PMRequest markImportant];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    
    [manager POST:urlString parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"markUnimportantThread Success: %@", responseObject);
        
        if([responseObject isKindOfClass:[NSDictionary class]] && [responseObject[@"success"] boolValue])
        {
            NSString *folderId = [[PMFolderManager sharedInstance] getFolderIdForAccount:accountId folderName:@"Read Later"];
            
            if(!folderId)
            {
                DBNamespace *account = [DBNamespace getNamespaceWithAccountId:accountId];
                [[PMAPIManager shared] createFolderWithName:@"Read Later" account:account comlpetion:^(id data, id error, BOOL success) {
                    if(!success)
                    {
                        if(handler) handler(nil, NO);
                        return;
                    }
                    
                    [self moveThread:thread toFolder:data[@"id"] completion:^(id data, id error, BOOL success) {
                        
                        if(handler)
                        {
                            handler(nil, success);
                        }
                        
                    }];
                }];
            }
            else
            {
                [self moveThread:thread toFolder:folderId completion:^(id data, id error, BOOL success) {
                    
                    if(handler)
                    {
                        handler(nil, success);
                    }
                    
                }];
            }
        }
        else
        {
            if(handler)
            {
                handler(nil, NO);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"markUnimportantThread Error: %@", error);
        if(handler)
            handler(error, NO);
    }];
}

#pragma mark - Unsubscribe APIs

- (void)addEmailToBlackList:(NSArray *)emails forAccount:(NSString*)accountId completion:(ExtendedBlockHandler)handler
{
    DBNamespace *namespace = [DBNamespace getNamespaceWithAccountId:accountId];
    NSDictionary *params = @{@"email_id" : namespace.email_address, @"blacklist_id" : [emails componentsJoinedByString:@";"]};
    
    NSString *urlString = [PMRequest addEmailToBlackList];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    
    [manager POST:urlString parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"addEmailToBlackList Success: %@", responseObject);
        
        NSDictionary *folderData = [[PMFolderManager sharedInstance] getFolderDataForAccount:accountId folderName:@"Black Hole"];
        
        NSArray *dbMails = [[DBManager instance] getInboxMailModelsWithParams:@{@"participants":emails} namespaceId:accountId];
        
        for(DBThread *mail in dbMails)
        {
            if(folderData)
                [mail setFolder:folderData];
            else
                [DBThread deleteModel:mail];
        }
        
        if(handler)
        {
            handler(responseObject, nil, YES);
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_EMAIL_ADDED_TO_BLACK_LIST object:nil];
        
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"addEmailToBlackList Error: %@", error);
        if(handler)
            handler(nil, error, NO);
    }];
    
}
- (void)removeEmailFromBlackList:(NSArray *)emails forAccount:(NSString*)accountId completion:(ExtendedBlockHandler)handler
{
    DBNamespace *namespace = [DBNamespace getNamespaceWithAccountId:accountId];
    
    NSDictionary *params = @{@"email_id":namespace.email_address, @"blacklist_id":[emails componentsJoinedByString:@";"]};
    
    NSString *urlString = [PMRequest removeEmailFromBlackList];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    
    [manager POST:urlString parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"removeEmailFromBlackList Success: %@", responseObject);
        
        NSDictionary *folderData = [[PMFolderManager sharedInstance] getFolderDataForAccount:accountId folderName:@"Inbox"];
        
        NSArray *dbMails = [[DBManager instance] getInboxMailModelsWithParams:@{@"participants":emails} namespaceId:accountId];
        
        for(DBThread *mail in dbMails)
        {
            [mail setFolder:folderData];
        }
        
        if(handler)
        {
            handler(responseObject, nil, YES);
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_EMAIL_REMOVED_FROM_BLACK_LIST object:nil];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"removeEmailFromBlackList Error: %@", error);
        if(handler)
            handler(nil, error, NO);
    }];
}

- (void)getBlackList:(NSString*)email completion:(ExtendedBlockHandler)handler
{
    NSDictionary *params = @{@"email_id" : email};
    
    NSString *urlString = [PMRequest getBlackList];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    
    [manager POST:urlString parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"getBlackList Success: %@", responseObject);
        
        if(handler)
        {
            if(responseObject[@"blacklist"])
                handler(responseObject[@"blacklist"], nil, YES);
            else
                handler(nil, nil, NO);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"getBlackList Error: %@", error);
        if(handler)
            handler(nil, error, NO);
    }];
}

- (void)getActiveSpammers:(NSString *)email count:(NSInteger)count completion:(ExtendedBlockHandler)handler
{
    NSDictionary *params = @{
                             @"email_id": email,
                             @"k": @(count)
                             };
    
    NSString *urlString = [PMRequest getActiveSpammers];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    
    [manager POST:urlString parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"getActiveSpammers Success: %@", responseObject);
        
        if(handler)
        {
            if(responseObject && [responseObject isKindOfClass:[NSDictionary class]])
                handler(responseObject, nil, YES);
            else
                handler(nil, nil, NO);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSString *errorString = [[NSString alloc] initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding];
        NSLog(@"getActiveSpammers Error: %@", errorString);
        if(handler)
            handler(nil, error, NO);
    }];
}

- (void)getMailsCountFromEmail:(NSString *)email forAccount:(NSString*)accountId completion:(ExtendedBlockHandler)handler
{
    DBNamespace *namespace = [DBNamespace getNamespaceWithAccountId:accountId];
    [_networkManager setCurrentToken:namespace.token];
    [_networkManager GET:[PMRequest countMailFromEmail:email] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        DLog(@"getMailsCountFromEmail -  stask - %@  / response - %@", task, responseObject);
        
        NSNumber *result = nil;
        if(responseObject) {
            result = [NSNumber numberWithInteger:[responseObject[@"count"] integerValue]];
        }
        if(handler) {
            handler(result, nil, YES);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if(handler) {
            handler(nil, error, NO);
        }
        DLog(@"getMailsCountFromEmail - ftask - %@  / error - %@", task, error);
    }];
}

- (void)getMessagesCountInFolder:(NSString *)folder forAccount:(NSString *)accountId completion:(ExtendedBlockHandler)handler
{
    DBNamespace *namespace = [DBNamespace getNamespaceWithAccountId:accountId];
    [_networkManager setCurrentToken:namespace.token];
    
    NSString *url = [PMRequest messages];
    [_networkManager GET:url parameters:@{@"in":folder,@"view":@"count"} success:^(NSURLSessionDataTask *task, id responseObject) {
        DLog(@"getMessagesCountInFolder -  stask - %@  / response - %@", task, responseObject);
        
        if(responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {            
            if(handler) {
                handler(responseObject[@"count"], nil, YES);
            }
        } else {
            if(handler) {
                handler(nil, nil, NO);
            }
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if(handler) {
            handler(nil, error, NO);
        }
        DLog(@"getMessagesCountInFolder - ftask - %@  / error - %@", task, error);
    }];
}
#pragma mark - Calendars

- (NSArray*)getCalendarsWithAccount:(NSString*)accountId comlpetion:(ExtendedBlockHandler)handler {
    NSMutableArray *calendars = [NSMutableArray new];
    
    DBNamespace *namespace = [DBNamespace getNamespaceWithAccountId:accountId];
    [_networkManager setCurrentToken:namespace.token];
    [_networkManager GET:@"/calendars" parameters:nil success:^ (NSURLSessionDataTask *task, id responseObjet) {
        DLog(@"getCalendarsWithAccount - %@", responseObjet);
        
        NSMutableArray *remoteCalendars = [NSMutableArray new];
        
        NSManagedObjectContext *context = [[DBManager instance] workerContext];
        for (NSDictionary *item in responseObjet) {
            
            DBCalendar *calendar = [DBCalendar createOrUpdateCalendarWithData:item onContext:context];
            
            [remoteCalendars addObject:calendar];
        }
        [[DBManager instance] saveOnContext:context];
        if(handler) {
            handler(remoteCalendars, nil, YES);
        }
    } failure:^ (NSURLSessionDataTask * task, NSError *error) {
        DLog(@"error: %@", error);
        if(handler) {
            handler(nil, error, YES);
        }
    }];
    
    NSArray *localCalendars = [DBCalendar getCalendarsWithAccountId:namespace.account_id];
    
    if(localCalendars!=nil && localCalendars.count>0)
        calendars = [NSMutableArray arrayWithArray:localCalendars];
    
    return calendars;
}

- (NSArray*)getEventsWithAccount:(NSString*)accountId
                     eventParams:(NSDictionary *)eventParams
                      comlpetion:(ExtendedBlockHandler)handler
{
    DBNamespace *namespace = [DBNamespace getNamespaceWithAccountId:accountId];
    DLog(@"Email Address: %@, Access Token: %@", namespace.email_address, namespace.token);
    [_networkManager setCurrentToken:namespace.token];
    [_networkManager GET:@"/events" parameters:eventParams success:^(NSURLSessionDataTask *task, id responseObjet) {
        DLog(@"getEventsWithAccount - %@", responseObjet);
        
        NSMutableArray *events = [NSMutableArray new];
        if([responseObjet isKindOfClass:[NSArray class]]) {
            
            
            NSManagedObjectContext *context = [[DBManager instance] workerContext];
            for(NSDictionary *eventDict in responseObjet) {
                
                if([eventDict[@"calendar_id"] isEqual:[NSNull null]]) continue;
                
                PMEventModel *eventModel = [[PMEventModel alloc] initWithDictionary:eventDict];
                
                [events addObject:eventModel];
                
                NSNumber *flag = [[PMSettingsManager instance] wasFlaggedForEventId:eventDict[@"id"]];
                
                if(flag==nil || [flag boolValue]!=YES)
                {
                    [DBEvent createOrUpdateEventWithData:eventDict onContext:context];
                }
                
            }
            [[DBManager instance] saveOnContext:context];
        }
        
        if(handler) {
            handler(events, nil, YES);
        }
    } failure:^ (NSURLSessionDataTask * task, NSError *error) {
        DLog(@"error: %@", error);
        if(handler) {
            handler(nil, error, NO);
        }
    }];
    
    NSMutableArray *localEvents = [NSMutableArray new];
    
    NSArray *localDBEvents = [DBEvent getEventsWithAccountId:namespace.account_id params:eventParams];
    for(DBEvent *dbEvent in localDBEvents)
    {
        [localEvents addObject:[[PMEventModel alloc] initWithDictionary:[dbEvent convertToDictionary]]];
    }
    
    return localEvents;
}

- (void)createCalendarEventWithAccount:(id<PMAccountProtocol>)account
                           eventParams:(NSDictionary *)eventParams
                            comlpetion:(ExtendedBlockHandler)handler {
    
    [_networkManager setCurrentToken:account.token];
    [_networkManager POST:@"/events?notify_participants=true" parameters:eventParams success:^ (NSURLSessionDataTask *task, id responseObject) {
        DLog(@"createCalendarEventWithAccount - %@", responseObject);
        if(handler) {
            handler(responseObject, nil, YES);
        }
    } failure:^ (NSURLSessionDataTask *task, NSError *error) {
        DLog(@"error: %@", error);
        if(handler) {
            handler(nil, error, NO);
        }
    }];
}

- (void)updateCalendarEventWithAccount:(id<PMAccountProtocol>)account
                               eventId:(NSString *)eventId
                           eventParams:(NSDictionary *)eventParams
                            comlpetion:(ExtendedBlockHandler)handler {
    
    NSString *urlString = [NSString stringWithFormat:@"/events/%@?notify_participants=true", eventId];
    [_networkManager setCurrentToken:account.token];
    [_networkManager PUT:urlString parameters:eventParams success:^ (NSURLSessionDataTask *task, id responseObject) {
        DLog(@"updateCalendarEventWithAccount - %@", responseObject);
        if(handler) {
            handler(responseObject, nil, YES);
        }
    } failure:^ (NSURLSessionDataTask *task, NSError *error) {
        DLog(@"updateCalendarEventWithAccount - Error : %@", error);
        if(handler) {
            handler(nil, error, NO);
        }
    }];
}

- (void)deleteCalendarEventWithAccount:(id<PMAccountProtocol>)account
                            eventId:(NSString *)eventId
                           eventParams:(NSDictionary *)eventParams
                            comlpetion:(ExtendedBlockHandler)handler {
    
    NSString *urlString = [PMRequest deleteEventWithEventId:eventId namespacesId:account.namespace_id];
    [_networkManager setCurrentToken:account.token];
    [_networkManager DELETE:urlString parameters:eventParams success:^ (NSURLSessionDataTask *task, id responseObject) {
        DLog(@"deleteCalendarEventWithAccount SUCCESS - %@", responseObject);
        
        DBEvent *event = [DBEvent getEventWithId:eventId];
        [DBEvent deleteModel:event];
        
        if(handler) handler(responseObject, nil, YES);
    } failure:^ (NSURLSessionDataTask *task, NSError *error) {
        DLog(@"deleteCalendarEventWithAccount ERROR - %@", error);
        DBEvent *event = [DBEvent getEventWithId:eventId];
        [DBEvent deleteModel:event];
        if(handler) handler(nil, error, NO);
    }];
}
- (void)sendRSVP:(NSDictionary *)params completion:(ExtendedBlockHandler)handler
{
    [_networkManager POST:[PMRequest sendRSVP] parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        DLog(@"sendRSVP-  stask - %@  / response - %@", task, responseObject);
        NSManagedObjectContext *context = [[DBManager instance] workerContext];
        [DBEvent createOrUpdateEventWithData:responseObject onContext:context];
        [[DBManager instance] saveOnContext:context];
        if(handler) {
            handler(responseObject, nil, YES);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"sendRSVP - ftask - %@  / error - %@", task, error);
        if(handler) {
            handler(nil, error, NO);
        }
    }];
}
#pragma mark - Private methods

// Sourav API

- (void)saveToken:(NSString *)token andEmail:(NSString*)email completion:(BasicBlockHandler)handler
{
    AFHTTPSessionManager *lNewSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/server/", PLANCK_SERVER_URL]]];
    
    lNewSessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [lNewSessionManager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    //email = [email stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"email_id" : email,
                                                                                  @"token" : token,
                                                                                  @"access_token" : @"planck_test"}];
    
    
#ifdef PLANCK_SYNC_ENGINE
    [params setObject:@"planck" forKey:@"source"];
#endif
    
    DLog(@"Save Token Params: %@", params);
    [lNewSessionManager POST:@"save_token" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        DLog(@"saveToken -  stask - %@  / response - %@", task, [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        if(handler) {
            handler(nil, YES);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if(handler) {
            handler(nil, NO);
        }
        DLog(@"saveToken - ftask - %@  / error - %@", task, error);
    }];
}

- (void)getTokenWithEmail:(NSString *)email completion:(ExtendedBlockHandler)handler
{
    AFHTTPSessionManager *lNewSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/server/", PLANCK_SERVER_URL]]];
    lNewSessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [lNewSessionManager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    //email = [email stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"email_id" : email,
                                                                                  @"access_token" : @"planck_test"}];
    
#ifdef PLANCK_SYNC_ENGINE
    [params setObject:@"planck" forKey:@"source"];
#endif
    
    DLog(@"getTokenWithEmail Parameters: %@", params);
    [lNewSessionManager POST:@"get_token" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        DLog(@"getTokenWithEmail -  stask - %@  / response - %@", task, [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        if(handler) {
            handler(responseObject, nil, YES);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if(handler) {
            handler(error, nil, NO);
        }
        DLog(@"getTokenWithEmail - ftask - %@  / error - %@", task, error);
    }];
}

- (void)deleteTokenWithEmail:(NSString *)email completion:(BasicBlockHandler)handler {
    AFHTTPSessionManager *lNewSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/server/", PLANCK_SERVER_URL]]];
    lNewSessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [lNewSessionManager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    email = [email stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                  @"email_id" : email,
                                                                                  @"access_token" : @"planck_test"
                                                                                  }];
    
#ifdef PLANCK_SYNC_ENGINE
    [params setObject:@"planck" forKey:@"source"];
#endif
    
    [lNewSessionManager POST:@"delete_token" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        DLog(@"deleteTokenWithEmail -  stask - %@  / response - %@", task, [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        if(handler) {
            handler(nil, YES);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if(handler) {
            handler(nil, NO);
        }
        DLog(@"deleteTokenWithEmail - ftask - %@  / error - %@", task, error);
    }];
}

- (void)setTagToThread:(NSString *)threadId email:(NSString *)email completion:(BasicBlockHandler)handler
{
    AFHTTPSessionManager *lNewSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/api/", PLANCK_SERVER_URL2]]];
    lNewSessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //[lNewSessionManager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *lParams = @{
                              @"email_id" : email,
                              @"thread_id" : threadId
                              };
    
    [lNewSessionManager POST:@"tag_thread/" parameters:lParams success:^(NSURLSessionDataTask *task, id responseObject) {
        DLog(@"setTagToThread -  stask - %@  / response - %@", task, [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        if(handler) {
            handler(nil, YES);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if(handler) {
            handler(nil, NO);
        }
        DLog(@"setTagToThread - ftask - %@  / error - %@", task, error);
    }];
}

- (void)addUserToPriorityListWithAccount:(id<PMAccountProtocol>)account completion:(ExtendedBlockHandler)handler {
    AFHTTPSessionManager *lNewSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/server/", PLANCK_SERVER_URL]]];
    lNewSessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [lNewSessionManager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
     __block NSString* lEmail = ((DBNamespace*)account).email_address;
    
    NSDictionary *lParams = @{@"email_id" : lEmail,
                              @"token" : account.token
                              };
    
    [lNewSessionManager POST:@"add_user_to_priority_list" parameters:lParams success:^(NSURLSessionDataTask *task, id responseObject) {
        DLog(@"getTheadWithAccount -  stask - %@  / response - %@", task, [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        if(handler) {
            handler(responseObject, nil, YES);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if(handler) {
            handler(error, nil, NO);
        }
        DLog(@"getTheadWithAccount - ftask - %@  / error - %@", task, error);
    }];
    
}

- (void)getTheadWithAccount:(id<PMAccountProtocol>)account completion:(BasicBlockHandler)handler
{
    AFHTTPSessionManager *lNewSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/server/", PLANCK_SERVER_URL]]];
    lNewSessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [lNewSessionManager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    __block NSString* lEmail = ((DBNamespace*)account).email_address;
    
    [self getTokenWithEmail:lEmail completion:^(id data, id error, BOOL success) {
        NSLog(@"data - %@", data);
        if(success)
        {
            NSDictionary * lResponseDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSDictionary *lParams = @{@"email_id" : lEmail,
                                      @"token" : lResponseDic[@"token"],
                                      @"important_thread_count" : @10,
                                      @"unimportant_thread_count" : @20
                                      };
            
            [lNewSessionManager POST:@"get_top_threads_with_msgs_by_tag" parameters:lParams success:^(NSURLSessionDataTask *task, id responseObject) {
                DLog(@"getTheadWithAccount -  stask - %@  / response - %@", task, [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
                if(handler) {
                    handler(nil, YES);
                }
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                if(handler) {
                    handler(nil, NO);
                }
                DLog(@"getTheadWithAccount - ftask - %@  / error - %@", task, error);
            }];
        } else {
            if(handler) {
                handler(nil, NO);
            }
        }
    }];
}

- (void)getThreadsWithAccount:(NSString*)accountId
                     parameters:(NSDictionary *)parameters
                           path:(NSString *)path
                     completion:(ExtendedBlockHandler)handler
{
    
    DBNamespace *namespace = [DBNamespace getNamespaceWithAccountId:accountId];
    
    NSString *emailAddress = namespace.email_address;
    
    NSString *token = namespace.token;
    [_networkManager setCurrentToken:token];
    
    [_networkManager GET:path parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        DLog(@"getInboxMailWithAccount-  stask - %@  / response - %@", task, responseObject);
        if(responseObject == nil || ![responseObject isKindOfClass:[NSArray class]])
        {
            if(handler) {
                handler(nil, nil, NO);
            }
            NSString *errorString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            
            return;
        }
        
        NSArray *lResponse = responseObject;
        
        if(lResponse.count == 0)
        {
            if(handler) {
                handler(nil,nil,YES);
            }
            return;
        }
        
        NSManagedObjectContext *context = [[DBManager instance] workerContext];
        
        NSMutableArray *lResultItems = [NSMutableArray new];
        
        for (NSDictionary *item in lResponse) {
            
            NSString *threadId = item[@"id"];
            
            PMThread *thread = [PMThread initWithDicationary:item ownerEmail:emailAddress token:token];
            
            // Compare version and if is not equal update the local database and tag thread
            NSNumber *localVersion = [[PMSettingsManager instance] getVersionForThreadId:threadId];
            NSNumber *version = item[@"version"];
            
            if(localVersion==nil || [localVersion compare:version]!=NSOrderedSame)
            {
                
                [DBThread createOrUpdateFromPMThread:thread onContext:context];
                
                
                //dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(){
                @try
                {
                    [self getMessagesWithThreadId:threadId forAccount:accountId completion:nil];
                    [self setTagToThread:threadId email:self.emailAddress completion:nil];
                    
                    [[PMSettingsManager instance] setVersionForThreadId:threadId timestamp:version];
                }
                @catch (NSException *exception) {
                    DLog(@"Try Catch Error: ErrorName:%@ - ErrorReason:%@", [exception name], [exception reason]);
                }
                @finally {
                    
                }
                //});
                
            }
            
            [lResultItems addObject:thread];
        }
        
        [[DBManager instance] saveOnContext:context];
        if(handler) {
            handler(lResultItems, nil, YES);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"getInboxMailWithAccount - ftask - %@  / error - %@", task, error);
        if(handler) {
            handler(nil, error, NO);
        }
    }];
    
}

- (void)getThreadWithId:(NSString *)threadId forAccount:(NSString *)accountId completion:(ExtendedBlockHandler)handler
{
    DBNamespace *namespace = [DBNamespace getNamespaceWithAccountId:accountId];
    
    NSString *emailAddress = namespace.email_address;
    
    NSString *token = namespace.token;
    [_networkManager setCurrentToken:token];
    
    [_networkManager GET:[NSString stringWithFormat:@"/threads/%@",threadId] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        DLog(@"getThreadWithId-  stask - %@  / response - %@", task, responseObject);
        
        if(responseObject == nil || ![responseObject isKindOfClass:[NSDictionary class]])
        {
            if(handler) {
                handler(nil, nil, NO);
            }
            
            return;
        }
        
        NSDictionary *item = responseObject;
        
        
        NSString *threadId = item[@"id"];
        
        PMThread *thread = [PMThread initWithDicationary:item ownerEmail:emailAddress token:token];
        
        // Compare version and if is not equal update the local database and tag thread
        NSNumber *localVersion = [[PMSettingsManager instance] getVersionForThreadId:threadId];
        NSNumber *version = item[@"version"];
        
        if(localVersion==nil || [localVersion compare:version]!=NSOrderedSame)
        {
            [DBThread createOrUpdateFromPMThread:thread onContext:[DBManager instance].mainContext];
        }
        if(handler) {
            handler(item, nil, YES);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"getThreadWithId - ftask - %@  / error - %@", task, error);
        if(handler) {
            handler(nil, error, NO);
        }
    }];

}

- (NSArray*)getContactsWithAccount:(id<PMAccountProtocol>)account
                 params:(NSDictionary *)params
                  comlpetion:(ExtendedBlockHandler)handler {
    /*[_networkManager setCurrentToken:account.token];
    [_networkManager GET:@"/contacts" parameters:params success:^(NSURLSessionDataTask *task, id responseObjet) {
        DLog(@"getContactsWithAccount - %@", responseObjet);
        
        if(handler) {
            handler(responseObjet, nil, YES);
        }
        
        
        for(NSDictionary *item in responseObjet)
        {
            [DBContact createOrUpdateContactWithData:item];
        }
    } failure:^ (NSURLSessionDataTask * task, NSError *error) {
        DLog(@"error: %@", error);
        if(handler) {
            handler(nil, error, NO);
        }
    }];*/
    
    
    NSMutableArray *contacts = [NSMutableArray new];
    DBManager *dbManager = [DBManager instance];
    
    NSArray *dbContacts = [dbManager getContactsWithKeyword:nil namespaceId:self.namespaceId.namespace_id];
    for(DBContact *dbContact in dbContacts)
    {
        [contacts addObject:[dbContact convertToDictionary]];
    }
    
    NSLog(@"DB Contacts : %@", contacts);
    return contacts;
}


- (NSURLSessionDownloadTask*)downloadFileWithAccount:(id<PMAccountProtocol>)account file:(NSDictionary *)file
                     completion:(DownloadBlockHandler)handler {
    [_networkManager setCurrentToken:account.token];    
    
    NSURL *url = [NSURL URLWithString:[PMRequest downloadFileWithFileId:file[@"id"] namespacesId:account.namespace_id]];
    
    
    NSMutableURLRequest *request = [_networkManager.requestSerializer requestWithMethod:@"GET" URLString:[url absoluteString] parameters:nil error:nil];
    
    
    NSURLSessionDownloadTask *downloadTask = [_networkManager downloadTaskWithRequest:request  progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response)
    {
        NSString *filename = file[@"filename"]&&![file[@"filename"] isEqual:[NSNull null]]?file[@"filename"]:@"Untitled";
        
        NSString *filepath = [NSString stringWithFormat:@"%@/%@", [PMFileManager MobileDirectory], filename];
        NSInteger cnt = 0;
        while([[NSFileManager defaultManager] fileExistsAtPath:filepath])
        {
            cnt ++;
            
            NSString *tempname = [filename copy];
            NSString *ext = [tempname pathExtension];
            
            tempname = [NSString stringWithFormat:@"%@(%i)", [tempname stringByDeletingPathExtension], (int)cnt];
            
            if(ext && ext.length)
                tempname = [NSString stringWithFormat:@"%@.%@", tempname, ext];
            
            filepath = [NSString stringWithFormat:@"%@/%@", [PMFileManager MobileDirectory], tempname];
        }
        
        return [NSURL fileURLWithPath:filepath];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error){
        NSLog(@"File Download Error: %@", error);
        NSLog(@"File downloaded to: %@", filePath);
        NSLog(@"Response Data: %@", response);
        
        if(handler!=nil)
            handler(response, filePath, error);
    }];
    
    
    return downloadTask;
}

- (NSURLSessionUploadTask*)uploadFileWithAccount:(id<PMAccountProtocol>)account filepath:(NSString*)filepath
                                          completion:(UploadBlockHandler)handler {
    [_networkManager setCurrentToken:account.token];
    
    NSURL *url = [NSURL URLWithString:[PMRequest uploadFileWithAccount:account.namespace_id]];
    
    NSString *filename = [filepath lastPathComponent];
    
    NSMutableURLRequest *request = [_networkManager.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:[url absoluteString] parameters:nil constructingBodyWithBlock:^(id formData) {
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:filepath] name:@"file" fileName:filename mimeType:[PMFileManager MimeTypeForFile:filepath] error:nil];
    } error:nil];
    
    NSProgress *progress = nil;
    
    NSURLSessionUploadTask *uploadTask = [_networkManager uploadTaskWithStreamedRequest:request progress:&progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Nylas file upload error: %@", error);
        } else {
            //NSLog(@"%@ %@", response, responseObject);
        }
        
        if(handler)
            handler(response, responseObject, error);
    }];
    
    
    return uploadTask;
}

-(void)getSummariesFromText:(NSString *)text lines:(NSInteger)lines completion:(ExtendedBlockHandler)handler
{
    if(text==nil)
    {
        if(handler)
            handler(nil, nil, NO);
        return;
    }
    NSString *url = [NSString stringWithFormat:@"%@/api/basicsummarize/", PLANCK_SERVER_URL1];
    //NSDictionary *params = @{@"TEXT":text, @"LENGTH":[NSNumber numberWithInteger:lines]};
    NSDictionary *params = @{@"TEXT":text};
    
    DLog(@"Summarize URL: %@\n Params: %@", url, params);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager.requestSerializer setTimeoutInterval:5.0];
    [manager POST:url parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"Text Summarize Success: %@", responseObject);
        
        if(handler)
            handler(responseObject, nil, YES);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Text Summarize Error: %@", error);
        if(handler)
            handler(nil, error, NO);
    }];
}

-(void)getKeywordPhrasesFromText:(NSString *)text subject:(NSString *)subject completion:(ExtendedBlockHandler)handler
{
    NSString *url = [NSString stringWithFormat:@"%@/api/keyphrases/", PLANCK_SERVER_URL1];
    NSDictionary *params = @{@"TEXT":text, @"SUBJECT":subject};
    
    DLog(@"Summarize URL: %@\n Params: %@", url, params);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:url parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"Keyword Phrases Success: %@", responseObject);
        
        if(handler)
            handler(responseObject, nil, YES);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Keyword Phrases Error: %@", error);
        if(handler)
            handler(nil, error, NO);
    }];
}

-(void)getBusyTimeSlotsWithParams:(NSDictionary *)params completion:(ExtendedBlockHandler)handler
{
    
    NSString *urlString = [NSString stringWithFormat:@"%@/va/get_free_slots/", PLANCK_SERVER_URL];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    //[manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    DLog(@"ButyTimeSlotsWithParams: %@", params);
    [manager POST:urlString parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"Busy Time Slots: %@", responseObject);
        
        if(handler)
        {
            handler(responseObject, nil, YES);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Busy Time Slots Error: %@", error);
        if(handler)
            handler(nil, error, NO);
    }];
}

#pragma mark Email Tracking APIs
-(void)createEmailTrack:(ExtendedBlockHandler)handler
{
    NSString *urlString = [NSString stringWithFormat:@"%@/create", TRACK_SERVER_ROOT];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"Created Email Track Data: %@", responseObject);
        
        
        if(handler)
        {
            if([responseObject isKindOfClass:[NSDictionary class]] && responseObject[@"success"] && [responseObject[@"success"] boolValue])
            {
                handler(responseObject, nil, YES);
            }
            else
            {
                handler(nil, nil, NO);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Created Email Track Error: %@", error);
        if(handler)
            handler(nil, error, NO);
    }];
}
-(void)updateEmailTrack:(NSNumber*)trackId threadId:(NSString*)threadId messageId:(NSString*)messageId subject:(NSString *)subject ownerEmail:(NSString *)ownerEmail targetEmails:(NSString *)targetEmails completion:(ExtendedBlockHandler)handler
{
    NSString *urlString = [NSString stringWithFormat:@"%@/update", TRACK_SERVER_ROOT];
    NSDictionary *params = @{@"id":trackId, @"thread_id":threadId, @"message_id":messageId, @"subject":subject, @"owner_email":ownerEmail, @"target_emails":targetEmails};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:urlString parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"Updated Email Track Data: %@", responseObject);
        
        if(handler)
        {
            handler(responseObject, nil, YES);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Update Email Track Error: %@", error);
        if(handler)
            handler(nil, error, NO);
    }];
}

- (NSArray*)getEmailTrackList:(NSString *)email trackStatus:(NSString *)status time:(NSString*)time completion:(ExtendedBlockHandler)handler{
    
    NSString *urlString = [NSString stringWithFormat:@"%@/list", TRACK_SERVER_ROOT];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:email forKey:@"owner_email"];
    if(status) [params setObject:status forKey:@"status"];
    if(time) [params setObject:time forKey:@"time"];
    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:urlString parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"getEmailTrackList Data: %@", responseObject);
        
        BOOL success = [responseObject[@"success"] boolValue];
        if(success)
        {
            NSManagedObjectContext *context = [[DBManager instance] workerContext];
            NSArray *data = responseObject[@"data"];
            
            NSMutableArray *items = [NSMutableArray new];
            for(NSDictionary *d in data)
            {
                NSMutableDictionary *item = [NSMutableDictionary dictionaryWithDictionary:d];
                
                DBThread *thread = [[DBManager instance] getThreadWithMessageId:item[@"message_id"]];
                
                if(thread == nil)
                {
                    [item setObject:@(0) forKey:@"replies"];
                }
                else
                {
                    NSArray *messageIds = [thread.messageIds componentsSeparatedByString:@","];
                    [item setObject:[NSNumber numberWithInteger:messageIds.count] forKey:@"replies"];
                }
                
                [DBTrack createOrUpdateTrackWithData:item onContext:context];
                
                [items addObject:item];
            }
            
            
            [[DBManager instance] saveOnContext:context];
            //NSArray *dbTracks = [[DBManager instance] getTracks:email trackStatus:status time:time];
            
            if(handler)
            {
                handler(items, nil, YES);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"getEmailTrackList Error: %@", error);
        if(handler)
            handler(nil, error, NO);
    }];
    
    
    NSMutableArray *tracks = [NSMutableArray new];
    DBManager *dbManager = [DBManager instance];
    
    NSArray *dbTracks = [dbManager getTracks:email trackStatus:status time:time];
    for(DBTrack *dbTrack in dbTracks)
    {
        [tracks addObject:[dbTrack toDictionary]];
    }
    
    return tracks;
}

- (NSArray*)getEmailTrackDetailList:(NSNumber *)trackId completion:(ExtendedBlockHandler)handler{
    
    NSString *urlString = [NSString stringWithFormat:@"%@/details?track_id=%@", TRACK_SERVER_ROOT, trackId];
    
    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"getEmailTrackDetailList Data: %@", responseObject);
        
        BOOL success = [responseObject[@"success"] boolValue];
        if(success)
        {
            NSManagedObjectContext *context = [[DBManager instance] workerContext];
            NSArray *data = responseObject[@"data"];
            for(NSDictionary *item in data)
            {
                [DBTrackDetail createOrUpdateTrackDetailWithData:item onContext:context];
            }
            [[DBManager instance] saveOnContext:context];
            //NSArray *dbTrackDetails = [[DBManager instance] getTrackDetails:trackId];
            
            if(handler)
            {
                handler(data, nil, YES);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"getEmailTrackList Error: %@", error);
        if(handler)
            handler(nil, error, NO);
    }];
    
    
    NSMutableArray *details = [NSMutableArray new];
    DBManager *dbManager = [DBManager instance];
    
    NSArray *dbTrackDetails = [dbManager getTrackDetails:trackId];
    for(DBTrackDetail *dbDetail in dbTrackDetails)
    {
        [details addObject:[dbDetail toDictionary]];
    }
    
    return details;
}


#pragma mark Salesforce APIs

-(void)getSalesforceUserInfo:(ExtendedBlockHandler)handler
{
    NSDictionary *credentials = [[PMSettingsManager instance] getSalesforceCredential];
    
    NSLog(@"Salesforce Credential - %@", credentials);
    if(!credentials)
    {
        if(handler)
            handler(nil,nil,NO);
        return;
    }
    
    NSString *urlString = credentials[@"id"];
    
    [_networkManager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", credentials[@"access_token"]] forHTTPHeaderField:@"Authorization"];
    
    [_networkManager GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        DLog(@"getSalesforceUserInfo results - %@  / response - %@", task, responseObject);
        
        if(handler) {
            handler(responseObject, nil, YES);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"getSalesforceUserInfo - ftask - %@  / error - %@", task, error);
        if(handler) {
            handler(nil, error, NO);
        }
    }];
}
-(void)getSalesforceContacts:(ExtendedBlockHandler)handler
{
    NSDictionary *credentials = [[PMSettingsManager instance] getSalesforceCredential];
    
    NSLog(@"Salesforce Credential - %@", credentials);
    if(!credentials)
    {
        if(handler)
            handler(nil,nil,NO);
        return;
    }
    
    NSString *queryString = @"SELECT+Id,Name,Email,Phone,MobilePhone,Title,Department,MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry+FROM+Contact+LIMIT+50";
    NSString *urlString = [NSString stringWithFormat:@"%@/services/data/v35.0/query?q=%@", credentials[@"instance_url"], queryString];
    
    [_networkManager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", credentials[@"access_token"]] forHTTPHeaderField:@"Authorization"];
    
    [_networkManager GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        DLog(@"getSalesforceContacts results - %@  / response - %@", task, responseObject);
        
        NSArray *records = responseObject[@"records"];
        
        NSManagedObjectContext *context = [[DBManager instance] workerContext];
        NSMutableArray *emails = [NSMutableArray new];
        for(NSDictionary *record in records)
        {
            NSMutableDictionary *item = [NSMutableDictionary new];
            
            [item setObject:[NSString stringWithFormat:@"salesforce-%@", record[@"Id"]] forKey:@"id"];
            [item setObject:notEmptyStrValue(record[@"Name"]) forKey:@"name"];
            [item setObject:notEmptyStrValue(record[@"Title"]) forKey:@"job"];
            [item setObject:notEmptyStrValue(record[@"Department"]) forKey:@"company"];
            
            NSString *email = notEmptyStrValue(record[@"Email"]);
            [item setObject:email forKey:@"email"];
            
            if(email && email.length)
            {
                [item setObject:@[email] forKey:@"emails"];
                
                [emails addObject:email];
            }
            
            NSString *phone = notNullValue(record[@"Phone"]);
            NSString *mobilePhone = notNullValue(record[@"MobilePhone"]);
            
            NSMutableArray *phoneNumbers = [NSMutableArray new];
            if(phone && phone.length)
            {
                [phoneNumbers addObject:@{kPhoneTitle:@"home", kPhoneNumber:phone}];
                [item setObject:record[@"Phone"] forKey:@"phone_number"];
            }
            if(mobilePhone && mobilePhone.length)
                [phoneNumbers addObject:@{kPhoneTitle:@"mobile", kPhoneNumber:mobilePhone}];
            
            [item setObject:phoneNumbers forKey:@"phone_numbers"];
            
            NSString *address = [NSString stringWithFormat:@"%@ %@, %@ %@, %@",
                                 notEmptyStrValue(record[@"MailingStreet"]),
                                 notEmptyStrValue(record[@"MailingCity"]),
                                 notEmptyStrValue(record[@"MailingState"]),
                                 notEmptyStrValue(record[@"MailingPostalCode"]),
                                 notEmptyStrValue(record[@"MailingCountry"])];
            [item setObject:address forKey:@"address"];
            
            [DBSavedContact createOrUpdateContactWithData:item onContext:context];
        }
        [[DBManager instance] saveOnContext:context];
        
        [[PMSettingsManager instance] setSalesforceEmails:emails];
        NSArray *results = [[DBManager instance] getSavedContactsWithType:CONTACT_TYPE_SALESFORCE];
        handler(results, nil, YES);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"getSalesforceContacts - ftask - %@  / error - %@", task, error);
        if(handler) {
            handler(nil, error, NO);
        }
        
        [self refreshSalesforceAccessToken:nil];
    }];
}

- (void)saveSalesforceContact:(NSDictionary *)data completion:(ExtendedBlockHandler)handler
{
    NSDictionary *credentials = [[PMSettingsManager instance] getSalesforceCredential];
    
    if(!credentials)
    {
        if(handler)
            handler(nil,nil,NO);
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@/services/data/v35.0/sobjects/Contact", credentials[@"instance_url"]];
    
    [_networkManager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", credentials[@"access_token"]] forHTTPHeaderField:@"Authorization"];
    [_networkManager POST:urlString parameters:data success:^ (NSURLSessionDataTask *task, id responseObject) {
        DLog(@"saveSalesforceContact - %@", responseObject);
        if(handler) {
            handler(responseObject, nil, YES);
        }
    } failure:^ (NSURLSessionDataTask *task, NSError *error) {
        DLog(@"saveSalesforceContact Error: %@", error);
        if(handler) {
            handler(nil, error, NO);
        }
        
    }];
}
- (void)saveSalesforceLead:(NSDictionary *)data completion:(ExtendedBlockHandler)handler
{
    NSDictionary *credentials = [[PMSettingsManager instance] getSalesforceCredential];
    
    if(!credentials)
    {
        if(handler)
            handler(nil,nil,NO);
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@/services/data/v35.0/sobjects/Lead", credentials[@"instance_url"]];
    
    
    [_networkManager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", credentials[@"access_token"]] forHTTPHeaderField:@"Authorization"];
    
    NSString *leadId = data[@"Id"];
    
    if(!leadId)
    {
        [_networkManager POST:urlString parameters:data success:^ (NSURLSessionDataTask *task, id responseObject) {
            DLog(@"saveSalesforceLead - %@", responseObject);
            if(handler) {
                handler(responseObject, nil, YES);
            }
        } failure:^ (NSURLSessionDataTask *task, NSError *error) {
            DLog(@"saveSalesforceLead Error: %@", error);
            if(handler) {
                handler(nil, error, NO);
            }
        }];
    }
    else
    {
        urlString = [NSString stringWithFormat:@"%@/%@",urlString, leadId];
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:data];
        [params removeObjectForKey:@"Id"];
        [params removeObjectForKey:@"Name"];
        
        NSLog(@"%@", params);
        [_networkManager PATCH:urlString parameters:params success:^ (NSURLSessionDataTask *task, id responseObject) {
            DLog(@"saveSalesforceLead - %@", responseObject);
            if(handler) {
                handler(responseObject, nil, YES);
            }
        } failure:^ (NSURLSessionDataTask *task, NSError *error) {
            DLog(@"saveSalesforceLead Error: %@", error);
            if(handler) {
                handler(nil, error, NO);
            }
        }];
    }
}
- (void)saveSalesforceOpportunity:(NSDictionary *)data completion:(ExtendedBlockHandler)handler
{
    NSDictionary *credentials = [[PMSettingsManager instance] getSalesforceCredential];
    
    if(!credentials)
    {
        if(handler)
            handler(nil,nil,NO);
        return;
    }
    
    NSString *opportunityId = data[@"Id"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/services/data/v35.0/sobjects/Opportunity", credentials[@"instance_url"]];
    
    [_networkManager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", credentials[@"access_token"]] forHTTPHeaderField:@"Authorization"];
    
    
    if(!opportunityId)
    {
        NSLog(@"%@", data);
        
        [_networkManager POST:urlString parameters:data success:^ (NSURLSessionDataTask *task, id responseObject) {
            DLog(@"saveSalesforceOpportunity - %@", responseObject);
            if(handler) {
                handler(responseObject, nil, YES);
            }
        } failure:^ (NSURLSessionDataTask *task, NSError *error) {
            DLog(@"saveSalesforceOpportunity Error: %@", error);
            if(handler) {
                handler(nil, error, NO);
            }
        }];
    }
    else
    {
        urlString = [NSString stringWithFormat:@"%@/%@",urlString, opportunityId];        
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:data];
        [params removeObjectForKey:@"Id"];
        [params removeObjectForKey:@"IsClosed"];
        [params removeObjectForKey:@"IsWon"];
        
        NSLog(@"%@", params);
        //NSDictionary *params = @{@"AccountId":@"00158000002b290AAA", @"Budget_Confirmed__c":@(NO), @"CloseDate":@"2016-01-27", @"Discovery_Completed__c":@(1), @"IsClosed":@(0)};
        [_networkManager PATCH:urlString parameters:params success:^ (NSURLSessionDataTask *task, id responseObject) {
            DLog(@"saveSalesforceOpportunity - %@", responseObject);
            if(handler) {
                handler(responseObject, nil, YES);
            }
        } failure:^ (NSURLSessionDataTask *task, NSError *error) {
            DLog(@"saveSalesforceOpportunity Error: %@", error);
            if(handler) {
                handler(nil, error, NO);
            }
        }];
    }
}
-(void)getSalesforceUsers:(ExtendedBlockHandler)handler
{
    NSDictionary *credentials = [[PMSettingsManager instance] getSalesforceCredential];
    
    NSLog(@"Salesforce Credential - %@", credentials);
    if(!credentials)
    {
        if(handler)
            handler(nil,nil,NO);
        return;
    }
    
    NSString *queryString = @"SELECT+Id,Name+FROM+User+LIMIT+50";
    NSString *urlString = [NSString stringWithFormat:@"%@/services/data/v35.0/query?q=%@", credentials[@"instance_url"], queryString];
    
    [_networkManager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", credentials[@"access_token"]] forHTTPHeaderField:@"Authorization"];
    
    [_networkManager GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        DLog(@"getSalesforceUsers results - %@  / response - %@", task, responseObject);
        
        NSArray *records = responseObject[@"records"];
        
        if(handler) {
            if(records && records.count)
                handler(records, nil, YES);
            else
                handler(nil, nil, NO);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"getSalesforceUsers - ftask - %@  / error - %@", task, error);
        if(handler) {
            handler(nil, error, NO);
        }
    }];
}

-(void)getSalesforceAccounts:(ExtendedBlockHandler)handler
{
    NSDictionary *credentials = [[PMSettingsManager instance] getSalesforceCredential];
    
    NSLog(@"Salesforce Credential - %@", credentials);
    if(!credentials)
    {
        if(handler)
            handler(nil,nil,NO);
        return;
    }
    
    NSString *queryString = @"SELECT+Id,Name+FROM+Account+LIMIT+50";
    NSString *urlString = [NSString stringWithFormat:@"%@/services/data/v35.0/query?q=%@", credentials[@"instance_url"], queryString];
    
    [_networkManager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", credentials[@"access_token"]] forHTTPHeaderField:@"Authorization"];
    
    [_networkManager GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        DLog(@"getSalesforceAccounts results - %@  / response - %@", task, responseObject);
        
        NSArray *records = responseObject[@"records"];
        
        if(handler) {
            if(records && records.count)
                handler(records, nil, YES);
            else
                handler(nil, nil, NO);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"getSalesforceAccounts - ftask - %@  / error - %@", task, error);
        if(handler) {
            handler(nil, error, NO);
        }
    }];
}

-(void)getSalesforceLeads:(NSInteger)offset completion:(ExtendedBlockHandler)handler
{
    NSDictionary *credentials = [[PMSettingsManager instance] getSalesforceCredential];
    
    NSLog(@"Salesforce Credential - %@", credentials);
    if(!credentials)
    {
        if(handler)
            handler(nil,nil,NO);
        return;
    }
    
    NSString *queryString = [NSString stringWithFormat:@"SELECT+Id,Salutation,Name,FirstName,LastName,Status,Title,Email,Phone,MobilePhone,Rating,OwnerId,Website,Company,Industry,NumberOfEmployees,LeadSource,Street,City,State,PostalCode,Country+FROM+Lead+ORDER+BY+LastModifiedDate+DESC+LIMIT+50+OFFSET+%d", (int)offset];
    NSString *urlString = [NSString stringWithFormat:@"%@/services/data/v35.0/query?q=%@", credentials[@"instance_url"], queryString];
    
    [_networkManager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", credentials[@"access_token"]] forHTTPHeaderField:@"Authorization"];
    
    [_networkManager GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        DLog(@"getSalesforceLeads results - %@  / response - %@", task, responseObject);
        
        NSArray *records = responseObject[@"records"];
        
        NSMutableArray *newRecords = [NSMutableArray new];
        for(NSDictionary *item in records)
        {
            NSMutableDictionary *newItem = [NSMutableDictionary dictionaryWithDictionary:item];
            
            [newItem removeObjectForKey:@"attributes"];
            
            for(NSString *key in [newItem allKeys])
            {
                if([newItem[key] isEqual:[NSNull null]])
                    [newItem removeObjectForKey:key];
            }
            
            [newRecords addObject:newItem];
        }
        if(handler) {
            handler(newRecords, nil, YES);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"getSalesforceLeads - ftask - %@  / error - %@", task, error);
        if(handler) {
            handler(nil, error, NO);
        }
        [self refreshSalesforceAccessToken:nil];
    }];
}
-(void)getSalesforceOpportunities:(NSInteger)offset completion:(ExtendedBlockHandler)handler
{
    NSDictionary *credentials = [[PMSettingsManager instance] getSalesforceCredential];
    
    NSLog(@"Salesforce Credential - %@", credentials);
    if(!credentials)
    {
        if(handler)
            handler(nil,nil,NO);
        return;
    }
    
    NSString *queryString = [NSString stringWithFormat:@"SELECT+Id,Name,Type,NextStep,Description,Amount,Probability,CloseDate,LeadSource,StageName,IsClosed,IsWon,AccountId,Opportunity.Account.Name,OwnerId,Opportunity.Owner.Name,CampaignId,Opportunity.Campaign.Name,LastActivityDate+FROM+Opportunity+ORDER+BY+LastModifiedDate+DESC+LIMIT+50+OFFSET+%d", (int)offset];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/services/data/v35.0/query?q=%@", credentials[@"instance_url"], queryString];
    
    [_networkManager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", credentials[@"access_token"]] forHTTPHeaderField:@"Authorization"];
    
    [_networkManager GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        DLog(@"getSalesforceOpportunities results - %@  / response - %@", task, responseObject);
        
        NSArray *records = responseObject[@"records"];
        
        NSMutableArray *newRecords = [NSMutableArray new];
        for(NSDictionary *item in records)
        {
            NSMutableDictionary *newItem = [NSMutableDictionary dictionaryWithDictionary:item];
            
            [newItem removeObjectForKey:@"attributes"];
            
            if(![newItem[@"Account"] isEqual:[NSNull null]])
                [newItem setObject:newItem[@"Account"][@"Name"] forKey:@"AccountName"];
            
            if(![newItem[@"Campaign"] isEqual:[NSNull null]])
                [newItem setObject:newItem[@"Campaign"][@"Name"] forKey:@"CampaignName"];
            
            if(![newItem[@"Owner"] isEqual:[NSNull null]])
                [newItem setObject:newItem[@"Owner"][@"Name"] forKey:@"OwnerName"];
            
            [newItem removeObjectForKey:@"Account"];
            [newItem removeObjectForKey:@"Campaign"];
            [newItem removeObjectForKey:@"Owner"];
            
            for(NSString *key in [newItem allKeys])
            {
                if([newItem[key] isEqual:[NSNull null]])
                    [newItem removeObjectForKey:key];
            }
            
            [newRecords addObject:newItem];
        }
        if(handler) {
            handler(newRecords, nil, YES);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"getSalesforceOpportunities - ftask - %@  / error - %@", task, error);
        if(handler) {
            handler(nil, error, NO);
        }
        [self refreshSalesforceAccessToken:nil];
    }];
}

-(void)getSalesforceCampaigns:(ExtendedBlockHandler)handler
{
    NSDictionary *credentials = [[PMSettingsManager instance] getSalesforceCredential];
    
    NSLog(@"Salesforce Credential - %@", credentials);
    if(!credentials)
    {
        if(handler)
            handler(nil,nil,NO);
        return;
    }
    
    NSString *queryString = @"SELECT+Id,Name+FROM+Campaign+ORDER+BY+LastModifiedDate+DESC+LIMIT+50";
    NSString *urlString = [NSString stringWithFormat:@"%@/services/data/v35.0/query?q=%@", credentials[@"instance_url"], queryString];
    
    [_networkManager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", credentials[@"access_token"]] forHTTPHeaderField:@"Authorization"];
    
    [_networkManager GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        DLog(@"getSalesforceCampaigns results - %@  / response - %@", task, responseObject);
        
        NSArray *records = responseObject[@"records"];
        
        if(handler) {
            handler(records, nil, YES);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"getSalesforceCampaigns - ftask - %@  / error - %@", task, error);
        if(handler) {
            handler(nil, error, NO);
        }
        [self refreshSalesforceAccessToken:nil];
    }];
}

-(void)getSalesforceLeadStatusList:(ExtendedBlockHandler)handler
{
    NSDictionary *credentials = [[PMSettingsManager instance] getSalesforceCredential];
    
    NSLog(@"Salesforce Credential - %@", credentials);
    if(!credentials)
    {
        if(handler)
            handler(nil,nil,NO);
        return;
    }
    
    NSString *queryString = @"SELECT+Id,MasterLabel+FROM+LeadStatus+ORDER+BY+SortOrder";
    NSString *urlString = [NSString stringWithFormat:@"%@/services/data/v35.0/query?q=%@", credentials[@"instance_url"], queryString];
    
    [_networkManager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", credentials[@"access_token"]] forHTTPHeaderField:@"Authorization"];
    
    [_networkManager GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        DLog(@"getSalesforceLeadStatusList results - %@  / response - %@", task, responseObject);
        
        NSArray *records = responseObject[@"records"];
        
        if(handler) {
            handler(records, nil, YES);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"getSalesforceLeadStatusList - ftask - %@  / error - %@", task, error);
        if(handler) {
            handler(nil, error, NO);
        }
        [self refreshSalesforceAccessToken:nil];
    }];
}

-(void)getSalesforceOpportunityStageList:(ExtendedBlockHandler)handler
{
    NSDictionary *credentials = [[PMSettingsManager instance] getSalesforceCredential];
    
    NSLog(@"Salesforce Credential - %@", credentials);
    if(!credentials)
    {
        if(handler)
            handler(nil,nil,NO);
        return;
    }
    
    NSString *queryString = @"SELECT+Id,MasterLabel,DefaultProbability+FROM+OpportunityStage+ORDER+BY+SortOrder";
    NSString *urlString = [NSString stringWithFormat:@"%@/services/data/v35.0/query?q=%@", credentials[@"instance_url"], queryString];
    
    [_networkManager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", credentials[@"access_token"]] forHTTPHeaderField:@"Authorization"];
    
    [_networkManager GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        DLog(@"getSalesforceOpportunityStageList results - %@  / response - %@", task, responseObject);
        
        NSArray *records = responseObject[@"records"];
        
        if(handler) {
            handler(records, nil, YES);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"getSalesforceOpportunityStageList - ftask - %@  / error - %@", task, error);
        if(handler) {
            handler(nil, error, NO);
        }
        [self refreshSalesforceAccessToken:nil];
    }];
}

-(void)getSalesforcePicklistValuesForLead:(ExtendedBlockHandler)handler
{
    NSDictionary *credentials = [[PMSettingsManager instance] getSalesforceCredential];
    
    NSLog(@"Salesforce Credential - %@", credentials);
    if(!credentials)
    {
        if(handler)
            handler(nil,nil,NO);
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@/services/data/v35.0/sobjects/lead/describe", credentials[@"instance_url"]];
    
    [_networkManager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", credentials[@"access_token"]] forHTTPHeaderField:@"Authorization"];
    
    [_networkManager GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        DLog(@"getSalesforcePicklistValuesForLead results - %@  / response - %@", task, responseObject);
        
        NSMutableDictionary *result = [NSMutableDictionary new];
        NSArray *fields = responseObject[@"fields"];
        for(NSDictionary *item in fields)
        {
            if([item[@"name"] isEqualToString:@"Salutation"])
            {
                if(item[@"picklistValues"])
                {
                    NSMutableArray *values = [NSMutableArray new];
                    for(NSDictionary *value in item[@"picklistValues"])
                    {
                        [values addObject:value[@"value"]];
                    }
                    
                    [result setObject:values forKey:item[@"name"]];
                }
            }
            else if([item[@"name"] isEqualToString:@"LeadSource"])
            {
                if(item[@"picklistValues"])
                {
                    NSMutableArray *values = [NSMutableArray new];
                    for(NSDictionary *value in item[@"picklistValues"])
                    {
                        [values addObject:value[@"value"]];
                    }
                    
                    [result setObject:values forKey:item[@"name"]];
                }
            }
            else if([item[@"name"] isEqualToString:@"Status"])
            {
                if(item[@"picklistValues"])
                {
                    NSMutableArray *values = [NSMutableArray new];
                    for(NSDictionary *value in item[@"picklistValues"])
                    {
                        [values addObject:value[@"value"]];
                    }
                    
                    [result setObject:values forKey:item[@"name"]];
                }
            }
            else if([item[@"name"] isEqualToString:@"Industry"])
            {
                if(item[@"picklistValues"])
                {
                    NSMutableArray *values = [NSMutableArray new];
                    for(NSDictionary *value in item[@"picklistValues"])
                    {
                        [values addObject:value[@"value"]];
                    }
                    
                    [result setObject:values forKey:item[@"name"]];
                }
            }
            else if([item[@"name"] isEqualToString:@"Rating"])
            {
                if(item[@"picklistValues"])
                {
                    NSMutableArray *values = [NSMutableArray new];
                    for(NSDictionary *value in item[@"picklistValues"])
                    {
                        [values addObject:value[@"value"]];
                    }
                    
                    [result setObject:values forKey:item[@"name"]];
                }
            }
        }
        
        if(handler) {
            handler(result, nil, YES);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"getSalesforcePicklistValuesForLead - ftask - %@  / error - %@", task, error);
        if(handler) {
            handler(nil, error, NO);
        }
        [self refreshSalesforceAccessToken:nil];
    }];
}

-(void)getSalesforcePicklistValuesForOpportunity:(ExtendedBlockHandler)handler
{
    NSDictionary *credentials = [[PMSettingsManager instance] getSalesforceCredential];
    
    NSLog(@"Salesforce Credential - %@", credentials);
    if(!credentials)
    {
        if(handler)
            handler(nil,nil,NO);
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@/services/data/v35.0/sobjects/opportunity/describe", credentials[@"instance_url"]];
    
    [_networkManager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", credentials[@"access_token"]] forHTTPHeaderField:@"Authorization"];
    
    [_networkManager GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        DLog(@"getSalesforcePicklistValuesForOpportunity results - %@  / response - %@", task, responseObject);
        
        NSMutableDictionary *result = [NSMutableDictionary new];
        NSArray *fields = responseObject[@"fields"];
        for(NSDictionary *item in fields)
        {
            if([item[@"name"] isEqualToString:@"Type"])
            {
                if(item[@"picklistValues"])
                {
                    NSMutableArray *values = [NSMutableArray new];
                    for(NSDictionary *value in item[@"picklistValues"])
                    {
                        [values addObject:value[@"value"]];
                    }
                    
                    [result setObject:values forKey:item[@"name"]];
                }
            }
            else if([item[@"name"] isEqualToString:@"LeadSource"])
            {
                if(item[@"picklistValues"])
                {
                    NSMutableArray *values = [NSMutableArray new];
                    for(NSDictionary *value in item[@"picklistValues"])
                    {
                        [values addObject:value[@"value"]];
                    }
                    
                    [result setObject:values forKey:item[@"name"]];
                }
            }
            else if([item[@"name"] isEqualToString:@"StageName"])
            {
                if(item[@"picklistValues"])
                {
                    NSMutableArray *values = [NSMutableArray new];
                    for(NSDictionary *value in item[@"picklistValues"])
                    {
                        [values addObject:value[@"value"]];
                    }
                    
                    [result setObject:values forKey:item[@"name"]];
                }
            }
        }
        
        if(handler) {
            handler(result, nil, YES);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"getSalesforcePicklistValuesForOpportunity - ftask - %@  / error - %@", task, error);
        if(handler) {
            handler(nil, error, NO);
        }
        [self refreshSalesforceAccessToken:nil];
    }];
}
- (void)refreshSalesforceAccessToken:(ExtendedBlockHandler)handler
{
    NSDictionary *credentials = [[PMSettingsManager instance] getSalesforceCredential];
    
    if(!credentials)
    {
        if(handler)
            handler(nil,nil,NO);
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"https://login.salesforce.com/services/oauth2/token?grant_type=refresh_token&refresh_token=%@&client_id=%@&client_secret=%@&format=json",credentials[@"refresh_token"],SALESFORCE_CONSUMER_KEY,SALESFORCE_CONSUMER_SECRET];
    
    NSDictionary *params = @{
                             @"grant_type": @"refresh_token",
                             @"refresh_token": credentials[@"refresh_token"],
                             @"client_id": SALESFORCE_CONSUMER_KEY,
                             @"client_secret": SALESFORCE_CONSUMER_SECRET,
                             @"format": @"json"
                             };
    
    NSLog(@"RefreshToken Params: %@", params);
    [_networkManager POST:urlString parameters:nil success:^ (NSURLSessionDataTask *task, id responseObject) {
        DLog(@"refreshSalesforceAccessToken - %@", responseObject);
        
        NSMutableDictionary *newCredentials = [NSMutableDictionary dictionaryWithDictionary:credentials];
        [newCredentials setObject:responseObject[@"access_token"] forKey:@"access_token"];
        [newCredentials setObject:responseObject[@"signature"] forKey:@"signature"];
        [newCredentials setObject:responseObject[@"scope"] forKey:@"scope"];
        [newCredentials setObject:responseObject[@"instance_url"] forKey:@"instance_url"];
        [newCredentials setObject:responseObject[@"id"] forKey:@"id"];
        [newCredentials setObject:responseObject[@"token_type"] forKey:@"token_type"];
        [newCredentials setObject:responseObject[@"issued_at"] forKey:@"issued_at"];
        
        [[PMSettingsManager instance] setSalesforceCredential:newCredentials];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SALESFORCE_TOKEN_REFRESHED object:nil];
        
        if(handler) {
            handler(responseObject, nil, YES);
        }
    } failure:^ (NSURLSessionDataTask *task, NSError *error) {
        DLog(@"refreshSalesforceAccessToken Error: %@", error);
        if(handler) {
            handler(nil, error, NO);
        }
    }];
}

-(void)getSalesforceOrganizationWithId:(NSString *)organizationId completion:(ExtendedBlockHandler)handler
{ 
    
    NSDictionary *credentials = [[PMSettingsManager instance] getSalesforceCredential];
    
    NSLog(@"Salesforce Credential - %@", credentials);
    if(!credentials)
    {
        if(handler)
            handler(nil,nil,NO);
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@/services/data/v35.0/sobjects/Organization/%@", credentials[@"instance_url"], organizationId];
    
    [_networkManager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", credentials[@"access_token"]] forHTTPHeaderField:@"Authorization"];
    
    [_networkManager GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        DLog(@"getSalesforceOrganization results - %@  / response - %@", task, responseObject);
        
        
        if(handler) {
            handler(responseObject, nil, YES);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"getSalesforceOrganization - ftask - %@  / error - %@", task, error);
        if(handler) {
            handler(nil, error, NO);
        }
        [self refreshSalesforceAccessToken:nil];
    }];
}


#pragma mark LinkedIn and Twitter Link
- (void)getLinkedInAndTwitterLink:(NSString *)name emails:(NSArray *)emails company:(NSString*)company completion:(ExtendedBlockHandler)handler
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:name&&![name isEqual:[NSNull null]] ? name : @"" forKey:@"NAME"];
    
    if(emails.count)
        [params setObject:[emails componentsJoinedByString:@","] forKey:@"EMAILS"];
    
    if(company && ![company isEqual:[NSNull null]] && company.length)
        [params setObject:company forKey:@"COMPANY"]; DLog(@"%@", params);
    
    NSString *urlString = [PMRequest getLinkedInAndTwitterLink];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    
    [manager POST:urlString parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"getLinkedInAndTwitterLink Success: %@", responseObject);
        
        if(responseObject && [responseObject isKindOfClass:[NSDictionary class]])
        {
            if(handler)
            {
                handler(responseObject, nil, YES);
            }
        }
        else
        {
            if(handler)
            {
                handler(nil, nil, NO);
            }
        }
        
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSString *errorString = [[NSString alloc] initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding];
        NSLog(@"getLinkedInAndTwitterLink Error: %@", errorString);
        if(handler)
            handler(nil, error, NO);
    }];
}

#pragma mark set device token

- (void)setDeviceToken:(NSString *)deviceToken forEmail:(NSString *)email completion:(ExtendedBlockHandler)handler
{
    NSDictionary *params = @{@"email_id":email, @"ios_id":deviceToken}; DLog(@"%@", params);
    
    NSString *urlString = [PMRequest setDeviceToken];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    
    [manager POST:urlString parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"setDeviceToken Success: %@", responseObject);
        
        if(responseObject && [responseObject isKindOfClass:[NSDictionary class]])
        {
            if(handler)
            {
                handler(responseObject, nil, YES);
            }
        }
        else
        {
            if(handler)
            {
                handler(nil, nil, NO);
            }
        }
        
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSString *errorString = [[NSString alloc] initWithData:error.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding];
        NSLog(@"setDeviceToken Error: %@", errorString);
        if(handler)
            handler(nil, error, NO);
    }];
}

@end
