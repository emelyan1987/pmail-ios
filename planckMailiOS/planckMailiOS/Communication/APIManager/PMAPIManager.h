//
//  PMAPIManager.h
//  planckMailiOS
//
//  Created by Admin on 5/10/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PMRequest.h"
#import "DBManager.h"
#import "PMAccountProtocol.h"

typedef void (^BasicBlockHandler)(id error, BOOL success);
typedef void (^ExtendedBlockHandler)(id data, id error, BOOL success);
typedef void (^DownloadBlockHandler)(NSURLResponse *responseData, NSURL *filepath, NSError *error);
typedef void (^UploadBlockHandler)(NSURLResponse *response, id responseObject, NSError *error);


@class PMThread;
@interface PMAPIManager : NSObject 

@property (nonatomic, readonly) DBNamespace *namespaceId;
@property (nonatomic, readonly) NSString *emailAddress;

+ (PMAPIManager *)shared;

- (DBNamespace *)getRecentNamespace;
- (void)setActiveNamespace:(DBNamespace *)namespace;

- (void)saveNamespaceIdFromToken:(NSString *)token completion:(ExtendedBlockHandler)handler;

- (void)getThreadsWithAccount:(NSString *)accountId
                 parameters:(NSDictionary *)parameters
                       path:(NSString *)path
                 completion:(ExtendedBlockHandler)handler;

- (NSArray*)getThreadsWithAccount:(NSString*)accountId
                         folder:(NSString*)folder
                         offset:(NSUInteger)offset
                          limit:(NSUInteger)limit;

- (void)getThreadsWithAccount:(NSString*)accountId
                    folder:(NSString*)folder
                     offset:(NSUInteger)offset
                      limit:(NSUInteger)limit
                 completion:(ExtendedBlockHandler)handler;

- (void)getThreadWithId:(NSString*)threadId forAccount:(NSString*)accountId completion:(ExtendedBlockHandler)handler;

- (void)searchMailWithKeyword:(NSString *)keyword
                      account:(id<PMAccountProtocol>)account
                   completion:(ExtendedBlockHandler)handler;


- (NSArray*)getMessagesWithThreadId:(NSString *)threadId
                         forAccount:(NSString*)accountId
                         completion:(ExtendedBlockHandler)handler;

- (void)getMessagesWithParams:(NSDictionary *)params
                         forAccount:(NSString*)accountId
                         completion:(ExtendedBlockHandler)handler;

- (NSArray*)getDetailWithAnyEmail:(NSString *)anyEmail
                      account:(id<PMAccountProtocol>)account
                   completion:(ExtendedBlockHandler)handler;

- (NSDictionary*)getMessageWithId:(NSString *)messageId
                          account:(id<PMAccountProtocol>)account
                       completion:(ExtendedBlockHandler)handler;

- (void)getDraftWithId:(NSString *)draftId
            forAccount:(NSString*)accountId
            completion:(ExtendedBlockHandler)handler;

- (void)replyMessage:(NSDictionary *)message
          completion:(ExtendedBlockHandler)handler;
- (void)sendRSVP:(NSDictionary *)params
          completion:(ExtendedBlockHandler)handler;

- (void)createDraft:(NSDictionary *)params
          completion:(ExtendedBlockHandler)handler;
- (void)updateDraft:(NSString*)draftId
              params:(NSDictionary *)params
          completion:(ExtendedBlockHandler)handler;
- (void)deleteDraft:(NSString*)draftId
             params:(NSDictionary *)params
         completion:(ExtendedBlockHandler)handler;


- (void)getUnreadCountForNamespaseToken:(NSString *)token completion:(ExtendedBlockHandler)handler;
- (void)getUnreadMessagesForNamespaseToken:(NSString *)token completion:(ExtendedBlockHandler)handler;
- (void)getUnreadCountForFolder:(NSString *)folder forAccount:(NSString*)accountId completion:(ExtendedBlockHandler)handler;

- (void)updateThread:(NSString*)threadId
          forAccount:(NSString*)accountId
              params:(NSDictionary*)params
          completion:(ExtendedBlockHandler)handler;

