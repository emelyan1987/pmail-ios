//
//  PMRSVPManager.m
//  planckMailiOS
//
//  Created by LionStar on 2/2/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import "PMRSVPManager.h"
#import "DBManager.h"
#import "AlertManager.h"
#import "PMAPIManager.h"

@implementation PMRSVPManager
+ (PMRSVPManager *)sharedInstance {
    static PMRSVPManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [PMRSVPManager new];
    });
    return instance;
}

-(void)sendRSVPByMessageId:(NSString *)messageId type:(RSVP_TYPE)type completion:(void(^)(id data, NSError *error))handler
{
    DBMessage *dbMessage = [DBMessage getMessageWithId:messageId];
    
    if(dbMessage)
    {
        NSDictionary *message = [dbMessage convertToDictionary];
        
        NSArray *events = message[@"events"];
        if(events && events.count)
        {
            NSString *eventId = events[0][@"id"];
            [self sendRSVP:eventId type:type completion:handler];
        }
    }
    
}

-(void)sendRSVP:(NSString *)eventId type:(RSVP_TYPE)type completion:(void(^)(id data, NSError *error))handler
{
    NSString *status;
    NSString *comment;
    if(type==RSVP_TYPE_ACCEPT)
    {
        status = @"yes";
        comment = [NSString stringWithFormat:@"%@ has accepted this meeting.", [[PMAPIManager shared] namespaceId].email_address];
    }
    else if(type==RSVP_TYPE_TENTATIVE)
    {
        status = @"maybe";
        comment = [NSString stringWithFormat:@"%@ has tentatively accepted this meeting.", [[PMAPIManager shared] namespaceId].email_address];
    }
    else if(type==RSVP_TYPE_DECLINE)
    {
        status = @"no";
        comment = [NSString stringWithFormat:@"%@ has declined this meeting.", [[PMAPIManager shared] namespaceId].email_address];
    }
    
    
    NSDictionary *params = @{
                             @"event_id" : eventId,
                             @"status" : status,
                             @"comment" : comment
                             };
    
    NSDate *issuedTime = [NSDate date];
    [AlertManager showStatusBarWithMessage:@"Sending RSVP...." type:ACTIVITY_STATUS_TYPE_PROGRESS time:issuedTime];
    [[PMAPIManager shared] sendRSVP:params completion:^(id data, id error, BOOL success)
    {
        [AlertManager hideStatusBar:issuedTime];
        if (success) {
            
            [AlertManager showStatusBarWithMessage:@"RSVP sent." type:ACTIVITY_STATUS_TYPE_INFO time:nil];
            
            if(handler) handler(data, nil);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_EVENT_UPDATED object:nil];
                
        }
        else
        {
            [AlertManager showStatusBarWithMessage:@"Sending RSVP failed." type:ACTIVITY_STATUS_TYPE_ERROR time:nil];
            if(handler) handler(nil, error);
        }
        
    }];
}
@end
