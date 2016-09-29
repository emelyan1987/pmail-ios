//
//  PMTrackListVC.m
//  planckMailiOS
//
//  Created by LionStar on 1/15/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import "PMTrackListVC.h"
#import "DBTrack.h"
#import "PMTrackTVCell.h"
#import "PMTrackDetailVC.h"
#import "PMAPIManager.h"
#import "Config.h"
#import "AlertManager.h"

#define LINE_HEIGHT 3
typedef NS_ENUM(NSInteger, SelectedTime) {
    Today = 0,
    Last7Days,
    Last31Days
};

@interface PMTrackListVC () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lblTotals;
@property (weak, nonatomic) IBOutlet UILabel *lblOpens;
@property (weak, nonatomic) IBOutlet UILabel *lblClicks;
@property (weak, nonatomic) IBOutlet UILabel *lblReplies;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentCategory;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSString* filterStatus;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (nonatomic, strong) NSArray *items;

@property (weak, nonatomic) IBOutlet UIButton *btnTimeToday;
@property (weak, nonatomic) IBOutlet UIButton *btnTimeLast7;
@property (weak, nonatomic) IBOutlet UIButton *btnTimeLast31;

@property (weak, nonatomic) IBOutlet UIView *viewSelectedLine;
@property (nonatomic, assign) SelectedTime currentSelectedTime;
@end

@implementation PMTrackListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _items = [NSMutableArray new];
    
    _filterStatus = EMAIL_TRACKING_OPENED;
    
    
    _refreshControl = [[UIRefreshControl alloc] init];
    
    [_refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];
    
    [self selectTime:Last7Days];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlerForAccountChangedNotification:) name:NOTIFICATION_ACTIVE_ACCOUNT_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlerForEmailTrackingChangedNotification:) name:NOTIFICATION_EMAIL_TRACKING_CHANGED object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    //[self loadData:_filterStatus];
}
-(void)handleRefresh:(id)sender
{
    [self loadData:_filterStatus];
    [_refreshControl endRefreshing];
}
- (void)handlerForAccountChangedNotification:(NSNotification*)notification
{
    [self loadData:_filterStatus];
}
- (void)handlerForEmailTrackingChangedNotification:(NSNotification*)notification
{
    [self loadData:_filterStatus];
}

-(void)loadData:(NSString*)status
{
    NSString *time;
    
    switch (_currentSelectedTime) {
        case Today:
            time = EMAIL_TRACKING_TODAY;
            break;
        case Last31Days:
            time = EMAIL_TRACKING_LAST31;
            break;
        case Last7Days:
        default:
            time = EMAIL_TRACKING_LAST7;
            break;
    }
    
    _items = [[PMAPIManager shared] getEmailTrackList:[PMAPIManager shared].namespaceId.email_address trackStatus:status time:time completion:^(id data, id error, BOOL success) {
        
        _items = [NSMutableArray arrayWithArray:data];
        
        
        [self updateStatisticsData:_items];
        [_tableView reloadData];
    }];
    
    [self updateStatisticsData:_items];
    [_tableView reloadData];
}

-(void)updateStatisticsData:(NSArray*)tracks
{
    
    _lblTotals.text = [NSString stringWithFormat:@"%d Totals", (int)tracks.count];
    
    NSDictionary *statisticsData = [self calculateStatistics:tracks];
    _lblOpens.text = [NSString stringWithFormat:@"%d Opens", [statisticsData[@"opens"] intValue]];
    _lblClicks.text = [NSString stringWithFormat:@"%d Clicks", [statisticsData[@"links"] intValue]];
    _lblReplies.text = [NSString stringWithFormat:@"%d Replies", [statisticsData[@"replies"] intValue]];
}
-(NSDictionary*)calculateStatistics:(NSArray*)tracks
{
    int opens = 0, links = 0, replies = 0;
    for(NSDictionary *track in tracks)
    {
        if(track[@"opens"] && ![track[@"opens"] isEqual:[NSNull null]] && [track[@"opens"] intValue]>0) opens+=[track[@"opens"] intValue];
        if(track[@"links"] && ![track[@"links"] isEqual:[NSNull null]] && [track[@"links"] intValue]>0) links+=[track[@"links"] intValue];
        if(track[@"replies"] && ![track[@"replies"] isEqual:[NSNull null]] && [track[@"replies"] intValue]>0) replies+=[track[@"replies"] intValue];
    }
    
    return @{@"opens":@(opens), @"links":@(links), @"replies":@(replies)};
}
- (IBAction)segmentCategoryValueChanged:(id)sender
{
    UISegmentedControl *segmentCtrl = (UISegmentedControl*)sender;
    
    _filterStatus = nil;
    if(segmentCtrl.selectedSegmentIndex==0) _filterStatus = EMAIL_TRACKING_OPENED;
    else if(segmentCtrl.selectedSegmentIndex==2) _filterStatus = EMAIL_TRACKING_UNOPENED;
    else _filterStatus = nil;
    
    [self loadData:_filterStatus];
}


# pragma mark UITableViewDataSource & UITableViewDelegate implementation

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 85;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _items.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PMTrackTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"trackCell"];
    
    NSDictionary *item = _items[indexPath.row];
    [cell bindData:item];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PMTrackDetailVC *detailVC = [TRACKING_STORYBOARD instantiateViewControllerWithIdentifier:@"PMTrackDetailVC"];
    
    NSDictionary *track = _items[indexPath.row];
    detailVC.track = track;
    [self.navigationController pushViewController:detailVC animated:YES];
}

-(void)selectTime:(SelectedTime)selectedTime
{
    [UIView animateWithDuration:.2f animations:^{
        CGRect lineCurrentFrame = _viewSelectedLine.frame;
        CGRect lineNewFrame;
        
        if (selectedTime == Today)
        {
            lineNewFrame = CGRectMake(_btnTimeToday.frame.origin.x, _btnTimeToday.frame.size.height - LINE_HEIGHT, lineCurrentFrame.size.width, LINE_HEIGHT);
        }
        else if (selectedTime == Last7Days)
        {
            lineNewFrame = CGRectMake(_btnTimeLast7.frame.origin.x, _btnTimeLast7.frame.size.height - LINE_HEIGHT, lineCurrentFrame.size.width, LINE_HEIGHT);
        }
        else if (selectedTime == Last31Days)
        {
            lineNewFrame = CGRectMake(_btnTimeLast31.frame.origin.x, _btnTimeLast31.frame.size.height - LINE_HEIGHT, lineCurrentFrame.size.width, LINE_HEIGHT);
        }
        
        [_viewSelectedLine setFrame:lineNewFrame];
        
    }];
    
    _currentSelectedTime = selectedTime;
    
    [self loadData:_filterStatus];
}
- (IBAction)btnTodayPressed:(id)sender {
    [self selectTime:Today];
}
- (IBAction)btnLast7Pressed:(id)sender {
    [self selectTime:Last7Days];
}
- (IBAction)btnLast31Pressed:(id)sender {
    [self selectTime:Last31Days];
}
@end
