//
//  PMCalendarVC.m
//  planckMailiOS
//
//  Created by admin on 7/18/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMCalendarVC.h"

#import "UIViewController+PMStoryboard.h"
#import "PMCreateEventVC.h"
#import "PMEventDetailsVC.h"
#import "PMCalendarCell.h"
#import "NSDate+DateConverter.h"

#import "PMCalendarListVC.h"

#import "PMEventModel.h"
#import "PMAPIManager.h"

#import <JTCalendar/JTCalendar.h>
#import "UITableView+BackgroundText.h"

#import "DDCalendarView.h"
#import "EventView.h"
#import "DDCalendarEvent.h"

#import "NSDate+DateConverter.h"
#import "Config.h"

@interface PMCalendarVC () <UITableViewDelegate, UITableViewDataSource, JTCalendarDelegate, UIGestureRecognizerDelegate, DDCalendarViewDataSource, DDCalendarViewDelegate, PMCreateEventVCDelegate, PMCalendarListVCDelegate> {
    IBOutlet UITableView *_tableView;
    IBOutlet UILabel *_currentMonth;
    IBOutlet DDCalendarView *_calendarGrid;
    
    NSMutableDictionary *_eventsByDate;
    
    NSDate *_todayDate;
    NSDate *_minDate;
    NSDate *_maxDate;
    
    NSDate *_dateSelected;

    NSMutableArray *_dateItemsArray;
    NSMutableDictionary *_section;
    NSArray *_eventSections;
    
    NSInteger _offset;

    
}
@property (weak, nonatomic) IBOutlet UIButton *btnEventListView;
@property (weak, nonatomic) IBOutlet UIButton *btnEventGraphView;
@property (nonatomic, strong) UIButton *todayBtn;
@property (nonatomic, strong) NSMutableArray *eventsArray;

@property (weak, nonatomic) IBOutlet JTHorizontalCalendarView *calendarContentView;
@property (strong, nonatomic) JTCalendarManager *calendarManager;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *calendarContentViewHeight;

- (IBAction)menuBtnPressed:(id)sender;
- (IBAction)createEventBtnPressed:(id)sender;
- (IBAction)btnEventListViewPressed:(id)sender;
- (IBAction)btnEventGraphViewPressed:(id)sender;
@end

@implementation PMCalendarVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _eventsArray = [NSMutableArray new];
    _eventsByDate = [NSMutableDictionary new];
    _section = [NSMutableDictionary new];
    
    [self customizeVC];
    _offset = 0;
    
    
//    [[PMAPIManager shared] getTheadWithAccount:[[PMAPIManager shared] namespaceId] completion:^(id error, BOOL success) {
//        
//    }];
    
    
    _todayBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 70, self.view.frame.size.height - 100, 42, 42)];
    [_todayBtn addTarget:self action:@selector(todayBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [_todayBtn setBackgroundImage:[UIImage imageNamed:@"arrowUpIcon"] forState:UIControlStateNormal];
    [_todayBtn setHidden:YES];
    [self.view addSubview:_todayBtn];
    
    [_tableView showEmptyMessage:@"You have no events or problem with load Calendar events!"];
    
    [self performSelector:@selector(loadEvents) withObject:nil afterDelay:.1];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlerNotificationEventChanged:) name:NOTIFICATION_EVENT_UPDATED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlerNotificationMailAccountAdded:) name:NOTIFICATION_MAIL_ACCOUNT_ADDED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlerNotificationMailAccountDeleted:) name:NOTIFICATION_MAIL_ACCOUNT_DELETED object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void)handlerNotificationEventChanged:(NSNotification*)notification
{
    [self performSelector:@selector(loadEvents) withObject:nil afterDelay:.1];    
}

- (void)handlerNotificationMailAccountAdded:(NSNotification*)notification
{
    [self loadEvents];
}

- (void)handlerNotificationMailAccountDeleted:(NSNotification*)notification
{
    [self loadEvents];
}

