//
//  PMConferenceModel.m
//  planckMailiOS
//
//  Created by LionStar on 2/4/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import "PMConferenceModel.h"
#import "DBMessage.h"
#import "PMParticipantModel.h"

@implementation PMConferenceModel

-(instancetype)initFromEventModel:(PMEventModel *)eventModel
{
    if(self)
    {
        self.startTime = [NSDate dateWithTimeIntervalSince1970:[eventModel.startTime doubleValue]];
        self.endTime = [NSDate dateWithTimeIntervalSince1970:[eventModel.endTime doubleValue]];
        
        self.title = eventModel.title;
        
        
        self.participants = [NSMutableArray new];
        if(eventModel.messageId)
        {
            DBMessage *message = [DBMessage getMessageWithId:eventModel.messageId];
            
            if(message)
            {                
                NSDictionary *from = [message getFrom];
                NSString *name = from[@"name"];
                NSString *email = from[@"email"];
                
                self.organizerName = name;
                self.organizerEmail = email;
                
                PMParticipantModel *organizer = [[PMParticipantModel alloc] initWithDictionary:@{@"name":name, @"email":email}];
                
                organizer.isOrganizer = YES;
                [self.participants addObject:organizer];
            }
        }
        [self.participants addObjectsFromArray:eventModel.participants];
        
        self.eventId = eventModel.id;
        return self;
    }
    
    return nil;
}
@end
