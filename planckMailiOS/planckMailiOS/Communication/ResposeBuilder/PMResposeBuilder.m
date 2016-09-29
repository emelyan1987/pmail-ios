//
//  PMResposeBuilder.m
//  planckMailiOS
//
//  Created by Lyubomyr Hlozhyk on 10/11/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMResposeBuilder.h"
#import "PMEventModel.h"

@implementation PMResposeBuilder

+ (NSArray *)fetchListOfEventDayWithEvents:(NSArray *)events minDate:(NSDate *)minDate maxDate:(NSDate *)maxDate {
    
    
    NSMutableArray *lResultEventDayArray = [NSMutableArray array];
    

    
    lResultEventDayArray = [@[minDate] mutableCopy];
    
    
    NSCalendar *gregorianCalendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                        fromDate:minDate
                                                          toDate:maxDate
                                                         options:0];
    
    for (int i = 1; i < components.day; ++i) {
        NSDateComponents *newComponents = [NSDateComponents new];
        newComponents.day = i;
        
        NSDate *date = [gregorianCalendar dateByAddingComponents:newComponents
                                                          toDate:minDate
                                                         options:0];
        [lResultEventDayArray addObject:date];
    }
    
    [lResultEventDayArray addObject:minDate];
    
    
    
    if([events isKindOfClass:[NSArray class]]) {
        for(NSDictionary *eventDict in events) {
            PMEventModel *eventModel = [[PMEventModel alloc] initWithDictionary:eventDict];
            [lResultEventDayArray addObject:eventModel];
        }
    }
    
    return nil;
}

@end