- (void)handlerNotificationAccountDeleted:(NSNotification*)notification
{
    [self loadEvents];
}
- (void)loadEvents
{
    if(self.eventsArray==nil) self.eventsArray = [NSMutableArray new];
    if(self.eventsArray.count) [self.eventsArray removeAllObjects];
    
    __weak typeof(self)__self = self;
    
    NSMutableDictionary *eventParams = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                       @"starts_after" : [NSString stringWithFormat:@"%f", [self timeStampWithDate:_minDate]],
                                                                                       @"ends_before" : [NSString stringWithFormat:@"%f", [self timeStampWithDate:_maxDate]],
                                                                                       @"expand_recurring" : @"true"/*,
                                                                                                                     @"limit" : @100,
                                                                                                                     @"offset" : @(_offset)*/
                                                                                       }];
    NSArray *calendars = [DBCalendar getCalendars];
    for(DBCalendar *calendar in calendars)
    {
        BOOL selected = !calendar.selected?NO:[calendar.selected boolValue];
        
        if(selected)
        {
            [eventParams setObject:calendar.calendarId forKey:@"calendar_id"];
            
            DBNamespace *namespace = [DBNamespace getNamespaceWithAccountId:calendar.account_id];
            
            NSArray *events = [[PMAPIManager shared] getEventsWithAccount:namespace.account_id eventParams:eventParams comlpetion:^(id data, id error, BOOL success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    for(PMEventModel *event in data)
                    {
                        NSString *eventId = event.id;
                        PMEventModel *localEvent = [self getEventFromEventsArrayWithId:eventId];
                        
                        if(!localEvent)
                        {
                            [__self.eventsArray addObject:event];
                        }
                        else
                        {
                            NSInteger index = [self.eventsArray indexOfObject:localEvent];
                            [__self.eventsArray replaceObjectAtIndex:index withObject:event];
                        }
                        
                    }
                    
                    //_offset = __self.eventsArray.count;
                    // Generate random events sort by date using a dateformatter for the demonstration
                    [__self createRandomEvents];
                    
                });
            }];
            
            for(PMEventModel *event in events)
            {
                NSString *eventId = event.id;
                PMEventModel *localEvent = [self getEventFromEventsArrayWithId:eventId];
                if(!localEvent)
                {
                    [self.eventsArray addObject:event];
                }
                else
                {
                    NSInteger index = [self.eventsArray indexOfObject:localEvent];
                    [self.eventsArray replaceObjectAtIndex:index withObject:event];
                }
            }
        }
    }

    
    
    [self createRandomEvents];
}

- (PMEventModel*)getEventFromEventsArrayWithId:(NSString*)eventId
{
    for(PMEventModel *event in self.eventsArray)
    {
        if([event.id isEqualToString:eventId]) return event;
    }
    
    return nil;
}
- (BOOL)compareEvent:(PMEventModel *)event withEvent:(PMEventModel*)withEvent
{
    BOOL bResult = YES;
 
    if(![event.id isEqualToString:withEvent.id]) return NO;
    return bResult;
}
- (NSTimeInterval)timeStampWithDate:(NSDate*)date {
    return [date timeIntervalSince1970];
}

- (void)todayBtnPressed {
    NSString *key = [[self dateFormatter] stringFromDate:_todayDate];
    if ([_eventSections containsObject:key]) {
        NSUInteger section = [_eventSections indexOfObject:key];
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]
                          atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    [_calendarManager setDate:_todayDate];
    _dateSelected = _todayDate;
    [_calendarManager reload];
    [_todayBtn setHidden:YES];
}

- (void)customizeVC {
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    _calendarManager = [JTCalendarManager new];
    _calendarManager.delegate = self;
    _calendarManager.settings.weekModeEnabled = YES;
    
    UISwipeGestureRecognizer *swipeUpDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(extendedCalendarContentView)];
    [swipeUpDown setDirection:(UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown)];
    [swipeUpDown setDelegate:self];
    [self.calendarContentView addGestureRecognizer:swipeUpDown];
    
    
    [self createRandomEvents];
    
    // Create a min and max date for limit the calendar, optional
    [self createMinAndMaxDate];
    
    [_calendarManager setContentView:_calendarContentView];
    [_calendarManager setDate:_todayDate];
}

