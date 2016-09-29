//
//  Global.h
//  planckMailiOS
//
//  Created by Admin on 5/10/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#ifndef planckMailiOS_Global_h
#define planckMailiOS_Global_h

#import "NSString+Utils.h"
#import "AlertManager.h"

#define SLOG(_str_) NSLog(@"fast log %@", _str_)

#define LLLOG(_longlong_) NSLog(@"fast ll log %lli", _longlong_)

#define STRING_FROM_DATA(_data_) [[NSString alloc] initWithData:_data_ encoding:NSUTF8StringEncoding]

#define TRIM_STRING(_string_) [ _string_ stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]

#define KEYBOARD_HEIGHT_OFFSET  (([UIScreen mainScreen].bounds.size.height < 568.0f) ? 175.0f : 90.0f)


#define TURQUOISE_COLOR [UIColor colorWithRed:90.0f/255.0f green:196.0f/255.0f blue:180.0f/255.0f alpha:1.0f]

// Emelyan
#define FILE_DOWNLOAD_FAILURE "File download was failed"

//screen

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

//save to userdefauls
#define SAVE_VALUE(obj,key)[[NSUserDefaults standardUserDefaults] setObject:obj forKey:key];\
[[NSUserDefaults standardUserDefaults] synchronize];
#define GET_VALUE(key) [[NSUserDefaults standardUserDefaults] objectForKey:key]

#define BUNDLE_VERSION @"CFBundleVersion"

#define safeStringWithKey(key, object) ([NSNull null] != [object objectForKey:key] && [object objectForKey:key] != nil) ? [NSString stringWithFormat:@"%@",[object objectForKey:key]] : @""

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define STORYBOARD [UIStoryboard storyboardWithName:@"Main" bundle:nil]
#define MAIN_STORYBOARD [UIStoryboard storyboardWithName:@"Main" bundle:nil]
#define MAIL_STORYBOARD [UIStoryboard storyboardWithName:@"Mail" bundle:nil]
#define CALENDAR_STORYBOARD [UIStoryboard storyboardWithName:@"Calendar" bundle:nil]
#define FILES_STORYBOARD [UIStoryboard storyboardWithName:@"Files" bundle:nil]
#define PEOPLE_STORYBOARD [UIStoryboard storyboardWithName:@"People" bundle:nil]
#define TRACKING_STORYBOARD [UIStoryboard storyboardWithName:@"Tracking" bundle:nil]
#define SETTINGS_STORYBOARD [UIStoryboard storyboardWithName:@"Settings" bundle:nil]
#define SALESFORCE_STORYBOARD [UIStoryboard storyboardWithName:@"Salesforce" bundle:nil]
#define LEADS_STORYBOARD [UIStoryboard storyboardWithName:@"Leads" bundle:nil]
#define OPPORTUNITIES_STORYBOARD [UIStoryboard storyboardWithName:@"Opportunities" bundle:nil]


// NOTIFICATION NAME DEFINE
#define NOTIFICATION_STATUS_BAR_SHOW @"NotificationStatusBarShow"
#define NOTIFICATION_STATUS_BAR_HIDE @"NOtificationStatusBarHide"

#define NOTIFICATION_CONTACT_DATA_CHANGED @"NotificationContactDataChanged"
#define NOTIFICATION_SALESFORCE_ENABLED @"NotificationSalesforceEnabled"
#define NOTIFICATION_SALESFORCE_DISABLED @"NotificationSalesforceDisabled"
#define NOTIFICATION_SALESFORCE_OPPORTUNITY_SAVE_SUCCEEDED @"NotificationSalesforceOpportunitySaveSucceeded"
#define NOTIFICATION_SALESFORCE_OPPORTUNITY_SAVE_FAILED @"NotificationSalesforceOpportunitySaveFailed"
#define NOTIFICATION_SALESFORCE_LEAD_SAVE_SUCCEEDED @"NotificationSalesforceLeadSaveSucceeded"
#define NOTIFICATION_SALESFORCE_LEAD_SAVE_FAILED @"NotificationSalesforceLeadSaveFailed"


#define NOTIFICATION_MESSAGE_UPDATED @"NotificationMessageUpdated"
#define NOTIFICATION_EVENT_UPDATED @"NotificationEventUpdated"

