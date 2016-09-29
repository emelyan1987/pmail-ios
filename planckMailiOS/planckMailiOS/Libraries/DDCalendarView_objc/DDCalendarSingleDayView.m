//
//  DDCalendarView.m
//  CustomerApp
//
//  Created by Dominik Pich on 25/09/15.
//  Copyright © 2015 Dominik Pich. All rights reserved.
//

#import "DDCalendarSingleDayView.h"
#import "DDCalendarView.h"
#import "FFViewWithHourLines.h"
#import "DDCalendarEvent.h"
#import "DDCalendarEventView.h"
#import "NSDate+DDCalendar.h"
#import "DDCalendarViewConstants.h"
#import "OBDragDrop.h"
#import "PMEventModel.h"


@interface DDCalendarSingleDayView () <OBOvumSource, OBDropZone>

@property(nonatomic,weak) UIScrollView *dayLinesView;
@property(nonatomic,weak) FFViewWithHourLines *timeLinesView;
@property(nonatomic,weak) UIView *timeLinesContainer;
@property(nonatomic,strong) NSArray *dayEventViews;
@property(nonatomic,strong) NSArray *timeEventViews;
@property(nonatomic,weak) DDCalendarEventView *activeEventView;
@property(nonatomic, weak) UIView *timeMarkerLine;
@end

@interface DDCalendarEventView (private)
@property(nonatomic, weak) DDCalendarSingleDayView *calendar;
@end

@implementation DDCalendarSingleDayView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        CGRect dayViewFrame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, 90);
        UIView *dayView = [[UIView alloc] initWithFrame:dayViewFrame];
        [self addSubview:dayView];
        self.dayView = dayView;
        
        
        UILabel *allDayLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 50, HEIGHT_CELL_MIN)];
        allDayLabel.text = @"All Day";
        allDayLabel.font = [UIFont fontWithName:@"Helvetica" size:11];
        allDayLabel.textColor = [UIColor lightGrayColor];
        [allDayLabel sizeToFit];
        
        [self.dayView addSubview:allDayLabel];
        
        //add a container for the events
        CGRect f = CGRectInset(dayView.frame, 10, 10);
        f.origin.x += TIME_LABEL_WIDTH;
        f.size.width -= TIME_LABEL_WIDTH;
        UIScrollView *dayLinesView = [[UIScrollView alloc] initWithFrame:f];
        [dayLinesView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        dayLinesView.scrollEnabled = YES;
        
        [self.dayView addSubview:dayLinesView];
        self.dayLinesView = dayLinesView;
        
        
        CGRect timeViewFrame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y+90, self.bounds.size.width, self.bounds.size.height-90);
        UIScrollView *timeView = [[UIScrollView alloc] initWithFrame:timeViewFrame];
        [timeView setContentInset:UIEdgeInsetsMake(10, 0, 10, 0)];
        [self addSubview:timeView];
        self.timeView = timeView;
        
        //add our hours view that draws the background
        FFViewWithHourLines *hourLines = [[FFViewWithHourLines alloc] initWithFrame:CGRectMake(0, 0, timeViewFrame.size.width, timeViewFrame.size.height)];
        [hourLines setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [hourLines sizeToFit];
        
        [self.timeView addSubview:hourLines];
        self.timeLinesView = hourLines;
        
        //add a container for the events
        f = CGRectInset(hourLines.frame, 15, 0);
        f.origin.x += TIME_LABEL_WIDTH;
        f.size.width -= TIME_LABEL_WIDTH;
        UIView *timeLinesContainer = [[UIView alloc] initWithFrame:f];
        [timeLinesContainer setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        
        [self.timeLinesView addSubview:timeLinesContainer];
        self.timeLinesContainer = timeLinesContainer;
        
        [self setShowsTomorrow:NO];
//        [self setDate:[NSDate date]];
        
        self.dropZoneHandler = self;
    }
    return self;
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    
    OBDragDropManager *manager = [OBDragDropManager sharedManager];
    [manager prepareOverlayWindowUsingMainWindow:self.window];
}

