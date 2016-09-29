//
//  Config.h
//  planckMailiOS
//
//  Created by admin on 5/24/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#ifndef planckMailiOS_Config_h
#define planckMailiOS_Config_h

//#define PLANCK_SYNC_ENGINE

#ifndef PLANCK_SYNC_ENGINE
#define APP_SERVER_LINK @"https://api.nylas.com"
#define APP_ID @"5girg6tjmjuenujbsg0lnatlq"
#else
#define APP_SERVER_LINK @"https://sync-dev.planckapi.com"
#define APP_ID @"ZSqm8GeRygJtr9czgVbgKYkwK"
#define APP_SECRET @"xjhwaych6ufut6xn77qp5kavp"
#endif


#define APP_GROUP_ID @"group.com.planckMailiOS"

#define TRACK_SERVER_ROOT @"http://ec2-54-200-236-238.us-west-2.compute.amazonaws.com/planckmail/web/track"
#define PLANCK_SERVER_URL @"http://planckapi-dev.elasticbeanstalk.com"
#define PLANCK_SERVER_URL1 @"http://planckapi-test.elasticbeanstalk.com"
#define PLANCK_SERVER_URL2 @"http://planckapi-prioritizer.us-west-1.elasticbeanstalk.com"

#define PLANCK_LINK @"http://www.plancklabs.com"

/**
 Dropbox app info
 Account    :   plancklabs@plancklabs.com/Planckmail11**
 App Name   :   PlanckMail
 */
#define DROPBOX_APP_KEY "rm8nd61ita6scjg"
#define DROPBOX_APP_SECRET "skywiu97rawg55p"

/**
 Box app info
 Account    :   plancklabs@plancklabs.com/Planckmail11**
 App Name   :   PlanckMail
 */
#define BOX_CLIENT_ID "fhqta6ms59vhzi5d0r7x2oepjfrj0rrv"
#define BOX_CLIENT_SECRET "QeZSXQwfyN6glwOH07siOSTN5H8LhL5L"
#define BOX_REDIRECT_URI "https://sync-dev.planckapi.com/static/callback/box.html"

/**
 GoogleDrive app info
 Account    :   
 App Name   :
 */
#define GOOGLE_KEYCHAIN_ITEM_NAME "PlanckMail: Google Drive1"
#define GOOGLE_CLIENT_ID "65711481506-bvb2d9rd6r23a5pan27uugn1c4liksm2.apps.googleusercontent.com"
#define GOOGLE_CLIENT_SECRET "WEsp1K-DAtFAgyQrDNlHjWtE"

#define GMS_API_KEY "AIzaSyBtHkTh2VW-FWiut05moz8cS4eQKkngxQs"

/**
 OneDrive app info
 Account    :   Plancklabs@hotmail.com/Planckmail11**
 App Name   :   PlanckMail
 */
#define ONEDRIVE_APP_ID "0000000048187F2D"
#define ONEDRIVE_APP_SECRET "tbdPwRp6JS7SADbIdvFLQZOIndtku684"

#define EVERNOTE_CONSUMER_KEY "planck-5467"
#define EVERNOTE_CONSUMER_SECRET "f70d9cee5e3d5d7d"


#define SALESFORCE_CONSUMER_KEY @"3MVG9uudbyLbNPZMg5Z9ToWHIfhLLnWX.j4DYLuLW9.bfdMi7mETjKuE3AchLfeen0An_RqBdZg=="
#define SALESFORCE_CONSUMER_SECRET @"5711898856374968508"
#define SALESFORCE_REDIRECT_URI @"planckmail://callback/salesforce"
#define SALESFORCE_AUTHORIZE_URL @"https://login.salesforce.com/services/oauth2/authorize"

#define ACCOUNT_ARCHIVE_FOLDER_ID @"account_archive_folder_id"
#define ARCHIVE @"Archive"




#define FOOTER_BAR_ERROR_COLOR [UIColor colorWithRed:255.0f/255.0f green:217.0f/255.0f blue:255.0f/255.0f alpha:1.0f]
#define FOOTER_BAR_INFO_COLOR [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:217.0f/255.0f alpha:1.0f]

#define UIColorFromRGB(rgbValue)   ([UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0])

#define PM_TURQUOISE_COLOR UIColorFromRGB(0x30c4b4)
#define PM_BLACK_COLOR UIColorFromRGB(0x1b1b1b)
#define PM_GREY_COLOR UIColorFromRGB(0x9f9f9f)
#define PM_WHITE_COLOR UIColorFromRGB(0xffffff)

#define COLOR_ITEM_0 [UIColor colorWithRed:192.0f/255.0f green:57.0f/255.0f blue:43.0f/255.0f alpha:1.0f]
#define COLOR_ITEM_1 [UIColor colorWithRed:229.0f/255.0f green:126.0f/255.0f blue:45.0f/255.0f alpha:1.0f]
#define COLOR_ITEM_2 [UIColor colorWithRed:241.0f/255.0f green:196.0f/255.0f blue:48.0f/255.0f alpha:1.0f]
#define COLOR_ITEM_3 [UIColor colorWithRed:97.0f/255.0f green:205.0f/255.0f blue:114.0f/255.0f alpha:1.0f]
#define COLOR_ITEM_4 [UIColor colorWithRed:59.0f/255.0f green:129.0f/255.0f blue:58.0f/255.0f alpha:1.0f]
#define COLOR_ITEM_5 [UIColor colorWithRed:84.0f/255.0f green:188.0f/255.0f blue:156.0f/255.0f alpha:1.0f]
#define COLOR_ITEM_6 [UIColor colorWithRed:52.0f/255.0f green:152.0f/255.0f blue:219.0f/255.0f alpha:1.0f]
#define COLOR_ITEM_7 [UIColor colorWithRed:34.0f/255.0f green:109.0f/255.0f blue:160.0f/255.0f alpha:1.0f]
#define COLOR_ITEM_8 [UIColor colorWithRed:142.0f/255.0f green:68.0f/255.0f blue:173.0f/255.0f alpha:1.0f]
#define COLOR_ITEM_9 [UIColor colorWithRed:154.0f/255.0f green:89.0f/255.0f blue:181.0f/255.0f alpha:1.0f]
#define COLOR_ITEM_10 [UIColor colorWithRed:235.0f/255.0f green:79.0f/255.0f blue:147.0f/255.0f alpha:1.0f]
#define COLOR_ITEM_11 [UIColor colorWithRed:127.0f/255.0f green:140.0f/255.0f blue:141.0f/255.0f alpha:1.0f]

