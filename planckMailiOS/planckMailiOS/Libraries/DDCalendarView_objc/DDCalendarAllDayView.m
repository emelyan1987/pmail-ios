//
//  DDCalendarView.m
//  CustomerApp
//
//  Created by Dominik Pich on 25/09/15.
//  Copyright © 2015 Dominik Pich. All rights reserved.
//

#import "DDCalendarAllDayView.h"
#import "DDCalendarView.h"
#import "DDCalendarEvent.h"
#import "DDCalendarEventView.h"
#import "NSDate+DDCalendar.h"
#import "DDCalendarViewConstants.h"
#import "PMEventModel.h"


@interface DDCalendarAllDayView ()

@property(nonatomic,strong) NSArray *eventViews;
@property(nonatomic,weak) DDCalendarEventView *activeEventView;
@end

@interface DDCalendarEventView (private)
@property(nonatomic, weak) DDCalendarAllDayView *calendar;
@end

@implementation DDCalendarAllDayView

- (void)setEvents:(NSArray * _Nullable)events {
    _events = events;
    
    //rm all events
    for (UIView *v in self.eventViews) {
        [v removeFromSuperview];
    }
    self.eventViews = nil;
    
    id ds = self.calendar.dataSource;

    
    if(events.count) {
        //add event view for all events from left to right.
        NSMutableArray *newEventViews = [NSMutableArray array];
        for (int i=0; i<events.count; i++) {
            DDCalendarEvent *e = events[i];
            CGRect f = CGRectMake(0, i*(20), self.frame.size.width, 17);
            
            
            DDCalendarEventView *ev = nil;
            
            if([ds respondsToSelector:@selector(calendarView:viewForEvent:)]) {
                ev = [ds calendarView:self.calendar viewForEvent:e];
            }
            
            if(!ev) {
                ev = [[DDCalendarEventView alloc] initWithEvent:e];
            }
            
            ev.frame = f;
            ev.calendar = self;
            [self addSubview:ev];
            [newEventViews addObject:ev];

            //get taps and pressed
            UITapGestureRecognizer *g = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnEvent:)];
            [ev addGestureRecognizer:g];
            
        }
        self.eventViews = newEventViews;
    }
    

    //update content size with maxX
//    CGSize s = self.bg.frame.size;
//    s.width = 15 + TIME_TIME_LABEL_WIDTH + maxX + 15;
//    
//    [self setContentSize:s];
}

- (void)setDate:(NSDate * _Nonnull)date {
    _date = date;
    [self setEvents:self.events];
}

#pragma mark tap recognizer

- (void)handleTapOnEvent:(UIGestureRecognizer*)gestureRecognizer {
    DDCalendarEventView *activeEV = self.activeEventView;
    DDCalendarEventView *ev = (DDCalendarEventView*)gestureRecognizer.view;
    
    if(activeEV != ev) {
        ev.active = YES;

        id<DDCalendarViewDelegate> delegate = self.calendar.delegate;
        
        //tell click to delegate
        if([delegate respondsToSelector:@selector(calendarView:didSelectEvent:)]) {
            [delegate calendarView:self.calendar didSelectEvent:ev.event];
        }
    }
    else if(activeEV==ev) {
        activeEV.active = NO;
        self.activeEventView = nil;
    }
}



@end
