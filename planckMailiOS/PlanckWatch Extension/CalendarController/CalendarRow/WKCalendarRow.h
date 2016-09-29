//
//  WKCalendarRow.h
//  planckMailiOS
//
//  Created by nazar on 11/12/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>
@import WatchKit;

@interface WKCalendarRow : NSObject
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *eventTitleLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *durationLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceGroup *strip;
@end
