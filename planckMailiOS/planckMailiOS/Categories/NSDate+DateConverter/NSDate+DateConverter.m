//
//  NSDate+DateConverter.m
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 7/16/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#define SecondsPerDay 86400
#define DaysPerYear 365

#import "NSDate+DateConverter.h"

@implementation NSDate (DateConverter)

#pragma mark - Public methods

- (NSString *)convertedStringValue {
  NSString *convertedValue = @"";
  
  NSString *dateFormaterString = @"";
  NSLocale *locale = [NSLocale currentLocale];
  NSInteger days = [self daysBetween:[NSDate date]];
  if(days == 0) {
    dateFormaterString = [NSDateFormatter dateFormatFromTemplate:@"hh:mm a" options:0 locale:locale];
  } else if (days < DaysPerYear) {
    dateFormaterString = [NSDateFormatter dateFormatFromTemplate:@"MMM dd" options:0 locale:locale];
  } else {
    dateFormaterString = [NSDateFormatter dateFormatFromTemplate:@"MMM dd, yyy" options:0 locale:locale];
  }
  
  NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
  [dateFormater setDateFormat:dateFormaterString];
  convertedValue = [dateFormater stringFromDate:self];
  
  return convertedValue;
}

- (NSString *)timeStringValue {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    return [dateFormatter stringFromDate:self];
}
- (NSString *)readableTimeString {
    NSString *convertedValue = [self stringDateForDateFormat:@"hh:mm a"];
    return [convertedValue lowercaseString];
}
- (NSString *)dateStringValue {
    NSString *convertedValue = [self stringDateForDateFormat:@"YYYY-MM-dd"];
    return convertedValue;
}

-(NSString*)relativeDateTimeString
{
    NSDate *aDate = self;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned int unitFlags =  NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitWeekOfMonth|NSCalendarUnitWeekdayOrdinal|NSCalendarUnitWeekday|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute;
    NSDateComponents *messageDateComponents = [calendar components:unitFlags fromDate:aDate];
    NSDateComponents *todayDateComponents = [calendar components:unitFlags fromDate:[NSDate date]];
    
    NSUInteger dayOfYearForMessage = [calendar ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitYear forDate:aDate];
    NSUInteger dayOfYearForToday = [calendar ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitYear forDate:[NSDate date]];
    
    
    
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    
    if ([messageDateComponents year] == [todayDateComponents year] && [messageDateComponents month] == [todayDateComponents month] && [messageDateComponents day] == [todayDateComponents day])
    {
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        return [dateFormatter stringFromDate:self];
    }
    else if ([messageDateComponents year] == [todayDateComponents year] && dayOfYearForMessage == (dayOfYearForToday-1))
    {
        return @"Yesterday";
    }
    else if ([messageDateComponents year] == [todayDateComponents year] && dayOfYearForMessage > (dayOfYearForToday-6))
    {
        [dateFormatter setDateFormat:@"EEEE"];
        return [dateFormatter stringFromDate:aDate];
    }
    else
    {
        
        NSString *localeFormatString = [NSDateFormatter dateFormatFromTemplate:@"ddMMyy" options:0 locale:dateFormatter.locale];
        [dateFormatter setDateFormat:localeFormatString];
        
        return [dateFormatter stringFromDate:self];
    }
    
}

