//
//  PMEventModel.m
//  planckMailiOS
//
//  Created by admin on 9/21/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMEventModel.h"
#import "PMParticipantModel.h"
#import "NSDate+DateConverter.h"
#import "DBManager.h"
#import "Global.h"
#import "Config.h"

@interface PMEventModel ()
- (id)whenEventTakePlaceParams;
- (id)partisipantsParams;
- (EventDateType)eventTypeForObject:(NSString *)object;
@end

@implementation PMEventModel

- (instancetype)init {
    self = [super init];
    if (self) {
        [self defaultInit];
    }
    return self;
}
- (instancetype)initWithDictionary:(NSDictionary *)eventDictionary {
    self = [super init];
    if(self) {
        
        //event info
        self.id = notNullStrValue(eventDictionary[@"id"]);
        self.title = notNullStrValue(eventDictionary[@"title"]);
        self.location = notNullStrValue(eventDictionary[@"location"]);

        NSString *calendarId = eventDictionary[@"calendar_id"];
        if(![calendarId isEqual:[NSNull null]])
        {
            
            self.calendarId = calendarId;
        }
        
        
        self.eventDescription = notNullStrValue(eventDictionary[@"description"]);
        self.owner = notNullStrValue(eventDictionary[@"owner"]);
        
        _readonly = [eventDictionary[@"read_only"] boolValue];
        
        //init event participants
        NSMutableArray *participantsModels = [NSMutableArray new];
        NSArray *participants = eventDictionary[@"participants"];
        if ([participants count] > 0) {
            for(NSDictionary *participant in participants) {
                PMParticipantModel *participantModel = [[PMParticipantModel alloc] initWithDictionary:participant];
                [participantsModels addObject:participantModel];
            }
        }
        self.participants = participantsModels;
        
        //event date or time
        NSDictionary *whenDict = eventDictionary[@"when"];
        self.eventDateType = [self eventTypeForObject:whenDict[@"object"]];
        
        switch (_eventDateType) {
            case EventDateTimeType:
                self.startTime = [whenDict[@"time"] stringValue];
                self.endTime = [whenDict[@"time"] stringValue];
                
                break;
                
            case EventDateTimespanType:
                self.startTime = [whenDict[@"start_time"] stringValue];
                self.endTime = [whenDict[@"end_time"] stringValue];
                
                break;
                
            case EventDateDateType:
                self.startTime = whenDict[@"date"];
                self.endTime = whenDict[@"date"];
                
                break;
                
            case EventDateDatespanType:
                self.startTime = whenDict[@"start_date"];
                self.endTime = whenDict[@"end_date"];
                
                break;
                
            default:
                break;
        }
        
        self.messageId = notNullStrValue(eventDictionary[@"message_id"]);
        self.accountId = notNullStrValue(eventDictionary[@"account_id"]);
    }
    return self;
}

- (NSDictionary*)convertDictionary
{
    return @{@"title":self.title, @"start_time":self.startTime, @"end_time":self.endTime, @"location":self.location, @"event_description":self.eventDescription,@"owner":self.owner, @"participants":[self getParticipantsArray]};
}

- (NSArray*)getParticipantsArray
{
    NSMutableArray *participantsArray = [NSMutableArray new];
    for(PMParticipantModel *participant in self.participants)
    {
        [participantsArray addObject:[participant convertToDictionary]];
    }
    
    return participantsArray;
}

- (void)defaultInit {
    self.title = @"";
    self.location = @"";
    self.calendarId = @"";
    self.eventDescription = @"";
    self.owner = @"";
    self.participants = @[];
    self.eventDateType = EventDateTimespanType;
    self.alertTime = nil;
    _readonly = NO;
}

#pragma mark - Public methods

- (NSDictionary *)getEventParams {
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    if(_title) [params setObject:_title forKey:@"title"];
    if(_eventDescription) [params setObject:_eventDescription forKey:@"description"];
    NSDictionary *whenParams = [self whenEventTakePlaceParams];
    if(whenParams) [params setObject:whenParams forKey:@"when"];
    if(_location) [params setObject:_location forKey:@"location"];
    if(_calendarId) [params setObject:_calendarId forKey:@"calendar_id"];
    if(_participants) [params setObject:_participants forKey:@"participants"];
    if(_owner) [params setObject:_owner forKey:@"owner"];
    
    return params;
}

#pragma mark - Private methods

- (EventDateType)eventTypeForObject:(NSString *)object {
    EventDateType eventDateType = EventDateDateType;
    
    if ([object isEqualToString:@"time"]) {
        eventDateType = EventDateTimeType;
    } else if ([object isEqualToString:@"timespan"]) {
        eventDateType = EventDateTimespanType;
    } else if ([object isEqualToString:@"datespan"]) {
        eventDateType = EventDateDatespanType;
    }
    
    return eventDateType;
}

- (id)whenEventTakePlaceParams {
    
    if(_eventDateType == EventDateDatespanType || _eventDateType == EventDateDateType)
    {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *startDate = [dateFormatter dateFromString:_startTime];
        NSDate *endDate = [dateFormatter dateFromString:_endTime];
        NSTimeInterval interval = [endDate timeIntervalSinceDate:startDate];
        if(interval > 24)
        {
            return @{@"start_date": [dateFormatter stringFromDate:startDate], @"end_date": [dateFormatter stringFromDate:endDate]};
        }
        return @{@"date": [dateFormatter stringFromDate:startDate]};
    }
    else
    {
        NSDate *startTime = [NSDate dateWithTimeIntervalSince1970:[_startTime doubleValue]];
        NSDate *endTime = [NSDate dateWithTimeIntervalSince1970:[_endTime doubleValue]];
        
        NSTimeInterval interval = [endTime timeIntervalSinceDate:startTime];
        if(interval == 0)
        {
            return @{@"time": [NSString stringWithFormat:@"%f", [startTime timeIntervalSince1970]]};
        }
        
        return @{@"start_time": [NSString stringWithFormat:@"%f", [startTime timeIntervalSince1970]], @"end_time": [NSString stringWithFormat:@"%f", [endTime timeIntervalSince1970]]};
    }
    
}


