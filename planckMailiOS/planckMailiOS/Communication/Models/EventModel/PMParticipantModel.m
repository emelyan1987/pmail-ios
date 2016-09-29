//
//  PMParticipantModel.m
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 9/22/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMParticipantModel.h"
#import "Global.h"

@implementation PMParticipantModel

- (instancetype)initWithDictionary:(NSDictionary *)object {
    if(self = [super init]) {
        self.comment = notNullStrValue(object[@"comment"]);
        self.email = notNullStrValue(object[@"email"]);
        self.name = notNullStrValue(object[@"name"]);
        self.status = notNullStrValue(object[@"status"]);
        self.statusType = [self statusTypeForStatus:_status];
    }
    return self;
}

- (ParticipantStatuType)statusTypeForStatus:(NSString *)status {
    ParticipantStatuType statusType = ParticipantNoreplyStatus;
    
    if([status isEqualToString:@"no"]) {
        statusType = ParticipantNoStatus;
    } else if([status isEqualToString:@"maybe"]) {
        statusType = ParticipantMaybeStatus;
    } else if([status isEqualToString:@"yes"]) {
        statusType = ParticipantYesStatus;
    }
    return statusType;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_comment forKey:@"comment"];
    [aCoder encodeObject:_email forKey:@"email"];
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_status forKey:@"status"];
    [aCoder encodeObject:[NSNumber numberWithInteger:_statusType] forKey:@"statusType"];


    
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    PMParticipantModel *newParticipant = [PMParticipantModel new];
    
    newParticipant.comment = [aDecoder decodeObjectForKey:@"comment"];
    newParticipant.email = [aDecoder decodeObjectForKey:@"email"];
    newParticipant.name = [aDecoder decodeObjectForKey:@"name"];
    newParticipant.status = [aDecoder decodeObjectForKey:@"status"];
    newParticipant.statusType = [[aDecoder decodeObjectForKey:@"statusType"] integerValue];


    
    return newParticipant;
}
- (NSDictionary*)convertToDictionary
{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    if(self.comment) [dict setObject:self.comment forKey:@"comment"];
    if(self.email) [dict setObject:self.email forKey:@"email"];
    if(self.name) [dict setObject:self.name forKey:@"name"];
    if(self.status) [dict setObject:self.status forKey:@"status"];
    
    return dict;
}
@end
