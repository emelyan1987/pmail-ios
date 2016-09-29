//
//  PMRequest.m
//  planckMailiOS
//
//  Created by admin on 5/24/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMRequest.h"
#import "Config.h"
#import "DBNamespace.h"

@implementation PMRequest

+ (NSString *)loginWithAppId:(NSString *)appId
                       mail:(NSString *)mail
                redirectUri:(NSString *)uri {
    
    return [NSString stringWithFormat:@"%@/oauth/authorize?client_id=%@&response_type=token&login_hint=%@&scope=email&redirect_uri=%@", APP_SERVER_LINK, appId, mail, uri];
    //return [NSString stringWithFormat:@"%@/oauth/authorize?client_id=%@&scope=email&response_type=token&redirect_uri=%@", APP_SERVER_LINK, appId, uri];
}

+ (NSString *)namespaces {
    return [NSString stringWithFormat:@"%@/n", APP_SERVER_LINK];
}

+ (NSString *)inboxMailWithNamespaceId:(NSString*)namespaceId limit:(NSUInteger)limit offset:(NSUInteger)offset {
    //return [NSString stringWithFormat:@"%@/n/%@/threads?limit=%lu&offset=%lu", APP_SERVER_LINK, namespaceId, (unsigned long)limit, (unsigned long)offset];
    return [NSString stringWithFormat:@"%@/threads?limit=%lu&offset=%lu", APP_SERVER_LINK, (unsigned long)limit, (unsigned long)offset];
}

+ (NSString *)messageId:(NSString *)messageId namespacesId:(NSString *)namespacesId {
    //return [NSString stringWithFormat:@"%@/n/%@/messages?thread_id=%@", APP_SERVER_LINK, namespacesId, messageId];
    return [NSString stringWithFormat:@"%@/messages?thread_id=%@", APP_SERVER_LINK, messageId];
}

+ (NSString *)searchMailWithKeyword:(NSString *)keyword namespacesId:(NSString *)namespacesId {
    //return [NSString stringWithFormat:@"%@/n/%@/threads/search?q=%@", APP_SERVER_LINK, namespacesId, keyword];
    return [NSString stringWithFormat:@"%@/threads/search?q=%@", APP_SERVER_LINK, keyword];
}

+ (NSString *)updateThread:(NSString *)threadId {
    return [NSString stringWithFormat:@"%@/threads/%@", APP_SERVER_LINK, threadId];
}

+ (NSString *)deleteMailWithThreadId:(NSString *)threadId {
    return [NSString stringWithFormat:@"%@/threads/%@", APP_SERVER_LINK, threadId];
}

+ (NSString *)updateMailWithThreadId:(NSString *)threadId {
    return [NSString stringWithFormat:@"%@/threads/%@", APP_SERVER_LINK, threadId];
}
+ (NSString *)replyMessageWithNamespacesId:(NSString *)namespacesId {
    //return [NSString stringWithFormat:@"%@/n/%@/send", APP_SERVER_LINK, namespacesId];
    return [NSString stringWithFormat:@"%@/send", APP_SERVER_LINK];
}
+ (NSString *)sendRSVP
{
    //return [NSString stringWithFormat:@"%@/n/%@/send", APP_SERVER_LINK, namespacesId];
    return [NSString stringWithFormat:@"%@/send-rsvp", APP_SERVER_LINK];
}
+ (NSString *)draftMessageWithNamespacesId:(NSString *)namespacesId {
    return [NSString stringWithFormat:@"%@/drafts", APP_SERVER_LINK];
}

+ (NSString *)unreadMessages {
  return [NSString stringWithFormat:@"%@/messages?tag=inbox&unread=true", APP_SERVER_LINK];
}

+ (NSString *)unreadMessagesCount {
  return [NSString stringWithFormat:@"%@/messages?in=inbox&unread=true&view=count", APP_SERVER_LINK];
}

