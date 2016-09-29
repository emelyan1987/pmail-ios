//
//  PMDefaultEmailVC.m
//  planckMailiOS
//
//  Created by LionStar on 12/25/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMDefaultCalendarTVC.h"
#import "DBManager.h"
#import "PMSettingsManager.h"
#import "PMAPIManager.h"
#import "Config.h"
#import "PMEventCalendarListTVCell.h"
#import "PMAccountManager.h"


@interface PMDefaultCalendarTVC () <UITableViewDataSource, UITableViewDelegate>
{
    NSArray *_namespaces;
    DBCalendar *_defaultCalendar;
    
    NSMutableDictionary *_calendarsForAccount;
}
@end

@implementation PMDefaultCalendarTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBar];
    [self.tableView setTableHeaderView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    _namespaces = [[DBManager instance] getNamespaces];
    _defaultCalendar = [[PMSettingsManager instance] getDefaultCalendar];
    
    
    _calendarsForAccount = [[NSMutableDictionary alloc] init];
    
    for(DBNamespace *namespace in _namespaces)
    {
        NSLog(@"Account Provider : %@", namespace.provider);
        
        NSArray *calendars = [[PMAPIManager shared] getCalendarsWithAccount:namespace.account_id comlpetion:^(id data, id error, BOOL success) {
            
            for (DBCalendar *calendar in data) {
                NSArray *inCalendars = _calendarsForAccount[namespace.account_id];
                if(![self containsCalendar:calendar inCalendars:inCalendars])
                {
                    NSMutableArray *calendars = [_calendarsForAccount objectForKey:namespace.account_id];
                    if(calendars==nil) calendars = [NSMutableArray new];
                    [calendars addObject:calendar];
                    
                    [_calendarsForAccount setObject:calendars forKey:namespace.account_id];
                }
            }
            
            [self.tableView reloadData];
            DLog(@"getCalendarsWithAccount - %@", data);
        }];
        
        for(DBCalendar *calendar in calendars)
        {
            NSMutableArray *calendars = [_calendarsForAccount objectForKey:namespace.account_id];
            if(calendars==nil) calendars = [NSMutableArray new];
            [calendars addObject:calendar];
            
            [_calendarsForAccount setObject:calendars forKey:namespace.account_id];
        }
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)setNavigationBar
{
    
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backArrow.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
    [self.navigationItem setLeftBarButtonItem:btnBack animated:NO];
    
    UILabel *lblTitle = [[UILabel alloc]init];
    [lblTitle setFont:[UIFont fontWithName:@"Helvetica" size:18.0f]];
    lblTitle.text = @"Default Calendar";
    lblTitle.textColor = [UIColor whiteColor];
    
    float maximumLabelSize =  [lblTitle.text boundingRectWithSize:lblTitle.frame.size  options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:lblTitle.font } context:nil].size.width;
    
    lblTitle.frame = CGRectMake(0, 0, maximumLabelSize, 35);
    UIView *headerview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, maximumLabelSize, 35)];
    
    [headerview addSubview:lblTitle];
    
    self.navigationItem.titleView = headerview;
}

-(void)onBack
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (BOOL)containsCalendar:(DBCalendar*)calendar inCalendars:(NSArray*)inCalendars
{
    for(DBCalendar *item in inCalendars)
    {
        if([item.calendarId isEqualToString:calendar.calendarId]) return YES;
    }
    
    return NO;
}

#pragma UITableViewDataSource & UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _namespaces.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DBNamespace *namespace = [_namespaces objectAtIndex:section];
    NSArray *calendars = _calendarsForAccount[namespace.account_id];
    return calendars.count;
}
//-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    DBNamespace *namespace = [_namespaces objectAtIndex:section];
//    
//    return namespace.email_address;
//}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    //put your values, this is part of my code
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44.0f)];
    [view setBackgroundColor:[UIColor clearColor]];
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(50, 5, view.bounds.size.width-50, 20)];
    lbl.font = [UIFont systemFontOfSize:16];
    lbl.textColor = [UIColor darkGrayColor];
    [view addSubview:lbl];
    
    DBNamespace *namespace = [_namespaces objectAtIndex:section];
    NSString *provider = namespace.provider;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 25, 25)];
    imageView.image = [UIImage imageNamed:[[PMAccountManager sharedManager] iconNameByProvider:provider]];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [view addSubview:imageView];
    
    [lbl setText:[NSString stringWithFormat:@"%@ - %@", namespace.provider, namespace.email_address]];
    
    return view;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DBNamespace *namespace = _namespaces[indexPath.section];
    
    DBCalendar *calendar = _calendarsForAccount[namespace.account_id][indexPath.row];
    
    static NSString *cellIdentifier = @"calendarCell";
    PMEventCalendarListTVCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    [cell configureCell:calendar selected:[_defaultCalendar.calendarId isEqualToString:calendar.calendarId]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DBNamespace *namespace = _namespaces[indexPath.section];
    _defaultCalendar = _calendarsForAccount[namespace.account_id][indexPath.row];
    
    [[PMSettingsManager instance] setDefaultCalendar:_defaultCalendar];
    
    [tableView reloadData];
    
    if([self.delegate respondsToSelector:@selector(defaultCalendarTVC:didSelectCalendar:)])
        [self.delegate defaultCalendarTVC:self didSelectCalendar:_defaultCalendar];
    
}
@end