- (id)partisipantsParams {
    return @[
//             @{
//                 @"email": @"lyubomyr.hlozhyk@gmail.com",
//                 @"name": @"Lyubomyr Hlozhyk",
//                 @"status" : @"yes"
//                 }
             ];
}


- (NSDate*)getStartDate
{
    NSDate *date;
    if(_eventDateType == EventDateDatespanType || _eventDateType == EventDateDateType)
    {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        date = [dateFormatter dateFromString:_startTime];
    }
    else
    {
        date = [NSDate dateWithTimeIntervalSince1970:[_startTime doubleValue]];
    }
    
    return date;
}

- (NSDate*)getEndDate
{
    NSDate *date;
    if(_eventDateType == EventDateDatespanType || _eventDateType == EventDateDateType)
    {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        date = [dateFormatter dateFromString:_endTime];
    }
    else
    {
        date = [NSDate dateWithTimeIntervalSince1970:[_endTime doubleValue]];
    }
    
    return date;
}

- (DBCalendar*)getCalendar
{
    return [DBCalendar getCalendarWithId:self.calendarId];
}

- (UIColor*)getColor
{
    DBCalendar *calendar = [self getCalendar];
    UIColor *color = [UIColor colorWithRed:90.0f/255.0f green:196.0f/255.0f blue:180.0f/255.0f alpha:1.0f];
    if (calendar) {
        UIColor *calendarColor = [CALENDAR_COLORS objectAtIndex:[calendar.color integerValue]];
        color = calendarColor;
    }
    
    return color;
}

-(BOOL)isEqualToEvent:(PMEventModel *)event
{
    if(![self.id isEqualToString:event.id]) return NO;
    else if(![self.title isEqualToString:event.title]) return NO;
    else if(![self.location isEqualToString:event.location]) return NO;
    else if(![self.eventDescription isEqualToString:event.eventDescription]) return NO;
    else if(self.eventDateType!=event.eventDateType) return NO;
    else if(![self.calendarId isEqualToString:event.calendarId]) return NO;
    else if(![self.startTime isEqualToString:event.startTime]) return NO;
    else if(![self.endTime isEqualToString:event.endTime]) return NO;
    
    else if(self.participants.count!=event.participants.count) return NO;
    
    for(PMParticipantModel *participant in event.participants)
    {
        if(![self containsParticipant:participant]) return NO;
    }
    
    return YES;
}

/**
 * check if event includes specified participant.
 *
 * @param:   PMParticipantModel *participant
 *
 * @return:     if includes return true, else false
 */
-(BOOL) containsParticipant:(PMParticipantModel*)participant
{
    for(PMParticipantModel *item in self.participants)
    {
        if([item.email isEqualToString:participant.email]) return YES;
    }
    
    return NO;
}
+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_id forKey:@"id"];
    [aCoder encodeObject:_title forKey:@"title"];
    [aCoder encodeObject:_location forKey:@"location"];
    [aCoder encodeObject:_calendarId forKey:@"calendarId"];
    [aCoder encodeObject:_startTime forKey:@"startTime"];
    [aCoder encodeObject:_endTime forKey:@"endTime"];
    [aCoder encodeObject:_eventDescription forKey:@"eventDescription"];
    [aCoder encodeObject:_participants forKey:@"participants"];
    [aCoder encodeObject:_owner forKey:@"owner"];
    [aCoder encodeObject:_alertTime forKey:@"alertTime"];
    [aCoder encodeInteger:_eventDateType forKey:@"eventDateType"];
    [aCoder encodeBool:_notifyParticipants forKey:@"notifyParticipants"];
    [aCoder encodeBool:_readonly forKey:@"readOnly"];

}

- (id)initWithCoder:(NSCoder *)aDecoder {
    PMEventModel *newMail = [PMEventModel new];
    
    newMail.id = [aDecoder decodeObjectForKey:@"id"];
    newMail.title = [aDecoder decodeObjectForKey:@"title"];
    newMail.location = [aDecoder decodeObjectForKey:@"location"];
    newMail.calendarId = [aDecoder decodeObjectForKey:@"calendarId"];
    newMail.startTime = [aDecoder decodeObjectForKey:@"startTime"];
    newMail.endTime = [aDecoder decodeObjectForKey:@"endTime"];
    newMail.eventDescription = [aDecoder decodeObjectForKey:@"eventDescription"];
    newMail.participants = [aDecoder decodeObjectForKey:@"participants"];
    newMail.owner = [aDecoder decodeObjectForKey:@"owner"];
    newMail.alertTime = [aDecoder decodeObjectForKey:@"alertTime"];
    newMail.eventDateType = [aDecoder decodeIntegerForKey:@"eventDateType"];
    newMail.notifyParticipants = [aDecoder decodeBoolForKey:@"notifyParticipants"];
    newMail.readonly = [aDecoder decodeBoolForKey:@"readOnly"];

    return newMail;
}
@end
