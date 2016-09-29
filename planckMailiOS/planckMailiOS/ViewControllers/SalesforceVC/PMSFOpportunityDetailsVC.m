//
//  PMSFCreateOpportunityVC.m
//  planckMailiOS
//
//  Created by LionStar on 1/26/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import "PMSFOpportunityDetailsVC.h"
#import "PMTextFieldTVCell.h"
#import "PMTextViewTVCell.h"
#import "PMSwitchTVCell.h"
#import "PMAPIManager.h"
#import "AlertManager.h"
#import "PMSettingsManager.h"
#import "PMSFCreateOpportunityNC.h"
#import "Config.h"

#define SECTION_OPPORTUNITY_INFO @"OPPORTUNITY INFORMATION"
#define SECTION_ADDITIONAL_INFO @"ADDITIONAL INFORMATION"


#define OPPORTUNITY_NAME_CELL @"sfOpportunityNameCell"
#define OPPORTUNITY_ACCOUNT_CELL @"sfOpportunityAccountCell"
#define OPPORTUNITY_TYPE_CELL @"sfOpportunityTypeCell"
#define OPPORTUNITY_CAMPAIGN_CELL @"sfOpportunityCampaignCell"
#define OPPORTUNITY_OWNER_CELL @"sfOpportunityOwnerCell"
#define OPPORTUNITY_CLOSE_DATE_CELL @"sfOpportunityCloseDateCell"
#define OPPORTUNITY_STAGE_CELL @"sfOpportunityStageCell"
#define OPPORTUNITY_PROBABILITY_CELL @"sfOpportunityProbabilityCell"
#define OPPORTUNITY_AMOUNT_CELL @"sfOpportunityAmountCell"
#define OPPORTUNITY_NEXT_STEP_CELL @"sfOpportunityNextStepCell"
#define OPPORTUNITY_LEAD_SOURCE_CELL @"sfOpportunityLeadSourceCell"
#define OPPORTUNITY_DESCRIPTION_CELL @"sfOpportunityDescriptionCell"



@interface PMSFOpportunityDetailsVC () <UITableViewDataSource, UITableViewDelegate>
{
    UITableViewCell *firstResponderCell;
    CGFloat keyboardHeight;
}


@property (weak, nonatomic) IBOutlet UITableView *tableView;


@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) NSDictionary *items;

@property (nonatomic, strong) NSString *ownerName;
@property (nonatomic, strong) NSString *accountName;
@property (nonatomic, strong) NSString *campaignName;
- (IBAction)actionEditTap:(id)sender;
@end

@implementation PMSFOpportunityDetailsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBar];
    
    _sections = @[SECTION_OPPORTUNITY_INFO, SECTION_ADDITIONAL_INFO];
    
    _items = @{SECTION_OPPORTUNITY_INFO: @[
                       OPPORTUNITY_NAME_CELL,
                       OPPORTUNITY_ACCOUNT_CELL,
                       OPPORTUNITY_TYPE_CELL,
                       OPPORTUNITY_LEAD_SOURCE_CELL,
                       OPPORTUNITY_CAMPAIGN_CELL,
                       OPPORTUNITY_OWNER_CELL,
                       OPPORTUNITY_CLOSE_DATE_CELL,
                       OPPORTUNITY_NEXT_STEP_CELL,
                       OPPORTUNITY_STAGE_CELL,
                       OPPORTUNITY_PROBABILITY_CELL,
                       OPPORTUNITY_AMOUNT_CELL],
               SECTION_ADDITIONAL_INFO: @[
                       OPPORTUNITY_DESCRIPTION_CELL
                       ]
               };
    
    
    
    NSDictionary *salesforceUserInfo = [[PMSettingsManager instance] getSalesforceUserInfo];
    if(salesforceUserInfo)
    {
        _ownerName = salesforceUserInfo[@"display_name"];        
    }
    
    if(_data)
    {
        _accountName = _data[@"AccountName"];
        _campaignName = _data[@"CampaignName"];
        
    }
    
    [self.navigationItem setTitle:_data[@"Name"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)setNavigationBar
{
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backArrow.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
    [self.navigationItem setLeftBarButtonItem:btnBack animated:NO];
}

-(void) onBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionEditTap:(id)sender
{
    PMSFCreateOpportunityNC *nc = [self.storyboard instantiateViewControllerWithIdentifier:@"PMSFCreateOpportunityNC"];
    
    nc.isUpdate = YES;
    nc.data = self.data;
    
    [self presentViewController:nc animated:YES completion:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSalesforceOpportunitySaveSuccess:) name:NOTIFICATION_SALESFORCE_OPPORTUNITY_SAVE_SUCCEEDED object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSalesforceOpportunitySaveFailure:) name:NOTIFICATION_SALESFORCE_OPPORTUNITY_SAVE_FAILED object:nil];
}

