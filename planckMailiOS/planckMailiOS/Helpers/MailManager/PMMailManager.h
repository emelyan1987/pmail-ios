//
//  PMEventManager.h
//  planckMailiOS
//
//  Created by LionStar on 2/2/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PMThread.h"


@interface PMMailManager : NSObject
+(PMMailManager*)sharedInstance;

/**
 *  Get event information for thread
 *  @param (NSString*)threadId: Mail thread unique identifier
 *  @return (NSDictionary*): returns event information with the following format
 *                           @{
 *                              @"start_time": @"1454247669",
 *                              @"end_time": @"1454247669",
 *                              @"status": @"noreply/yes/no/maybe"
 *                            }
 *
 *
 */
-(void)getAdditionalInfoWithThreadId:(NSString*)threadId context:(NSManagedObjectContext*)context completion:(void(^)(NSDictionary*info))handler;
-(void)getEventInfoWithMessageId:(NSString *)messageId completion:(void(^)(NSDictionary*info))handler;
-(NSString*)getFormattedDuration:(NSTimeInterval)interval;
@end
