//
//  EventView.m
//  CalendarDemo_objc
//
//  Created by Dominik Pich on 11/10/15.
//  Copyright © 2015 Dominik Pich. All rights reserved.
//

#import "EventView.h"
#import "DDCalendarEvent.h"
#import "PMEventModel.h"

@implementation EventView

- (void)setActive:(BOOL)active {
    super.active = active;
    
    UIColor *c = [UIColor redColor];
    if(self.event.userInfo[@"color"]) {
        c = self.event.userInfo[@"color"];
    }
    
    EventDateType eventDateType = ((PMEventModel*)self.event.event).eventDateType;
    
    
    if(super.active) {
        self.backgroundColor = (eventDateType == EventDateTimeType)?[UIColor clearColor]:[c colorWithAlphaComponent:0.5];
        self.layer.borderColor = nil;//c.CGColor;
        self.layer.borderWidth = 0;
    }
    else {
        self.backgroundColor = (eventDateType == EventDateTimeType)?[UIColor clearColor]:[c colorWithAlphaComponent:0.3];
        self.layer.borderColor = nil;
        self.layer.borderWidth = 0;
    }
}

@end