#pragma mark SalesforceOpportunitySave Notification Handler
- (void)handleSalesforceOpportunitySaveSuccess:(NSNotification*)notification
{
    [AlertManager showStatusBarWithMessage:@"Salesforce opportunity saved." type:ACTIVITY_STATUS_TYPE_INFO view:self.view time:nil];
    
    _data = [notification userInfo];
    
    [self.navigationItem setTitle:_data[@"Name"]];
    [_tableView reloadData];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_SALESFORCE_OPPORTUNITY_SAVE_SUCCEEDED object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_SALESFORCE_OPPORTUNITY_SAVE_FAILED object:nil];
}

- (void)handleSalesforceOpportunitySaveFailure:(NSNotification*)notification
{
    [AlertManager showStatusBarWithMessage:@"Saving salesforce opportunity failed." type:ACTIVITY_STATUS_TYPE_ERROR view:self.view time:nil];
    
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_SALESFORCE_OPPORTUNITY_SAVE_SUCCEEDED object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_SALESFORCE_OPPORTUNITY_SAVE_FAILED object:nil];
}

#pragma mark UITableViewDataSource & UITableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _sections.count;
}
-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return _sections[section];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==0) return ((NSArray*)_items[SECTION_OPPORTUNITY_INFO]).count;
    else if(section==1) return ((NSArray*)_items[SECTION_ADDITIONAL_INFO]).count;
    
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==1 && indexPath.row==0)
        return 150;
    return 75;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = _items[_sections[indexPath.section]][indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    
    if([cellIdentifier isEqualToString:OPPORTUNITY_NAME_CELL])
    {
        [((PMTextFieldTVCell*)cell).textField setText:_data[@"Name"]];
    }
    else if([cellIdentifier isEqualToString:OPPORTUNITY_ACCOUNT_CELL])
    {
        [((PMTextFieldTVCell*)cell).textField setText:_accountName];
    }
    else if([cellIdentifier isEqualToString:OPPORTUNITY_TYPE_CELL])
    {
        NSString *type = notNullEmptyString(_data[@"Type"]);
        [((PMTextFieldTVCell*)cell).textField setText:type];
    }
    else if([cellIdentifier isEqualToString:OPPORTUNITY_CAMPAIGN_CELL])
    {
        [((PMTextFieldTVCell*)cell).textField setText:_campaignName];
    }
    else if([cellIdentifier isEqualToString:OPPORTUNITY_OWNER_CELL])
    {
        [((PMTextFieldTVCell*)cell).textField setText:_ownerName];
    }
    else if([cellIdentifier isEqualToString:OPPORTUNITY_CLOSE_DATE_CELL])
    {
        [((PMTextFieldTVCell*)cell).textField setText:_data[@"CloseDate"]];
    }
    else if([cellIdentifier isEqualToString:OPPORTUNITY_STAGE_CELL])
    {
        [((PMTextFieldTVCell*)cell).textField setText:_data[@"StageName"]];
    }
    else if([cellIdentifier isEqualToString:OPPORTUNITY_PROBABILITY_CELL])
    {
        NSNumber *probability = notNullValue(_data[@"Probability"]);
        [((PMTextFieldTVCell*)cell).textField setText:probability?[probability stringValue]:@""];
    }
    else if([cellIdentifier isEqualToString:OPPORTUNITY_AMOUNT_CELL])
    {
        NSNumber *amount = notNullValue(_data[@"Amount"]);
        [((PMTextFieldTVCell*)cell).textField setText:amount?[NSString stringWithFormat:@"%1.2f", [amount doubleValue]]:@""];
    }
    else if([cellIdentifier isEqualToString:OPPORTUNITY_NEXT_STEP_CELL])
    {
        [((PMTextFieldTVCell*)cell).textField setText:_data[@"NextStep"]];
    }
    else if([cellIdentifier isEqualToString:OPPORTUNITY_LEAD_SOURCE_CELL])
    {
        NSString *leadSource = notNullEmptyString(_data[@"LeadSource"]);
        [((PMTextFieldTVCell*)cell).textField setText:leadSource];
    }
    else if([cellIdentifier isEqualToString:OPPORTUNITY_DESCRIPTION_CELL])
    {
        NSString *oppDescription = notNullEmptyString(_data[@"Description"]);
        [((PMTextViewTVCell*)cell).textView setText:oppDescription];
    }
    return cell;
}


@end