- (void)moveThread:(PMThread*)thread toFolder:(NSString*)folderId completion:(ExtendedBlockHandler)handler;
- (void)deleteThread:(PMThread *)thread completion:(ExtendedBlockHandler)handler;
- (void)archiveThread:(PMThread *)thread completion:(ExtendedBlockHandler)handler;
- (void)markReadThread:(PMThread *)thread completion:(BasicBlockHandler)handler;
- (void)markUnreadThread:(PMThread *)thread completion:(BasicBlockHandler)handler;
- (void)markImportantThread:(PMThread *)thread completion:(BasicBlockHandler)handler;
- (void)markUnimportantThread:(PMThread *)thread completion:(BasicBlockHandler)handler;
- (void)unsubscribeThread:(PMThread *)thread completion:(ExtendedBlockHandler)handler;

//folders
- (void)getFoldersWithAccount:(NSString*)accountId
                   comlpetion:(ExtendedBlockHandler)handler;

- (void)getFoldersWithAccount:(id<PMAccountProtocol>)account folderId:(NSString*)folderId comlpetion:(ExtendedBlockHandler)handler;

- (void)createFolderWithName:(NSString *)folderName
                     account:(id<PMAccountProtocol>)account
                  comlpetion:(ExtendedBlockHandler)handler;

- (void)renameFolderWithName:(NSString *)newFolderName
                     account:(id<PMAccountProtocol>)account
                    folderId:(NSString *)folderId
                  comlpetion:(ExtendedBlockHandler)handler;
- (void)deleteFolderWithId:(NSString*)folderId
                  account:(id<PMAccountProtocol>)account
               completion:(ExtendedBlockHandler)handler;



#pragma mark Snooze Relation
- (void)moveMailToReminderMailId:(NSString*)mailId account:(id<PMAccountProtocol>)account time:(int)time threadId:(NSString*)threadId messageId:(NSString*)messageId autoAsk:(NSString*)autoAsk subject:(NSString*)subject completion:(ExtendedBlockHandler)handler;
- (NSArray*)getSnoozedThreadsForAccount:(NSString*)accountId;

#pragma mark Unsubscrive Relation
- (void)addEmailToBlackList:(NSArray*)emails forAccount:(NSString*)accountId completion:(ExtendedBlockHandler)handler;
- (void)removeEmailFromBlackList:(NSArray*)emails forAccount:(NSString*)accountId completion:(ExtendedBlockHandler)handler;
- (void)getBlackList:(NSString*)email completion:(ExtendedBlockHandler)handler;
- (void)getActiveSpammers:(NSString*)email count:(NSInteger)count completion:(ExtendedBlockHandler)handler;

- (void)getMailsCountFromEmail:(NSString *)email forAccount:(NSString*)accountId completion:(ExtendedBlockHandler)handler;
- (void)getMessagesCountInFolder:(NSString*)folder forAccount:(NSString*)accountId completion:(ExtendedBlockHandler)handler;
//----

- (void)saveToken:(NSString *)token andEmail:(NSString*)email completion:(BasicBlockHandler)handler;
- (void)getTokenWithEmail:(NSString *)email completion:(ExtendedBlockHandler)handler;
- (void)deleteTokenWithEmail:(NSString *)email
                  completion:(BasicBlockHandler)handler;

- (void)setTagToThread:(NSString*)threadId email:(NSString*)email completion:(BasicBlockHandler)handler;



// Calendar methods

- (NSArray*)getCalendarsWithAccount:(NSString *)accountId
                     comlpetion:(ExtendedBlockHandler)handler;

- (NSArray*)getEventsWithAccount:(NSString*)accountId
                     eventParams:(NSDictionary *)eventParams
                      comlpetion:(ExtendedBlockHandler)handler;

- (void)createCalendarEventWithAccount:(id<PMAccountProtocol>)account
                           eventParams:(NSDictionary *)eventParams
                            comlpetion:(ExtendedBlockHandler)handler;

- (void)deleteCalendarEventWithAccount:(id<PMAccountProtocol>)account
                               eventId:(NSString*)eventId
                           eventParams:(NSDictionary *)eventParams
                            comlpetion:(ExtendedBlockHandler)handler;

- (void)updateCalendarEventWithAccount:(id<PMAccountProtocol>)account
                               eventId:(NSString*)eventId
                           eventParams:(NSDictionary *)eventParams
                            comlpetion:(ExtendedBlockHandler)handler;

- (NSURLSessionDownloadTask*)downloadFileWithAccount:(id<PMAccountProtocol>)account
                        file:(NSDictionary*)file
                        completion:(DownloadBlockHandler)handler;
- (NSURLSessionUploadTask*)uploadFileWithAccount:(id<PMAccountProtocol>)account
                                         filepath:(NSString*)filepath
                                         completion:(UploadBlockHandler)handler;
- (void)getTheadWithAccount:(id<PMAccountProtocol>)account
                 completion:(BasicBlockHandler)handler;