#define CALENDAR_COLORS @[COLOR_ITEM_0, COLOR_ITEM_1, COLOR_ITEM_2, COLOR_ITEM_3, COLOR_ITEM_4, COLOR_ITEM_5, COLOR_ITEM_6, COLOR_ITEM_7, COLOR_ITEM_8, COLOR_ITEM_9, COLOR_ITEM_10, COLOR_ITEM_11]

//mail labels

#define LABEL_ALL       @"all"
#define LABEL_SENT      @"sent"
#define LABEL_INBOX     @"inbox"
#define LABEL_IMPORTANT @"important"
#define LABEL_TRASH     @"trash"
#define LABEL_SPAM      @"spam"
#define LABEL_DRAFTS    @"drafts"


#define DEFAULT_HTML_TEXT(_object_) [NSString stringWithFormat:@"<!DOCTYPE html>\
<html>\
<head>\
<style>\
.highlighted { border-bottom:1px solid #bad8ec; }\
td.slot div a {color: white; font-size: 13px; text-decoration:none;}\
td.slot div {background: #5AC4B4; height: 24px; -moz-border-radius: 50px; -webkit-border-radius: 50px; border-radius: 50px; }\
td.slot {height: 36px;}\
</style>\
<script>\
function setScale(scale){\
var all_metas=document.getElementsByTagName('meta');\
if (all_metas){\
    var k;\
    for (k=0; k<all_metas.length;k++){\
        var meta_tag=all_metas[k];\
        var viewport= meta_tag.getAttribute('name');\
        if (viewport && viewport=='viewport') {\
            meta_tag.setAttribute('content','width=device-width; initial-scale='+scale+';');\
        }\
    }\
}\
}\
</script>\
</head>\
<body>\
<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\" />\
%@</body>\
</html>", _object_]


#define ATTACHMENT_ROW_HEIGHT 40

#define SWIPE_OPTIONS @{@"none":@"None", @"archive":@"Archive", @"mark_as_read_and_archive":@"Mark as Read and Archive", @"delete":@"Delete", @"schedule":@"Schedule", @"move":@"Move", @"mark_as_read_or_unread":@"Mark as Read or Unread", @"flag":@"Flag"}


// ACCOUNT CONSTANTS
#define ACCOUNT_TYPE_EMAIL @"email"
#define ACCOUNT_TYPE_CLOUD @"cloud"

#define ACCOUNT_PROVIDER_EMAIL_GMAIL @"gmail"
#define ACCOUNT_PROVIDER_EMAIL_YAHOO @"yahoo"
#define ACCOUNT_PROVIDER_EMAIL_EAS @"eas"
#define ACCOUNT_PROVIDER_EMAIL_OUTLOOK @"outlook"
#define ACCOUNT_PROVIDER_EMAIL_ICLOUD @"icloud"
#define ACCOUNT_PROVIDER_EMAIL_CUSTOME @"custom"
#define ACCOUNT_PROVIDER_CLOUD_GOOGLEDRIVE @"googledrive"
#define ACCOUNT_PROVIDER_CLOUD_ONEDRIVE @"onedrive"
#define ACCOUNT_PROVIDER_CLOUD_DROPBOX @"dropbox"
#define ACCOUNT_PROVIDER_CLOUD_BOX @"box"
#define ACCOUNT_PROVIDER_CLOUD_EVERNOTE @"evernote"
#define ACCOUNT_PROVIDER_CLOUD_SALESFORCE @"salesforce"

#define CONTACT_TYPE_ALL @"all"
#define CONTACT_TYPE_PHONE @"phone"
#define CONTACT_TYPE_EMAIL @"email"
#define CONTACT_TYPE_SALESFORCE @"salesforce"

#define PLANCK_EVERNOTE_NOTEBOOK_NAME @"Planck Notebook"

#define TELL_ABOUT_MESSAGE @"Hi,\nI've started using a great new app called PlanckMail for email on my iPhone.\nPlanckMail is super app."

#define PHONE_TITLES @[@"mobile",@"home",@"office"]
#define kPhoneTitle @"phone_title"
#define kPhoneNumber @"phone_number"


#pragma mark Email Tracking Constants
#define EMAIL_TRACKING_OPENED @"opened"
#define EMAIL_TRACKING_UNOPENED @"unopened"
#define EMAIL_TRACKING_TODAY @"today"
#define EMAIL_TRACKING_LAST7 @"last7"
#define EMAIL_TRACKING_LAST31 @"last31"


#define orderByFolder @{@"inbox":@"1", @"sent":@"2", @"archive":@"3", @"trash":@"4", @"drafts":@"5", @"outbox":@"6", @"spam":@"7", @"junk": @"8", @"important":@"9", @"all":@"10"};


#endif
