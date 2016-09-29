//
//  PMContactEventTableView.m
//  planckMailiOS
//
//  Created by Matko Lajbaher on 12/5/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMContactEventTableView.h"
#import "Config.h"
#import "PMAPIManager.h"
#import "UITableView+BackgroundText.h"
#import <JTCalendar/JTCalendar.h>
#import "PMParticipantModel.h"
#import "NSDate+DateConverter.h"
#import "PMCalendarCell.h"


@interface PMContactEventTableView() <UITableViewDataSource, UITableViewDelegate>
{
    UILabel *emptyMessageLabel;
    
    NSDate *_today;
    NSDate *_minDate;
    NSDate *_maxDate;
    
    
    NSMutableDictionary *_section;
    NSArray *_eventSections;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
@implementation PMContactEventTableView
+ (instancetype)createWithModel:(PMContactModel *)model
{
    PMContactEventTableView *view = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] lastObject];
    if ([view isKindOfClass:[self class]]){
        view.model = model;
        return view;
    } else {
        return nil;
    }
}
-(void)awakeFromNib
{
    [super awakeFromNib];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        
    _today = [NSDate date];
    _minDate = [_today dateByAddingTimeInterval:-60*60*24*60];
    _maxDate = [_today dateByAddingTimeInterval:60*60*24*365];
    
    _section = [NSMutableDictionary new];
    _events = [NSMutableArray new];
    //_eventSections = [NSMutableDictionary new];
    
    _tableView.backgroundView.hidden = NO;
}
- (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"dd-MM-yyyy";
    }
    
    return dateFormatter;
}
- (void)buildDataForShowing {
    [_section removeAllObjects];
    for(PMEventModel *event in _events){
        
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
    
    [_tableView reloadData];
    
    NSString *key = [[self dateFormatter] stringFromDate:_today];
    if ([_eventSections containsObject:key]) {
        NSUInteger section = [_eventSections indexOfObject:key];
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]
                          atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    
    NSLog(@"_eventsByDate - %@", _section);
}

-(void)setModel:(PMContactModel *)model
{
    _model = model;
    
    
    [_tableView showEmptyMessage:[NSString stringWithFormat:@"You have no events with %@", [_model.name isEqual:[NSNull null]] || _model.name.length==0 ? _model.email : _model.name]];
    
    [self loadEvents];
}

-(void)loadEvents
{
    [_events removeAllObjects];
    NSDictionary *eventParams = @{
                                  @"starts_after" : [NSString stringWithFormat:@"%f", [_minDate timeIntervalSince1970]],
                                  @"ends_before" : [NSString stringWithFormat:@"%f", [_maxDate timeIntervalSince1970]],
                                  @"expand_recurring" : @"true"/*,
                                                                @"limit" : @100,
                                                                @"offset" : @(_offset)*/
                                  };
    __weak typeof(self)__self = self;
    
    NSMutableArray *eventArray = [NSMutableArray new];
    NSArray *namespaces = [[DBManager instance] getNamespaces];
    for(DBNamespace *namespace in namespaces)
    {
        NSArray *events = [[PMAPIManager shared] getEventsWithAccount:namespace.account_id eventParams:eventParams comlpetion:^(id data, id error, BOOL success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSArray *results = data;
                //_offset = __self.eventsArray.count;
                
                [self setEventsData:results];
                
            });
        }];
        
        [eventArray addObjectsFromArray:events];
    }
    
    [self setEventsData:eventArray];
    
}

- (void)setEventsData:(NSArray*)eventArray
{
    for(PMEventModel *event in eventArray)
    {
        for(PMParticipantModel *participant in event.participants)
        {
            if(![self containsEvent:event] && [participant.email isEqualToString:_model.email])
            {
                [_events addObject:event]; break;
            }
        }
    }
    
    
    if (_events.count > 0) {
        _tableView.backgroundView.hidden = YES;
        // Generate random events sort by date using a dateformatter for the demonstration
        if([self.delegate respondsToSelector:@selector(didLoadEvents:)])
            [self.delegate didLoadEvents:_events];
        [self buildDataForShowing];
    }

}
- (BOOL)containsEvent:(PMEventModel *)event
{
    for(PMEventModel *item in self.events)
    {
        if([event.id isEqualToString:item.id]) return YES;
    }
    
    return NO;
}
//-(void)setEvents:(NSArray *)events
//{
//    _events = events;
//    [self.tableView reloadData];
//}

-(void)refreshData
{
    [self loadEvents];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 70;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _eventSections.count;
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
    
    NSInteger index = indexPath.row;
    NSArray *array = _section[_eventSections[indexPath.section]];
    PMEventModel *event = array[indexPath.row];
    
    if([self.delegate respondsToSelector:@selector(didSelectEvent:index:)])
        [self.delegate didSelectEvent:event index:index];
}


@end