- (void)extendedCalendarContentView {
    _calendarManager.settings.weekModeEnabled = !_calendarManager.settings.weekModeEnabled;
    [_calendarManager reload];
    
    CGFloat newHeight = 300;
    if(_calendarManager.settings.weekModeEnabled) {
        newHeight = 85.;
    }
    
    self.calendarContentViewHeight.constant = newHeight;
    [UIView animateWithDuration:0.25f animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - UITapRecodnizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    NSArray *indexPaths = [_tableView indexPathsForVisibleRows];
    
    if(indexPaths!=nil && indexPaths.count>0)
    {        
        NSIndexPath *firstVisibleIndexPath = [indexPaths objectAtIndex:0];
        NSLog(@"first visible cell's section: %li, row: %li", (long)firstVisibleIndexPath.section, (long)firstVisibleIndexPath.row);
        
        NSDate *lSelectedDate = [[self dateFormatter] dateFromString:_eventSections[firstVisibleIndexPath.section]];
        if (![_calendarManager.dateHelper date:_dateSelected isTheSameDayThan:lSelectedDate] ) {
            [_calendarManager setDate:lSelectedDate];
            _dateSelected = lSelectedDate;
            [_calendarManager reload];
        }
        [self.view bringSubviewToFront:_todayBtn];
        [_todayBtn setHidden:[_dateSelected isEqualToDate:_todayDate]];
        
        if ([_dateSelected compare:_todayDate] == NSOrderedDescending) {
            [_todayBtn setBackgroundImage:[UIImage imageNamed:@"arrowUpIcon"] forState:UIControlStateNormal];
        } else {
            [_todayBtn setBackgroundImage:[UIImage imageNamed:@"arrowDownIcon"] forState:UIControlStateNormal];
        }
    }
}

#pragma mark - TableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger count = _eventSections.count;
    return count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 35)];
    [headerView setBackgroundColor:UIColorFromRGB(0xf4fafd)];
    NSString *dateString = [self tableView:tableView titleForHeaderInSection:section];
    
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 2, tableView.bounds.size.width, 26)];
    dateLabel.font = [UIFont systemFontOfSize:12];
    dateLabel.text = dateString;
    if ([dateString containsString:@"TODAY"])
        [dateLabel setTextColor:UIColorFromRGB(0x4999c5)];
    else
        [dateLabel setTextColor:UIColorFromRGB(0xa3a1a3)];
    
    [headerView addSubview:dateLabel];
    return headerView;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *dateString = _eventSections[section];
    NSDate *date = [[self dateFormatter] dateFromString:dateString];
    
    return [date relativeDateString];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = _section[_eventSections[section]];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PMCalendarCell *lCell = [tableView dequeueReusableCellWithIdentifier:@"PMCalendarCell"];
    if(lCell==nil) lCell = [PMCalendarCell newCell];
    
    NSArray *array = _section[_eventSections[indexPath.section]];
    
    [lCell setEvent:array[indexPath.row]];
    return lCell;
}

#pragma mark - TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *events = _section[_eventSections[indexPath.section]];
    
    PMEventDetailsVC *lDetailEventVC = [[PMEventDetailsVC alloc] initWithEvents:events index:indexPath.row];
    
    [self.navigationController pushViewController:lDetailEventVC animated:YES];
}

#pragma mark - IBAction selectors

- (IBAction)menuBtnPressed:(id)sender {
    PMCalendarListVC *lCalendarLisctVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PMCalendarListVC"];
    lCalendarLisctVC.delegate = self;
    [self presentViewController:lCalendarLisctVC animated:YES completion:nil];
}

- (IBAction)createEventBtnPressed:(id)sender {
    PMCreateEventVC *lNewEventVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PMCreateEventVC"];
    UINavigationController *lNavContoller = [[UINavigationController alloc] initWithRootViewController:lNewEventVC];
    lNavContoller.navigationBarHidden = YES;
    [lNewEventVC setTitle:@"New Event"];
    [lNewEventVC setDelegate:self];
    [self.tabBarController presentViewController:lNavContoller animated:YES completion:nil];
}

