//
//  PMAccountManager.m
//  planckMailiOS
//
//  Created by LionStar on 12/28/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMAccountManager.h"
#import "Config.h"

@implementation PMAccountManager

+(PMAccountManager*)sharedManager{
    static PMAccountManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedManager = [PMAccountManager new];
    });
    return sharedManager;
    
}


-(NSString*)iconNameByProvider:(NSString*)provider
{
    if([provider isEqualToString:ACCOUNT_PROVIDER_EMAIL_EAS])
        return @"account_exchange_icon";
    else if([provider isEqualToString:ACCOUNT_PROVIDER_EMAIL_OUTLOOK])
        return @"account_outlook_icon";
    else if([provider isEqualToString:ACCOUNT_PROVIDER_EMAIL_GMAIL])
        return @"account_gmail_icon";
    else if([provider isEqualToString:ACCOUNT_PROVIDER_EMAIL_ICLOUD])
        return @"account_icloud_icon";
    else if([provider isEqualToString:ACCOUNT_PROVIDER_EMAIL_YAHOO])
        return @"account_yahoo_icon";
    else if([provider isEqualToString:ACCOUNT_PROVIDER_CLOUD_DROPBOX])
        return @"account_dropbox_icon";
    else if([provider isEqualToString:ACCOUNT_PROVIDER_CLOUD_BOX])
        return @"account_box_icon";
    else if([provider isEqualToString:ACCOUNT_PROVIDER_CLOUD_ONEDRIVE])
        return @"account_onedrive_icon";
    else if([provider isEqualToString:ACCOUNT_PROVIDER_CLOUD_GOOGLEDRIVE])
        return @"account_googledrive_icon";
    else if([provider isEqualToString:ACCOUNT_PROVIDER_CLOUD_EVERNOTE])
        return @"account_evernote_icon";
    else if([provider isEqualToString:ACCOUNT_PROVIDER_CLOUD_SALESFORCE])
        return @"account_salesforce_icon";
    
    return @"account_all_icon";
}
@end