- (void)setEvents:(NSArray * _Nullable)events {
    _events = events;
    
    //rm all events
    for (UIView *v in self.dayEventViews) {
        [v removeFromSuperview];
    }
    self.dayEventViews = nil;
    
    for (UIView *v in self.timeEventViews) {
        [v removeFromSuperview];
    }
    self.timeEventViews = nil;
    
    id ds = self.calendar.dataSource;

    CGFloat maxX = 0;
    
    if(events.count) {
        //add event view for all events from left to right.
        NSMutableArray *newDayEventViews = [NSMutableArray array];
        NSMutableArray *newTimeEventViews = [NSMutableArray array];
        
        NSInteger dayEventIndex = 0;
        for (DDCalendarEvent *e in events) {
            PMEventModel *eventModel = (PMEventModel*) e.event;
            EventDateType eventDateType = eventModel.eventDateType;
            
            BOOL isAllDay = NO;
            if(eventDateType == EventDateTimeType || eventDateType == EventDateTimespanType)
            {
                NSDate *startTime = [NSDate dateWithTimeIntervalSince1970:[eventModel.startTime integerValue]];
                NSDate *endTime = [NSDate dateWithTimeIntervalSince1970:[eventModel.endTime integerValue]];
                
                if([startTime timeIntervalSinceDate:self.date] <= 0 && [endTime timeIntervalSinceDate:self.date] >= 60*60*24)
                    isAllDay = YES;
            }
            
            if(eventDateType == EventDateDateType || eventDateType == EventDateDatespanType || isAllDay)
            {
                DDCalendarEventView *ev = nil;
                
                if([ds respondsToSelector:@selector(calendarView:viewForEvent:)]) {
                    ev = [ds calendarView:self.calendar viewForEvent:e];
                }
                
                if(!ev) {
                    ev = [[DDCalendarEventView alloc] initWithEvent:e];
                }
                
                ev.frame = CGRectMake(0, dayEventIndex*20, self.dayLinesView.frame.size.width, 18);
                ev.calendar = self;
                [self.dayLinesView addSubview:ev];
                [newDayEventViews addObject:ev];
                
                //get taps and pressed
                UITapGestureRecognizer *g = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnEvent:)];
                [ev addGestureRecognizer:g];
                
                
                // Drag drop with long press gesture
                OBDragDropManager *dragDropManager = [OBDragDropManager sharedManager];
                UIGestureRecognizer *recognizer = [dragDropManager createLongPressDragDropGestureRecognizerWithSource:self];
                [ev addGestureRecognizer:recognizer];
                
                
                dayEventIndex++;
            }
            else if(eventDateType==EventDateTimeType || eventDateType == EventDateTimespanType)
            {
                CGRect f = [self frameForEvent:e];
                f = [self adjustAvoidOverlapForFrame:f forPastEvents:newTimeEventViews];
                
                DDCalendarEventView *ev = nil;
                
                if([ds respondsToSelector:@selector(calendarView:viewForEvent:)]) {
                    ev = [ds calendarView:self.calendar viewForEvent:e];
                }
                
                if(!ev) {
                    ev = [[DDCalendarEventView alloc] initWithEvent:e];
                }
                
                
                [ev setFrame:f];
                
                ev.calendar = self;
                [self.timeLinesContainer addSubview:ev];
                [newTimeEventViews addObject:ev];
                
                //get taps and pressed
                UITapGestureRecognizer *g = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnEvent:)];
                [ev addGestureRecognizer:g];
                
                
                // Drag drop with long press gesture
                OBDragDropManager *dragDropManager = [OBDragDropManager sharedManager];
                UIGestureRecognizer *recognizer = [dragDropManager createLongPressDragDropGestureRecognizerWithSource:self];
                [ev addGestureRecognizer:recognizer];
                
                //get the rightmost coordinate
                maxX = MAX(maxX, CGRectGetMaxX(f));
            }
        }
        
        self.timeEventViews = newTimeEventViews;
        self.dayEventViews = newDayEventViews;
        
        //check if gotta scale to fit on screen
        if(maxX > self.timeLinesContainer.frame.size.width) {
            CGFloat factor = self.timeLinesContainer.frame.size.width/maxX;
            //        if(self.eventMinimumWidthFactor > factor) {
            //            factor = MIN(self.eventMinimumWidthFactor, 1);
            //        }
            
            [self compressAllEventViewsByFactor:factor];
            
            //        maxX *= factor;
        }
        
        [self.dayLinesView setContentSize:CGSizeMake(self.dayLinesView.frame.size.width, dayEventIndex*20)];
    }

    //update content size with maxX