-(NSString*)relativeDateString
{
    NSDate *aDate = self;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned int unitFlags =  NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitWeekOfMonth|NSCalendarUnitWeekdayOrdinal|NSCalendarUnitWeekday|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute;
    NSDateComponents *messageDateComponents = [calendar components:unitFlags fromDate:aDate];
    NSDateComponents *todayDateComponents = [calendar components:unitFlags fromDate:[NSDate date]];
    
    NSUInteger dayOfYearForMessage = [calendar ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitYear forDate:aDate];
    NSUInteger dayOfYearForToday = [calendar ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitYear forDate:[NSDate date]];
    
    
    NSString *dateString;
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"EEEE, MMMM dd"];
    NSString *originDateString = [dateFormatter stringFromDate:aDate];
    
    if ([messageDateComponents year] == [todayDateComponents year] && [messageDateComponents month] == [todayDateComponents month] && [messageDateComponents day] == [todayDateComponents day])
    {
        dateString = [NSString stringWithFormat:@"Today - %@", originDateString];
    }
    else if ([messageDateComponents year] == [todayDateComponents year] && dayOfYearForMessage == (dayOfYearForToday+1))
    {
        dateString = [NSString stringWithFormat:@"Tomorrow - %@", originDateString];
    }
    else if ([messageDateComponents year] == [todayDateComponents year] && dayOfYearForMessage == (dayOfYearForToday-1))
    {
        dateString = [NSString stringWithFormat:@"Yesterday - %@", originDateString];
    }
    else
    {
        dateString = [NSString stringWithString:originDateString];
    }
    return [dateString uppercaseString];
}

-(NSString*)readableDateString
{
    NSDate *aDate = self;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned int unitFlags =  NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitWeekOfMonth|NSCalendarUnitWeekdayOrdinal|NSCalendarUnitWeekday|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute;
    NSDateComponents *messageDateComponents = [calendar components:unitFlags fromDate:aDate];
    NSDateComponents *todayDateComponents = [calendar components:unitFlags fromDate:[NSDate date]];
    
    NSUInteger dayOfYearForMessage = [calendar ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitYear forDate:aDate];
    NSUInteger dayOfYearForToday = [calendar ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitYear forDate:[NSDate date]];
    
    
    NSString *dateString;
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"EEEE, MMM dd"];
    NSString *originDateString = [dateFormatter stringFromDate:aDate];
    
    if ([messageDateComponents year] == [todayDateComponents year] && [messageDateComponents month] == [todayDateComponents month] && [messageDateComponents day] == [todayDateComponents day])
    {
        dateString = @"Today";
    }
    else if ([messageDateComponents year] == [todayDateComponents year] && dayOfYearForMessage == (dayOfYearForToday+1))
    {
        dateString = @"Tomorrow";
    }
    else if ([messageDateComponents year] == [todayDateComponents year] && dayOfYearForMessage == (dayOfYearForToday-1))
    {
        dateString = @"Yesterday";
    }
    else
    {
        dateString = originDateString;
    }
    return dateString;
}
+ (NSDate *)eventDateFromString:(NSString *)string {
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"YYYY-MM-dd"];
    
    NSDate *date = [dateFormater dateFromString:string];
    return date;
}

+ (NSDate *)eventDateFromString:(NSString *)string dateFormat:(NSString*)dateFormat {
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:dateFormat];
    
    NSDate *date = [dateFormater dateFromString:string];
    return date;
}


#pragma mark - Private methods

- (NSUInteger)daysBetween:(NSDate *)date {
  NSDate *dt1 = [self dateWithoutTimeComponents];
  NSDate *dt2 = [date dateWithoutTimeComponents];
  return ABS([dt1 timeIntervalSinceDate:dt2] / SecondsPerDay);
}

- (NSComparisonResult)timelessCompare:(NSDate *)date {
  NSDate *dt1 = [self dateWithoutTimeComponents];
  NSDate *dt2 = [date dateWithoutTimeComponents];
  return [dt1 compare:dt2];
}

- (NSDate *)dateWithoutTimeComponents {
  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSDateComponents *components = [calendar components:NSCalendarUnitYear  |
                                  NSCalendarUnitMonth |
                                  NSCalendarUnitDay
                                             fromDate:self];
  return [calendar dateFromComponents:components];
}

- (NSString *)stringDateForDateFormat:(NSString *)dateFormat {
    NSString *convertedValue = @"";
    
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:dateFormat];
    convertedValue = [dateFormater stringFromDate:self];
    
    return convertedValue;
}

- (NSInteger)getDay
{
    NSDateComponents *dateComponent = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:self];
    
    return dateComponent.day;
}

- (NSString*)formattedDateString:(NSString *)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    
    return [dateFormatter stringFromDate:self];
}
@end