- (void)btnEventListViewPressed:(id)sender
{
    [_tableView setHidden:NO];
    [_calendarGrid setHidden:YES];
    [_btnEventGraphView setHidden:NO];
    [_btnEventListView setHidden:YES];
}

- (void)btnEventGraphViewPressed:(id)sender
{
    [_tableView setHidden:YES];
    [_calendarGrid setHidden:NO];
    [_btnEventGraphView setHidden:YES];
    [_btnEventListView setHidden:NO];
}

#pragma mark - Private methods

#pragma mark - CalendarManager delegate

// Exemple of implementation of prepareDayView method
// Used to customize the appearance of dayView
- (void)calendar:(JTCalendarManager *)calendar prepareDayView:(JTCalendarDayView *)dayView {
    
    NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
    [dateformate setDateFormat:@"MMM yyy"]; // Date formater
    NSString *date = [dateformate stringFromDate:calendar.date];
    _currentMonth.text = date;
    
    // Today
    if([_calendarManager.dateHelper date:[NSDate date] isTheSameDayThan:dayView.date]){
        dayView.circleView.hidden = NO;
        dayView.circleView.backgroundColor = [UIColor blueColor];
        dayView.dotView.backgroundColor = [UIColor whiteColor];
        dayView.textLabel.textColor = [UIColor whiteColor];
    }
    // Selected date
    else if(_dateSelected && [_calendarManager.dateHelper date:_dateSelected isTheSameDayThan:dayView.date]){
        dayView.circleView.hidden = NO;
        dayView.circleView.backgroundColor = [UIColor colorWithRed:90.0f/255.0f green:196.0f/255.0f blue:180.0f/255.0f alpha:1.0f];
        dayView.dotView.backgroundColor = [UIColor whiteColor];
        dayView.textLabel.textColor = [UIColor whiteColor];
    }
    // Other month
    else if(![_calendarManager.dateHelper date:_calendarContentView.date isTheSameMonthThan:dayView.date]){
        dayView.circleView.hidden = YES;
        dayView.dotView.backgroundColor = [UIColor colorWithRed:90.0f/255.0f green:196.0f/255.0f blue:180.0f/255.0f alpha:1.0f];
        dayView.textLabel.textColor = [UIColor lightGrayColor];
    }
    // Another day of the current month
    else{
        dayView.circleView.hidden = YES;
        dayView.dotView.backgroundColor = [UIColor colorWithRed:90.0f/255.0f green:196.0f/255.0f blue:180.0f/255.0f alpha:1.0f];
        dayView.textLabel.textColor = [UIColor blackColor];
    }
    
    if([self haveEventForDay:dayView.date]){
        dayView.dotView.hidden = NO;
    }
    else{
        dayView.dotView.hidden = YES;
    }
}

- (void)calendar:(JTCalendarManager *)calendar didTouchDayView:(JTCalendarDayView *)dayView {
    _dateSelected = dayView.date;
    
    // Animation for the circleView
    dayView.circleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
    [UIView transitionWithView:dayView
                      duration:.3
                       options:0
                    animations:^{
                        dayView.circleView.transform = CGAffineTransformIdentity;
                        [_calendarManager reload];
                    } completion:nil];
    
    
    // Load the previous or next page if touch a day from another month
    
    /*if(![_calendarManager.dateHelper date:_calendarContentView.date isTheSameMonthThan:dayView.date]){
        if([_calendarContentView.date compare:dayView.date] == NSOrderedAscending){
            [_calendarContentView loadNextPageWithAnimation];
        }
        else{
            [_calendarContentView loadPreviousPageWithAnimation];
        }
    }*/
    
    //if (_eventSections.count > 0) {
        NSString *key = [[self dateFormatter] stringFromDate:dayView.date];
        if ([_eventSections containsObject:key]) {
            NSUInteger section = [_eventSections indexOfObject:key];
            [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]
                              atScrollPosition:UITableViewScrollPositionTop animated:YES];
            
        }
    
    [_calendarGrid scrollDateToVisible:dayView.date animated:YES];
    //}
}