#define NOTIFICATION_PHONE_CONTACT_UPDATED @"NotificationPhoneContactUpdated"

#define NOTIFICATION_ACTIVE_ACCOUNT_CHANGED @"NotificationActiveAccountChanged"
#define NOTIFICATION_MENU_FOLDER_SELECTED @"NotificationMenuFolderSelected"

#define NOTIFICATION_ENABLE_IMPORTANT_CHANGED @"NotificationEnableImportantChanged"

#define NOTIFICATION_UNREAD_COUNT_CHANGED @"NotificationUnreadCountChanged"

#define NOTIFICATION_EMAIL_ADDED_TO_BLACK_LIST @"NotificationEmailAddedToBlackList"
#define NOTIFICATION_EMAIL_REMOVED_FROM_BLACK_LIST @"NotificationEmailRemovedFromBlackList"

#define NOTIFICATION_MAIL_SCHEDULED @"NotificationMailScheduled"

#define NOTIFICATION_ACCOUNT_CHANGED @"NotificationAccountChanged"

#define NOTIFICATION_MAIL_ACCOUNT_ADDED @"NotificationMailAccountAdded"
#define NOTIFICATION_MAIL_ACCOUNT_DELETED @"NotificationMailAccountDeleted"


#define NOTIFICATION_SALESFORCE_TOKEN_REFRESHED @"NotificationSalesforceTokenRefreshed"
#define NOTIFICATION_BLACK_LIST_UPDATED @"NotificationBlackListUpdated"

#define NOTIFICATION_ACTIVE_SPAMMER_ADDED @"NotificationActiveSpammerAdded"

#define NOTIFICATION_DROPBOX_ACCOUNT_DELETED @"NotificationDropboxAccountDeleted"
#define NOTIFICATION_BOX_ACCOUNT_DELETED @"NotificationBoxAccountDeleted"
#define NOTIFICATION_GOOGLEDRIVE_ACCOUNT_DELETED @"NotificationGoogleDriveAccountDeleted"
#define NOTIFICATION_ONEDRIVE_ACCOUNT_DELETED @"NotificationOneDriveAccountDeleted"
#define NOTIFICATION_EVERNOTE_ACCOUNT_DELETED @"NotificationEvernoteAccountDeleted"

#define NOTIFICATION_EMAIL_TRACKING_CHANGED @"NotificationEmailTrackingChanged"


#define CONTACT_BG_COLOR_1 [UIColor colorWithRed:0 green:203.0/255.0f blue:182.0/255.0f alpha:1.0f]
#define CONTACT_BG_COLOR_2 [UIColor colorWithRed:0 green:203.0/255.0f blue:182.0/255.0f alpha:1.0f]
#define CONTACT_BG_COLOR_3 [UIColor colorWithRed:72.0/255.0f green:146.0/255.0f blue:209.0/255.0f alpha:1.0f]
#define CONTACT_BG_COLOR_4 [UIColor colorWithRed:171.0/255.0f green:171.0/255.0f blue:171.0/255.0f alpha:1.0f]

// Activity Status Types
#define ACTIVITY_STATUS_TYPE_INFO @"ActivityStatusTypeInfo"
#define ACTIVITY_STATUS_TYPE_ERROR @"ActivityStatusTypeError"
#define ACTIVITY_STATUS_TYPE_PROGRESS @"ActivityStatusTypeProgress"

//string value
#define stringValue(str) (([str isKindOfClass:[NSNull class]]) ? @"": str)


#define notNullValue(obj) [obj isKindOfClass:[NSNull class]]?nil:obj
#define notNullEmptyString(obj) [obj isKindOfClass:[NSNull class]]?@"":obj

//debug log
#ifdef DEBUG
# define DLog(...) NSLog(__VA_ARGS__)
#else
# define DLog(...) /* */
#endif
#define ALog(...) NSLog(__VA_ARGS__)

#define WSELF   __weak typeof(self) wself = self

typedef NS_ENUM(NSInteger, selectedMessages) {
    ImportantMessagesSelected = 0,
    SocialMessagesSelected = 1,
    ReadLaterMessagesSelected = 2,
    FollowUpsMessagesSelected = 3
};

#endif
//---
