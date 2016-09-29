//
//  PMRequest.h
//  planckMailiOS
//
//  Created by admin on 5/24/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBNamespace;
@interface PMRequest : NSObject
+ (NSString*)loginWithAppId:(NSString *)appId
                       mail:(NSString *)mail
                redirectUri:(NSString *)uri;

+ (NSString*)namespaces;

+ (NSString *)inboxMailWithNamespaceId:(NSString *)namespaceId
                                 limit:(NSUInteger)limit
                                offset:(NSUInteger)offset;

+ (NSString *)messageId:(NSString *)messageId
           namespacesId:(NSString *)namespacesId;

+ (NSString *)searchMailWithKeyword:(NSString *)keyword
                       namespacesId:(NSString *)namespacesId;

+ (NSString *)updateThread:(NSString *)threadId;
+ (NSString *)deleteMailWithThreadId:(NSString *)threadId;
+ (NSString *)updateMailWithThreadId:(NSString *)threadId;

+ (NSString *)replyMessageWithNamespacesId:(NSString *)namespacesId;
+ (NSString *)sendRSVP;

+ (NSString *)draftMessageWithNamespacesId:(NSString *)namespacesId;

+ (NSString *)foldersWithNamespaceId:(DBNamespace *)namespaceId
                            folderId:(NSString *)folderId;
+  (NSString*)reminder;
+ (NSString *)unreadMessages;
+ (NSString *)unreadMessagesCount;
+ (NSString *)unreadMessagesCountForFolder:(NSString*)folder;
+ (NSString*)messageId:(NSString*)messageId;
+ (NSString*)threadId:(NSString*)messageId;

+ (NSString *)downloadFileWithFileId:(NSString *)fileId
                        namespacesId:(NSString *)namespacesId;

+ (NSString *)uploadFileWithAccount:(NSString *)namespacesId;

+ (NSString *)deleteEventWithEventId:(NSString *)eventId namespacesId:(NSString *)namespacesId;


+ (NSString*)salesforceAuthorization;
+ (NSString*)salesforceContacts;

+ (NSString*)addEmailToBlackList;
+ (NSString*)removeEmailFromBlackList;
+ (NSString*)getBlackList;
+ (NSString*)getActiveSpammers;

+ (NSString*)countMailFromEmail:(NSString*)email;
+ (NSString *)messagesCountInFolder:(NSString *)folder;
+ (NSString *)messages;
+ (NSString *)emailAddressesFromFolder:(NSString*)folder;

+ (NSString*)markImportant;

+(NSString*)getLinkedInAndTwitterLink;

+ (NSString*)setDeviceToken;
@end
