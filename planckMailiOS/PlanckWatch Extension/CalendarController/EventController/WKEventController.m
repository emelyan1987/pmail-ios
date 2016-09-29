//
//  WKEventController.m
//  planckMailiOS
//
//  Created by nazar on 11/13/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "WKEventController.h"
#import "WKEventRow.h"
#import "PMEventModel.h"
#import "PMParticipantModel.h"

@import UIKit;

@interface WKEventController ()
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceTable *tableView;

@end

@implementation WKEventController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    [self setTitle:@"Event"];
    
    
    [self configureTableWithContext:context];
   
    
    // Configure interface objects here.

    [self addMenuItemWithItemIcon:WKMenuItemIconAccept title:@"Going" action:@selector(goAction)];
    [self addMenuItemWithItemIcon:WKMenuItemIconDecline title:@"Decline" action:@selector(declineAction)];
    [self addMenuItemWithItemIcon:WKMenuItemIconMaybe title:@"Maybe" action:@selector(maybeAction)];
    
}

-(void)configureTableWithContext:(id)context {

    NSDictionary *event = context;
    
    [self.tableView setNumberOfRows:10 withRowType:@"eventRowType"];
    
    [self.eventTitleLabel setText:event[@"title"]];
    [self.eventDateLabel setText:[self getDateFromTimeIntervalString:event[@"start_time"]]];
    [self.eventTimeFrameLabel setText:[self getTimeFrameFromDate:event[@"start_time"] toDate:event[@"end_time"]]];
    [self.eventDurationLabel setText:[self getDurationFromDate:event[@"start_time"] toDate:event[@"end_time"]]];
    [self.eventLocationLabel setText:event[@"location"]];
    
    WKEventRow *eventRow1 = [self.tableView rowControllerAtIndex:0];
    
    [eventRow1.rowGroup setBackgroundColor:[UIColor clearColor]];
    [eventRow1.organizerNameLabel setAttributedText:[self attributedStringFromString:@"ORGANIZER"]];
    
    WKEventRow *eventRow2 = [self.tableView rowControllerAtIndex:1];
    [eventRow2.organizerNameLabel setText:event[@"owner"]];
    
    WKEventRow *eventRow3 = [self.tableView rowControllerAtIndex:2];
    [eventRow3.organizerNameLabel setAttributedText:[self attributedStringFromString:@"ACCEPTED"]];
    [eventRow3.rowGroup setBackgroundColor:[UIColor clearColor]];
    
    WKEventRow *eventRow4 = [self.tableView rowControllerAtIndex:3];
    NSString *joinedComponents = [[self getParticipiantsForType:ParticipantYesStatus fromAllParticipiants:event[@"participants"]] componentsJoinedByString:@","];
    [eventRow4.organizerNameLabel setText:joinedComponents];
    
    WKEventRow *eventRow5 = [self.tableView rowControllerAtIndex:4];
    [eventRow5.organizerNameLabel setAttributedText:[self attributedStringFromString:@"MAYBE"]];
    [eventRow5.rowGroup setBackgroundColor:[UIColor clearColor]];
    
    WKEventRow *eventRow6 = [self.tableView rowControllerAtIndex:5];
    NSString *joinedComponents2 = [[self getParticipiantsForType:ParticipantMaybeStatus fromAllParticipiants:event[@"participants"]] componentsJoinedByString:@","];
    [eventRow6.organizerNameLabel setText:joinedComponents2];
    
    WKEventRow *eventRow7 = [self.tableView rowControllerAtIndex:6];
    [eventRow7.organizerNameLabel setAttributedText:[self attributedStringFromString:@"NO REPLY"]];
    [eventRow7.rowGroup setBackgroundColor:[UIColor clearColor]];
    
    WKEventRow *eventRow8 = [self.tableView rowControllerAtIndex:7];
    NSString *joinedComponents3 = [[self getParticipiantsForType:ParticipantNoreplyStatus fromAllParticipiants:event[@"participants"]] componentsJoinedByString:@","];
    [eventRow8.organizerNameLabel setText:joinedComponents3];
    
    
    WKEventRow *eventRow9 = [self.tableView rowControllerAtIndex:8];
    [eventRow9.organizerNameLabel setAttributedText:[self attributedStringFromString:@"NOTES"]];
    [eventRow9.rowGroup setBackgroundColor:[UIColor clearColor]];
    
    WKEventRow *eventRow10 = [self.tableView rowControllerAtIndex:9];
    [eventRow10.organizerNameLabel setText:event[@"event_description"]];

}

