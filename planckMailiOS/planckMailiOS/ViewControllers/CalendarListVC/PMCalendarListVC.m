//
//  PMCalendarListVC.m
//  planckMailiOS
//
//  Created by Lyubomyr Hlozhyk on 10/18/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMCalendarListVC.h"
#import "PMAPIManager.h"
#import "DBManager.h"
#import "PMCalendarColourVC.h"
#import "UIViewController+PMStoryboard.h"
#import "PMCalendarListTVCell.h"

@interface PMCalendarListVC () <UITableViewDataSource, UITableViewDelegate, PMCalendarColourVCDelegate, PMCalendarListTVCellDelegate>
{
    IBOutlet UITableView *_tableView;
    
    NSArray *namespaces;
    NSMutableDictionary *calendarsOfNamespace;
}
- (IBAction)closeBtnPressed:(id)sender;


@end

@implementation PMCalendarListVC

#pragma mark - PMCalendarListVC lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    namespaces = [[DBManager instance] getNamespaces];
    calendarsOfNamespace = [[NSMutableDictionary alloc] init];
    
    for(DBNamespace *namespace in namespaces)
    {
        NSLog(@"Account Provider : %@", namespace.provider);
        
        NSArray *calendars = [[PMAPIManager shared] getCalendarsWithAccount:namespace.account_id comlpetion:^(id data, id error, BOOL success)
        {
            
            for (DBCalendar *calendar in data) {
                NSArray *inCalendars = calendarsOfNamespace[namespace.account_id];
                if(![self containsCalendar:calendar inCalendars:inCalendars])
                {
                    NSMutableArray *calendars = [calendarsOfNamespace objectForKey:namespace.account_id];
                    if(calendars==nil) calendars = [NSMutableArray new];
                    [calendars addObject:calendar];
                    
                    [calendarsOfNamespace setObject:calendars forKey:namespace.account_id];
                }
            }
            
            [_tableView reloadData];
            DLog(@"getCalendarsWithAccount - %@", data);
        }];
        
        for(DBCalendar *calendar in calendars)
        {
            NSMutableArray *calendars = [calendarsOfNamespace objectForKey:namespace.account_id];
            if(calendars==nil) calendars = [NSMutableArray new];
            [calendars addObject:calendar];
            
            [calendarsOfNamespace setObject:calendars forKey:namespace.account_id];
        }
    }
    
    [_tableView reloadData];
    
    
    
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
}

- (BOOL)containsCalendar:(DBCalendar*)calendar inCalendars:(NSArray*)inCalendars
{
    for(DBCalendar *item in inCalendars)
    {
        if([item.calendarId isEqualToString:calendar.calendarId]) return YES;
    }
    
    return NO;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction selectors

- (void)closeBtnPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];    
}

#pragma mark - UITableView delegates

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PMCalendarListTVCell *lCell = [tableView dequeueReusableCellWithIdentifier:@"calendarListCell"];
    [lCell setDelegate:self];
    
    DBNamespace *namespace = [namespaces objectAtIndex:indexPath.section];
    DBCalendar *calendar = [calendarsOfNamespace objectForKey:namespace.account_id][indexPath.row];
    
    [lCell configureCell:calendar];
    
    return lCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = namespaces.count;
    return count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DBNamespace *namespace = [namespaces objectAtIndex:section];
    NSArray *calendars = calendarsOfNamespace[namespace.account_id];
    return calendars.count;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    DBNamespace *namespace = [namespaces objectAtIndex:section];
    
    return namespace.email_address;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PMCalendarListTVCell *lCell = [tableView cellForRowAtIndexPath:indexPath];
    [lCell changeSelectedState];
}

#pragma mark - PMCalendarColourVC delegate

- (void)PMCalendarColourVCDelegateColourDidChange:(PMCalendarColourVC *)calendarColourVC {
    [calendarColourVC dismissViewControllerAnimated:YES completion:nil];
    [[DBManager instance] save];
    [_tableView reloadData];
}

#pragma mark - PMCalendarListTVCell delegate

- (void)PMCalendarListTVCellColorBtnDidPress:(PMCalendarListTVCell *)cell calendar:(DBCalendar *)calendar {
    PMCalendarColourVC *lCalendarColourVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PMCalendarColourVC"];
    [lCalendarColourVC setCalendar:calendar];
    [lCalendarColourVC setDelegate:self];
    [self presentViewController:lCalendarColourVC animated:YES completion:nil];
}

- (void)PMCalendarListTVCell:(PMCalendarListTVCell *)cell selectedState:(BOOL)state {
    [[DBManager instance] save];
    [_tableView reloadData];
    
    if([_delegate respondsToSelector:@selector(didSelectCalendar)])
        [_delegate didSelectCalendar];
}

@end