+ (NSString *)unreadMessagesCountForFolder:(NSString*)folder {
    return [NSString stringWithFormat:@"%@/messages?in=%@&unread=true&view=count", APP_SERVER_LINK, folder];
}
+ (NSString *)emailAddressesFromFolder:(NSString*)folder
{
    return [NSString stringWithFormat:@"%@/messages?in=%@&view=from", APP_SERVER_LINK, folder];
}
+ (NSString *)foldersWithNamespaceId:(DBNamespace *)namespaceId
                            folderId:(NSString *)folderId {
    NSString *unitName = [namespaceId.organizationUnit isEqualToString:@"label"]? @"labels" : @"folders";
    
    if (folderId){
        return [NSString stringWithFormat:@"%@/%@/%@",APP_SERVER_LINK, unitName, folderId];
    } else {
        return [NSString stringWithFormat:@"%@/%@",APP_SERVER_LINK, unitName];
    }
}

+ (NSString*)messageId:(NSString*)messageId {

    return [NSString stringWithFormat:@"%@/messages/%@",APP_SERVER_LINK,messageId];
}

+ (NSString*)threadId:(NSString*)messageId {
    
    return [NSString stringWithFormat:@"%@/threads/%@",APP_SERVER_LINK,messageId];
}

+(NSString*)reminder {

    return [NSString stringWithFormat:@"%@/server/add_thread_to_reminder_list", PLANCK_SERVER_URL];
    
}

+(NSString *)downloadFileWithFileId:(NSString *)fileId namespacesId:(NSString *)namespacesId
{
    //return [NSString stringWithFormat:@"%@/n/%@/files/%@/download", APP_SERVER_LINK, namespacesId, fileId];
    return [NSString stringWithFormat:@"%@/files/%@/download", APP_SERVER_LINK, fileId];
}

+(NSString *)uploadFileWithAccount:(NSString *)namespacesId
{
    //return [NSString stringWithFormat:@"%@/n/%@/files", APP_SERVER_LINK, namespacesId];
    return [NSString stringWithFormat:@"%@/files", APP_SERVER_LINK];
}

+(NSString *)deleteEventWithEventId:(NSString *)eventId namespacesId:(NSString *)namespacesId {
    //return [NSString stringWithFormat:@"%@/n/%@/threads/%@", APP_SERVER_LINK, namespacesId, threadId];
    return [NSString stringWithFormat:@"%@/events/%@", APP_SERVER_LINK, eventId];
}


+(NSString*)salesforceAuthorization
{
    return [NSString stringWithFormat:@"%@?response_type=token&client_id=%@&redirect_uri=%@", SALESFORCE_AUTHORIZE_URL, SALESFORCE_CONSUMER_KEY, SALESFORCE_REDIRECT_URI];
}
+(NSString*)salesforceContacts
{
    return [NSString stringWithFormat:@""];
}

+(NSString*)markImportant
{
    return [NSString stringWithFormat:@"%@/api/mark_contact/", PLANCK_SERVER_URL2];
}
+(NSString*)addEmailToBlackList {
    return [NSString stringWithFormat:@"%@/api/add_to_blacklist/", PLANCK_SERVER_URL2];
}
+(NSString*)removeEmailFromBlackList {
    return [NSString stringWithFormat:@"%@/api/remove_from_blacklist/", PLANCK_SERVER_URL2];
}
+(NSString*)getBlackList
{
    return [NSString stringWithFormat:@"%@/api/get_blacklist/", PLANCK_SERVER_URL2];
}
+(NSString*)getActiveSpammers
{
    return [NSString stringWithFormat:@"%@/server/get_contact_mail_counts_topk", PLANCK_SERVER_URL];
}

+ (NSString *)countMailFromEmail:(NSString *)email
{
    return [NSString stringWithFormat:@"%@/messages?from=%@&view=count", APP_SERVER_LINK, email];
}
+ (NSString *)messagesCountInFolder:(NSString *)folder
{
    return [NSString stringWithFormat:@"%@/messages?in=%@&view=count", APP_SERVER_LINK, folder];
}
+ (NSString *)messages
{
    return [NSString stringWithFormat:@"%@/messages", APP_SERVER_LINK];
}
+(NSString*)getLinkedInAndTwitterLink {
    return [NSString stringWithFormat:@"%@/api/dossier", PLANCK_SERVER_URL1];
}

+ (NSString*)setDeviceToken
{
    return [NSString stringWithFormat:@"%@/server/set_push_user", PLANCK_SERVER_URL];
}
@end
