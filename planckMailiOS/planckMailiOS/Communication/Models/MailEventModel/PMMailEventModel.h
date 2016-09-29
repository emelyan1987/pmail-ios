//
//  PMMailEventModel.h
//  planckMailiOS
//
//  Created by LionStar on 12/23/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PMMailEventModel : NSObject
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *location;
@property(nonatomic, strong) NSArray *participants;
@property(nonatomic, copy) NSString *owner;
@property(nonatomic, copy) NSString *timeText;
@property(nonatomic, assign) NSTimeInterval time;
@property(nonatomic, assign) NSInteger duration;    //minutes
@property(nonatomic, copy) NSString *durationText;

- (NSDictionary*)getEventParams;

- (NSString*)getDurationText;

- (NSString*)getTimeText;
@end