#pragma mark - CalendarManager delegate - Page mangement

// Used to limit the date for the calendar, optional
- (BOOL)calendar:(JTCalendarManager *)calendar canDisplayPageWithDate:(NSDate *)date
{
    return [_calendarManager.dateHelper date:date isEqualOrAfter:_minDate andEqualOrBefore:_maxDate];
}

- (void)calendarDidLoadNextPage:(JTCalendarManager *)calendar
{
    //    NSLog(@"Next page loaded");
}

- (void)calendarDidLoadPreviousPage:(JTCalendarManager *)calendar
{
    //    NSLog(@"Previous page loaded");
}

#pragma mark - Fake data

- (void)createMinAndMaxDate {
    _todayDate = [NSDate date];
    
    // Min date will be 2 month before today
    _minDate = [_calendarManager.dateHelper addToDate:_todayDate months:-3];
    
    // Max date will be 2 month after today
    _maxDate = [_calendarManager.dateHelper addToDate:_todayDate months:12];
}

// Used only to have a key for _eventsByDate
- (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"dd-MM-yyyy";
    }
    
    return dateFormatter;
}

- (BOOL)haveEventForDay:(NSDate *)date
{
    NSString *key = [[self dateFormatter] stringFromDate:date];
    
    if(_section[key] && [_section[key] count] > 0){
        return YES;
    }
    
    return NO;
    
}

- (void)createRandomEvents {
   
    [_section removeAllObjects];
    for(PMEventModel *event in _eventsArray){
        
        // Generate 30 random dates between now and 60 days later
        NSDate *date = [NSDate date];
        
        switch (event.eventDateType) {
            case EventDateTimeType: {
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:[event.startTime doubleValue]];
                
                NSString *key = [[self dateFormatter] stringFromDate:date];
                
                if(!_section[key]) _section[key] = [NSMutableArray new];
                
                [_section[key] addObject:event];
            }
                break;
                
            case EventDateTimespanType: {
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:[event.startTime doubleValue]];
                NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:[event.endTime doubleValue]];
                
                NSTimeInterval interval = [endDate timeIntervalSinceDate:date];
                
                while(interval > 0)
                {
                    
                    NSString *key = [[self dateFormatter] stringFromDate:date];
                    
                    if(!_section[key]) _section[key] = [NSMutableArray new];
                    
                    [_section[key] addObject:event];
                    
                    date = [date dateByAddingTimeInterval:60*60*24];
                    
                    interval = [endDate timeIntervalSinceDate:date];
                }
            }
                
                break;
                
            case EventDateDateType: {
                date = [NSDate eventDateFromString:event.startTime];
                
                // Use the date as key for eventsByDate
                NSString *key = [[self dateFormatter] stringFromDate:date];
                
                if(!_section[key]) _section[key] = [NSMutableArray new];
                
                [_section[key] addObject:event];
            }
                break;
                
            case EventDateDatespanType: {
                NSDate *date = [NSDate eventDateFromString:event.startTime];
                NSDate *endDate = [NSDate eventDateFromString:event.endTime];
                
                NSTimeInterval interval = [endDate timeIntervalSinceDate:date];
                while(interval > 0)
                {
                    
                    NSString *key = [[self dateFormatter] stringFromDate:date];
                    
                    if(!_section[key]) _section[key] = [NSMutableArray new];
                    
                    [_section[key] addObject:event];
                    
                    date = [date dateByAddingTimeInterval:60*60*24];
                    
                    interval = [endDate timeIntervalSinceDate:date];
                }
            }
                break;
                
            default:
                break;
        }
        
        
    }
    
    _eventSections = [_section.allKeys sortedArrayUsingComparator:
                                            ^(id obj1, id obj2) {
                                                NSDate *d1 = [[self dateFormatter] dateFromString:obj1];
                                                NSDate *d2 = [[self dateFormatter] dateFromString:obj2];
                                                
                                                return [d1 compare:d2];
                                            }];
    
    for(NSString*key in _section.allKeys) {
        NSArray *events = _section[key];
        
        events = [events sortedArrayUsingComparator:^NSComparisonResult(PMEventModel *event1, PMEventModel *event2) {
            NSDate *date1 = [event1 getStartDate];
            NSDate *date2 = [event2 getStartDate];
            
            return [date1 compare:date2];
        }];
        
        [_section setObject:events forKey:key];
    }
    
    [_tableView reloadData];
    [_calendarGrid reloadData];
    [_calendarManager reload];
    NSString *key = [[self dateFormatter] stringFromDate:_todayDate];
    if ([_eventSections containsObject:key]) {
        NSUInteger section = [_eventSections indexOfObject:key];
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]
                          atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    
    DLog(@"_eventsByDate - %@", _section);
    
    
    _tableView.backgroundView.hidden = _eventsArray.count;
    
    
    NSIndexPath *indexPathToScroll;
    
    NSDate *today = [NSDate date];
    NSString *todayKey = [[self dateFormatter] stringFromDate:today];
    NSInteger index = [_section.allKeys indexOfObject:todayKey];
    if(index == NSNotFound)
    {
        index = _section.allKeys.count - 1;
    }
    
    if(index >= 0)
    {
        indexPathToScroll = [NSIndexPath indexPathForRow:0 inSection:index];
        [_tableView scrollToRowAtIndexPath:indexPathToScroll
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:YES];
    }
    
    
    

}

