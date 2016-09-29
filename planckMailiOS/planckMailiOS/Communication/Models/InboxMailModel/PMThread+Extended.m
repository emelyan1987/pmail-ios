//
//  PMInboxMailModel(Extended).m
//  planckMailiOS
//
//  Created by LionStar on 2/11/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import "PMThread+Extended.h"
#import "DBSavedContact.h"
#import "PMMailManager.h"
#import "AppDelegate.h"
#import "PMSettingsManager.h"
#import "PMAPIManager.h"
#import "DBNamespace.h"
@implementation PMThread(Extended)


- (BOOL)isComeFromSalesforce
{
    NSArray *emailsFromSalesforce = [[PMSettingsManager instance] getSalesforceEmails];
    if(emailsFromSalesforce && emailsFromSalesforce.count)
    {        
        for(NSDictionary *participant in self.participants)
        {
            NSString *email = participant[@"email"];
            if([email isEqualToString:[PMAPIManager shared].namespaceId.email_address])
                continue;
            if([emailsFromSalesforce containsObject:email]) return YES;
        }
    }
    return NO;
}

//- (void)isComeFromSalesforce:(void(^)(BOOL value))handler
//{
//    NSMutableArray *emails = [NSMutableArray new];
//    for(NSDictionary *participant in self.participants)
//    {
//        NSString *email = participant[@"email"];
//        
//        [emails addObject:email];
//    }
//    [DBSavedContact getContactsWithEmailsInBackground:emails completion:^(NSArray *contacts) {
//        if(contacts && contacts.count)
//        {
//            BOOL isComeFromSalesforce = NO;
//            for(DBSavedContact *contact in contacts)
//            {
//                if([contact getContactTypeValue]==3) isComeFromSalesforce = YES;
//                break;
//            }
//            if(handler)
//                handler (isComeFromSalesforce);
//        }
//        
//        if(handler)
//            handler (NO);
//    }];
//}

- (BOOL)isReply
{
    DBNamespace *namespace = [DBNamespace getNamespaceWithAccountId:self.accountId];
    
    NSInteger cnt = 0;
    for(NSDictionary *participant in self.participants)
    {
        NSString *email = participant[@"email"];
        
        if([[email lowercaseString] isEqualToString:[namespace.email_address lowercaseString]]) cnt++;
    }
    
    return cnt>1 ? YES : NO;
}

-(void)getAdditionalInfo:(NSManagedObjectContext*)context completion:(void (^)(NSDictionary *info))handler
{
    [[PMMailManager sharedInstance] getAdditionalInfoWithThreadId:self.id context:context completion:^(NSDictionary *info) {
        if(handler)
            handler(info);
    }];
    
}
@end
