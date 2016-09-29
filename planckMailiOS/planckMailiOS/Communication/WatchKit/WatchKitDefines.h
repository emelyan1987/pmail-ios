//
//  WatchKitDefines.h
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 7/17/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#ifndef planckMailiOS_WatchKitDefines_h
#define planckMailiOS_WatchKitDefines_h

#import <Foundation/Foundation.h>

#define WK_REQUEST_TYPE @"wk_request_type"
#define WK_REQUEST_INFO @"wk_request_info"
#define WK_REQUEST_EMAILS_LIMIT @"wk_request_emails_limit"
#define WK_REQUEST_RESPONSE @"wk_request_response"
#define WK_REQUEST_PHONE @"wk_request_phone"
#define WK_REQUEST_MESSAGE @"wk_request_message"
#define WK_RESPONSE_TYPE @"wk_response_type"
#define WK_RESPONSE_UNREADS @"wk_response_unreads"
#define WK_RESPONSE_INFO @"wk_response_info"

#define LIST_CONTROLLER_IDENTIFIER @"emailListController"
#define TITLE @"title"
#define CONTENT @"content"
#define ADDITIONAL_INFO @"additional_info"

#define EMAILS_LIMIT_COUNT 10

#define CONTACTS_LIMIT_COUNT 200
#define CONTACTS_OFFSET @"contacts_offset"
#define CONTACTS_LIMIT @"contacts_limit"

#define WK_CONTACT_LIST @"wkContactList"


#define WK_NOTIFICATION_DID_RECEIVE_CONTACT_LIST @"wkNotificationDidReceiveContactList"

typedef NS_ENUM(NSInteger, PMWatchRequestType) {
    PMWatchRequestAccounts,
    PMWatchRequestGetEmails,
    PMWatchRequestGetEmailDetails,
    PMWatchRequestReply,
    PMWatchRequestGetContacts,
    PMWatchRequestGetContactInfo,
    PMWatchRequestCall,
    PMWatchRequestSendSMS,
    PMWatchRequestGetUnreadEmailsCount,
    PMWatchRequestGetUnreadEmails,
    PMWatchRequestGetImages,
    PMWatchRequestGetEvents
};

#endif
