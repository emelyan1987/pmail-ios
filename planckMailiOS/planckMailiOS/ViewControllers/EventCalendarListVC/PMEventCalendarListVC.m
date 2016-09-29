//
//  PMEventCalendarListVC.m
//  planckMailiOS
//
//  Created by admin on 9/21/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMEventCalendarListVC.h"
#import "DBManager.h"
#import "PMAPIManager.h"
#import "PMEventCalendarListTVCell.h"

@interface PMEventCalendarListVC ()<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *calendars;
    
    NSInteger selectedIndex;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation PMEventCalendarListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavigationBar];
    
    
    calendars = [NSMutableArray arrayWithArray:[[DBManager instance] getWritableCalendars]];
    
    [[PMAPIManager shared] getCalendarsWithAccount:[[PMAPIManager shared] namespaceId].account_id comlpetion:^(id data, id error, BOOL success) {
        
        for (DBCalendar *item in data) {
            
            if(![self containsCalendar:item] && ![item.readOnly boolValue])
            {
                [calendars addObject:item];
            }
        }
        [_tableView reloadData];
        DLog(@"getCalendarsWithAccount - %@", data);
    }];
    
    selectedIndex = 0;
}
- (BOOL)containsCalendar:(DBCalendar*)calendar
{
    for(DBCalendar *item in calendars)
    {
        if([item.calendarId isEqualToString:calendar.calendarId]) return YES;
    }
    
    return NO;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setNavigationBar
{
    
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backArrow.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
    [self.navigationItem setLeftBarButtonItem:btnBack animated:NO];
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc]initWithTitle:@"DONE"  style:UIBarButtonItemStylePlain target:self action:@selector(onDone)];
    
    [doneBtn setTitleTextAttributes:@{
                                         NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:14.0f],
                                         NSForegroundColorAttributeName: [UIColor whiteColor]
                                         } forState:UIControlStateNormal];
    [self.navigationItem setRightBarButtonItem:doneBtn];
    
    UILabel *lblTitle = [[UILabel alloc]init];
    [lblTitle setFont:[UIFont fontWithName:@"Helvetica" size:18.0f]];
    lblTitle.text = @"Select Calendar";
    lblTitle.textColor = [UIColor whiteColor];
    
    float maximumLabelSize =  [lblTitle.text boundingRectWithSize:lblTitle.frame.size  options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:lblTitle.font } context:nil].size.width;
    
    lblTitle.frame = CGRectMake(0, 0, maximumLabelSize, 35);
    UIView *headerview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, maximumLabelSize, 35)];
    
    [headerview addSubview:lblTitle];
    
    self.navigationItem.titleView = headerview;
}

-(void)onDone
{
    if([self.delegate respondsToSelector:@selector(didSelectCalendar:)])
        [self.delegate didSelectCalendar:_selectedCalendar];
    
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)onBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UITableViewDataSource & UITableViewDelegate implements


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PMEventCalendarListTVCell *lCell = [tableView dequeueReusableCellWithIdentifier:@"eventCalendarListCell"];
    
    DBCalendar *calendar = calendars[indexPath.row];
    [lCell configureCell:calendar selected:[calendar.calendarId isEqualToString:_selectedCalendar.calendarId]];
    
    return lCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return calendars.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    _selectedCalendar = [calendars objectAtIndex:indexPath.row];
    
    [_tableView reloadData];
}
@end
