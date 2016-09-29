//
//  PMEventModel.h
//  planckMailiOS
//
//  Created by admin on 9/21/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DBCalendar.h"
typedef NS_ENUM(NSInteger, EventDateType) {
    EventDateDateType,
    EventDateTimeType,
    EventDateTimespanType,
    EventDateDatespanType
};

@interface PMEventModel : NSObject <NSSecureCoding>
@property(nonatomic, copy) NSString *id;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *location;
@property(nonatomic, copy) NSString *calendarId;
@property(nonatomic, copy) NSString *startTime;
@property(nonatomic, copy) NSString *endTime;
@property(nonatomic, copy) NSString *eventDescription;
@property(nonatomic, strong) NSArray *participants;
@property(nonatomic, copy) NSString *owner;
@property(nonatomic, copy) NSDate *alertTime;
@property(nonatomic, copy) NSString *alertMessage;
@property(nonatomic, assign) EventDateType eventDateType;
@property(nonatomic, assign) BOOL notifyParticipants;
@property(nonatomic, assign) BOOL readonly;

@property(nonatomic, copy) NSString *messageId;
@property(nonatomic, copy) NSString *accountId;

- (instancetype)initWithDictionary:(NSDictionary *)eventDictionary;
- (NSDictionary*)convertDictionary;
- (NSDictionary*)getEventParams;

- (NSDate*)getStartDate;
- (NSDate*)getEndDate;

- (DBCalendar*)getCalendar;

- (UIColor*)getColor;

- (BOOL)isEqualToEvent:(PMEventModel*)event;
@end