//    CGSize s = self.timeLinesView.frame.size;
//    s.width = 15 + TIME_TIME_LABEL_WIDTH + maxX + 15;
//    
//    [self setContentSize:s];
}

- (void)setDate:(NSDate * _Nonnull)date {
    NSDateComponents* comps = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    _date = [[NSCalendar currentCalendar] dateFromComponents:comps];
    
    [self setEvents:self.events];
}

- (void)setShowsTomorrow:(BOOL)showsTomorrow {
    _showsTomorrow = showsTomorrow;
    
    CGFloat height = self.timeLinesView.frame.size.height;
    if(!_showsTomorrow) {
        height /= 2;
    }
    self.timeView.contentSize = CGSizeMake(self.bounds.size.width, height);
}

- (void)scrollTimeToVisible:(NSDate *)date animated:(BOOL)animated {
    NSDateComponents *comps = date.currentCalendarDateComponents;
    NSInteger hours = comps.hour;
    NSInteger mins = comps.minute;
    
    hours = MAX(0, hours-1);
    
    NSDate *tempDate = [NSDate todayDateWithHour:hours min:mins];
    CGPoint offset = [self pointForDate:tempDate];
    CGRect rect = CGRectMake(0, offset.y, 10, 10);
    rect.size = self.bounds.size;
    [self.timeView scrollRectToVisible:rect animated:animated];
}

- (void)setShowsTimeMarker:(BOOL)showsTimeMarker {
    _showsTimeMarker = showsTimeMarker;
    
    if(_showsTimeMarker) {
        if(!self.timeMarkerLine) {
            UIView *timeMarkerLine = [[UIView alloc] initWithFrame:CGRectZero];
            timeMarkerLine.backgroundColor = [UIColor redColor];
            [self insertSubview:timeMarkerLine aboveSubview:self.timeLinesContainer];
            self.timeMarkerLine = timeMarkerLine;
        }
        
        NSDateComponents *now = [NSDate date].currentCalendarDateComponents;
        NSInteger days = [self.date daysFromDate:[NSDate date]];
        NSDate *date = [NSDate dateWithHour:now.hour min:now.minute inDays:days];
        CGPoint datePoint = [self pointForDate:date];
        datePoint.y += HEIGHT_CELL_MIN/2;
        datePoint.y += 2; //;)
        
        CGRect f = self.bounds;
        f.origin.y = datePoint.y;
        f.size.height = 2;
        self.timeMarkerLine.frame = f;
    }
    else {
        [self.timeMarkerLine removeFromSuperview];
    }
}

#pragma mark event frame helpers

- (CGRect)frameForEvent:(DDCalendarEvent*)event {
    CGFloat yBegin = [self pointForDate:event.dateBegin].y;
    CGFloat yEnd = [self pointForDate:event.dateEnd].y;
    
    CGFloat height = yEnd - yBegin;
    EventDateType eventDateType = ((PMEventModel*)event.event).eventDateType;
    if(height<15/* && eventDateType==EventDateTimespanType*/) height = 15;
    return CGRectMake(0, yBegin, self.timeLinesContainer.frame.size.width, height);
}

- (CGRect)adjustAvoidOverlapForFrame:(CGRect)frame forPastEvents:(NSArray*)eventViews {
    BOOL satisified;
    
    do {
        satisified = YES;
        
        for (DDCalendarEventView *ev in eventViews) {
            if(CGRectIntersectsRect(frame, ev.frame)) {
                //if it intersects, move it and retry!
                frame.origin.x += self.timeLinesContainer.frame.size.width+15;
                satisified = NO;
            }
        }
    } while (!satisified);
    
    return frame;
}

- (void)compressAllEventViewsByFactor:(CGFloat)factor {
    for (DDCalendarEventView *ev in self.timeEventViews) {
        CGRect f = ev.frame;
        f.origin.x *= factor;
        f.size.width *= factor;
        ev.frame = f;
    }
}

#pragma mark convert points <> dates