#pragma mark DDCalendarViewDelegate

- (void)calendarView:(DDCalendarView* _Nonnull)view focussedOnDay:(NSDate* _Nonnull)date {
    //self.dayLabel.text = date.stringWithDateOnly;
    if (![_calendarManager.dateHelper date:_dateSelected isTheSameDayThan:date] ) {
        [_calendarManager setDate:date];
        _dateSelected = date;
        [_calendarManager reload];
    }
}

- (void)calendarView:(DDCalendarView* _Nonnull)view didSelectEvent:(DDCalendarEvent* _Nonnull)event {
    NSInteger index = [_eventsArray indexOfObject:event.event];
    PMEventDetailsVC *lDetailEventVC = [[PMEventDetailsVC alloc] initWithEvents:_eventsArray index:index];
    
    [self.navigationController pushViewController:lDetailEventVC animated:YES];
}

- (BOOL)calendarView:(DDCalendarView* _Nonnull)view allowEditingEvent:(DDCalendarEvent* _Nonnull)event {
    return NO;
}

- (void)calendarView:(DDCalendarView* _Nonnull)view commitEditEvent:(DDCalendarEvent* _Nonnull)event {
    NSLog(@"%@", event);
    //should do conflic validation and maybe save ;) or revert :P
}

#pragma mark DDCalendarViewDataSource

- (NSArray *)calendarView:(DDCalendarView *)view eventsForDay:(NSDate *)date {
    NSString *key = [[self dateFormatter] stringFromDate:date];
    NSMutableArray *lResult = [NSMutableArray new];
    NSMutableArray *dates = _section[key];
    for (PMEventModel *e in dates) {
        //if(e.eventDateType == EventDateTimeType || e.eventDateType == EventDateTimespanType)
        {
            DDCalendarEvent *event2 = [DDCalendarEvent new];
            [event2 setTitle:e.title];
            [event2 setEvent:e];
            [event2 setDateBegin:[NSDate dateWithTimeIntervalSince1970:[e.startTime doubleValue]]];
            [event2 setDateEnd:[NSDate dateWithTimeIntervalSince1970:[e.endTime doubleValue]]];
            [event2 setUserInfo:@{@"color":[e getColor]}];
            [lResult addObject:event2];
        }
    }
    return lResult;
}

//optionally provide a view
- (DDCalendarEventView *)calendarView:(DDCalendarView *)view viewForEvent:(DDCalendarEvent *)event {
    return [[EventView alloc] initWithEvent:event];
}



#pragma PMCalendarListVCDelegate

-(void)didSelectCalendar
{
    [self loadEvents];
}
@end
