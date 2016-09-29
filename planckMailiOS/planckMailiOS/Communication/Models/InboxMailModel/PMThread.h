//
//  PMInboxMailModel.h
//  planckMailiOS
//
//  Created by admin on 5/25/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PMAccountProtocol.h"

typedef NS_ENUM(NSInteger, ScheduleDateType) {
    LaterToday,
    ThisEvening,
    Tomorrow,
    ThisWeekend,
    NextWeek,
    InAMonth,
    Someday,
    PickADate
};

@interface PMThread : NSObject <NSSecureCoding, PMAccountProtocol>

@property(nonatomic, copy) NSString *id;
@property(nonatomic, copy) NSString *accountId;
@property(nonatomic, copy) NSString *ownerName;
@property(nonatomic, copy) NSString *ownerEmail;
@property(nonatomic, copy) NSString *snippet;
@property(nonatomic, copy) NSString *subject;
@property(nonatomic, copy) NSString *lastMessageTimestamp;
@property(nonatomic, copy) NSString *token;
@property(nonatomic, copy) NSArray *messageIds;
@property(nonatomic, copy) NSArray *folders;
@property(nonatomic, copy) NSArray *participants;
@property(nonatomic, copy) NSDate *lastMessageDate;
@property(nonatomic, assign) NSUInteger version;

@property(nonatomic, copy) NSDate *snoozeDate;
@property(nonatomic, assign) ScheduleDateType snoozeDateType;

@property(nonatomic) BOOL isUnread;
@property(nonatomic) BOOL isFlagged;
@property(nonatomic) BOOL isLoadMore;
@property(nonatomic) BOOL hasAttachments;
@property(nonatomic) BOOL hasEvents;
@property(nonatomic) NSInteger messagesCount;

+ (PMThread *)initWithDicationary:(NSDictionary *)info ownerEmail:(NSString*)ownerEmail token:(NSString*)token;

- (BOOL)isReadLater;

- (NSString*)getParticipantNames;
- (NSArray*)getParticipantNamesExcludingMe;
- (NSArray*)getParticipantEmailsExcludingMe;

- (BOOL)belongsToFolder:(NSString*)folder;
@end
