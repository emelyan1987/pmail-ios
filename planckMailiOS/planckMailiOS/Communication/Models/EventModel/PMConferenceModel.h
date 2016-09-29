//
//  PMConferenceModel.h
//  planckMailiOS
//
//  Created by LionStar on 2/4/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PMEventModel.h"


@interface PMConferenceModel : NSObject

-(instancetype)initFromEventModel:(PMEventModel*)eventModel;
@property (nonatomic, strong) NSString *link;

@property (nonatomic, assign) NSDate *startTime;
@property (nonatomic, assign) NSDate *endTime;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *organizerName;
@property (nonatomic, strong) NSString *organizerEmail;
@property (nonatomic, strong) NSMutableArray *participants;
@property (nonatomic, strong) NSString *eventId;

@end
