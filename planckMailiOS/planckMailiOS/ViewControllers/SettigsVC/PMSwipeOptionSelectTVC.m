//
//  PMDefaultEmailVC.m
//  planckMailiOS
//
//  Created by LionStar on 12/25/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMSwipeOptionSelectTVC.h"
#import "PMSettingsManager.h"
#import "Config.h"

@interface PMSwipeOptionSelectTVC () <UITableViewDataSource, UITableViewDelegate>
{
    NSArray *_options;
    NSString *_selectedOption;
}
@end

@implementation PMSwipeOptionSelectTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBar];
    
    [self.tableView setTableHeaderView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    _options = @[@"none", @"archive", @"mark_as_read_and_archive", @"delete", @"schedule", @"move", @"mark_as_read_or_unread", @"flag"];
    _selectedOption = [self.directionType isEqualToString:@"right"]?[[PMSettingsManager instance] getRightSwipeOption]:[[PMSettingsManager instance] getLeftSwipeOption];
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
    
    NSString *directionTitle = @"";
    if([self.directionType isEqualToString:@"right"])
        directionTitle = @"Right";
    else
        directionTitle = @"Left";
    
    lblTitle.text =  [NSString stringWithFormat:@"Swipe %@", directionTitle];
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
#pragma UITableViewDataSource & UITableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _options.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *option = _options[indexPath.row];
    
    NSString *cellIdentifier;
    
    if([option isEqualToString:@"none"])
        cellIdentifier = @"optionNoneCell";
    else if([option isEqualToString:@"archive"])
        cellIdentifier = @"optionArchiveCell";
    else if([option isEqualToString:@"mark_as_read_and_archive"])
        cellIdentifier = @"optionMarkAsReadAndArchiveCell";
    else if([option isEqualToString:@"delete"])
        cellIdentifier = @"optionDeleteCell";
    else if([option isEqualToString:@"schedule"])
        cellIdentifier = @"optionScheduleCell";
    else if([option isEqualToString:@"move"])
        cellIdentifier = @"optionMoveCell";
    else if([option isEqualToString:@"mark_as_read_or_unread"])
        cellIdentifier = @"optionMarkAsReadOrUnreadCell";
    else if([option isEqualToString:@"flag"])
        cellIdentifier = @"optionFlagCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    
    
    
    if([_selectedOption isEqualToString:option])
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    _selectedOption = _options[indexPath.row];
    
    [[PMSettingsManager instance] setWeekStart:_selectedOption];
    
    [tableView reloadData];
    
    if([self.delegate respondsToSelector:@selector(swipeOptionSelectTVC:didSelectSwipeOption:)])
        [self.delegate swipeOptionSelectTVC:self didSelectSwipeOption:_selectedOption];
    
}
@end