-(NSArray*)getParticipiantsForType:(ParticipantStatuType)statusType fromAllParticipiants:(NSArray*)participiants {
    
    NSMutableArray *validNames = [NSMutableArray new];
    
    [participiants enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *participiant = obj;
        if ([participiant[@"status_type"] integerValue] == statusType) {
            [validNames addObject:participiant[@"name"]];
        }
    }];
    
    return validNames;
}

-(void)maybeAction {
    
}

-(void)declineAction {
    
}

-(void)goAction {
   
    [self popController];
    
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

-(NSMutableAttributedString*)attributedStringFromString:(NSString*)string {
    
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:11] range:NSMakeRange(0,string.length)];
    
    return attributedString;
}

#pragma mark - Formatter

-(NSString*)getDateFromTimeIntervalString:(NSString*)timeIntervalString {
    NSInteger from = [timeIntervalString doubleValue];
    NSTimeInterval fromTimeInterval = from;
    
    NSDate* date1 = [NSDate dateWithTimeIntervalSince1970:fromTimeInterval];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY"];
    // Tuesday 04 Jun
    
    NSString *year = [dateFormatter stringFromDate:date1];
    
    NSString *day = [self getDayForDate:date1];
    
    return [NSString stringWithFormat:@"%@ %@",day, year];
}

#pragma mark - Day formatter

-(NSString*)getDayForDate:(NSDate*)date {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE"];
    NSString *dayName = [dateFormatter stringFromDate:date];
    
    return dayName;
}

#pragma mark - Date Representation

-(NSString *)stringForDateFormat:(NSString*)dateFormat forDate:(NSDate*)date {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:dateFormat];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSString *stringFromDateFormat = [dateFormatter stringFromDate:date];
    
    return stringFromDateFormat;
}

-(NSString*)getTimeFrameFromDate:(NSString*)fromDate toDate:(NSString*)toDate {
    
    NSInteger from = [fromDate doubleValue];
    NSInteger end = [toDate doubleValue];
    
    NSTimeInterval fromTimeInterval = from;
    NSTimeInterval endTimeInterval = end;
    
    NSLog(@"fromTimeInterval %f", fromTimeInterval);
    NSLog(@"fromTimeInterval %f", endTimeInterval);
    NSDate* date1 = [NSDate dateWithTimeIntervalSince1970:endTimeInterval];
    NSDate* date2 = [NSDate dateWithTimeIntervalSince1970:fromTimeInterval];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm"];
    
    NSString *stringFromDate1 = [dateFormatter stringFromDate:date1];
    NSString *stringFromDate2 = [dateFormatter stringFromDate:date2];
    
    return [NSString stringWithFormat:@"%@ - %@",stringFromDate2, stringFromDate1];
}

-(NSString*)getDurationFromDate:(NSString*)fromDate toDate:(NSString*)toDate {
    
    NSInteger from = [fromDate doubleValue];
    NSInteger end = [toDate doubleValue];
    
    NSTimeInterval fromTimeInterval = from;
    NSTimeInterval endTimeInterval = end;
    
    NSLog(@"fromTimeInterval %f", fromTimeInterval);
    NSLog(@"fromTimeInterval %f", endTimeInterval);
    NSDate* date1 = [NSDate dateWithTimeIntervalSince1970:endTimeInterval];
    NSDate* date2 = [NSDate dateWithTimeIntervalSince1970:fromTimeInterval];
    NSTimeInterval distanceBetweenDates = [date1 timeIntervalSinceDate:date2];
    double secondsInAnHour = 3600;
    double secondsInAnMinute = 60;
    
    NSInteger duration;
    NSString *durationString;

    if (distanceBetweenDates > secondsInAnHour) {
        duration = distanceBetweenDates / secondsInAnHour;
        durationString = [NSString stringWithFormat:@"%luh", (long)duration];

    }else {
        duration = distanceBetweenDates / secondsInAnMinute;
        durationString = [NSString stringWithFormat:@"%lum", (long)duration];

    }
    
    return durationString;
}

@end



