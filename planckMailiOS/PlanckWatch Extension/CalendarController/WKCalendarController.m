//
//  WKCalendarController.m
//  planckMailiOS
//
//  Created by nazar on 11/12/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "WKCalendarController.h"
#import "WKCalendarRow.h"
#import "PMEventModel.h"
#import "WatchKitDefines.h"

@interface WKCalendarController () <WCSessionDelegate>
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceTable *tableView;
@property (strong, nonatomic) NSMutableArray *events;

@end

@implementation WKCalendarController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    if ([WCSession isSupported]) {
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
        
        [self getCalendarEvents];
    }
    
    [self setTitle:@"Calendar"];

    // Configure interface objects here.
}

#pragma mark - Table view methods

- (void)updateTableView {
    [self.tableView setNumberOfRows:[self.events count] withRowType:@"calendarRowType"];
    
    NSInteger i = 0;
    for(NSDictionary *event in self.events) {
        WKCalendarRow *row = [self.tableView rowControllerAtIndex:i++];
        [row.eventTitleLabel setText:event[@"title"]];
        [row.durationLabel setText:[self getDurationLabelFromTimeFrame:event[@"start_time"] toDate:event[@"end_time"]]];
    }
    [self showActivityIndicator:NO];

}

-(NSString*)getDurationFromDate:(NSString*)fromDate toDate:(NSString*)toDate {
    
    NSInteger from = [fromDate doubleValue];
    NSInteger end = [toDate doubleValue];
    
    NSTimeInterval fromTimeInterval = from;
    NSTimeInterval endTimeInterval = end;
    
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

-(NSString*)getTimeFrameFromDate:(NSString*)fromDate {
    
    NSInteger from = [fromDate doubleValue];
    
    NSTimeInterval fromTimeInterval = from;
    
    NSDate* date1 = [NSDate dateWithTimeIntervalSince1970:fromTimeInterval];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm"];
    
    NSString *stringFromDate1 = [dateFormatter stringFromDate:date1];
    
    return [NSString stringWithFormat:@"%@", stringFromDate1];
}

-(NSString*)getDurationLabelFromTimeFrame:(NSString*)fromDate toDate:(NSString*)toDate{
    
    return [NSString stringWithFormat:@"%@ - %@",[self getTimeFrameFromDate:fromDate], [self getDurationFromDate:fromDate toDate:toDate]];
}

-(void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
    
    [self pushControllerWithName:@"EventController" context:self.events[rowIndex]];
}


- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
    
    
    
}

-(void)getCalendarEvents {
    [self showActivityIndicator:YES];


    
    [[WCSession defaultSession] sendMessage:@{WK_REQUEST_TYPE:@(PMWatchRequestGetEvents)} replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
        
        self.events = replyMessage[WK_REQUEST_RESPONSE];
        
        [self updateTableView];
        
    } errorHandler:^(NSError * _Nonnull error) {
        [self showActivityIndicator:NO];
      
        NSLog(@"error = %@",error);
    }];
    
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



