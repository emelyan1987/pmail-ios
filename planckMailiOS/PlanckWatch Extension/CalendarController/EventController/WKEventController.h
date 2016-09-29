//
//  WKEventController.h
//  planckMailiOS
//
//  Created by nazar on 11/13/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface WKEventController : WKInterfaceController
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *eventTitleLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *eventDateLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *eventTimeFrameLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *eventDurationLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *eventLocationLabel;

@end
