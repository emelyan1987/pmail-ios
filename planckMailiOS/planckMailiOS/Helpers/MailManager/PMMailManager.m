//
//  PMEventManager.m
//  planckMailiOS
//
//  Created by LionStar on 2/2/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import "PMMailManager.h"
#import "DBManager.h"
#import "DBMessage.h"
#import "PMEventModel.h"
#import "PMParticipantModel.h"
#import "PMAPIManager.h"
#import "PMSettingsManager.h"

@implementation PMMailManager
+(PMMailManager*)sharedInstance{
    static PMMailManager *instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [PMMailManager new];
    });
    return instance;
    
}

-(void)getAdditionalInfoWithThreadId:(NSString *)threadId context:(NSManagedObjectContext*)context completion:(void (^)(NSDictionary *))handler
{
    [[DBManager instance] getMailAdditionalInfoWithThreadIdInBackground:threadId context:context completion:^(DBMailAdditionalInfo *info) {
        if(info)
        {
            if(handler)
                handler([info convertToDictionary]);
        }
        else
        {
            if(handler) handler(nil);
        }
    }];
//    [[DBManager instance] getMessagesWithThreadIdInBackground:threadId context:context completion:^(NSArray *messages) {
//        if(messages && messages.count)
//        {
//            NSMutableDictionary *info = [NSMutableDictionary new];
//            DBMessage *message = messages[0];
//            
//            // First check whether come from salesforce contacts
//            NSArray *emailsFromSalesforce = [[PMSettingsManager instance] getSalesforceEmails];
//            if(emailsFromSalesforce && emailsFromSalesforce.count)
//            {
//                for(NSDictionary *from in [message getFromArray])
//                {
//                    NSString *email = from[@"email"];
//                    if([email isEqualToString:[PMAPIManager shared].namespaceId.email_address])
//                        continue;
//                    if([emailsFromSalesforce containsObject:email])
//                    {
//                        [info setObject:@(YES) forKey:@"salesforce"];
//                        break;
//                    }
//                }
//            }
//            
//            // Second check event invitation status
//            NSString *messageId = message.id;
//            DLog(@"DBMessageID: %@", messageId);
//            [[DBManager instance] getEventsWithMessageIdInBackground:messageId context:context completion:^(NSArray *events) {
//                if(events && events.count)
//                {
//                    DBEvent *event = events[0];
//                    
//                    PMEventModel *eventModel = [[PMEventModel alloc] initWithDictionary:[event convertToDictionary]];
//                    
//                    [info setObject:eventModel.startTime forKey:@"start_time"];
//                    [info setObject:eventModel.endTime forKey:@"end_time"];
//                    
//                    NSString *email = [[PMAPIManager shared] namespaceId].email_address;
//                    
//                    for(PMParticipantModel *participant in eventModel.participants)
//                    {
//                        if([participant.email isEqualToString:email])
//                        {
//                            [info setObject:participant.status forKey:@"status"];
//                            break;
//                        }
//                    }
//                }
//                
//                if(handler)
//                    handler(info);
//            }];
//
//        }
//        else
//        {
//            if(handler) handler(nil);
//        }
//    }];
    
    
}

-(void)getEventInfoWithMessageId:(NSString *)messageId completion:(void (^)(NSDictionary *))handler
{
    NSManagedObjectContext *context = [[DBManager instance] workerContext];
    [[DBManager instance] getEventsWithMessageIdInBackground:messageId context:context completion:^(NSArray *data) {
        if(data && data.count)
        {
            DBEvent *event = data[0];
            
            PMEventModel *eventModel = [[PMEventModel alloc] initWithDictionary:[event convertToDictionary]];
            
            
            NSString *email = [[PMAPIManager shared] namespaceId].email_address;
            NSString *status = @"";
            for(PMParticipantModel *participant in eventModel.participants)
            {
                if([participant.email isEqualToString:email])
                {
                    status = participant.status;
                    break;
                }
            }
            
            if(handler)
                handler(@{
                          @"start_time": eventModel.startTime,
                          @"end_time": eventModel.endTime,
                          @"status": status
                          });
            
            return;
        }
    }];
}

-(NSString*)getFormattedDuration:(NSTimeInterval)interval
{
    
    NSInteger seconds = interval;
    NSInteger days = interval/(3600*24);
    seconds -= days*3600*24;
    NSInteger hours = seconds/3600;
    seconds -= hours*3600;
    NSInteger mins = seconds/60;
    
    NSMutableString *durationText = [NSMutableString new];
    
    if(days>0) [durationText appendFormat:@"%dd", (int)days];
    if(hours>0) (durationText.length>0)?[durationText appendFormat:@" %dh", (int)hours]:[durationText appendFormat:@"%dh", (int)hours];
    if(mins>0) (durationText.length>0)?[durationText appendFormat:@" %dm", (int)mins]:[durationText appendFormat:@"%dm", (int)mins];
    
    return durationText;
    
}
@end
