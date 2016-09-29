//
//  PMConferenceVC.m
//  planckMailiOS
//
//  Created by LionStar on 2/4/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import "PMConferenceVC.h"
#import "DBNamespace.h"
#import "DBManager.h"
#import "PMEventModel.h"
#import "PMConferenceModel.h"
#import "PMConferenceCell.h"
#import "PMAPIManager.h"
#import "NSDate+DateConverter.h"
#import "UITableView+BackgroundText.h"

#define CONFERENCE_LINK_CISCO_WEBEX @"https://cisco.webex.com/join/"
#define CONFERENCE_LINK_GO_WEBEX @"https://go.webex.com/meeting"
#define CONFERENCE_LINK_GOOGLE_HANGOUT @"https://plus.google.com/hangouts"
#define CONFERENCE_LINK_GOTO_MEETING @"https://global.gotomeeting.com/join"
#define CONFERENCE_LINK_JOIN_ME @"https://join.me/"
#define CONFERENCE_LINK_SKYPE @">https://join.skype.com"

@interface PMConferenceVC () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *conferences;
@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSMutableDictionary *itemsForSection;

@property (nonatomic, strong) NSDate *minDate;
@property (nonatomic, strong) NSDate *maxDate;


@property (nonatomic, strong) UIRefreshControl *refreshControl;


@end

@implementation PMConferenceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self loadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlerNotificationEventChanged:) name:NOTIFICATION_EVENT_UPDATED object:nil];
    
    
    _refreshControl = [[UIRefreshControl alloc] init];
    
    [_refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];
    
    [_tableView showEmptyMessage:@"There is no conference call today."];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)handleRefresh:(id)sender
{
    [self loadData];

    [_refreshControl endRefreshing];
}
-(void)handlerNotificationEventChanged:(NSNotification*)notification
{
    [self loadData];
}
- (void)loadData
{
    if(self.conferences==nil) self.conferences = [NSMutableArray new];
    if(self.conferences.count) [self.conferences removeAllObjects];
    
    //_minDate = [NSDate date];
    _minDate = [NSDate dateWithTimeIntervalSinceNow:0];
    _maxDate = [NSDate dateWithTimeIntervalSinceNow:24 * 60 * 60];
    
    __weak typeof(self)__self = self;
    
    NSMutableDictionary *eventParams = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                       @"starts_after" : [NSString stringWithFormat:@"%f", [_minDate timeIntervalSince1970]],
                                                                                       @"ends_before" : [NSString stringWithFormat:@"%f", [_maxDate timeIntervalSince1970]],
                                                                                       @"expand_recurring" : @"true"                                                                                       }];
    
    NSArray *namespaces = [[DBManager instance] getNamespaces];
    for(DBNamespace *namespace in namespaces)
    {
        NSArray *events = [[PMAPIManager shared] getEventsWithAccount:namespace.account_id eventParams:eventParams comlpetion:^(id data, id error, BOOL success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                for(PMEventModel *event in data)
                {
                    NSDate *startTime = [NSDate dateWithTimeIntervalSince1970:[event.startTime doubleValue]];
                    NSDate *endTime = [NSDate dateWithTimeIntervalSince1970:[event.endTime doubleValue]];
                    
                    if([_minDate compare:startTime] == NSOrderedDescending || [_maxDate compare:endTime] == NSOrderedAscending || event.messageId == nil) continue;
                    
                    NSString *link = [__self getConferenceLinkFromEventModel:event];
                    if(link)
                    {
                        PMConferenceModel *newConference = [[PMConferenceModel alloc] initFromEventModel:event];
                        newConference.link = link;
                        
                        NSString *eventId = event.id;
                        PMConferenceModel *existConference = [__self getConferenceWithEventId:eventId];
                        if(!existConference)
                        {
                            [__self.conferences addObject:newConference];
                        }
                        else
                        {
                            NSInteger index = [__self.conferences indexOfObject:existConference];
                            [__self.conferences replaceObjectAtIndex:index withObject:newConference];
                        }
                    }
                }
                
                [__self refreshData];
                
            });
        }];
        
        for(PMEventModel *event in events)
        {
            NSDate *startTime = [NSDate dateWithTimeIntervalSince1970:[event.startTime doubleValue]];
            NSDate *endTime = [NSDate dateWithTimeIntervalSince1970:[event.endTime doubleValue]];
            
            if([_minDate compare:startTime] == NSOrderedDescending || [_maxDate compare:endTime] == NSOrderedAscending || event.messageId == nil) continue;
            
            NSString *link = [self getConferenceLinkFromEventModel:event];
            if(link)
            {
                PMConferenceModel *newConference = [[PMConferenceModel alloc] initFromEventModel:event];
                newConference.link = link;
                
                NSString *eventId = event.id;
                PMConferenceModel *existConference = [self getConferenceWithEventId:eventId];
                if(!existConference)
                {
                    [self.conferences addObject:newConference];
                }
                else
                {
                    NSInteger index = [self.conferences indexOfObject:existConference];
                    [self.conferences replaceObjectAtIndex:index withObject:newConference];
                }
            }
        }
        
        
        
        [self refreshData];
    }
    
}

- (void)refreshData
{
    if(_conferences.count==0)
    {
        _tableView.backgroundView.hidden = NO;
    }
    else
    {
        _tableView.backgroundView.hidden = YES;
        
        [_conferences sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NSDate *startTime1 = ((PMConferenceModel*)obj1).startTime;
            NSDate *startTime2 = ((PMConferenceModel*)obj2).startTime;
            
            if (startTime1 < startTime2) {
                return (NSComparisonResult)NSOrderedAscending;
            } else {
                return (NSComparisonResult)NSOrderedDescending;
            }
        }];
        
        [_tableView reloadData];
    }
}
- (NSString*)getConferenceLinkFromEventModel:(PMEventModel*)eventModel
{
    DBMessage *message = [DBMessage getMessageWithId:eventModel.messageId];
    
    
    return [self getConferenceLinkFromText:message.body];
}

