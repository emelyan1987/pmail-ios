//
//  PMDateConverter.m
//  planckMailiOS
//
//  Created by nazar on 11/11/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMDateConverter.h"

@implementation PMDateConverter

+(PMDateConverter*)sharedInstance {

    static PMDateConverter *sharedManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[PMDateConverter alloc] init];
    });
    
    return sharedManager;
}

+(NSString*)getStringDateFromDate:(NSDate *)date {

    
    NSString *month = [[PMDateConverter sharedInstance] getMonthNameFromDate:date];
    
    NSString *year = [[PMDateConverter sharedInstance] getYearForDate:date];
    
    return [NSString stringWithFormat:@"%@ %@", month, year];
}

+(int)getDifferenceFromDate:(NSDate *)date {
    int currentDay = [[PMDateConverter sharedInstance] getCurrenDay];
    
    NSRange dayRange = [[NSCalendar currentCalendar]
                        rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    int difference = (int)dayRange.length - currentDay;
    
    return difference+31;
}

+(NSString*)getStringDateWithCustomFormatFromDate:(NSDate*)date {

    
    NSString *datek = [[PMDateConverter sharedInstance] getDateFromDate:date];
    
    
    return [NSString stringWithFormat:@"%@",datek];
}

-(NSString*)getDateFromDate:(NSDate*)date {

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"dd/MM/YYYY hh:mm a"];
    
    NSString *stringFromDate = [dateFormatter stringFromDate:date];
    
    
    return stringFromDate;
}

-(int)getCurrenDay{

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"d"];
    
    NSString *day = [dateFormatter stringFromDate:[NSDate date]];
    int currentDay = [day intValue];
    
    return currentDay;
}

-(NSString*)getYearForDate:(NSDate*)date {

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY"];
    
    NSString *year = [dateFormatter stringFromDate:date];
    
    return year;
}

-(NSString*)getMonthNameFromDate:(NSDate*)date {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM:YYYY"];
    
    NSString *month = [dateFormatter stringFromDate:date];
    int monthNumber = [month intValue];
    NSString *monthName = [dateFormatter monthSymbols][monthNumber-1];
    
    return monthName;
}

@end
