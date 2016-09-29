//
//  PMDefaultEmailVC.m
//  planckMailiOS
//
//  Created by LionStar on 12/25/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMSetNotificationsTVC.h"
#import "DBManager.h"
#import "PMSettingsManager.h"
#import "PMSettingsSwitchTVCell.h"
#import "PMSoundSelectTVC.h"
#import "PMAccountManager.h"

@interface PMSetNotificationsTVC () <UITableViewDataSource, UITableViewDelegate, PMSettingsSwitchTVCellDelegate, PMSoundSelectTVCDelegate>
{
    NSArray *_namespaces;
    NSString *_defaultEmail;
}
@end

@implementation PMSetNotificationsTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBar];
    [self.tableView setTableHeaderView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    _namespaces = [[DBManager instance] getNamespaces];
    _defaultEmail = [[PMSettingsManager instance] getDefaultEmail];
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
    lblTitle.text = [NSString stringWithFormat:@"%@ Notifications", [self.type isEqualToString:@"mail"]?@"Mail":@"Calendar"];
    
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
    return _namespaces.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}
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
    
    [lbl setText:[NSString stringWithFormat:@"%@", namespace.email_address]];
    
    return view;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DBNamespace *namespace = _namespaces[indexPath.section];
    NSString *email = namespace.email_address;
    
    BOOL notificationEnabled = NO;
    if([self.type isEqualToString:@"mail"])
        notificationEnabled = [[PMSettingsManager instance] getMailNotificationEnabled:email];
    else if([self.type isEqualToString:@"calendar"])
        notificationEnabled = [[PMSettingsManager instance] getCalendarNotificationEnabled:email];
    
    if(indexPath.row == 0)
    {
        PMSettingsSwitchTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"enableNotificationCell"];
        cell.tagString = email;
        cell.delegate = self;
        cell.switchControl.on = notificationEnabled;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        return cell;
    }
    else if(indexPath.row == 1)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"soundCell"];
        
        if(!notificationEnabled)
        {
            cell.detailTextLabel.text = @"Disabled";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.userInteractionEnabled = NO;
        }
        else
        {
            if([self.type isEqualToString:@"mail"])
                cell.detailTextLabel.text = [[PMSettingsManager instance] getMailNotificationSound:email];
            else if([self.type isEqualToString:@"calendar"])
                cell.detailTextLabel.text = [[PMSettingsManager instance] getCalendarNotificationSound:email];
            
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.userInteractionEnabled = YES;

        }
        
        return cell;
    }
    
    
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.row == 1)
    {
        
        DBNamespace *namespace = _namespaces[indexPath.section];
        
        PMSoundSelectTVC *tvc = [self.storyboard instantiateViewControllerWithIdentifier:@"PMSoundSelectTVC"];
        tvc.type = self.type;
        tvc.email = namespace.email_address;
        tvc.delegate = self;
        
        [self.navigationController pushViewController:tvc animated:YES];
    }
    
}

#pragma mark PMSettingsSwitchTVCellDelegate
-(void)switchCell:(PMSettingsSwitchTVCell *)cell switchControllValueChanged:(BOOL)value
{
    NSString *email = cell.tagString;
    
    if([self.type isEqualToString:@"mail"])
        [[PMSettingsManager instance] setMailNotificationEnabled:value email:email];
    else
        [[PMSettingsManager instance] setCalendarNotificationEnabled:value email:email];
    
    [self.tableView reloadData];
}

#pragma mark PMSoundSelectTVCDelegate
-(void)soundSelectTVC:(PMSoundSelectTVC *)tvc didSelectSound:(NSString *)sound
{
    NSString *email = tvc.email;
    
    if([self.type isEqualToString:@"mail"])
        [[PMSettingsManager instance] setMailNotificationSound:sound email:email];
    else
        [[PMSettingsManager instance] setCalendarNotificationSound:sound email:email];
    
    [self.tableView reloadData];
}
@end
