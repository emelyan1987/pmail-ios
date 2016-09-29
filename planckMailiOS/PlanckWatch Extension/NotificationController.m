//
//  NotificationController.m
//  planckMailiOS WatchKit Extension
//
//  Created by Dmytro Nosulich on 7/14/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "NotificationController.h"

@import WatchConnectivity;
@import UIKit;

@interface NotificationController() <WCSessionDelegate>

@property (nonatomic, weak) IBOutlet WKInterfaceLabel *notificationLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *dateLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *timeLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *durationLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *eventTitleLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *remainTimeLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceGroup *upcoming_meetingGroup;

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceGroup *accepted_meetingGroup;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *acceptedNames;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *acceptedTime;

@end


@implementation NotificationController

- (instancetype)init {
    self = [super init];
    if (self){
        // Initialize variables here.
        // Configure interface objects here.
           
        
    }
    return self;
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];


   
    
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}


- (void)didReceiveLocalNotification:(UILocalNotification *)localNotification withCompletion:(void (^)(WKUserNotificationInterfaceType))completionHandler {
    // This method is called when a local notification needs to be presented.
    // Implement it if you use a dynamic notification interface.
    // Populate your dynamic notification interface as quickly as possible.
    
   // [self.notificationLabel setText:[NSString stringWithFormat:@"Info: %@", localNotification.userInfo]];
    if ([localNotification.userInfo[@"type"] isEqualToString:@"upcoming_meeting"]) {
        
        [self.upcoming_meetingGroup setHidden:NO];

        [self.remainTimeLabel setText:localNotification.userInfo[@"remainTime"]];
        [self.eventTitleLabel setText:localNotification.userInfo[@"eventTitle"]];
        [self.dateLabel setText:[NSString stringWithFormat:@"%@", localNotification.userInfo[@"date"]]];
        [self.timeLabel setText:localNotification.userInfo[@"time"]];
        [self.durationLabel setText:localNotification.userInfo[@"duration"]];
        
    }else if ([localNotification.userInfo[@"type"] isEqualToString:@"accepted_meeting"]) {
    
        [self.accepted_meetingGroup setHidden:NO];
        [self.acceptedNames setText:localNotification.userInfo[@"acceptedNames"]];
        [self.acceptedTime setText:localNotification.userInfo[@"acceptedTime"]];
    }
    

  
    // After populating your dynamic notification interface call the completion block.
    completionHandler(WKUserNotificationInterfaceTypeCustom);
}



/*
- (void)didReceiveRemoteNotification:(NSDictionary *)remoteNotification withCompletion:(void (^)(WKUserNotificationInterfaceType))completionHandler {
    // This method is called when a remote notification needs to be presented.
    // Implement it if you use a dynamic notification interface.
    // Populate your dynamic notification interface as quickly as possible.
    //
    // After populating your dynamic notification interface call the completion block.
    completionHandler(WKUserNotificationInterfaceTypeCustom);
}
*/

@end