- (NSArray*)getContactsWithAccount:(id<PMAccountProtocol>)account
                        params:(NSDictionary *)params
                    comlpetion:(ExtendedBlockHandler)handler;

-(void)getSummariesFromText:(NSString*)text lines:(NSInteger)lines completion:(ExtendedBlockHandler)handler;
-(void)getKeywordPhrasesFromText:(NSString*)text subject:(NSString*)subject completion:(ExtendedBlockHandler)handler;

-(void)getBusyTimeSlotsWithParams:(NSDictionary*)params completion:(ExtendedBlockHandler)handler;

/**
    Create email tracking record to PlanckDB and get track record id
    @param  completion:     (^ExtendedBlockHandler)(id data, id error, BOOL success)
                            if success created track record id come from data parameter, else error
 **/
- (void)createEmailTrack:(ExtendedBlockHandler)handler;
/**
 Update email tracking record to PlanckDB
 @param  trackId    :       existing track record id
 @param  threadId  :       thread id from Nylas after sent email successfully.
 @param  messageId  :       message id from Nylas after sent email successfully.
 @param  subject    :       email subject
 @param  ownerEmail      :       email address of owner created this email
 @param  targetEmails    :       email address array string distinguished by comma of receipts to receive this email(e.g nicolaianton727@hotmail.com,rajesh.x.kumar@gmail.com,emelyan.a@outlook.com)
 @param  completion :       (^ExtendedBlockHandler)(id data, id error, BOOL success)
 if success created track record come from data parameter, else error
 **/
- (void)updateEmailTrack:(NSNumber*)trackId
               threadId:(NSString*)threadId
               messageId:(NSString*)messageId
                 subject:(NSString*)subject
              ownerEmail:(NSString*)ownerEmail
            targetEmails:(NSString*)targetEmails
              completion:(ExtendedBlockHandler)handler;


- (NSArray*)getEmailTrackList:(NSString*)email
                  trackStatus:(NSString*)status
                         time:(NSString*)time   // "today", "last7", "last31"
                   completion:(ExtendedBlockHandler)handler;
- (NSArray*)getEmailTrackDetailList:(NSNumber*)trackId
                         completion:(ExtendedBlockHandler)handler;


#pragma mark Salesforce API endpoints
- (void)getSalesforceUserInfo:(ExtendedBlockHandler)handler;
- (void)getSalesforceContacts:(ExtendedBlockHandler)handler;
- (void)saveSalesforceContact:(NSDictionary*)data completion:(ExtendedBlockHandler)handler;
- (void)saveSalesforceLead:(NSDictionary*)data completion:(ExtendedBlockHandler)handler;
- (void)saveSalesforceOpportunity:(NSDictionary*)data completion:(ExtendedBlockHandler)handler;
- (void)getSalesforceUsers:(ExtendedBlockHandler)handler;
- (void)getSalesforceAccounts:(ExtendedBlockHandler)handler;
- (void)getSalesforceLeads:(NSInteger)offset completion:(ExtendedBlockHandler)handler;
- (void)getSalesforceOpportunities:(NSInteger)offset completion:(ExtendedBlockHandler)handler;
- (void)getSalesforceCampaigns:(ExtendedBlockHandler)handler;
- (void)refreshSalesforceAccessToken:(ExtendedBlockHandler)handler;
- (void)getSalesforceOrganizationWithId:(NSString*)organizationId completion:(ExtendedBlockHandler)handler;
- (void)getSalesforceLeadStatusList:(ExtendedBlockHandler)handler;
- (void)getSalesforceOpportunityStageList:(ExtendedBlockHandler)handler;

/**
 * Get picklist values for lead
 *
 * Salutation, LeadSource, Status, Industry, Rating
 */
- (void)getSalesforcePicklistValuesForLead:(ExtendedBlockHandler)handler;
/**
 * Get picklist values for opportunity
 *
 * Type, LeadSource, StageName
 */
- (void)getSalesforcePicklistValuesForOpportunity:(ExtendedBlockHandler)handler;

// ============= TimeSlot APIs for Calendar availability ============


#pragma mark LinkedIn and Twitter ProfileLink
- (void)getLinkedInAndTwitterLink:(NSString*)name emails:(NSArray*)emails company:(NSString*)company completion:(ExtendedBlockHandler)handler;

- (void)setDeviceToken:(NSString*)deviceToken forEmail:(NSString*)email completion:(ExtendedBlockHandler)handler;

@end