-(NSString*)getConferenceLinkFromText:(NSString*)text
{
    text = [text stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
    text = [text stringByReplacingOccurrencesOfString:@"\\\'" withString:@"\'"];
    
    NSRange range = [text rangeOfString:CONFERENCE_LINK_CISCO_WEBEX];
    if(range.location != NSNotFound)
    {
        NSString *subString = [text substringFromIndex:range.location];
        
        NSRange subRange = [subString rangeOfString:@"\""];
        if(subRange.location != NSNotFound)
        {
            NSRange linkRange = NSMakeRange(0, subRange.location);
            NSString *link = [subString substringWithRange:linkRange];
            
            return link;
        }
        
        subRange = [subString rangeOfString:@"\'"];
        if(subRange.location != NSNotFound)
        {
            NSRange linkRange = NSMakeRange(0, subRange.location);
            NSString *link = [subString substringWithRange:linkRange];
            
            return link;
        }
    }
    
    range = [text rangeOfString:CONFERENCE_LINK_GO_WEBEX];
    if(range.location != NSNotFound)
    {
        NSString *subString = [text substringFromIndex:range.location];
        
        NSRange subRange = [subString rangeOfString:@"\""];
        if(subRange.location != NSNotFound)
        {
            NSRange linkRange = NSMakeRange(0, subRange.location);
            NSString *link = [subString substringWithRange:linkRange];
            
            return link;
        }
        
        subRange = [subString rangeOfString:@"\'"];
        if(subRange.location != NSNotFound)
        {
            NSRange linkRange = NSMakeRange(0, subRange.location);
            NSString *link = [subString substringWithRange:linkRange];
            
            return link;
        }
    }
    
    range = [text rangeOfString:CONFERENCE_LINK_GOOGLE_HANGOUT];
    if(range.location != NSNotFound)
    {
        NSString *subString = [text substringFromIndex:range.location];
        
        NSRange subRange = [subString rangeOfString:@"\""];
        if(subRange.location != NSNotFound)
        {
            NSRange linkRange = NSMakeRange(0, subRange.location);
            NSString *link = [subString substringWithRange:linkRange];
            
            return link;
        }
        
        subRange = [subString rangeOfString:@"\'"];
        if(subRange.location != NSNotFound)
        {
            NSRange linkRange = NSMakeRange(0, subRange.location);
            NSString *link = [subString substringWithRange:linkRange];
            
            return link;
        }
    }
    range = [text rangeOfString:CONFERENCE_LINK_GOTO_MEETING];
    if(range.location != NSNotFound)
    {
        NSString *subString = [text substringFromIndex:range.location];
        
        NSRange subRange = [subString rangeOfString:@"\""];
        if(subRange.location != NSNotFound)
        {
            NSRange linkRange = NSMakeRange(0, subRange.location);
            NSString *link = [subString substringWithRange:linkRange];
            
            return link;
        }
        
        subRange = [subString rangeOfString:@"\'"];
        if(subRange.location != NSNotFound)
        {
            NSRange linkRange = NSMakeRange(0, subRange.location);
            NSString *link = [subString substringWithRange:linkRange];
            
            return link;
        }
    }
    range = [text rangeOfString:CONFERENCE_LINK_JOIN_ME];
    if(range.location != NSNotFound)
    {
        NSString *subString = [text substringFromIndex:range.location];
        
        NSRange subRange = [subString rangeOfString:@"\""];
        if(subRange.location != NSNotFound)
        {
            NSRange linkRange = NSMakeRange(0, subRange.location);
            NSString *link = [subString substringWithRange:linkRange];
            
            return link;
        }
        
        subRange = [subString rangeOfString:@"\'"];
        if(subRange.location != NSNotFound)
        {
            NSRange linkRange = NSMakeRange(0, subRange.location);
            NSString *link = [subString substringWithRange:linkRange];
            
            return link;
        }
    }
    range = [text rangeOfString:CONFERENCE_LINK_SKYPE];
    if(range.location != NSNotFound)
    {
        NSString *subString = [text substringFromIndex:range.location];
        
        NSRange subRange = [subString rangeOfString:@"</"];
        if(subRange.location != NSNotFound)
        {
            NSRange linkRange = NSMakeRange(1, subRange.location-1);
            NSString *link = [subString substringWithRange:linkRange];
            
            return link;
        }
        
        subRange = [subString rangeOfString:@"\'"];
        if(subRange.location != NSNotFound)
        {
            NSRange linkRange = NSMakeRange(0, subRange.location);
            NSString *link = [subString substringWithRange:linkRange];
            
            return link;
        }
    }
    return nil;
}
- (PMConferenceModel*)getConferenceWithEventId:(NSString*)eventId
{
    for(PMConferenceModel *conference in self.conferences)
    {
        if([conference.eventId isEqualToString:eventId]) return conference;
    }
    
    return nil;
}

#pragma mark UITableViewDataSource & UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [_minDate relativeDateString];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _conferences.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PMConferenceModel *model = [_conferences objectAtIndex:indexPath.row];
    
    PMConferenceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"conferenceCell"];
    
    [cell bindModel:model];
    
    cell.btnJoinTapAction = ^(id sender) {
        DLog(@"Conference Link: %@", model.link);
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: model.link]];
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