- (CGPoint)pointForDate:(NSDate*)date {
    /*NSDateComponents *compsNow = self.date.currentCalendarDateComponents;
    NSDateComponents *compsOfBegin = date.currentCalendarDateComponents;
    
    //hours
    NSInteger beginInHoursSinceMidnightToday = compsOfBegin.hour;
    
    //we only encompass prev and next day.. we dont care about 2 or more days
    NSInteger nowDay = compsNow.day, beginDay = compsOfBegin.day;
    
    if(beginDay > nowDay) beginInHoursSinceMidnightToday += 24;
    else if(beginDay < nowDay) beginInHoursSinceMidnightToday -= 24;
    
    //pixels
    CGFloat yBegin = beginInHoursSinceMidnightToday * HEIGHT_CELL_HOUR;
    yBegin += compsOfBegin.minute * PIXELS_PER_MIN;*/
    
    
    NSTimeInterval interval = [date timeIntervalSinceDate:self.date];
    
    CGFloat yBegin = (interval / 60) * PIXELS_PER_MIN;
    return CGPointMake(0, yBegin);
}

- (NSDate*)dateForPoint:(CGPoint)pt {
    CGFloat y = pt.y; //we only care about y
    
    y -= HEIGHT_CELL_MIN/2; //  ;)
    
    //determine how many hours fit
    int beginInHoursSinceMidnightToday = floor(pt.y / HEIGHT_CELL_HOUR);
    y = y - (beginInHoursSinceMidnightToday * HEIGHT_CELL_HOUR);
    assert(y < HEIGHT_CELL_HOUR);
    int minutesSinceLastHour = floor(y / PIXELS_PER_MIN);
    
    NSInteger daysMod = [self.date daysFromDate:[NSDate date]];
    NSDate *date = [NSDate dateWithHour:beginInHoursSinceMidnightToday min:minutesSinceLastHour inDays:daysMod];
    
    return date;
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

#pragma mark d&d

-(BOOL) shouldCreateOvumFromView:(UIView*)sourceView {
    BOOL editable = NO;
    id<DDCalendarViewDelegate> del = self.calendar.delegate;
    DDCalendarEventView *ev = (DDCalendarEventView*)sourceView;
    
    if([del respondsToSelector:@selector(calendarView:allowEditingEvent:)]) {
        editable = [del calendarView:self.calendar allowEditingEvent:ev.event];
    }
    
    if(editable) {
        //activate it
        ev.active = YES;
        self.activeEventView = ev;
    }
    return editable;
}

-(OBOvum *) createOvumFromView:(UIView*)sourceView {
    assert([sourceView isKindOfClass:[DDCalendarEventView class]]);
    
    OBOvum *ovum = [[OBOvum alloc] init];
    ovum.dataObject = ((DDCalendarEventView*)sourceView).event;
    ovum.isCentered = YES;
    return ovum;
}

-(UIView *) createDragRepresentationOfSourceView:(UIView *)sourceView inWindow:(UIWindow*)overlay {
    assert([sourceView isKindOfClass:[DDCalendarEventView class]]);

    UIView *dragView = [(DDCalendarEventView*)sourceView draggableView];
    
    // Create a view that represents this source. It will be place on
    // the overlay window and hence the coordinates conversion to make
    // sure user doesn't see a jump in object location
    CGRect f = dragView.frame;
    f = [self.timeLinesContainer convertRect:f toView:self.window];
    f = [self.window convertRect:f toView:overlay];
    dragView.frame = f;
    
    return dragView;
}

-(OBDropAction) ovumEntered:(OBOvum*)ovum inView:(UIView*)view atLocation:(CGPoint)location {
    return OBDropActionMove;
}

- (void)ovumExited:(OBOvum *)ovum inView:(UIView *)view atLocation:(CGPoint)location {
    //noop
}

-(void) ovumDropped:(OBOvum*)ovum inView:(UIView*)view atLocation:(CGPoint)location {
    //to get the top of the event
    location.y -= CGRectGetHeight(ovum.dragView.frame)/2;
    
    // Handle the drop action
    DDCalendarEvent *event = ovum.dataObject;
    NSTimeInterval duration = [event.dateEnd timeIntervalSinceDate:event.dateBegin];

    NSDate *newStartDate = [self dateForPoint:location];
    NSDate *newEndDate = [newStartDate dateByAddingTimeInterval:duration];
    
    event.dateBegin = newStartDate;
    event.dateEnd  = newEndDate;
    
    self.events = self.events; //refresh ourself
    
    //commit it
    id<DDCalendarViewDelegate> del = self.calendar.delegate;
    if([del respondsToSelector:@selector(calendarView:commitEditEvent:)]) {
        [del calendarView:self.calendar commitEditEvent:event];
    }
}

@end
